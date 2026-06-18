// ==UserScript==
// @name         Telegram Web MPV Bridge
// @namespace    local.telegram-web-mpv-bridge
// @version      0.1.1
// @description  Forward Telegram Web video byte ranges to a local MPV bridge.
// @match        https://web.telegram.org/*
// @match        https://webk.telegram.org/*
// @grant        none
// @run-at       document-start
// ==/UserScript==

(function () {
  'use strict';

  const WS_URL = 'ws://127.0.0.1:9000/ws';
  const MPV_URL = 'http://127.0.0.1:8999/stream/current';
  const PLAY_URL = 'http://127.0.0.1:8999/play/current';
  const RETRY_MS = 1500;
  const LOG_PREFIX = '[TG-MPV]';

  let socket = null;
  let lastVideoUrl = '';
  let statusTimer = null;
  const streamCandidates = [];
  const blobStore = new Map();

  function log(...args) {
    console.log(LOG_PREFIX, ...args);
  }

  function warn(...args) {
    console.warn(LOG_PREFIX, ...args);
  }

  function absoluteUrl(value) {
    if (!value) return '';
    try {
      return new URL(String(value), location.href).href;
    } catch {
      return String(value || '');
    }
  }

  function isTelegramStreamUrl(value) {
    const url = absoluteUrl(value);
    return /^https:\/\/web(k|z)?\.telegram\.org\//i.test(url)
      && /\/(stream|download|hls|hls_stream|hls_quality_file)\//i.test(url);
  }

  function safeJsonSend(payload) {
    if (!socket || socket.readyState !== WebSocket.OPEN) return false;
    socket.send(JSON.stringify(payload));
    return true;
  }

  function rememberCandidate(value, reason) {
    const url = absoluteUrl(value);
    if (!url || !isTelegramStreamUrl(url)) return;
    const now = Date.now();
    streamCandidates.unshift({ url, reason, time: now });
    const seen = new Set();
    for (let i = 0; i < streamCandidates.length;) {
      const item = streamCandidates[i];
      if (seen.has(item.url) || now - item.time > 10 * 60 * 1000) {
        streamCandidates.splice(i, 1);
      } else {
        seen.add(item.url);
        i += 1;
      }
    }
    if (streamCandidates.length > 30) streamCandidates.length = 30;
    log('captured stream candidate', reason, url.slice(0, 180));
  }

  function installCaptureHooks() {
    const originalCreateObjectURL = URL.createObjectURL.bind(URL);
    URL.createObjectURL = function patchedCreateObjectURL(object) {
      const url = originalCreateObjectURL(object);
      try {
        if (object instanceof Blob) {
          blobStore.set(url, { blob: object, type: object.type || 'video/mp4', size: object.size || null, time: Date.now() });
          log('captured blob URL', { url, type: object.type, size: object.size });
        }
      } catch (error) {
        warn('createObjectURL hook failed', error);
      }
      return url;
    };

    const originalSetAttribute = Element.prototype.setAttribute;
    Element.prototype.setAttribute = function patchedSetAttribute(name, value) {
      if (this && this.tagName === 'VIDEO' && String(name).toLowerCase() === 'src') {
        rememberCandidate(value, 'video.setAttribute(src)');
      }
      return originalSetAttribute.call(this, name, value);
    };

    const descriptor = Object.getOwnPropertyDescriptor(HTMLMediaElement.prototype, 'src');
    if (descriptor && descriptor.get && descriptor.set) {
      Object.defineProperty(HTMLMediaElement.prototype, 'src', {
        configurable: true,
        enumerable: descriptor.enumerable,
        get() {
          return descriptor.get.call(this);
        },
        set(value) {
          rememberCandidate(value, 'video.src setter');
          return descriptor.set.call(this, value);
        },
      });
    }

    const originalFetch = window.fetch.bind(window);
    window.fetch = function patchedFetch(input, init) {
      const url = typeof input === 'string' ? input : input && input.url;
      rememberCandidate(url, 'fetch');
      return originalFetch(input, init);
    };
  }

  function latestPerformanceStreamUrl() {
    try {
      const entries = performance.getEntriesByType('resource') || [];
      for (let i = entries.length - 1; i >= 0; i -= 1) {
        const url = entries[i].name;
        if (isTelegramStreamUrl(url)) return url;
      }
    } catch (error) {
      warn('performance scan failed', error);
    }
    return '';
  }

  function getBestVideo() {
    const videos = Array.from(document.querySelectorAll('video'));
    const scored = videos.map((video, index) => {
      const rect = video.getBoundingClientRect();
      const src = video.currentSrc || video.src || video.querySelector('source')?.src || '';
      const visible = rect.width > 80 && rect.height > 80;
      const playingScore = video.paused ? 0 : 1_000_000;
      const area = Math.round(rect.width * rect.height);
      const durationScore = Number.isFinite(video.duration) ? Math.round(video.duration) : 0;
      return { video, index, src, score: playingScore + area + durationScore, visible, area };
    }).filter(item => item.src && item.visible);
    scored.sort((a, b) => b.score - a.score);
    return scored[0]?.video || null;
  }

  function resolvePlayableSource(video) {
    const directSources = [
      video?.getAttribute?.('src'),
      video?.currentSrc,
      video?.src,
      video?.querySelector?.('source')?.src,
    ].map(absoluteUrl).filter(Boolean);
    const directStream = directSources.find(isTelegramStreamUrl);
    if (directStream) return { url: directStream, kind: 'direct-stream' };
    const perfStream = latestPerformanceStreamUrl();
    if (perfStream) return { url: perfStream, kind: 'performance-stream' };
    const captured = streamCandidates[0];
    if (captured) return { url: captured.url, kind: `captured-${captured.reason}` };
    const blob = directSources.find(url => url.startsWith('blob:')) || '';
    if (blob) return { url: blob, kind: blobStore.has(blob) ? 'blob-object' : 'blob-url' };
    return { url: directSources[0] || '', kind: 'unknown' };
  }

  function buildVideoPayload(video) {
    const source = resolvePlayableSource(video);
    const title = document.title.replace(/^Telegram\s*/, '').trim() || 'Telegram Web video';
    return {
      type: 'registerVideo',
      url: source.url,
      sourceKind: source.kind,
      title,
      duration: Number.isFinite(video.duration) ? video.duration : null,
      width: video.videoWidth || null,
      height: video.videoHeight || null,
      contentType: 'video/mp4',
      size: null,
      userAgent: navigator.userAgent,
    };
  }

  async function probeSize(url) {
    if (url.startsWith('blob:') && blobStore.has(url)) {
      const stored = blobStore.get(url);
      return { size: stored.size, contentType: stored.type || 'video/mp4' };
    }
    try {
      const response = await fetch(url, { headers: { Range: 'bytes=0-1' }, credentials: 'include' });
      const contentRange = response.headers.get('Content-Range') || response.headers.get('content-range');
      const contentType = response.headers.get('Content-Type') || response.headers.get('content-type');
      if (contentRange) {
        const match = contentRange.match(/bytes\s+\d+-\d+\/(\d+|\*)/i);
        return {
          size: match && match[1] !== '*' ? Number(match[1]) : null,
          contentType: contentType || 'video/mp4',
          contentRange,
        };
      }
      const contentLength = response.headers.get('Content-Length') || response.headers.get('content-length');
      return { size: contentLength ? Number(contentLength) : null, contentType: contentType || 'video/mp4' };
    } catch (error) {
      warn('probe failed', error);
      return { size: null, contentType: 'video/mp4' };
    }
  }

  async function registerCurrentVideo(force = false) {
    const video = getBestVideo();
    if (!video) {
      warn('no visible video found');
      return false;
    }
    const payload = buildVideoPayload(video);
    if (!payload.url) {
      warn('video has no source');
      return false;
    }
    if (!force && payload.url === lastVideoUrl) return true;
    const probe = await probeSize(payload.url);
    payload.size = probe.size;
    payload.contentType = probe.contentType || payload.contentType;
    payload.probeContentRange = probe.contentRange || null;
    if (safeJsonSend(payload)) {
      lastVideoUrl = payload.url;
      log('registered video', { title: payload.title, size: payload.size, sourceKind: payload.sourceKind, url: payload.url });
      return true;
    }
    return false;
  }

  function packBinary(meta, buffer) {
    const metaBytes = new TextEncoder().encode(JSON.stringify(meta));
    const body = new Uint8Array(buffer);
    const output = new Uint8Array(4 + metaBytes.length + body.length);
    const view = new DataView(output.buffer);
    view.setUint32(0, metaBytes.length, false);
    output.set(metaBytes, 4);
    output.set(body, 4 + metaBytes.length);
    return output.buffer;
  }

  async function handleFetchRange(message) {
    const id = message.id;
    const start = Number(message.start || 0);
    const requestedEnd = Number.isFinite(message.end) ? Number(message.end) : null;
    const openEndedChunk = Number(message.openEndedChunk || 8 * 1024 * 1024);
    const end = requestedEnd == null ? start + openEndedChunk - 1 : requestedEnd;
    const range = `bytes=${start}-${end}`;
    try {
      if (message.url.startsWith('blob:') && blobStore.has(message.url)) {
        const stored = blobStore.get(message.url);
        const safeEnd = Math.min(end, stored.blob.size - 1);
        const buffer = await stored.blob.slice(start, safeEnd + 1).arrayBuffer();
        socket.send(packBinary({
          id,
          type: 'rangeResponse',
          status: 206,
          contentType: stored.type || 'video/mp4',
          contentRange: `bytes ${start}-${safeEnd}/${stored.blob.size}`,
          contentLength: String(buffer.byteLength),
          requestedRange: range,
        }, buffer));
        return;
      }

      if (message.url.startsWith('blob:')) {
        throw new Error('Blob URL is not fetchable and original Blob object was not captured. Refresh Telegram Web after updating the userscript.');
      }

      const response = await fetch(message.url, {
        method: 'GET',
        headers: { Range: range },
        credentials: 'include',
      });
      if (![200, 206].includes(response.status)) {
        throw new Error(`Fetch returned HTTP ${response.status}`);
      }
      const buffer = await response.arrayBuffer();
      const meta = {
        id,
        type: 'rangeResponse',
        status: response.status,
        contentType: response.headers.get('Content-Type') || 'video/mp4',
        contentRange: response.headers.get('Content-Range') || null,
        contentLength: response.headers.get('Content-Length') || String(buffer.byteLength),
        requestedRange: range,
      };
      socket.send(packBinary(meta, buffer));
    } catch (error) {
      safeJsonSend({ type: 'error', id, message: error && error.message ? error.message : String(error) });
    }
  }

  function connect() {
    if (socket && [WebSocket.OPEN, WebSocket.CONNECTING].includes(socket.readyState)) return;
    socket = new WebSocket(WS_URL);
    socket.binaryType = 'arraybuffer';
    socket.addEventListener('open', () => {
      safeJsonSend({ type: 'hello', userAgent: navigator.userAgent, location: location.href });
      registerCurrentVideo(true);
    });
    socket.addEventListener('message', (event) => {
      if (typeof event.data !== 'string') return;
      const message = JSON.parse(event.data);
      if (message.type === 'fetchRange') handleFetchRange(message);
    });
    socket.addEventListener('close', () => {
      setTimeout(connect, RETRY_MS);
    });
  }

  function addButton() {
    if (!document.documentElement || document.getElementById('tg-mpv-bridge-button')) return;
    const button = document.createElement('button');
    button.id = 'tg-mpv-bridge-button';
    button.textContent = 'MPV';
    button.title = 'Register current Telegram Web video for local MPV bridge';
    Object.assign(button.style, {
      position: 'fixed',
      right: '18px',
      bottom: '18px',
      zIndex: '2147483647',
      padding: '8px 12px',
      borderRadius: '6px',
      border: '1px solid rgba(255,255,255,0.3)',
      background: '#1d78d6',
      color: '#fff',
      font: '13px/1.2 sans-serif',
      cursor: 'pointer',
      boxShadow: '0 4px 12px rgba(0,0,0,0.25)',
    });
    button.addEventListener('click', async () => {
      const ok = await registerCurrentVideo(true);
      if (ok) {
        log('MPV URL:', MPV_URL);
        button.textContent = 'Starting...';
        try {
          const response = await fetch(PLAY_URL, { method: 'POST' });
          const result = await response.json();
          if (!response.ok || !result.ok) throw new Error(result.error || `HTTP ${response.status}`);
          log('launched MPV', result);
          button.textContent = 'MPV started';
        } catch (error) {
          warn('failed to launch MPV', error);
          button.textContent = 'MPV failed';
        }
        clearTimeout(statusTimer);
        statusTimer = setTimeout(() => { button.textContent = 'MPV'; }, 2200);
      }
    });
    document.documentElement.appendChild(button);
  }

  function startObservers() {
    setInterval(() => registerCurrentVideo(false), 2000);
    setInterval(addButton, 1000);
    document.addEventListener('play', (event) => {
      if (event.target && event.target.tagName === 'VIDEO') {
        setTimeout(() => registerCurrentVideo(true), 250);
      }
    }, true);
  }

  installCaptureHooks();
  connect();
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', addButton, { once: true });
  } else {
    addButton();
  }
  startObservers();
})();
