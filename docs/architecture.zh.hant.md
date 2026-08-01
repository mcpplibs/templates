# 架構文件

> 一個最小的 mcpp C++23 模組函式庫範本。
> [English](architecture.md) · [简体中文](architecture.zh.md) · [繁體中文](architecture.zh.hant.md)

## 目標

倉庫只表達四件事：

- 用 `.xlings.json` 宣告專案工具環境（用哪個 mcpp 版本建置）。
- 用 `mcpp.toml` 宣告 C++23 模組函式庫與測試相依；執行期相依按需新增。
- 用 `templates/` 宣告這個函式庫對外散布的專案範本。
- 用 `mcpp build`、`mcpp test`、`mcpp run` 驗證函式庫、單元測試與範例。

## mcpp 慣例

- 預設掃描 `src/**/*.{cppm,cpp,cc,c,S,s,asm}`。
- 只有 `src/*.cppm` 且沒有 `src/main.cpp` 時，mcpp 會推斷出以套件名稱命名的 **lib** 目標
  （`Inferred target mylib (lib from .cppm in src/)`）。需要覆寫預設行為時再明確寫
  `[targets.<name>]`。
- 函式庫根模組預設放在 `src/<套件名稱最後一段>.cppm`；`[lib] path` 可以改這個位置。
- 相依放 `[dependencies]` 或 `[dependencies.<namespace>]`；只在測試使用的放
  `[dev-dependencies]`（`mcpp build` 不解析它們，只有 `mcpp test` 會）。
- 單元測試放 `tests/**/*.cpp`，由 `mcpp test` 自動探索，一個檔案一個測試執行檔。
  測試檔只寫 `TEST(...)`，不要自己定義 `main()`。
- 預設建置 profile 是 `dev`（`-O0 -g`）；`mcpp build --release` 才是最佳化建置。
  C++ 標準預設 `c++23`，應寫在 `[package] standard`，不要寫進 `cxxflags`。
- `mcpp.lock` 不納入版本控制：這是一個函式庫，真正起作用的是使用方的版本解析。
  由 `templates/` 產生的應用程式則可以考慮提交自己的鎖定檔。

## 目前結構

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
│   ├── basic/                # 預設範本：主控台程式
│   │   ├── template.toml
│   │   ├── mcpp.toml.in
│   │   ├── src/main.cpp.in
│   │   └── .gitignore
│   └── lib/                  # 下游模組函式庫 + gtest
│       ├── template.toml
│       ├── mcpp.toml.in
│       ├── src/lib.cppm.in
│       └── tests/lib_test.cpp.in
├── tools/template_smoke.sh
└── .github/workflows/{ci-linux,ci-macos,ci-windows}.yml
```

## 根套件

```toml
[package]
namespace = "mcpplibs"
name      = "mylib"
version   = "0.1.0"

[dev-dependencies]
gtest = "1.15.2"
```

每個套件的身分由兩部分組成：**namespace** 與 **name**。`namespace = "mcpplibs"` 加
`name = "mylib"` 表示使用方在 `[dependencies.mcpplibs]` 底下寫 `mylib = "0.1.0"`
（也可以直接寫裸名 —— `mcpplibs` 是 mcpp 優先搜尋的預設命名空間）。

`src/mylib.cppm` 匯出模組 `mcpplibs.mylib`，而且不重新匯出任何東西：相依在用到的地方
import，而不是透過根模組轉發出去，除非公開 API 確實暴露了相依套件的型別。

## 新增相依

在根 `mcpp.toml` 加入相依宣告：

```toml
[dependencies.mcpplibs]
cmdline = "0.0.2"
```

在需要的位置匯入：

```cpp
import mcpplibs.cmdline;
```

預設不用 `export import`。只有當公開 API 直接交出相依套件的型別時，才考慮重新匯出。

## 範例套件

`examples/basic` 是獨立的 mcpp 套件，透過 path 相依引用根函式庫：

```toml
[dependencies.mcpplibs]
mylib = { path = "../.." }
```

執行：

```bash
cd examples/basic
mcpp run
```

它的意義在於**從外部**證明這個函式庫可用 —— 有自己的清單、走自己的相依解析，這是從 `tests/`
裡 import 驗證不了的。

## 範本

`templates/<name>/` 是函式庫把專案骨架散布給使用方的方式：`mcpp new myapp --template mylib`
會把範本算繪成一個新專案，而且範本版本會自動跟著函式庫版本走。

- `template.toml` —— `description`、所有範本中最多一個 `default = true`，以及選用的
  `post_message`（產生後印出）。它只是中繼資料，不會被複製。
- `*.in` —— 算繪後去掉副檔名。佔位符：`{{project.name}}`、`{{self.name}}`、`{{self.version}}`。
- 其他檔案 —— 原樣複製。

範本是純資料：mcpp 只做算繪與複製，不執行任何掛鉤或腳本。**檔名不參與算繪**，只有檔案內容
參與 —— 所以 `lib` 範本固定提供 `src/lib.cppm` 並用 `[lib] path` 指過去，而不是依賴
`src/<套件名稱>.cppm` 的預設慣例。

如果算繪出來的 `mcpp.toml` 沒有宣告對散布函式庫的相依，mcpp 會自動注入一條；本倉庫的範本已經
用 `{{self.version}}` 明確寫出，所以不會觸發注入。

`tools/template_smoke.sh` 會依 `mcpp new` 的方式算繪每個範本，把相依改指向當前倉庫
（這樣在函式庫尚未發布到索引時就能驗證範本），然後編譯；範本產生的是執行檔時還會執行它。

## CI

三個 workflow，每個平台一個（`.github/workflows/ci-{linux,macos,windows}.yml`），
都走新使用者會走的同一條路徑：

```bash
xlings install -y        # 依 .xlings.json 的固定版本安裝專案環境的 mcpp
mcpp build
mcpp test
cd examples/basic && mcpp run
bash tools/template_smoke.sh
```

依平台拆分讓每個作業系統各有一個徽章與一份日誌，macOS 或 Windows 上的回歸就不會被
Linux 的綠燈掩蓋。
