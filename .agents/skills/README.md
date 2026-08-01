# mcpplibs template — Agent Skills

Skills that help an agent understand this mcpp/mcpplibs module-library template, look things up
upstream, and follow the mcpp-style-ref rules when writing or reviewing Modern/Module C++.

## Available Skills

| Skill | Contents |
|------|------|
| [mcpp](mcpp/SKILL.md) | The mcpp build tool: commands, `mcpp.toml` fields, project conventions, shipping `templates/` |
| [mcpp-index](mcpp-index/SKILL.md) | The package index: finding dependencies, namespace rules, publishing this library |
| [mcpp-style-ref](mcpp-style-ref/SKILL.md) | Modern/Module C++23 naming, module organization and practice rules |
| [more-details](more-details/SKILL.md) | Where to look things up — this repository, mcpp docs, the index, reference libraries, xlings |

Start with `more-details` when you do not know where something lives; use `mcpp` and
`mcpp-index` for tool and packaging questions; use `mcpp-style-ref` whenever you touch
`.cppm` / `.cpp` files.

## Usage

To use them in Cursor, symlink or copy the skills into the project's `.cursor/skills/`:

```bash
mkdir -p .cursor/skills
for s in mcpp mcpp-index mcpp-style-ref more-details; do
    ln -s "../../.agents/skills/$s" ".cursor/skills/$s"
done
```

Or install them as personal skills:

```bash
ln -s /path/to/mcpp-template/.agents/skills/mcpp ~/.cursor/skills/mcpp
```

Claude Code and other agents that read `.agents/skills/` pick them up from this directory
directly.
