# Architecture

> A minimal mcpp C++23 module library template.
> [English](architecture.md) · [简体中文](architecture.zh.md) · [繁體中文](architecture.zh.hant.md)

## Goal

The repository expresses four things and nothing more:

- `.xlings.json` declares the project tool environment (which mcpp version builds this).
- `mcpp.toml` declares the C++23 module library and its test dependencies; runtime
  dependencies are added as needed.
- `templates/` declares the project templates the library ships to its users.
- `mcpp build`, `mcpp test`, `mcpp run` verify the library, the unit tests and the example.

## mcpp Conventions

- Sources are globbed from `src/**/*.{cppm,cpp,cc,c,S,s,asm}` by default.
- With `src/*.cppm` and no `src/main.cpp`, mcpp infers a **lib** target named after the
  package (`Inferred target mylib (lib from .cppm in src/)`). Write `[targets.<name>]`
  explicitly only when you need to override that.
- The lib-root module defaults to `src/<last segment of the package name>.cppm`; `[lib] path`
  overrides the location.
- Dependencies go in `[dependencies]` or `[dependencies.<namespace>]`; test-only ones go in
  `[dev-dependencies]` (`mcpp build` ignores those — only `mcpp test` resolves them).
- Unit tests live in `tests/**/*.cpp` and are discovered by `mcpp test`, one binary per file.
  Test files contain `TEST(...)` cases only — never their own `main()`.
- The default build profile is `dev` (`-O0 -g`); `mcpp build --release` produces the optimized
  build. The C++ standard defaults to `c++23` and belongs in `[package] standard`, never in
  `cxxflags`.
- `mcpp.lock` is not committed here: it is a library, so the versions that matter are the
  consumer's. Applications generated from `templates/` may want to commit theirs.

## Layout

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
│   ├── basic/                # default template: console app
│   │   ├── template.toml
│   │   ├── mcpp.toml.in
│   │   ├── src/main.cpp.in
│   │   └── .gitignore
│   └── lib/                  # downstream module library + gtest
│       ├── template.toml
│       ├── mcpp.toml.in
│       ├── src/lib.cppm.in
│       └── tests/lib_test.cpp.in
├── tools/template_smoke.sh
└── .github/workflows/{ci-linux,ci-macos,ci-windows}.yml
```

## The Root Package

```toml
[package]
namespace = "mcpplibs"
name      = "mylib"
version   = "0.1.0"

[dev-dependencies]
gtest = "1.15.2"
```

Every package has a two-part identity: a **namespace** and a **name**. `namespace = "mcpplibs"`
plus `name = "mylib"` means consumers write `mylib = "0.1.0"` under `[dependencies.mcpplibs]`
(or as a bare name — `mcpplibs` is the default namespace mcpp searches first).

`src/mylib.cppm` exports the module `mcpplibs.mylib`. It re-exports nothing: a dependency is
imported where it is used, not forwarded through the root module, unless the public API
genuinely exposes that dependency's types.

## Adding Dependencies

Declare the dependency in the root `mcpp.toml`:

```toml
[dependencies.mcpplibs]
cmdline = "0.0.2"
```

and import it where you need it:

```cpp
import mcpplibs.cmdline;
```

`export import` is not the default. Only re-export when your public API hands out types that
belong to the dependency.

## The Example Package

`examples/basic` is a standalone mcpp package that consumes the root library through a path
dependency:

```toml
[dependencies.mcpplibs]
mylib = { path = "../.." }
```

Run it:

```bash
cd examples/basic
mcpp run
```

It exists to prove the library is usable *from the outside* — with its own manifest and its own
resolution — which importing from `tests/` cannot show.

## Templates

`templates/<name>/` is how a library ships project scaffolds to its users:
`mcpp new myapp --template mylib` renders one into a new project, and the template version
tracks the library version automatically.

- `template.toml` — `description`, at most one `default = true` across all templates, and an
  optional `post_message` printed after generation. It is metadata; it is never copied.
- `*.in` — rendered, then the suffix is stripped. Placeholders: `{{project.name}}`,
  `{{self.name}}`, `{{self.version}}`.
- Everything else — copied verbatim.

Templates are pure data: mcpp renders and copies, and runs no hooks or scripts. File *names*
are not rendered, only file contents — that is why the `lib` template ships `src/lib.cppm` and
points `[lib] path` at it instead of relying on the `src/<package name>.cppm` convention.

If a rendered `mcpp.toml` does not declare a dependency on the shipping library, mcpp injects
one; the templates here declare it explicitly via `{{self.version}}`, so nothing is injected.

`tools/template_smoke.sh` renders every template the way `mcpp new` does, repoints the
dependency at this checkout (so templates are verified before a release exists in the index),
then builds it — and runs it when the template produced a binary.

## CI

Three workflows, one per platform (`.github/workflows/ci-{linux,macos,windows}.yml`), each
running the same path a new user walks:

```bash
xlings install -y        # project-env mcpp, at the .xlings.json pin
mcpp build
mcpp test
cd examples/basic && mcpp run
bash tools/template_smoke.sh
```

Splitting per platform keeps one badge and one log per OS, so a macOS or Windows regression
cannot hide behind a green Linux run.
