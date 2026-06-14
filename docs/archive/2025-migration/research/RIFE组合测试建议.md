# RIFE 组合测试建议（2026-06-13，修正版）

## 结论先行

当前报告不再把 `4.15_lite/4.22/4.25_lite/4.26` 的 `flow_scale=0.5/0.25` 写成绝对不可用。
这些组合的模型本身可作为候选，当前问题是 `k7sfunc` 的限制逻辑过粗：代码用 `model >= 47` 判断，导致 `4151/4251/426` 这类旧模型编号也被拦截。
正确方向是把限制从“数字大小判断”改为“模型版本语义判断”：只有真正的 `4.7+` 禁止非 `1.0`，旧模型如 `4.15_lite/4.22/4.25_lite/4.26` 应允许测试。

## 状态说明

- `当前可用`：不改代码即可使用。
- `需改代码`：模型和组合有测试价值，但当前 `k7sfunc` 会拦截，需要先修正限制逻辑。
- `语义不推荐`：例如 `turbo=2 + flow!=1.0`，会退回 `implementation=1`，不再是干净的 v2 快速路径。
- `模型不支持`：`4.7/4.8/4.9` 按 vsmlrt 规则不支持非 `1.0` flow。
- `缺模型`：目标模型文件不存在，不应加入菜单。

## 代码修正建议

当前逻辑类似：

```python
if model >= 47 and flow_scale != 1.0:
    raise vs.Error(...) 
```

建议改为显式模型集合：

```python
FLOW_SCALE_UNSUPPORTED_MODELS = {47, 48, 49}
if model in FLOW_SCALE_UNSUPPORTED_MODELS and flow_scale != 1.0:
    raise vs.Error(...) 
```

这样 `4.15_lite=4151`、`4.22=422`、`4.25_lite=4251`、`4.26=426` 不会被误伤。

## 分模型组合建议

### 4.6

- 模型文件基名：`rife_v4.6`
- 模型是否理论支持 `flow_scale != 1.0`：是

| 组合 | 当前状态 | 所需模型 | 建议 |
|---|---|---|---|
| `turbo=0, flow=1.0` | 当前可用 | `vs-plugins/models/rife/rife_v4.6_ensemble.onnx` | 可测：质量/ensemble 路径，负载最高或接近最高 |
| `turbo=0, flow=0.5` | 当前可用 | `vs-plugins/models/rife/rife_v4.6_ensemble.onnx` | 可测：质量/ensemble 路径，负载最高或接近最高 |
| `turbo=0, flow=0.25` | 当前可用 | `vs-plugins/models/rife/rife_v4.6_ensemble.onnx` | 可测：质量/ensemble 路径，负载最高或接近最高 |
| `turbo=1, flow=1.0` | 当前可用 | `vs-plugins/models/rife/rife_v4.6.onnx` | 可测：完整尺度质量基准 |
| `turbo=1, flow=0.5` | 当前可用 | `vs-plugins/models/rife/rife_v4.6.onnx` | 推荐：降负载测试 |
| `turbo=1, flow=0.25` | 当前可用 | `vs-plugins/models/rife/rife_v4.6.onnx` | 可测：应急低负载 |
| `turbo=2, flow=1.0` | 当前可用 | `vs-plugins/models/rife_v2/rife_v4.6.onnx` | 推荐：快速路径，接近 2025 turbo=True |
| `turbo=2, flow=0.5` | 语义不推荐 | `vs-plugins/models/rife_v2/rife_v4.6.onnx` | 不建议：会从 v2 快速路径退回 implementation=1 |
| `turbo=2, flow=0.25` | 语义不推荐 | `vs-plugins/models/rife_v2/rife_v4.6.onnx` | 不建议：会从 v2 快速路径退回 implementation=1 |

### 4.15_lite

- 模型文件基名：`rife_v4.15_lite`
- 模型是否理论支持 `flow_scale != 1.0`：是

