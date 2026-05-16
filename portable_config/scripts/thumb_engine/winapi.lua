local M = {}

function M.init(options, os_name)
	if not options.direct_io then return M end

	local ffi_loaded, ffi = pcall(require, "ffi")
	if not ffi_loaded then
		options.direct_io = false
		return M
	end

	M.ffi = ffi
	M.C = ffi.C
	M.bit = require("bit")
	M.socket_wc = ""

	-- WinAPI constants
	M.CP_UTF8 = 65001
	M.GENERIC_WRITE = 0x40000000
	M.OPEN_EXISTING = 3
	M.FILE_FLAG_WRITE_THROUGH = 0x80000000
	M.FILE_FLAG_NO_BUFFERING = 0x20000000
	M.PIPE_NOWAIT = ffi.new("unsigned long[1]", 0x00000001)

	M.INVALID_HANDLE_VALUE = ffi.cast("void*", -1)

	-- don't care about how many bytes WriteFile wrote, so allocate something to store the result once
	M._lpNumberOfBytesWritten = ffi.new("unsigned long[1]")

	-- cache flags used in run() to avoid bor() call
	M._createfile_pipe_flags = M.bit.bor(M.FILE_FLAG_WRITE_THROUGH, M.FILE_FLAG_NO_BUFFERING)

	ffi.cdef[[
		void* __stdcall CreateFileW(const wchar_t *lpFileName, unsigned long dwDesiredAccess, unsigned long dwShareMode, void *lpSecurityAttributes, unsigned long dwCreationDisposition, unsigned long dwFlagsAndAttributes, void *hTemplateFile);
		bool __stdcall WriteFile(void *hFile, const void *lpBuffer, unsigned long nNumberOfBytesToWrite, unsigned long *lpNumberOfBytesWritten, void *lpOverlapped);
		bool __stdcall CloseHandle(void *hObject);
		bool __stdcall SetNamedPipeHandleState(void *hNamedPipe, unsigned long *lpMode, unsigned long *lpMaxCollectionCount, unsigned long *lpCollectDataTimeout);
		int __stdcall MultiByteToWideChar(unsigned int CodePage, unsigned long dwFlags, const char *lpMultiByteStr, int cbMultiByte, wchar_t *lpWideCharStr, int cchWideChar);
	]]

	M.MultiByteToWideChar = function(MultiByteStr)
		if MultiByteStr then
			local utf16_len = M.C.MultiByteToWideChar(M.CP_UTF8, 0, MultiByteStr, -1, nil, 0)
			if utf16_len > 0 then
				local utf16_str = M.ffi.new("wchar_t[?]", utf16_len)
				if M.C.MultiByteToWideChar(M.CP_UTF8, 0, MultiByteStr, -1, utf16_str, utf16_len) > 0 then
					return utf16_str
				end
			end
		end
		return ""
	end

	-- 初始化 socket 宽字符缓存
	if os_name == "windows" then
		M.socket_wc = M.MultiByteToWideChar("\\\\.\\pipe\\" .. options.socket)
	end

	if M.socket_wc == "" then
		options.direct_io = false
	end

	return M
end

return M
