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