| 组合 | 当前状态 | 所需模型 | 建议 |
|---|---|---|---|
| `turbo=0, flow=1.0` | 当前可用 | `vs-plugins/models/rife/rife_v4.15_lite_ensemble.onnx` | 可测：质量/ensemble 路径，负载最高或接近最高 |
| `turbo=0, flow=0.5` | 需改代码 | `vs-plugins/models/rife/rife_v4.15_lite_ensemble.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=0, flow=0.25` | 需改代码 | `vs-plugins/models/rife/rife_v4.15_lite_ensemble.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=1, flow=1.0` | 当前可用 | `vs-plugins/models/rife/rife_v4.15_lite.onnx` | 可测：完整尺度质量基准 |
| `turbo=1, flow=0.5` | 需改代码 | `vs-plugins/models/rife/rife_v4.15_lite.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=1, flow=0.25` | 需改代码 | `vs-plugins/models/rife/rife_v4.15_lite.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=2, flow=1.0` | 当前可用 | `vs-plugins/models/rife_v2/rife_v4.15_lite.onnx` | 推荐：快速路径，接近 2025 turbo=True |
| `turbo=2, flow=0.5` | 需改代码 | `vs-plugins/models/rife_v2/rife_v4.15_lite.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=2, flow=0.25` | 需改代码 | `vs-plugins/models/rife_v2/rife_v4.15_lite.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |

### 4.22

- 模型文件基名：`rife_v4.22`
- 模型是否理论支持 `flow_scale != 1.0`：是

| 组合 | 当前状态 | 所需模型 | 建议 |
|---|---|---|---|
| `turbo=0, flow=1.0` | 当前可用 | `vs-plugins/models/rife/rife_v4.22.onnx` | 可测：质量/ensemble 路径，负载最高或接近最高 |
| `turbo=0, flow=0.5` | 需改代码 | `vs-plugins/models/rife/rife_v4.22.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=0, flow=0.25` | 需改代码 | `vs-plugins/models/rife/rife_v4.22.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=1, flow=1.0` | 当前可用 | `vs-plugins/models/rife/rife_v4.22.onnx` | 可测：完整尺度质量基准 |
| `turbo=1, flow=0.5` | 需改代码 | `vs-plugins/models/rife/rife_v4.22.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=1, flow=0.25` | 需改代码 | `vs-plugins/models/rife/rife_v4.22.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=2, flow=1.0` | 当前可用 | `vs-plugins/models/rife_v2/rife_v4.22.onnx` | 推荐：快速路径，接近 2025 turbo=True |
| `turbo=2, flow=0.5` | 需改代码 | `vs-plugins/models/rife_v2/rife_v4.22.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=2, flow=0.25` | 需改代码 | `vs-plugins/models/rife_v2/rife_v4.22.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |

### 4.22_lite

- 模型文件基名：`rife_v4.22_lite`
- 模型是否理论支持 `flow_scale != 1.0`：是

| 组合 | 当前状态 | 所需模型 | 建议 |
|---|---|---|---|
| `turbo=0, flow=1.0` | 当前可用 | `vs-plugins/models/rife/rife_v4.22_lite.onnx` | 可测：质量/ensemble 路径，负载最高或接近最高 |
| `turbo=0, flow=0.5` | 需改代码 | `vs-plugins/models/rife/rife_v4.22_lite.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=0, flow=0.25` | 需改代码 | `vs-plugins/models/rife/rife_v4.22_lite.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=1, flow=1.0` | 当前可用 | `vs-plugins/models/rife/rife_v4.22_lite.onnx` | 可测：完整尺度质量基准 |
| `turbo=1, flow=0.5` | 需改代码 | `vs-plugins/models/rife/rife_v4.22_lite.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=1, flow=0.25` | 需改代码 | `vs-plugins/models/rife/rife_v4.22_lite.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=2, flow=1.0` | 当前可用 | `vs-plugins/models/rife_v2/rife_v4.22_lite.onnx` | 推荐：快速路径，接近 2025 turbo=True |
| `turbo=2, flow=0.5` | 需改代码 | `vs-plugins/models/rife_v2/rife_v4.22_lite.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=2, flow=0.25` | 需改代码 | `vs-plugins/models/rife_v2/rife_v4.22_lite.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |

### 4.25_lite

- 模型文件基名：`rife_v4.25_lite`
- 模型是否理论支持 `flow_scale != 1.0`：是

| 组合 | 当前状态 | 所需模型 | 建议 |
|---|---|---|---|
| `turbo=0, flow=1.0` | 当前可用 | `vs-plugins/models/rife/rife_v4.25_lite.onnx` | 可测：质量/ensemble 路径，负载最高或接近最高 |
| `turbo=0, flow=0.5` | 需改代码 | `vs-plugins/models/rife/rife_v4.25_lite.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=0, flow=0.25` | 需改代码 | `vs-plugins/models/rife/rife_v4.25_lite.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=1, flow=1.0` | 当前可用 | `vs-plugins/models/rife/rife_v4.25_lite.onnx` | 可测：完整尺度质量基准 |
| `turbo=1, flow=0.5` | 需改代码 | `vs-plugins/models/rife/rife_v4.25_lite.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=1, flow=0.25` | 需改代码 | `vs-plugins/models/rife/rife_v4.25_lite.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=2, flow=1.0` | 当前可用 | `vs-plugins/models/rife_v2/rife_v4.25_lite.onnx` | 推荐：快速路径，接近 2025 turbo=True |
| `turbo=2, flow=0.5` | 需改代码 | `vs-plugins/models/rife_v2/rife_v4.25_lite.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=2, flow=0.25` | 需改代码 | `vs-plugins/models/rife_v2/rife_v4.25_lite.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |

