add_rules("mode.release", "mode.debug")

set_languages("c++23")

target("mcpplibs-templates")
    set_kind("static")
    add_files("src/templates.cppm", { public = true, install = true })

target("tests")
    set_kind("binary")
    add_files("tests/main.cpp")
    add_deps("mcpplibs-templates")
    --set_policy("build.c++.modules", true)