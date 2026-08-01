# mcpplibs.mylib

> A minimal mcpp C++23 module library scaffold — `import mcpplibs.mylib;`

[![C++23](https://img.shields.io/badge/C%2B%2B-23-blue.svg)](https://en.cppreference.com/w/cpp/23)
[![Module](https://img.shields.io/badge/module-ok-green.svg)](https://en.cppreference.com/w/cpp/language/modules)
[![License](https://img.shields.io/badge/license-Apache_2.0-blue.svg)](LICENSE)

| **English** - [简体中文](README.zh.md) - [繁體中文](README.zh.hant.md) |
|:---:|
| [mcpp build tool](https://github.com/mcpp-community/mcpp) · [package index](https://github.com/mcpplibs/mcpp-index) · [architecture](docs/architecture.md) · [Issues](https://github.com/mcpplibs/template/issues) |
| [![ci-linux](https://github.com/mcpplibs/template/actions/workflows/ci-linux.yml/badge.svg?branch=main)](https://github.com/mcpplibs/template/actions/workflows/ci-linux.yml) [![ci-macos](https://github.com/mcpplibs/template/actions/workflows/ci-macos.yml/badge.svg?branch=main)](https://github.com/mcpplibs/template/actions/workflows/ci-macos.yml) [![ci-windows](https://github.com/mcpplibs/template/actions/workflows/ci-windows.yml/badge.svg?branch=main)](https://github.com/mcpplibs/template/actions/workflows/ci-windows.yml) |

A template repository for building **modern C++ modular libraries** with the mcpp build tool:
one library module, one gtest suite, one consumer example, project templates other people can
scaffold from, and CI on Linux / macOS / Windows.

## Quick Start

1. Open the template repository: https://github.com/mcpplibs/template
2. Click [**Use this template**](https://github.com/new?template_name=template&template_owner=mcpplibs) to create your own library repository.
3. Clone it locally:

```bash
git clone https://github.com/<your-org>/<your-lib>.git
cd <your-lib>
```

4. Run the scaffold as-is first, to confirm the environment works:

<details>
<summary>Click for the xlings install command</summary>

**Linux / macOS**
```bash
curl -fsSL https://d2learn.org/xlings-install.sh | bash
```

**Windows — PowerShell**
```powershell
irm https://d2learn.org/xlings-install.ps1.txt | iex
```

> More about xlings → [xlings.d2learn.org](https://xlings.d2learn.org)

</details>

```bash
xlings install
mcpp build
mcpp test
```

> [!NOTE]
> `xlings install` installs mcpp into the **project environment**, at the version pinned by
> [`.xlings.json`](.xlings.json) — so every contributor and CI build uses the same mcpp.
> To install mcpp **globally** instead, run `xlings install mcpp -g`.

5. Then rename `mylib` to your own library name. The places that matter:

- `mcpp.toml` — package name, description, repository URL
- `src/mylib.cppm` — module name and API
- `tests/mylib_test.cpp` — test cases
- `examples/basic/` — dependency and `import`
- `templates/` — the project templates your library ships (see below)
- `README*.md` and `docs/architecture.md` — the prose

## Repository Layout

```text
.
├── .xlings.json              # project tool environment (pins the mcpp version)
├── mcpp.toml                 # package metadata, dependencies, dev-dependencies
├── src/mylib.cppm            # the library module interface
├── tests/mylib_test.cpp      # gtest unit tests, run by `mcpp test`
├── examples/basic/           # standalone consumer package (path dependency)
├── templates/                # project templates shipped WITH the library
│   ├── basic/                #   mcpp new myapp --template mylib
│   └── lib/                  #   mcpp new mylib2 --template mylib:lib
├── tools/template_smoke.sh   # compiles every template against this checkout
├── docs/architecture.md      # structure, mcpp conventions, dependency management
└── .github/workflows/        # ci-linux.yml · ci-macos.yml · ci-windows.yml
```

## Library Example

The library exports one simple API:

```cpp
import std;
import mcpplibs.mylib;

int main() {
    std::println("{}", mcpplibs::mylib::hello_mcpplibs());
}
```

Output:

```text
hello mcpplibs
```

Relevant files:

- `src/mylib.cppm`: module interface
- `tests/mylib_test.cpp`: unit tests
- `examples/basic/`: consumer example

Run the consumer example:

```bash
cd examples/basic
mcpp run
```

To add a dependency, declare it in `mcpp.toml`:

```toml
[dependencies.mcpplibs]
cmdline = "0.0.2"
```

then `import mcpplibs.cmdline;` where you need it. Do not `export import` a third-party
dependency from your root module by default — only do so when your public API genuinely
exposes that dependency's types.

## Project Templates

A library can ship **project templates** in `templates/`. Users scaffold from them with
`mcpp new`, and the template version tracks the library version automatically:

```bash
mcpp new --list-templates mylib      # list what this library provides
mcpp new myapp --template mylib      # the default template (basic)
mcpp new mylib2 --template mylib:lib # pick one explicitly
```

This repository ships two:

| Template | Contents |
|---|---|
| `basic` (default) | Minimal console app that imports the library |
| `lib` | A downstream C++23 module library built on this one, with gtest tests |

Layout of a template — templates are pure data, rendered and copied, with no hooks and no
script execution:

```text
templates/<name>/
├── template.toml      # metadata: description, default = true, post_message
├── mcpp.toml.in       # `.in` files are rendered, then the suffix is stripped
└── src/main.cpp.in    # everything else is copied verbatim
```

The placeholder vocabulary is owned by mcpp and deliberately small:

| Placeholder | Expands to |
|---|---|
| `{{project.name}}` | the name the user passed to `mcpp new` |
| `{{self.name}}` | this library's package name (`mylib`) |
| `{{self.version}}` | this library's resolved version |

Exactly one template may declare `default = true` in its `template.toml`; that is the one
`--template mylib` picks when no `:<template>` is given. Verify templates before a release
exists in the index with:

```bash
bash tools/template_smoke.sh
```

It renders each template the way `mcpp new` does, repoints the dependency at this checkout,
and builds it. CI runs it on all three platforms.

## Using the Library from Another Project

During development, or inside the same repository, use a local path:

```toml
[dependencies]
mylib = { path = "../mylib" }
```

Before the library reaches a package index, a Git repository works too:

```toml
[dependencies]
mylib = { git = "https://github.com/mcpplibs/mylib.git", tag = "v0.1.0" }
```

Once published to the mcpp package index, name and version are enough:

```toml
[dependencies]
mylib = "0.1.0"
```

Either way, the import stays the same:

```cpp
import mcpplibs.mylib;
```

### Publishing to the mcpp Package Index

[mcpp-index](https://github.com/mcpplibs/mcpp-index) is the default package index — every
package there is one `pkgs/<initial>/<name>.lua` descriptor. mcpp generates yours from
`mcpp.toml`:

```bash
mcpp publish --dry-run   # package a tarball, hash it, print the descriptor — upload nothing
mcpp emit xpkg -o mylib.lua   # just the descriptor, no packaging
```

`--dry-run` also prints the remaining steps with your project's real URLs filled in: tag and
push, attach `target/dist/<name>-<version>.tar.gz` to the GitHub Release, then open a PR
adding `pkgs/<initial>/<name>.lua` to mcpp-index. Useful links along the way:

- Repository: https://github.com/mcpplibs/mcpp-index — browse the packages online at https://mcpplibs.github.io/mcpp-index/
- Contributor docs: [docs/README.md](https://github.com/mcpplibs/mcpp-index/blob/main/docs/README.md) · [package types](https://github.com/mcpplibs/mcpp-index/blob/main/docs/package-types.md) · [repository & schema](https://github.com/mcpplibs/mcpp-index/blob/main/docs/repository-and-schema.md) · [CN mirror](https://github.com/mcpplibs/mcpp-index/blob/main/docs/cn-mirror.md)
- End-to-end procedure (human or agent): the [`add-mcpp-index-package`](https://github.com/mcpplibs/mcpp-index/blob/main/.agents/skills/add-mcpp-index-package/SKILL.md) skill
- In this repository: [`.agents/skills/mcpp-index/SKILL.md`](.agents/skills/mcpp-index/SKILL.md)

A library like this one is a **Form A** package: your repository already carries `mcpp.toml`,
so the descriptor only declares metadata and a download address. After the PR is merged,
`mcpp add mylib` resolves for everybody.

## CI

CI is split per platform, so a macOS or Windows problem can never hide behind a green Linux
run. Each workflow walks the same path a new user walks:

| Workflow | Runner | Steps |
|---|---|---|
| [`ci-linux.yml`](.github/workflows/ci-linux.yml) | `ubuntu-latest` | install → **build** → **test** → example → templates |
| [`ci-macos.yml`](.github/workflows/ci-macos.yml) | `macos-latest` (arm64) | same |
| [`ci-windows.yml`](.github/workflows/ci-windows.yml) | `windows-latest` | same |

Locally that is:

```bash
xlings install -y
mcpp build
mcpp test
cd examples/basic && mcpp run
bash tools/template_smoke.sh
```

## Developing with an AI Agent

This repository ships agent skills under [`.agents/skills/`](.agents/skills/README.md):

| Skill | Purpose |
|---|---|
| [`mcpp`](.agents/skills/mcpp/SKILL.md) | The mcpp build tool: commands, `mcpp.toml`, conventions, templates |
| [`mcpp-index`](.agents/skills/mcpp-index/SKILL.md) | The package index: finding, adding and publishing packages |
| [`mcpp-style-ref`](.agents/skills/mcpp-style-ref/SKILL.md) | Modern/Module C++23 naming and structure rules |
| [`more-details`](.agents/skills/more-details/SKILL.md) | Where to look things up, in this repo and upstream |

A prompt to get an agent oriented:

```text
Repository: https://github.com/mcpplibs/template

Read .agents/skills/more-details/SKILL.md, .agents/skills/mcpp/SKILL.md,
.agents/skills/mcpp-style-ref/SKILL.md and docs/architecture.md first.

For now, only understand this template's mcpp project structure, module organization,
testing approach and dependency management — do not modify files yet.

When you need more, follow the links in more-details (mcpp docs, mcpp-index,
mcpplibs/cmdline, mcpplibs/llmapi).
Stay mcpp-only; follow the `mcpp test` conventions; do not re-export third-party
dependencies by default. Keep README as the entry point and details in docs/architecture.md.
```

## Reference Projects

Real mcpp module libraries worth reading before you design your own:

- [mcpplibs/llmapi](https://github.com/mcpplibs/llmapi) — a C++23 LLM client (OpenAI-compatible).
  Read it for: shipping several `templates/`, multilingual READMEs, a library split across many
  `.cppm` files, and depending on another mcpplibs package.
- [mcpplibs/cmdline](https://github.com/mcpplibs/cmdline) — a small command-line parsing library.
  Read it for: the minimal shape of a single-module library with tests and examples — the closest
  thing to what this template grows into.

## More Information

- mcpp build tool: https://github.com/mcpp-community/mcpp
- mcpp docs: https://github.com/mcpp-community/mcpp/tree/main/docs
- Getting started: https://github.com/mcpp-community/mcpp/blob/main/docs/00-getting-started.md
- `mcpp.toml` guide: https://github.com/mcpp-community/mcpp/blob/main/docs/05-mcpp-toml.md
- mcpp package index: https://github.com/mcpplibs/mcpp-index · https://mcpplibs.github.io/mcpp-index/
- mcpplibs organization: https://github.com/mcpplibs
- This template: https://github.com/mcpplibs/template
- C++23 module style reference: https://github.com/mcpp-community/mcpp-style-ref
- xlings tool environment: https://github.com/openxlings/xlings
