# 架构文档

> 一个最小 mcpp C++23 模块库模板。
> [English](architecture.md) · [简体中文](architecture.zh.md) · [繁體中文](architecture.zh.hant.md)

## 目标

仓库只表达四件事：

- 用 `.xlings.json` 声明项目工具环境（用哪个 mcpp 版本构建）。
- 用 `mcpp.toml` 声明 C++23 模块库和测试依赖；运行时依赖按需添加。
- 用 `templates/` 声明这个库对外分发的项目模板。
- 用 `mcpp build`、`mcpp test`、`mcpp run` 验证库、单元测试和示例。

## mcpp 约定

- 默认扫描 `src/**/*.{cppm,cpp,cc,c,S,s,asm}`。
- 只有 `src/*.cppm` 且没有 `src/main.cpp` 时，mcpp 会推断出以包名命名的 **lib** 目标
  （`Inferred target mylib (lib from .cppm in src/)`）。需要覆盖默认行为时再显式写
  `[targets.<name>]`。
- 库根模块默认放在 `src/<包名最后一段>.cppm`；`[lib] path` 可以改这个位置。
- 依赖放 `[dependencies]` 或 `[dependencies.<namespace>]`；只在测试用的放
  `[dev-dependencies]`（`mcpp build` 不解析它们，只有 `mcpp test` 会）。
- 单元测试放 `tests/**/*.cpp`，由 `mcpp test` 自动发现，一个文件一个测试二进制。
  测试文件只写 `TEST(...)`，不定义自己的 `main()`。
- 默认构建 profile 是 `dev`（`-O0 -g`）；`mcpp build --release` 才是优化构建。
  C++ 标准默认 `c++23`，应写在 `[package] standard`，不要写进 `cxxflags`。
- `mcpp.lock` 不入库：这是一个库，真正起作用的是使用方的版本解析。
  从 `templates/` 生成的应用则可以考虑提交自己的锁文件。

## 当前结构

```text
.
├── .xlings.json
├── mcpp.toml
├── src/mylib.cppm
├── tests/mylib_test.cpp
├── examples/basic/
│   ├── mcpp.toml
│   └── src/main.cpp
├── templates/
│   ├── basic/                # 默认模板：控制台程序
│   │   ├── template.toml
│   │   ├── mcpp.toml.in
│   │   ├── src/main.cpp.in
│   │   └── .gitignore
│   └── lib/                  # 下游模块库 + gtest
│       ├── template.toml
│       ├── mcpp.toml.in
│       ├── src/lib.cppm.in
│       └── tests/lib_test.cpp.in
├── tools/template_smoke.sh
└── .github/workflows/{ci-linux,ci-macos,ci-windows}.yml
```

## 根包

```toml
[package]
namespace = "mcpplibs"
name      = "mylib"
version   = "0.1.0"

[dev-dependencies]
gtest = "1.15.2"
```

每个包的身份由两部分组成：**namespace** 和 **name**。`namespace = "mcpplibs"` 加
`name = "mylib"` 意味着使用方在 `[dependencies.mcpplibs]` 下写 `mylib = "0.1.0"`
（也可以直接写裸名 —— `mcpplibs` 是 mcpp 优先搜索的默认命名空间）。

`src/mylib.cppm` 导出模块 `mcpplibs.mylib`，并且不重新导出任何东西：依赖在用到的地方
import，而不是通过根模块转发出去，除非公开 API 确实暴露了依赖包的类型。

## 添加依赖

在根 `mcpp.toml` 添加依赖声明：

```toml
[dependencies.mcpplibs]
cmdline = "0.0.2"
```

在需要的位置导入：

```cpp
import mcpplibs.cmdline;
```

默认不用 `export import`。只有当公开 API 直接交出依赖包的类型时，才考虑重新导出。

## 示例包

`examples/basic` 是独立的 mcpp 包，通过 path 依赖引用根库：

```toml
[dependencies.mcpplibs]
mylib = { path = "../.." }
```

运行：

```bash
cd examples/basic
mcpp run
```

它的意义在于**从外部**证明这个库可用 —— 有自己的清单、走自己的依赖解析，这是从 `tests/`
里 import 验证不了的。

## 模板

`templates/<name>/` 是库把项目脚手架分发给使用方的方式：`mcpp new myapp --template mylib`
会把模板渲染成一个新项目，而且模板版本自动跟随库版本。

- `template.toml` —— `description`，所有模板中最多一个 `default = true`，以及可选的
  `post_message`（生成后打印）。它只是元数据，不会被拷贝。
- `*.in` —— 渲染后去掉后缀。占位符：`{{project.name}}`、`{{self.name}}`、`{{self.version}}`。
- 其他文件 —— 原样拷贝。

模板是纯数据：mcpp 只做渲染和拷贝，不执行任何钩子或脚本。**文件名不参与渲染**，只有文件内容
参与 —— 所以 `lib` 模板固定提供 `src/lib.cppm` 并用 `[lib] path` 指过去，而不是依赖
`src/<包名>.cppm` 的默认约定。

如果渲染出来的 `mcpp.toml` 没有声明对分发库的依赖，mcpp 会自动注入一条；本仓库的模板已经用
`{{self.version}}` 显式写了，所以不会触发注入。

`tools/template_smoke.sh` 会按 `mcpp new` 的方式渲染每个模板，把依赖改指向当前仓库
（这样在库还没发布到索引时就能校验模板），然后编译；模板生成的是可执行程序时还会运行它。

## CI

三个 workflow，每个平台一个（`.github/workflows/ci-{linux,macos,windows}.yml`），
都走新用户会走的同一条路径：

```bash
xlings install -y        # 按 .xlings.json 的固定版本安装项目环境的 mcpp
mcpp build
mcpp test
cd examples/basic && mcpp run
bash tools/template_smoke.sh
```

按平台拆分让每个操作系统各有一个徽章和一份日志，macOS 或 Windows 上的回归就不会被
Linux 的绿灯掩盖。
