# Plugin System

Plugin system allows to customize SCP: Continued Path via code.

You can create either new NPCs, or customize existing ones.
> You can customize only SCP-131, SCP-173, SCP-650, SCP-737 or SCP-1507
> Several API functions are not supported in built-in puppets.

**⚠️ Attention to Windows users - Make sure your plugin scripts use LF as end-of-line**
> Default Windows CRLF will cause errors in your script.


## Where custom plugins are stored?
### Custom plugins (for new NPCs)

Windows - `%APPDATA%\\SCPContPr\\mods\\puppets\\custom\\`

^nix/Linux - `~/.local/share/SCPContPr/mods/puppets/custom/`

### Builtin plugins (or built-in NPCs)

Windows - `%APPDATA%\\SCPContPr\\mods\\puppets\\builtin\\`

^nix/Linux - `~/.local/share/SCPContPr/mods/puppets/builtin/`
