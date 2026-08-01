# mcpplibs.mylib

> 一個最小的 mcpp C++23 模組函式庫骨架 — `import mcpplibs.mylib;`

[![C++23](https://img.shields.io/badge/C%2B%2B-23-blue.svg)](https://en.cppreference.com/w/cpp/23)
[![Module](https://img.shields.io/badge/module-ok-green.svg)](https://en.cppreference.com/w/cpp/language/modules)
[![License](https://img.shields.io/badge/license-Apache_2.0-blue.svg)](LICENSE)

| [English](README.md) - [简体中文](README.zh.md) - **繁體中文** |
|:---:|
| [mcpp 建置工具](https://github.com/mcpp-community/mcpp) · [套件索引](https://github.com/mcpplibs/mcpp-index) · [架構文件](docs/architecture.zh.hant.md) · [Issues](https://github.com/mcpplibs/template/issues) |
| [![ci-linux](https://github.com/mcpplibs/template/actions/workflows/ci-linux.yml/badge.svg?branch=main)](https://github.com/mcpplibs/template/actions/workflows/ci-linux.yml) [![ci-macos](https://github.com/mcpplibs/template/actions/workflows/ci-macos.yml/badge.svg?branch=main)](https://github.com/mcpplibs/template/actions/workflows/ci-macos.yml) [![ci-windows](https://github.com/mcpplibs/template/actions/workflows/ci-windows.yml/badge.svg?branch=main)](https://github.com/mcpplibs/template/actions/workflows/ci-windows.yml) |

一個基於 mcpp 建置工具的**現代 C++ 模組化函式庫**範本倉庫：一個函式庫模組、一組 gtest 測試、
一個使用方範例、可供他人建立專案的範本，以及 Linux / macOS / Windows 三平台 CI。

## 快速開始

1. 開啟範本倉庫：https://github.com/mcpplibs/template
2. 點擊 [**Use this template**](https://github.com/new?template_name=template&template_owner=mcpplibs) 建立自己的函式庫倉庫。
3. 將新倉庫複製到本機：

```bash
git clone https://github.com/<your-org>/<your-lib>.git
cd <your-lib>
```

4. 先跑一次預設骨架，確認環境可用：

<details>
<summary>點擊查看 xlings 安裝指令</summary>

**Linux / macOS**
```bash
curl -fsSL https://d2learn.org/xlings-install.sh | bash
```

**Windows — PowerShell**
```powershell
irm https://d2learn.org/xlings-install.ps1.txt | iex
```

> xlings 詳情 → [xlings.d2learn.org](https://xlings.d2learn.org)

</details>

```bash
xlings install
mcpp build
mcpp test
```

> [!NOTE]
> 預設 `xlings install` 會把 mcpp 安裝到**專案環境**，版本由 [`.xlings.json`](.xlings.json) 固定，
> 讓所有協作者與 CI 使用同一個 mcpp 版本。
> 若要把 mcpp 安裝到**全域**，請執行 `xlings install mcpp -g`。

5. 再把 `mylib` 換成你的函式庫名稱，重點修改：

- `mcpp.toml`：套件名稱、描述與倉庫網址
- `src/mylib.cppm`：模組名稱與 API
- `tests/mylib_test.cpp`：測試案例
- `examples/basic/`：相依宣告與 import
- `templates/`：你的函式庫對外提供的專案範本（見下文）
- `README*.md` 與 `docs/architecture*.md`：文字說明

## 倉庫結構

```text
.
├── .xlings.json              # 專案工具環境（固定 mcpp 版本）
├── mcpp.toml                 # 套件資訊、相依、測試相依
├── src/mylib.cppm            # 函式庫模組介面
├── tests/mylib_test.cpp      # gtest 單元測試，由 `mcpp test` 執行
├── examples/basic/           # 獨立使用方範例（path 相依）
├── templates/                # 隨函式庫散布的專案範本
│   ├── basic/                #   mcpp new myapp --template mylib
│   └── lib/                  #   mcpp new mylib2 --template mylib:lib
├── tools/template_smoke.sh   # 以當前倉庫編譯驗證所有範本
├── docs/architecture.zh.hant.md  # 專案結構、mcpp 慣例、相依管理
└── .github/workflows/        # ci-linux.yml · ci-macos.yml · ci-windows.yml
```

## 函式庫範例

目前的函式庫匯出一個簡單 API：

```cpp
import std;
import mcpplibs.mylib;

int main() {
    std::println("{}", mcpplibs::mylib::hello_mcpplibs());
}
```

輸出：

```text
hello mcpplibs
```

相關檔案：

- `src/mylib.cppm`：模組介面
- `tests/mylib_test.cpp`：單元測試
- `examples/basic/`：使用方範例

執行使用方範例：

```bash
cd examples/basic
mcpp run
```

需要新增相依時，在 `mcpp.toml` 中宣告：

```toml
[dependencies.mcpplibs]
cmdline = "0.0.2"
```

然後在需要的位置直接 `import mcpplibs.cmdline;`。不要預設在主模組裡 `export import` 第三方相依，
除非公開 API 確實要暴露相依套件的型別。

## 專案範本

函式庫可以在 `templates/` 底下**隨函式庫散布專案範本**。使用者用 `mcpp new` 直接建立專案，
範本版本會自動跟著函式庫版本走：

```bash
mcpp new --list-templates mylib      # 列出這個函式庫提供的範本
mcpp new myapp --template mylib      # 使用預設範本（basic）
mcpp new mylib2 --template mylib:lib # 明確指定範本
```

本倉庫提供兩個範本：

| 範本 | 內容 |
|---|---|
| `basic`（預設） | 最小主控台程式，import 這個函式庫 |
| `lib` | 建構在這個函式庫之上的下游 C++23 模組函式庫，附 gtest 測試 |

範本的目錄結構 —— 範本是純資料，只做算繪與複製，沒有掛鉤也不執行腳本：

```text
templates/<name>/
├── template.toml      # 中繼資料：description、default = true、post_message
├── mcpp.toml.in       # `.in` 檔會被算繪，然後去掉副檔名
└── src/main.cpp.in    # 其他檔案原樣複製
```

佔位符詞彙由 mcpp 擁有，刻意保持精簡：

| 佔位符 | 展開為 |
|---|---|
| `{{project.name}}` | 使用者傳給 `mcpp new` 的專案名稱 |
| `{{self.name}}` | 本函式庫的套件名稱（`mylib`） |
| `{{self.version}}` | 本函式庫解析出的版本號 |

`template.toml` 中最多只能有一個範本宣告 `default = true`，它就是 `--template mylib`
未帶 `:<template>` 時選中的那一個。函式庫尚未發布到索引時，可以先在本機驗證範本：

```bash
bash tools/template_smoke.sh
```

它會依 `mcpp new` 的方式算繪每個範本，把相依改指向當前倉庫再編譯。CI 會在三個平台上執行它。

## 其他專案如何使用你寫的函式庫

開發期或同一個專案內可以直接用本機路徑：

```toml
[dependencies]
mylib = { path = "../mylib" }
```

尚未進入套件索引時，可以引用 Git 倉庫：

```toml
[dependencies]
mylib = { git = "https://github.com/mcpplibs/mylib.git", tag = "v0.1.0" }
```

發布到 mcpp 套件索引後，只用名稱與版本即可：

```toml
[dependencies]
mylib = "0.1.0"
```

無論哪一種方式，程式碼裡的匯入寫法都一樣：

```cpp
import mcpplibs.mylib;
```

### 發布到 mcpp 套件索引

[mcpp-index](https://github.com/mcpplibs/mcpp-index) 是預設套件索引，每個套件對應一個
`pkgs/<首字母>/<名稱>.lua` 描述檔。mcpp 可以直接從 `mcpp.toml` 產生：

```bash
mcpp publish --dry-run        # 打包 tarball、計算 sha256、印出描述檔，不上傳
mcpp emit xpkg -o mylib.lua   # 只產生描述檔，不打包
```

`--dry-run` 也會把後續步驟連同你專案的真實網址一起印出來：打 tag 並推送、把
`target/dist/<name>-<version>.tar.gz` 掛到 GitHub Release，再向 mcpp-index 發 PR 新增
`pkgs/<首字母>/<名稱>.lua`。相關連結：

- 倉庫：https://github.com/mcpplibs/mcpp-index —— 線上瀏覽所有套件：https://mcpplibs.github.io/mcpp-index/
- 貢獻文件：[docs/README.md](https://github.com/mcpplibs/mcpp-index/blob/main/docs/README.md) · [套件類型](https://github.com/mcpplibs/mcpp-index/blob/main/docs/package-types.md) · [倉庫與 schema](https://github.com/mcpplibs/mcpp-index/blob/main/docs/repository-and-schema.md) · [CN 鏡像](https://github.com/mcpplibs/mcpp-index/blob/main/docs/cn-mirror.md)
- 端到端流程（人或 Agent 皆可用）：[`add-mcpp-index-package`](https://github.com/mcpplibs/mcpp-index/blob/main/.agents/skills/add-mcpp-index-package/SKILL.md) skill
- 本倉庫內：[`.agents/skills/mcpp-index/SKILL.md`](.agents/skills/mcpp-index/SKILL.md)

像本範本這樣的函式庫屬於 **Form A** 套件：倉庫本身已經帶 `mcpp.toml`，所以描述檔只需要宣告
中繼資料與下載位址。PR 合併後，任何人都能用 `mcpp add mylib` 解析到它。

## CI

CI 依平台拆開，這樣 macOS 或 Windows 的問題不會被 Linux 的綠燈掩蓋。每個 workflow 都走
新使用者會走的同一條路徑：

| Workflow | Runner | 步驟 |
|---|---|---|
| [`ci-linux.yml`](.github/workflows/ci-linux.yml) | `ubuntu-latest` | 安裝 → **建置** → **測試** → 範例 → 範本 |
| [`ci-macos.yml`](.github/workflows/ci-macos.yml) | `macos-latest`（arm64） | 同上 |
| [`ci-windows.yml`](.github/workflows/ci-windows.yml) | `windows-latest` | 同上 |

對應到本機就是：

```bash
xlings install -y
mcpp build
mcpp test
cd examples/basic && mcpp run
bash tools/template_smoke.sh
```

## 用 AI Agent 了解與開發

本倉庫在 [`.agents/skills/`](.agents/skills/README.md) 底下提供了 Agent 技能：

| 技能 | 用途 |
|---|---|
| [`mcpp`](.agents/skills/mcpp/SKILL.md) | mcpp 建置工具：指令、`mcpp.toml`、慣例、範本 |
| [`mcpp-index`](.agents/skills/mcpp-index/SKILL.md) | 套件索引：尋找、新增與發布套件 |
| [`mcpp-style-ref`](.agents/skills/mcpp-style-ref/SKILL.md) | Modern/Module C++23 命名與結構規範 |
| [`more-details`](.agents/skills/more-details/SKILL.md) | 本倉庫與上游資料的查找入口 |

可以先用下面這段提示詞讓 Agent 進入狀況：

```text
倉庫位址：https://github.com/mcpplibs/template

先閱讀 .agents/skills/more-details/SKILL.md、.agents/skills/mcpp/SKILL.md、
.agents/skills/mcpp-style-ref/SKILL.md 與 docs/architecture.zh.hant.md。

先只了解這個範本的 mcpp 專案結構、模組組織、測試方式與相依管理方式，不要直接修改檔案。

需要更多資料時，從 more-details 裡的 mcpp docs、mcpp-index、mcpplibs/cmdline、
mcpplibs/llmapi 等連結繼續查。
保持 mcpp-only；測試遵循 mcpp test 規範；預設不要重新匯出第三方相依。
README 只做入口導引，細節放到 docs/architecture.zh.hant.md。
```

## 參考專案

設計自己的函式庫之前，值得先讀一讀這兩個真實的 mcpp 模組函式庫：

- [mcpplibs/llmapi](https://github.com/mcpplibs/llmapi) —— C++23 LLM 客戶端（OpenAI 相容）。
  可參考：散布多個 `templates/`、多語言 README、函式庫拆成多個 `.cppm`，以及相依另一個 mcpplibs 套件。
- [mcpplibs/cmdline](https://github.com/mcpplibs/cmdline) —— 小巧的命令列解析函式庫。
  可參考：單模組函式庫帶測試與範例的最小形態 —— 最接近本範本長大後的樣子。

## 更多資料

- mcpp 建置工具：https://github.com/mcpp-community/mcpp
- mcpp 文件：https://github.com/mcpp-community/mcpp/tree/main/docs
- 快速開始：https://github.com/mcpp-community/mcpp/blob/main/docs/00-getting-started.md
- `mcpp.toml` 指南：https://github.com/mcpp-community/mcpp/blob/main/docs/05-mcpp-toml.md
- mcpp 套件索引：https://github.com/mcpplibs/mcpp-index · https://mcpplibs.github.io/mcpp-index/
- mcpplibs 組織：https://github.com/mcpplibs
- 範本倉庫：https://github.com/mcpplibs/template
- C++23 模組風格參考：https://github.com/mcpp-community/mcpp-style-ref
- xlings 工具環境：https://github.com/openxlings/xlings
