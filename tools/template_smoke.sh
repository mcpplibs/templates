#!/usr/bin/env bash
# Compile-check every template in templates/ against the in-repo library.
#
# Renders each template the way `mcpp new` does ({{project.name}} /
# {{self.name}} / {{self.version}}), then swaps the generated version
# dependency for a *relative* path dependency on this checkout, so templates
# are verified before a release of this library exists in the package index.
# Relative on purpose: an absolute path would need TOML escaping on Windows.
#
# Usage: bash tools/template_smoke.sh   (requires mcpp on PATH, or $MCPP)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MCPP_BIN="${MCPP:-$(command -v mcpp || true)}"
if [[ -z "$MCPP_BIN" || ! -x "$MCPP_BIN" ]]; then
    echo "FATAL: set MCPP=/path/to/mcpp or put mcpp on PATH" >&2
    exit 1
fi

SELF_NAME="$(sed -n 's/^name *= *"\([^"]*\)".*/\1/p' "$ROOT/mcpp.toml" | head -1)"
SELF_VERSION="$(sed -n 's/^version *= *"\([^"]*\)".*/\1/p' "$ROOT/mcpp.toml" | head -1)"

# Stay inside the repo so the workspace mcpp pin (.xlings.json) still resolves
# the `mcpp` shim; target/ is gitignored. Depth is fixed, so every generated
# project reaches the library root at ../../..
TMP="$ROOT/target/template-smoke"
REL_ROOT="../../.."
rm -rf "$TMP"
mkdir -p "$TMP"

fail=0
for tdir in "$ROOT"/templates/*/; do
    tname="$(basename "$tdir")"
    proj="$TMP/smoke_$tname"
    mkdir -p "$proj"

    # render: strip .in, expand the placeholder vocabulary mcpp owns
    while IFS= read -r -d '' f; do
        rel="${f#"$tdir"}"
        [[ "$rel" == "template.toml" ]] && continue
        dest="$proj/${rel%.in}"
        mkdir -p "$(dirname "$dest")"
        if [[ "$f" == *.in ]]; then
            sed -e "s/{{project\.name}}/smoke_$tname/g" \
                -e "s/{{self\.name}}/$SELF_NAME/g" \
                -e "s/{{self\.version}}/$SELF_VERSION/g" "$f" > "$dest"
        else
            cp "$f" "$dest"
        fi
    done < <(find "$tdir" -type f -print0)

    # build against this checkout, not the (possibly unreleased) index version
    sed -i.bak "s|^\( *\)$SELF_NAME *= *\"[^\"]*\"|\1$SELF_NAME = { path = \"$REL_ROOT\" }|" \
        "$proj/mcpp.toml"
    rm -f "$proj/mcpp.toml.bak"
    grep -q "path = \"$REL_ROOT\"" "$proj/mcpp.toml" || {
        echo "FAIL: template '$tname' declares no '$SELF_NAME = \"...\"' dependency" >&2
        fail=1
        continue
    }

    echo "=== template: $tname ==="
    if [[ -f "$proj/src/main.cpp" ]]; then
        # a bin template: build AND run it
        (cd "$proj" && "$MCPP_BIN" run) || { echo "FAIL: template '$tname'" >&2; fail=1; }
    else
        (cd "$proj" && "$MCPP_BIN" build) || { echo "FAIL: template '$tname'" >&2; fail=1; }
    fi
done

if [[ $fail -eq 0 ]]; then
    echo "All templates compile."
fi
exit $fail
