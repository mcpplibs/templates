---
name: mcpp-index
description: Find, add and publish mcpp packages through mcpp-index (the default package index). Use when looking up a dependency, resolving a "package not found" error, choosing a namespace, or publishing this library to the index.
---

# mcpp-index

[mcpp-index](https://github.com/mcpplibs/mcpp-index) is the default package index for mcpp:
one `pkgs/<initial>/<name>.lua` descriptor per package. Browse it online at
**https://mcpplibs.github.io/mcpp-index/**.

Two kinds of packages live there:

- **Native mcpp module libraries** (`mcpplibs.*`, `nlohmann.json`, `imgui`, `opencv`, …) — the
  upstream repository carries its own `mcpp.toml`, so the descriptor (**Form A**) declares only
  metadata and a download address. **A library built from this template is Form A.**
- **Third-party C/C++ libraries** under the `compat` namespace — upstream has no mcpp support,
  so the descriptor (**Form B**) inlines the build information.

## Consuming: Finding and Adding a Dependency

```bash
mcpp search <keyword>          # search the index (also refreshes it)
mcpp add <pkg>[@<version>]     # write the dependency into mcpp.toml
mcpp build                     # fetch and build; dependencies propagate along the chain
mcpp index list|add|remove|update   # manage registries
```

Package identity is a pair: **`namespace` is a dotted hierarchical path, `name` is a single
atomic segment** (`compat` + `zlib`, `mcpplibs.capi` + `lua` — never `mcpplibs` + `capi.lua`).

A **bare** dependency name resolves in exactly three places, in order:

1. `mcpplibs` — the default namespace
2. `compat` — third-party C/C++ wrappers
3. packages that declare no namespace at all

Anything else must be spelled out — there is no index-wide fuzzy search by short name:

```toml
[dependencies]
"chriskohlhoff.asio" = "1.38.1"     # dotted selector

[dependencies.chriskohlhoff]        # or a namespace sub-table
asio = "1.38.1"
```

When resolution fails: read the error (it lists the namespaces searched), then check the
spelling against the online index, and run `xlings update` — a release tarball bundles an
index snapshot frozen at build time, which is the usual reason a fresh version "does not
exist".

Mirrors: `mcpp self config --mirror CN` switches to the GitCode mirror; `GLOBAL` (upstream) is
the default.

## Publishing This Library to the Index

```bash
mcpp publish --dry-run      # package a tarball, hash it, print the descriptor, upload nothing
mcpp emit xpkg -o mylib.lua # descriptor only, no packaging
```

`--dry-run` prints the remaining steps with the project's real URLs filled in:

1. Tag and push — `git tag -a v<version> -m "v<version>" && git push --tags`
2. Attach `target/dist/<name>-<version>.tar.gz` to that GitHub Release
3. Open a PR to mcpp-index adding `pkgs/<initial>/<name>.lua`

Before opening the PR, confirm `[package]` in `mcpp.toml` carries an accurate `namespace`,
`name`, `version`, `description`, `license` and `repo` — the descriptor is generated from
those fields, and a `repo` still pointing at the template is the classic mistake.

The index's CI (`validate.yml`) lints every descriptor, checks the GLOBAL/CN mirror tables,
and builds a small test project per package on three platforms. Reproduce the lint locally
with `mcpp xpkg parse pkgs/<initial>/<name>.lua`.

## Writing a Descriptor by Hand

For anything beyond a generated Form A descriptor — a `compat` wrapper, features, a CN mirror,
multiple majors in one package — follow the index's own end-to-end procedure rather than
improvising:

- Skill: [`add-mcpp-index-package`](https://github.com/mcpplibs/mcpp-index/blob/main/.agents/skills/add-mcpp-index-package/SKILL.md)
- [docs/package-types.md](https://github.com/mcpplibs/mcpp-index/blob/main/docs/package-types.md) — descriptor templates for the four library shapes
- [docs/repository-and-schema.md](https://github.com/mcpplibs/mcpp-index/blob/main/docs/repository-and-schema.md) — layout, schema cheat-sheet, `[indices]` redirection, CI behavior
- [docs/cn-mirror.md](https://github.com/mcpplibs/mcpp-index/blob/main/docs/cn-mirror.md) — the GitCode CN mirror loop and its fallback
- Chinese versions of all three live under [`docs/zh/`](https://github.com/mcpplibs/mcpp-index/tree/main/docs/zh)

Upstream mcpp is authoritative for the descriptor field specification; the index docs are
authoritative for repository conventions and the contribution flow.
