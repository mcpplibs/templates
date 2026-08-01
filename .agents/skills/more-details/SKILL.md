---
name: more-details
description: Navigation for mcpp/mcpplibs module-library development — where to look things up in this repository and upstream. Use when an agent needs the mcpp tool, mcpp.toml, the package index, the mcpplibs ecosystem, reference libraries, the xlings tool environment, or more external links.
---

# more-details

The lookup entry point for mcpp/mcpplibs module-library development. This skill only says
*where* to look; the answers themselves come from this repository's files, the upstream mcpp
docs, and actual command output.

## Principles

- Start with this repository, then follow links outward.
- Read only what the task needs — do not expand every link at once.
- For tool behavior, package versions and index contents, the current file or the live upstream
  page wins over anything remembered.
- When writing C++23 module code, also use `mcpp-style-ref`.

## Sibling Skills

| Skill | Use it for |
|---|---|
| [`mcpp`](../mcpp/SKILL.md) | Commands, `mcpp.toml` fields, project conventions, shipping `templates/` |
| [`mcpp-index`](../mcpp-index/SKILL.md) | Finding dependencies, namespace rules, publishing to the index |
| [`mcpp-style-ref`](../mcpp-style-ref/SKILL.md) | Modern/Module C++23 naming and structure |

## This Repository

- `README.md` (`README.zh.md`, `README.zh.hant.md`) — entry point, quick start, agent prompt, links.
- `docs/architecture.md` (`.zh.md`, `.zh.hant.md`) — structure, mcpp conventions, dependencies, templates, CI.
- `.xlings.json` — the project tool environment (which mcpp version builds this).
- `mcpp.toml` — package metadata, dependencies, dev-dependencies.
- `src/mylib.cppm` — the library module interface.
- `tests/mylib_test.cpp` — a gtest suite matching the `mcpp test` conventions.
- `examples/basic/` — a standalone consumer package.
- `templates/` — project templates shipped with the library (`basic`, `lib`).
- `tools/template_smoke.sh` — renders and builds every template against this checkout.
- `.github/workflows/ci-{linux,macos,windows}.yml` — per-platform CI.

## Upstream

### The mcpp tool

- Repository: https://github.com/mcpp-community/mcpp
- Docs: https://github.com/mcpp-community/mcpp/tree/main/docs (Chinese under `docs/zh/`)
- Getting started: `docs/00-getting-started.md` · Examples: `docs/01-examples.md`
- `mcpp.toml` guide: `docs/05-mcpp-toml.md` · Workspaces: `docs/06-workspace.md`

Use these to confirm:

- the behavior of `mcpp build`, `mcpp test`, `mcpp run`, `mcpp new --template`;
- the inference rules for `src/*.cppm`, `src/main.cpp`, `tests/**/*.cpp`;
- `[dependencies]`, `[dependencies.<namespace>]`, `[dev-dependencies]`, target overrides.

### Index and ecosystem

- Package index: https://github.com/mcpplibs/mcpp-index · https://mcpplibs.github.io/mcpp-index/
- mcpplibs organization: https://github.com/mcpplibs
- Reference library — small and close to this template: https://github.com/mcpplibs/cmdline
- Reference library — templates, i18n, multi-module: https://github.com/mcpplibs/llmapi

Check the index before adding a dependency; read `cmdline`/`llmapi` when you want to see how a
real library is shaped. Import modules directly — do not `export import` a dependency from the
root module by default.

### Style

- mcpp-style-ref: https://github.com/mcpp-community/mcpp-style-ref
- Local copy: `.agents/skills/mcpp-style-ref/SKILL.md`

When writing or changing `.cppm` / `.cpp` files: `import std`, stable module names, a small
public API, and tests without a custom `main()`.

### Tool environment

- xlings: https://github.com/openxlings/xlings

This template pins its tools in `.xlings.json`. After entering the repository:

```bash
xlings install         # installs mcpp into the PROJECT environment (xlings install mcpp -g for global)
mcpp --version
```

## Common Tasks

- **Understand the template** → `README.md` and `docs/architecture.md`.
- **Confirm an `mcpp.toml` field** → `mcpp.toml`, the [`mcpp`](../mcpp/SKILL.md) skill, then upstream `docs/05-mcpp-toml.md`.
- **Add a dependency** → the [`mcpp-index`](../mcpp-index/SKILL.md) skill, then `mcpplibs/cmdline` for a real example.
- **Add a module API** → `mcpp-style-ref`, then edit `src/*.cppm`.
- **Add a test** → follow `tests/mylib_test.cpp`, verify with `mcpp test`.
- **Add an example** → follow `examples/basic/` — its own `mcpp.toml` with a path dependency.
- **Add or change a template** → `templates/<name>/`, verify with `bash tools/template_smoke.sh`.
- **Publish the library** → the [`mcpp-index`](../mcpp-index/SKILL.md) skill.
