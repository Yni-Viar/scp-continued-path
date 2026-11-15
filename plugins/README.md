# Plugin System

Plugin system allows to customize SCP: Continued Path via code.

Currently, only creating new NPCs is supported, modifying existing ones is no longer supported after v10.6.1

**⚠️ Attention to Windows users - Make sure your plugin scripts use LF as end-of-line**
> Default Windows CRLF will cause errors in your script.


## Where custom plugins are stored?
### Custom plugins (for new NPCs)

Windows - `%APPDATA%\\SCPContPr\\mods\\puppets\\custom\\`

^nix/Linux - `~/.local/share/SCPContPr/mods/puppets/custom/`

### built-in NPCs (you can change only their model)

Windows - `%APPDATA%\\SCPContPr\\mods\\puppets\\builtin\\`

^nix/Linux - `~/.local/share/SCPContPr/mods/puppets/builtin/`