### 4.26

- 模型文件基名：`rife_v4.26`
- 模型是否理论支持 `flow_scale != 1.0`：是

| 组合 | 当前状态 | 所需模型 | 建议 |
|---|---|---|---|
| `turbo=0, flow=1.0` | 当前可用 | `vs-plugins/models/rife/rife_v4.26.onnx` | 可测：质量/ensemble 路径，负载最高或接近最高 |
| `turbo=0, flow=0.5` | 需改代码 | `vs-plugins/models/rife/rife_v4.26.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=0, flow=0.25` | 需改代码 | `vs-plugins/models/rife/rife_v4.26.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=1, flow=1.0` | 当前可用 | `vs-plugins/models/rife/rife_v4.26.onnx` | 可测：完整尺度质量基准 |
| `turbo=1, flow=0.5` | 需改代码 | `vs-plugins/models/rife/rife_v4.26.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=1, flow=0.25` | 需改代码 | `vs-plugins/models/rife/rife_v4.26.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=2, flow=1.0` | 当前可用 | `vs-plugins/models/rife_v2/rife_v4.26.onnx` | 推荐：快速路径，接近 2025 turbo=True |
| `turbo=2, flow=0.5` | 需改代码 | `vs-plugins/models/rife_v2/rife_v4.26.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=2, flow=0.25` | 需改代码 | `vs-plugins/models/rife_v2/rife_v4.26.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |

### 4.26_heavy

- 模型文件基名：`rife_v4.26_heavy`
- 模型是否理论支持 `flow_scale != 1.0`：是

| 组合 | 当前状态 | 所需模型 | 建议 |
|---|---|---|---|
| `turbo=0, flow=1.0` | 当前可用 | `vs-plugins/models/rife/rife_v4.26_heavy.onnx` | 可测：质量/ensemble 路径，负载最高或接近最高 |
| `turbo=0, flow=0.5` | 需改代码 | `vs-plugins/models/rife/rife_v4.26_heavy.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=0, flow=0.25` | 需改代码 | `vs-plugins/models/rife/rife_v4.26_heavy.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=1, flow=1.0` | 当前可用 | `vs-plugins/models/rife/rife_v4.26_heavy.onnx` | 可测：完整尺度质量基准 |
| `turbo=1, flow=0.5` | 需改代码 | `vs-plugins/models/rife/rife_v4.26_heavy.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=1, flow=0.25` | 需改代码 | `vs-plugins/models/rife/rife_v4.26_heavy.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=2, flow=1.0` | 当前可用 | `vs-plugins/models/rife_v2/rife_v4.26_heavy.onnx` | 推荐：快速路径，接近 2025 turbo=True |
| `turbo=2, flow=0.5` | 需改代码 | `vs-plugins/models/rife_v2/rife_v4.26_heavy.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=2, flow=0.25` | 需改代码 | `vs-plugins/models/rife_v2/rife_v4.26_heavy.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |

### 4.7

- 模型文件基名：`rife_v4.7`
- 模型是否理论支持 `flow_scale != 1.0`：否

