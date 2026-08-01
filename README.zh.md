# mcpplibs.mylib

> 一个最小 mcpp C++23 模块库脚手架 — `import mcpplibs.mylib;`

[![C++23](https://img.shields.io/badge/C%2B%2B-23-blue.svg)](https://en.cppreference.com/w/cpp/23)
[![Module](https://img.shields.io/badge/module-ok-green.svg)](https://en.cppreference.com/w/cpp/language/modules)
[![License](https://img.shields.io/badge/license-Apache_2.0-blue.svg)](LICENSE)

| [English](README.md) - **简体中文** - [繁體中文](README.zh.hant.md) |
|:---:|
| [mcpp 构建工具](https://github.com/mcpp-community/mcpp) · [包索引](https://github.com/mcpplibs/mcpp-index) · [架构文档](docs/architecture.zh.md) · [Issues](https://github.com/mcpplibs/template/issues) |
| [![ci-linux](https://github.com/mcpplibs/template/actions/workflows/ci-linux.yml/badge.svg?branch=main)](https://github.com/mcpplibs/template/actions/workflows/ci-linux.yml) [![ci-macos](https://github.com/mcpplibs/template/actions/workflows/ci-macos.yml/badge.svg?branch=main)](https://github.com/mcpplibs/template/actions/workflows/ci-macos.yml) [![ci-windows](https://github.com/mcpplibs/template/actions/workflows/ci-windows.yml/badge.svg?branch=main)](https://github.com/mcpplibs/template/actions/workflows/ci-windows.yml) |

一个基于 mcpp 构建工具的**现代 C++ 模块化库**模板仓库：一个库模块、一套 gtest 测试、
一个使用方示例、可供他人脚手架的项目模板，以及 Linux / macOS / Windows 三平台 CI。

## 快速开始

1. 打开模板仓库：https://github.com/mcpplibs/template
2. 点击 [**Use this template**](https://github.com/new?template_name=template&template_owner=mcpplibs) 创建自己的库仓库。
3. 克隆新仓库到本地：

```bash
git clone https://github.com/<your-org>/<your-lib>.git
cd <your-lib>
```

4. 先运行默认模板，确认环境可用：

<details>
<summary>点击查看 xlings 安装命令</summary>

**Linux / macOS**
```bash
curl -fsSL https://d2learn.org/xlings-install.sh | bash
```

**Windows — PowerShell**
```powershell
irm https://d2learn.org/xlings-install.ps1.txt | iex
```

> xlings 详情 → [xlings.d2learn.org](https://xlings.d2learn.org)

</details>

```bash
xlings install
mcpp build
mcpp test
```

> [!NOTE]
> 默认 `xlings install` 是把 mcpp 安装到**项目环境**，版本由 [`.xlings.json`](.xlings.json) 固定，
> 这样所有协作者和 CI 用的是同一个 mcpp 版本。
> 如果要把 mcpp 安装到**全局**，执行 `xlings install mcpp -g`。

5. 再把 `mylib` 替换成你的库名，重点修改：

- `mcpp.toml`：包名、描述和仓库地址
- `src/mylib.cppm`：模块名和 API
- `tests/mylib_test.cpp`：测试用例
- `examples/basic/`：依赖和 import
- `templates/`：你的库对外提供的项目模板（见下文）
- `README*.md` 与 `docs/architecture*.md`：文字说明

## 仓库结构

```text
.
├── .xlings.json              # 项目工具环境（固定 mcpp 版本）
├── mcpp.toml                 # 包信息、依赖、测试依赖
├── src/mylib.cppm            # 库模块接口
├── tests/mylib_test.cpp      # gtest 单元测试，由 `mcpp test` 运行
├── examples/basic/           # 独立使用方示例（path 依赖）
├── templates/                # 随库分发的项目模板
│   ├── basic/                #   mcpp new myapp --template mylib
│   └── lib/                  #   mcpp new mylib2 --template mylib:lib
├── tools/template_smoke.sh   # 用当前仓库编译校验所有模板
├── docs/architecture.zh.md   # 项目结构、mcpp 约定、依赖管理
└── .github/workflows/        # ci-linux.yml · ci-macos.yml · ci-windows.yml
```

## 库示例

当前库导出一个简单 API：

```cpp
import std;
import mcpplibs.mylib;

int main() {
    std::println("{}", mcpplibs::mylib::hello_mcpplibs());
}
```

输出：

```text
hello mcpplibs
```

相关文件：

- `src/mylib.cppm`：模块接口
- `tests/mylib_test.cpp`：单元测试
- `examples/basic/`：使用方示例

运行使用方示例：

```bash
cd examples/basic
mcpp run
```

需要添加依赖时，在 `mcpp.toml` 中声明：

```toml
[dependencies.mcpplibs]
cmdline = "0.0.2"
```

然后在需要的位置直接 `import mcpplibs.cmdline;`。不要默认在主模块里 `export import` 第三方依赖，
除非公开 API 确实要暴露依赖包的类型。

## 项目模板

一个库可以在 `templates/` 下**随库分发项目模板**。使用方用 `mcpp new` 直接脚手架，
模板版本会自动跟随库版本：

```bash
mcpp new --list-templates mylib      # 列出这个库提供的模板
mcpp new myapp --template mylib      # 使用默认模板（basic）
mcpp new mylib2 --template mylib:lib # 显式指定模板
```

本仓库提供两个模板：

| 模板 | 内容 |
|---|---|
| `basic`（默认） | 最小控制台程序，import 这个库 |
| `lib` | 基于这个库的下游 C++23 模块库，带 gtest 测试 |

模板的目录结构 —— 模板是纯数据，只做渲染和拷贝，没有钩子也不执行脚本：

```text
templates/<name>/
├── template.toml      # 元数据：description、default = true、post_message
├── mcpp.toml.in       # `.in` 文件会被渲染，然后去掉后缀
└── src/main.cpp.in    # 其他文件原样拷贝
```

占位符词汇表由 mcpp 拥有，刻意保持很小：

| 占位符 | 展开为 |
|---|---|
| `{{project.name}}` | 用户传给 `mcpp new` 的项目名 |
| `{{self.name}}` | 本库的包名（`mylib`） |
| `{{self.version}}` | 本库解析出的版本号 |

`template.toml` 里最多只能有一个模板声明 `default = true`，它就是 `--template mylib`
不带 `:<template>` 时选中的那个。库还没发布到索引时，可以先本地校验模板：

```bash
bash tools/template_smoke.sh
```

它会按 `mcpp new` 的方式渲染每个模板，把依赖改指向当前仓库，然后编译。CI 在三个平台上都会跑。

## 其他项目如何使用编写的库

开发期或同项目内可以直接用本地路径：

```toml
[dependencies]
mylib = { path = "../mylib" }
```

还没有进入包索引时，可以引用 Git 仓库：

```toml
[dependencies]
mylib = { git = "https://github.com/mcpplibs/mylib.git", tag = "v0.1.0" }
```

发布到 mcpp 包索引后，可以只按名字和版本引用：

```toml
[dependencies]
mylib = "0.1.0"
```

无论哪种方式，代码里的导入写法都一样：

```cpp
import mcpplibs.mylib;
```

### 发布到 mcpp 包索引

[mcpp-index](https://github.com/mcpplibs/mcpp-index) 是默认包索引，每个包对应一个
`pkgs/<首字母>/<名字>.lua` 描述符。mcpp 可以直接从 `mcpp.toml` 生成：

```bash
mcpp publish --dry-run        # 打包 tarball、算 sha256、打印描述符，不上传
mcpp emit xpkg -o mylib.lua   # 只生成描述符，不打包
```

`--dry-run` 还会把后续步骤连同你项目的真实 URL 一起打印出来：打 tag 并推送、把
`target/dist/<name>-<version>.tar.gz` 挂到 GitHub Release、再向 mcpp-index 提 PR 添加
`pkgs/<首字母>/<名字>.lua`。相关链接：

- 仓库：https://github.com/mcpplibs/mcpp-index —— 在线浏览所有包：https://mcpplibs.github.io/mcpp-index/
- 贡献文档：[docs/README.md](https://github.com/mcpplibs/mcpp-index/blob/main/docs/zh/README.md) · [包类型](https://github.com/mcpplibs/mcpp-index/blob/main/docs/zh/package-types.md) · [仓库与 schema](https://github.com/mcpplibs/mcpp-index/blob/main/docs/zh/repository-and-schema.md) · [CN 镜像](https://github.com/mcpplibs/mcpp-index/blob/main/docs/zh/cn-mirror.md)
- 端到端流程（人或 Agent 都可用）：[`add-mcpp-index-package`](https://github.com/mcpplibs/mcpp-index/blob/main/.agents/skills/add-mcpp-index-package/SKILL.md) skill
- 本仓库内：[`.agents/skills/mcpp-index/SKILL.md`](.agents/skills/mcpp-index/SKILL.md)

像本模板这样的库属于 **Form A** 包：仓库自身已经带 `mcpp.toml`，所以描述符只需要声明元数据和
下载地址。PR 合并后，所有人都能用 `mcpp add mylib` 解析到它。

## CI

CI 按平台拆开，这样 macOS 或 Windows 的问题不会被 Linux 的绿灯掩盖。每个 workflow 都走
新用户会走的同一条路径：

| Workflow | Runner | 步骤 |
|---|---|---|
| [`ci-linux.yml`](.github/workflows/ci-linux.yml) | `ubuntu-latest` | 安装 → **构建** → **测试** → 示例 → 模板 |
| [`ci-macos.yml`](.github/workflows/ci-macos.yml) | `macos-latest`（arm64） | 同上 |
| [`ci-windows.yml`](.github/workflows/ci-windows.yml) | `windows-latest` | 同上 |

对应到本地就是：

```bash
xlings install -y
mcpp build
mcpp test
cd examples/basic && mcpp run
bash tools/template_smoke.sh
```

## AI Agent 辅助了解和开发

本仓库在 [`.agents/skills/`](.agents/skills/README.md) 下提供了 Agent 技能：

| 技能 | 用途 |
|---|---|
| [`mcpp`](.agents/skills/mcpp/SKILL.md) | mcpp 构建工具：命令、`mcpp.toml`、约定、模板 |
| [`mcpp-index`](.agents/skills/mcpp-index/SKILL.md) | 包索引：查找、添加和发布包 |
| [`mcpp-style-ref`](.agents/skills/mcpp-style-ref/SKILL.md) | Modern/Module C++23 命名与结构规范 |
| [`more-details`](.agents/skills/more-details/SKILL.md) | 本仓库与上游资料的查找入口 |

可以先用下面这段提示词让 Agent 进入状态：

```text
仓库地址：https://github.com/mcpplibs/template

先阅读 .agents/skills/more-details/SKILL.md、.agents/skills/mcpp/SKILL.md、
.agents/skills/mcpp-style-ref/SKILL.md 和 docs/architecture.zh.md。

先只了解这个模板的 mcpp 项目结构、模块组织、测试方式和依赖管理方式，不要直接修改文件。

需要更多资料时，从 more-details 里的 mcpp docs、mcpp-index、mcpplibs/cmdline、
mcpplibs/llmapi 等链接继续查。
保持 mcpp-only；测试遵循 mcpp test 规范；默认不要重新导出第三方依赖。
README 只做入口引导，细节放到 docs/architecture.zh.md。
```

## 参考项目

设计自己的库之前，值得先读一读这两个真实的 mcpp 模块库：

- [mcpplibs/llmapi](https://github.com/mcpplibs/llmapi) —— C++23 LLM 客户端（OpenAI 兼容）。
  可以参考：分发多个 `templates/`、多语言 README、库拆成多个 `.cppm`、以及依赖另一个 mcpplibs 包。
- [mcpplibs/cmdline](https://github.com/mcpplibs/cmdline) —— 一个小巧的命令行解析库。
  可以参考：单模块库带测试和示例的最小形态 —— 最接近本模板成长后的样子。

## 更多资料

- mcpp 构建工具：https://github.com/mcpp-community/mcpp
- mcpp 文档：https://github.com/mcpp-community/mcpp/tree/main/docs
- 快速开始：https://github.com/mcpp-community/mcpp/blob/main/docs/zh/00-getting-started.md
- `mcpp.toml` 指南：https://github.com/mcpp-community/mcpp/blob/main/docs/zh/05-mcpp-toml.md
- mcpp 包索引：https://github.com/mcpplibs/mcpp-index · https://mcpplibs.github.io/mcpp-index/
- mcpplibs 组织：https://github.com/mcpplibs
- 模板仓库：https://github.com/mcpplibs/template
- C++23 模块风格参考：https://github.com/mcpp-community/mcpp-style-ref
- xlings 工具环境：https://github.com/openxlings/xlings
