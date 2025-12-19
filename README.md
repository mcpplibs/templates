# mcpplibs templates

mcpplibs templates...

`src/templates.cppm`

```cpp
module; // 0 - global module declaration

// 1 - include & macro area
// #include <stdio.h>

// 2 - module declaration
export module mcpplibs.templates;

// 3 - import area
import std;

// 4 - module implementation partition
namespace mcpplibs {

    // 5 - exported entities
    export void hello_mcpp() {
        std::println("hello mcpp!");
    }

}  // namespace mcpplibs
```

`tests/main.cpp`

```cpp
// 6 - import module
import mcpplibs.templates;

auto main() -> int {
    // 7 - call exported function
    mcpplibs::hello_mcpp();
}
```

## Install & Config

```bash
xlings install
```

## Build & Run

**Using xmake**

```bash
xmake build
xmake r
```

**Using CMake**

```bash
cmake -B build -G Ninja
cmake --build build
./build/tests
```

## Other

- [入门教程: 动手学现代C++](https://github.com/Sunrisepeak/mcpp-standard)
- [mcpp | 现代C++爱好者论坛](https://forum.d2learn.org/category/20)
- [mcpp-community | 现代C++爱好者社区](https://github.com/mcpp-community)
- [d2learn社区](https://github.com/d2learn)