## Development

### Requirements to build

The project uses Godot 4.7.x as a base (since 10.0 - Megarework update).
Godot 4.5 is no longer supported anymore since 10.0 - Megarework update.
Godot 4.4 is no longer supported anymore since 6.0 - Cleanlight update.

> Godot 4.6 was used in 5.8.0-5.8.2

### Building regular version

1. Project->Export
2. Choose your platform (e.g. Windows/Linux/Android)
3. Navigate to Resource tab and type in "Filter to exclude files/folders": `*.glb, *.gltf, Assets/*.bin, */Lite/*`. You may also want to add `, *.ico` to that filter, if you are not building for Windows.
4. (Optional) You can also navigate to Resource tab and type in "Filters to export non-resource files/folders": `*.zip` - used by Hikkan easter egg.


### Feature flags
#### Building lite version (for Web)
**In Lite version, some components are missing:**
There are no SCP-080, SCP-178 (item exists, but has no effect), *SCP: Unity* SCP-173 model, SCP-266, SCP-791, SCP-914, SCP-938.
1. Project->Export
2. Choose your platform (e.g. Web)
3. Navigate to Resource tab and type in "Filter to exclude files/folders": `*.glb, *.gltf, Assets/*.bin, */Optional/*, res://Stories/*`. You may also want to add `, *.ico` to that filter, if you are not building for Windows.
4. Navigate to Features tab and type in "Custom (comma separated)": `Lite`
5. (Optional) You can also navigate to Resource tab and type in "Filters to export non-resource files/folders": `*.zip` - used by Hikkan easter egg.

## Contributing

You can:
- Report a bug.
- Suggest a new SCP object (before you suggest, see [suggestion rules](./SUGGESTING-IDEAS.md))
- Suggest an own model for replacement of existing one. (e.g own SCP-023 model instead of bad quality 3-rd party one, or own SCP-178-1 model).
- Suggest an own audio (SFX, music) for addition/replacement into the game

### Folder structure

- 📁 All Lite folders are used ONLY by Lite/Web version
- 📁 All Optional folders are used by Full version


- 📁 Assets - Here is a place for most assets, excluding items and NPCs.
   - 📁 Doors - Here is a place for all doors
   - 📁 Environment - Here is a place for all environments
   - 📁 ExternalModels - Here is a place for most third-party props, models, textures...
      - 📁 SCPs - Here is a place for all third-party open-source assets from SCP games
   - 📁 Fonts - Here is a place for all fonts
   - 📁 HUD - Here is a place for first-party HUD textures
   - 📁 MakeHumanModels - Used only for SCP-446
   - 📁 Materials - Here is a place for common materials to quickly apply
   - 📁 OriginalModels - Here is a place for most first-party props, models, textures...
   - 📁 RoomAssets - A temporary folder, used when adding new room. Should remain empty with readme.md
   - 📁 Rooms - Here is a place for all room prefabs
      - 📁 room1 - Here is a place for all endrooms
      - 📁 room2 - Here is a place for all hallways
      - 📁 room2c - Here is a place for all corners
      - 📁 room3 - Here is a place for all intersections
      - 📁 room4 - Here is a place for all crossrooms
      - 📁 ScientistRooms - Here is place for all Scientists' rooms. Managed by Yni - repository's owner.
      - 📁 sublevels - Here is a place for all static sublevels
   - 📁 VFX - VFX stuff.
- 📁 Inventory - Here is a place for inventory and items
- 📁 MapGen - Map generator module
   - 📁 Resources - Here is a place for all room resources for map generator
- 📁 PlayerScript - Here is a place for all NPCs
   - 📁 PlayerClassPrefab - Here is a place for all NPC prefabs
      - 📁 Variations - Here is a place for all variable NPC models
   - 📁 PlayerClassRagdoll - Here is a place for all NPC ragdolls
   - 📁 PlayerClassResource - Here is a place for all NPC resources for registry
   - 📁 PlayerClassScript - Here is a place for all NPC-related code
- 📁 Scenes - Here is a place for all game scenes (such as Game, Menu, etc)
- 📁 Scripts - Here is a place for the most code
   - 📁 ElevatorSystem - Here is a place for the elevator stuff
   - 📁 GameData - Here is a place for the game registry
   - 📁 GDShaderCompositor - Here is a place for the GDShaderCompositor, which manages shaders
   - 📁 Interactables - Here is a place for the interactive stuff (e.g. item)
   - 📁 PluginSystem - Here is a place to custom plugin subsystem (here custom plugin validator is stored)
   - 📁 Scps - Here is a place for mostly static SCPs, such as SCP-249
   - 📁 Seasonal - Here is a place for the season stuff
   - 📁 SettingResource - Here is a place for the settings file and it's presets
   - 📁 StatusEffects - Here is place for status effect system and effect resources
   - 📁 TaskSystem - Here is a place for the in-game quests
   - 📁 Triggers - Here is a place for the triggers via Area3D
- 📁 Shaders - Here is a place for all shaders
   - 📁 OverlayMaterials - Here is a place for shader materials and GDShaderCompositor resources
   - 📁 OverlayShaders - Here is a place for GDShaderCompositor shader includes
- 📁 Sounds - Here is a place for all sounds
   - 📁 Character - Here is a place for NPC-related sounds
   - 📁 Environment - Here is a place for room/sublevel based sounds
   - 📁 Item - Here is a place for item-related sounds
   - 📁 Music - Here is a place for all music
- 📁 Stories - Here is a place for Stories and/or DLCs
- 📁 Translations - Here is a place for gettext translations
- 📁 UI - Here is a place for most 2D UI assets