| 组合 | 当前状态 | 所需模型 | 建议 |
|---|---|---|---|
| `turbo=0, flow=1.0` | 当前可用 | `vs-plugins/models/rife/rife_v4.7.onnx` | 可测：质量/ensemble 路径，负载最高或接近最高 |
| `turbo=0, flow=0.5` | 需改代码 | `vs-plugins/models/rife/rife_v4.7.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=0, flow=0.25` | 需改代码 | `vs-plugins/models/rife/rife_v4.7.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=1, flow=1.0` | 当前可用 | `vs-plugins/models/rife/rife_v4.7.onnx` | 可测：完整尺度质量基准 |
| `turbo=1, flow=0.5` | 需改代码 | `vs-plugins/models/rife/rife_v4.7.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=1, flow=0.25` | 需改代码 | `vs-plugins/models/rife/rife_v4.7.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=2, flow=1.0` | 缺模型 | `vs-plugins/models/rife_v2/rife_v4.7.onnx` | 不建议列入菜单，除非先补模型 |
| `turbo=2, flow=0.5` | 缺模型 | `vs-plugins/models/rife_v2/rife_v4.7.onnx` | 不建议列入菜单，除非先补模型 |
| `turbo=2, flow=0.25` | 缺模型 | `vs-plugins/models/rife_v2/rife_v4.7.onnx` | 不建议列入菜单，除非先补模型 |

### 4.8

- 模型文件基名：`rife_v4.8`
- 模型是否理论支持 `flow_scale != 1.0`：否

| 组合 | 当前状态 | 所需模型 | 建议 |
|---|---|---|---|
| `turbo=0, flow=1.0` | 当前可用 | `vs-plugins/models/rife/rife_v4.8.onnx` | 可测：质量/ensemble 路径，负载最高或接近最高 |
| `turbo=0, flow=0.5` | 需改代码 | `vs-plugins/models/rife/rife_v4.8.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=0, flow=0.25` | 需改代码 | `vs-plugins/models/rife/rife_v4.8.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=1, flow=1.0` | 当前可用 | `vs-plugins/models/rife/rife_v4.8.onnx` | 可测：完整尺度质量基准 |
| `turbo=1, flow=0.5` | 需改代码 | `vs-plugins/models/rife/rife_v4.8.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=1, flow=0.25` | 需改代码 | `vs-plugins/models/rife/rife_v4.8.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=2, flow=1.0` | 缺模型 | `vs-plugins/models/rife_v2/rife_v4.8.onnx` | 不建议列入菜单，除非先补模型 |
| `turbo=2, flow=0.5` | 缺模型 | `vs-plugins/models/rife_v2/rife_v4.8.onnx` | 不建议列入菜单，除非先补模型 |
| `turbo=2, flow=0.25` | 缺模型 | `vs-plugins/models/rife_v2/rife_v4.8.onnx` | 不建议列入菜单，除非先补模型 |

### 4.9

- 模型文件基名：`rife_v4.9`
- 模型是否理论支持 `flow_scale != 1.0`：否

| 组合 | 当前状态 | 所需模型 | 建议 |
|---|---|---|---|
| `turbo=0, flow=1.0` | 当前可用 | `vs-plugins/models/rife/rife_v4.9.onnx` | 可测：质量/ensemble 路径，负载最高或接近最高 |
| `turbo=0, flow=0.5` | 需改代码 | `vs-plugins/models/rife/rife_v4.9.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=0, flow=0.25` | 需改代码 | `vs-plugins/models/rife/rife_v4.9.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=1, flow=1.0` | 当前可用 | `vs-plugins/models/rife/rife_v4.9.onnx` | 可测：完整尺度质量基准 |
| `turbo=1, flow=0.5` | 需改代码 | `vs-plugins/models/rife/rife_v4.9.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=1, flow=0.25` | 需改代码 | `vs-plugins/models/rife/rife_v4.9.onnx` | 可作为候选：先把 k7sfunc 的 flow_scale 限制改成按模型版本判断 |
| `turbo=2, flow=1.0` | 缺模型 | `vs-plugins/models/rife_v2/rife_v4.9.onnx` | 不建议列入菜单，除非先补模型 |
| `turbo=2, flow=0.5` | 缺模型 | `vs-plugins/models/rife_v2/rife_v4.9.onnx` | 不建议列入菜单，除非先补模型 |
| `turbo=2, flow=0.25` | 缺模型 | `vs-plugins/models/rife_v2/rife_v4.9.onnx` | 不建议列入菜单，除非先补模型 |
