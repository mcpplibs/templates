---
name: mcpp
description: Use the mcpp build tool for C++23 module projects — commands (build/test/run/add/new/publish), mcpp.toml fields, project conventions, and shipping templates/. Use when building, testing, adding dependencies, editing mcpp.toml, or scaffolding with mcpp.
---

# mcpp

The build and package tool this repository is built with. mcpp is module-first C++23:
`import std` works out of the box, toolchains install into an isolated sandbox, and
dependencies resolve through a package index.

Verified against **mcpp 2026.8.1.1**. mcpp is pre-1.0 and moves fast — when this skill and
the tool disagree, the tool wins. Check with `mcpp --help`, `mcpp <cmd> --help`, and the
[upstream docs](https://github.com/mcpp-community/mcpp/tree/main/docs).

## Environment

The mcpp version is pinned per project in `.xlings.json` and installed into the **project**
environment:

```bash
xlings install            # install the pinned mcpp for this project
xlings install mcpp -g    # install mcpp globally instead
mcpp --version            # confirm which one you got
```

Never assume the mcpp on `PATH` matches the pin — check first when a build behaves oddly.

## Commands

| Command | Use |
|---|---|
| `mcpp build [--release]` | Build. Default profile is `dev` (`-O0 -g`); `--release` is opt-in |
| `mcpp test [pattern]` | Build + run `tests/**/*.cpp`, one binary per file (`--list`, `--timeout`) |
| `mcpp run [target] [-- args]` | Build + run a binary target |
| `mcpp new <name>` | New package skeleton; `--template <pkg>[@ver][:<tmpl>]`, `--list-templates <pkg>` |
| `mcpp add <pkg>[@ver]` / `mcpp remove <pkg>` | Edit dependencies in `mcpp.toml` |
| `mcpp update [pkg]` | Re-resolve and rewrite `mcpp.lock` |
| `mcpp search <keyword>` | Search the package index |
| `mcpp clean [--bmi-cache]` | Remove `target/` (and optionally the build cache) |
| `mcpp publish [--dry-run]` / `mcpp emit xpkg` | Publish to / generate a descriptor for the index |
| `mcpp self doctor` / `mcpp self env` | Diagnose the environment; print paths and toolchain |

Useful flags: `--verbose`, `--quiet`, `--offline`, `--strict` (turns manifest warnings into
errors), `--target <triple>`.

## Conventions Before Configuration

mcpp infers most of a project; write config only to override it.

- Sources: `src/**/*.{cppm,cpp,cc,c,S,s,asm}`.
- `src/main.cpp` present → a **bin** target named after the package.
- Only `src/*.cppm`, no `main.cpp` → a **lib** target named after the package.
- Lib-root module: `src/<last segment of the package name>.cppm`; override with `[lib] path`.
- Tests: `tests/**/*.cpp`, discovered by `mcpp test`, one binary per file. Test files contain
  `TEST(...)` cases only — **never their own `main()`** (gtest_main is linked in).
- Standard: `c++23` by default, set via `[package] standard` — never through `cxxflags`.
  The standard is module-graph-global and part of the cache key.

## mcpp.toml

```toml
[package]
namespace   = "mcpplibs"      # namespace + name form the package identity
name        = "mylib"
version     = "0.1.0"
standard    = "c++23"         # c++20 | c++23 (default) | c++26
description = "..."
license     = "Apache-2.0"
repo        = "https://github.com/mcpplibs/mylib"

[targets.mylib]               # only when overriding inference
kind = "lib"                  # bin | lib | shared

[lib]
path = "src/mylib.cppm"       # only when overriding the lib-root convention

[build]
include_dirs  = ["include"]
defines       = ["FOO=1"]     # bare names; reach every TU including module scans
default-profile = "release"   # project default when no --profile/--release is passed

[dependencies]                # runtime deps
cmdline = "0.0.2"             # bare name: searched in mcpplibs, then compat, then no-namespace

[dependencies.mcpplibs]       # namespace sub-table (preferred for several from one org)
tinyhttps = "0.2.3"

[dev-dependencies]            # test-only; `mcpp build` ignores these
gtest = "1.15.2"

[toolchain]
default = "gcc@16.1.0"        # pin only when the project genuinely needs it
```

Other sections, when you need them (see
[docs/05-mcpp-toml.md](https://github.com/mcpp-community/mcpp/blob/main/docs/05-mcpp-toml.md)):
`[features]` (additive, Cargo-style), `[feature-deps.<name>]`, `[profile.<name>]`,
`[target.'cfg(...)']` for platform-conditional deps/flags, `[generated_files]`,
`[build] flags` for per-glob compile flags.

Dependency forms: `"1.2.3"` · `"^1.2"` · `"~1.2"` · `">=1.0, <2.0"` ·
`{ path = "../mylib" }` · `{ git = "...", tag = "v1.0.0" }` ·
`{ version = "0.0.3", features = ["docking"] }`.

**Namespace rule:** a bare name resolves in exactly three places, in order — `mcpplibs`,
`compat` (third-party C/C++ wrappers), then packages that declare no namespace. Any other
namespace must be written out: `"chriskohlhoff.asio" = "1.38.1"` or a
`[dependencies.chriskohlhoff]` sub-table.

## Modules

- `import std;` — do not `#include <print>` etc. in module code.
- `.cppm` is the module interface; `.cpp` holds separated implementation.
- Import a dependency where it is used. Do **not** `export import` a third-party module from
  your root module unless the public API genuinely hands out that dependency's types.
- Do not hand-write module dependency order — mcpp scans `export module` / `import`
  declarations (P1689) and builds the graph itself.

## Shipping templates/

A package ships project scaffolds by adding `templates/<name>/`:

```text
templates/<name>/template.toml   # description, default = true (at most one), post_message
templates/<name>/**.in           # rendered, then the .in suffix is stripped
templates/<name>/**              # everything else copied verbatim
```

Placeholders — the whole vocabulary: `{{project.name}}`, `{{self.name}}`, `{{self.version}}`.
File *names* are not rendered, only contents. Templates are pure data: no hooks, no scripts.
Consumers use `mcpp new <proj> --template <pkg>[:<tmpl>]` and
`mcpp new --list-templates <pkg>`.

## Troubleshooting

- Wrong mcpp version → check `.xlings.json` vs `mcpp --version`; re-run `xlings install`.
- Dependency not found → `mcpp search <name>`; check the namespace rule above; `xlings update`
  refreshes a stale index snapshot.
- Stale build / BMI weirdness → `mcpp clean`, or `mcpp clean --bmi-cache` for the module cache.
- Environment trouble → `mcpp self doctor`, `mcpp self env`.
- An error code in the output → `mcpp self explain <CODE>`.

## Further Reading

- Docs index: https://github.com/mcpp-community/mcpp/tree/main/docs (`zh/` for Chinese)
- Getting started: `docs/00-getting-started.md` · Examples: `docs/01-examples.md`
- `mcpp.toml` guide: `docs/05-mcpp-toml.md` · Workspaces: `docs/06-workspace.md`
- Toolchains: `docs/03-toolchains.md` · Packaging: `docs/02-pack-and-release.md`
- Package index: see the [`mcpp-index`](../mcpp-index/SKILL.md) skill
