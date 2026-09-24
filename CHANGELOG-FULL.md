# SCP: Continued Path

This list contains all features, added in the game, or will be added in upcoming version, that is in development.

## v10.3.0 (Day of the Deer God update)
### New SCP
- [x] SCP-2845
### Plugin API
- [x] Updated Mila to 2026.09.24 revision
  - [x] Mila now cannot use native functions for security reasons, so alternative functions implemented in the API.
### Other things
- [x] \[Thirdparty\] Remove beetle bot easter egg, due to change of that asset license.

## v10.2.6 (2026.09.21)

- Tried to fix missing torso bug and optimized shaders.

## v10.2.5 (2026.09.16)

- \[Feedback\] - Re-branded to SCP: Continued Path

## v10.2.4 (2026.08.30)

- \[Feedback\] Returned hints for Casual mode (enabled if Casual mode is unlocked or if is Lite/Web version)

## v10.2.3 (2026.08.30)

- Forced vertex shading on Web to improve performance.
- Fixed D-Girl animations distorting her body.
- \[Christmas\] Fixed SCP-649 crashing the game due to removed parameter.

## v10.2.2 (2026.08.29)

- Added D-Girl
- Plugin system's base `slang.gd`, was renamed \(again\) to  `Mila.gd`.
- Added class-defined tombstones instead of ragdolls.

## v10.2.1 (2026.08.23)

- Fixed error spam for some SCPs' signals.

## v10.2.0 (2026.08.22)
### Plugin API
- \[⚠️ Compatibility breakage!\] Plugin system's base `GOMPL`, was renamed to  `slang.gd`. File extension was changed to `.script` instead of `.gompl`. While custom scripts are automatically upgraded, builtin ones need manual file rename.
  - Bumped minimum version for built-in scripts to v10.2.0 (was v10.1.0). **Custom scripts are not affected to this change**, and still require 10.1.0 as a minimum version.

### Misc changes

- Optimized game size

## v10.1.1 (2026.08.22)

- Added new easter egg
- Make WC room in Storage Zone spawn.
- Optimize some lightmaps.
- Added link to support the author.

## v10.1.0 (2026.08.16)
### New and reworked SCP
- SCP-737
- SCP-939 refactor
- SCP-1507 refactor

### Plugin API expansion

- \[⚠️ Compatibility breakage!\] Implement mandatory API versions.
- Add status effect applying function
- Add get_all_items function
- Add go_to_target function, previously available for CI and MTF puppets
- NPCs can have more than 1 custom models again (was broken in 10.0.0)!

### Other changes

- Removed easter egg.
- SCP-173 now has more audio cues, one of them plays rarely. Find them!
- SCP-173 and SCP-939 now cannot kill SCP-131 instances and SCP-347, by specifying `team = 2048`
- Added version info in main menu
- Decreased camera far on Surface Zone only to 160.0 (was 192.0).
- Implement Sky as a setting, since not all PCs can run advanced sky, and that was default for 10.0
- \[Technical\] Deprecate `Settings.DATA_COMPATIBILITY` in favor of `Settings.get_game_version()`

## v10.0.0 (Initiation / Megarework update, 2026.08.14)
### Gameplay rework / Story mode
- Added support for timed tasks
- Added whole story
  - Added save system
- Remove hard mode
- Remove CI and MTF, re-introduce MTF Agent.
- Remove wave subsystem (until proper re-implementation)
- Day cycle and AAA-quality clouds
- Add door system
- Rework several rooms to support doors
  - New SCP-005 Containment chamber (in Maintenance Zone)
  - SCP-173 containment chamber
  - SCP-650 containment chamber
  - SCP-178 containment chamber
  - SCP-522 containment chamber
  - SCP-1507 containment chamber
  - Research Zone testroom
  - Research Zone endroom
- Add support for custom stories/DLCs.

### Plugin System
- Plugin System, based on GOMPL, a dialect of IMP Language
  - Add modding manager node (child of `Game` node), which auto-loads mods.
  - Add modding support to SkinnablePuppetScripts (or NPCs) (limited to static meshes)
- Added plugin installer (except Web platform)
- Added plugin uninstaller (only for Android currently)
- Added build flag for Web platform enabling support for custom SCP-261 and Plugin system (disabled by default due to security concerns)

### New Storage Zone
- Spun off *SCP: Echoes* rooms from Maintenance Zone to new zone
- Moved SCP-067, SCP-109, SCP-249, SCP-686, SCP-1223, SCP-2028 and SCP-5270 into Storage Zone, SCP-005 - in Maintenance Zone
- Added rooms for Story mode into that zone.

### Rework Personnel Zone
- Made it more comfortable for inhabitants.

### New SCPs
- SCP-079 (as a prop)
- SCP-181 (exclusively for Story mode)
- SCP-983
- Reworked SCP-261 to support translations.

### Reworked customized item system
- Reworked customized items system and SCP-5270

### Other changes
- Updated Maintenance Zone textures
- Rework setting presets for Android, Web and others.
- \[Web\] Remove lighting in Web by-default (you can revert this change in Settings, but it may affect performance)
- Fixed SCP-5270 being sad, even after using SCP-2306 if SCP-5270 was already used.
- Increased camera far on Surface Zone only to 192.0 (was 60.0).
- Updated toolbar icons.
- Fix crash with empty SCP-261.json cache file
- UI theme update
- Added easter egg.
- Reworked Credits system to use same base, as SCP-261
- SCP-023 will now activate in Story mode with 50% chance, in Casual mode it will be always dormant.
- Added support for moving via keyboard in third-person mode.
- Removed SCP-266, due to incompatibility with SCP article.
- Removed spoilers window.
- Removed SCP-938, due to strange bug. Awaiting rework...
- Removed SCP-446 in both Lite and Full versions.
- Removed rain in all seasons due to new sky performance impact.
- Sound rework
- Moved to Godot 4.7, thus breaking partial Windows 8.1 support.
  - Temporarily disabled RD renderers support due to https://github.com/godotengine/godot/issues/120534
  - Reverted to single-threaded pre-5.8.0 loader, due to https://github.com/godotengine/godot/issues/121124

## v9.1.3 (2026.06.28, ⚠️ Last version, that unofficially supports Windows 8.1!!!)

- \[PC only\] Fix cloud color to be more realistic

## v9.1.2 (2026.06.24)

- Fix documentation
- Fixed unused variables
- Moved Basement spawn next to the nearest door, since the only way to get there is SCP-249 door.
- New HUD icons
- Moved SCP-939 sublevel under elevator room to avoid Gate B overlap.
- Fixed item drop duplicating items in hand.
- Make *SCP: Echoes* corner in Maintenance Zone available to Lite/Web version.

## v9.1.1 (2026.06.23)

- Remove available beta features
- Limit Settings and spoilers window resize to minimum 32 pixels.

## v9.1.0 (2026.06.20)
- Allow to sideload characters (via GLTF) (supported ONLY for specific SCPs: SCP-131, SCP-173, SCP-650 and SCP-1507)
- Fixed Gate B elevator wrong rotation
- Fixed Gate B elevator being triggered by just spawned guard.
- Fixed SCP-131 (Unity edition) transparency

## v9.0.4 (2026.06.18)

- Updated credits
- Fixed SCP-1507 containment chamber and generic room1 navmesh + add boxes in latter room.

## v9.0.3 (2026.06.17)

- Removed remaining MTF Agent textures
- Fixed SCP-162 collider.
- \[Christmas\] SCP-080 Containment chamber: Add support for SCP-649 freeze.
- \[Halloween\] \[Christmas\] Improve decorations around facility.

## v9.0.2 (2026.06.16)

- Unify puppet models and ragdolls scale.
- Removed entirely remnants of SCP-347 task and MTF agent class... For now.
- Fixed SCP-347 being at the exit on Surface Zone could crash the game.
- Fixed elevator dialogue
- \[Main menu\] Fix game logo overlapping with seed input control
- \[Main menu\] Separated achievement UI from game configure one.
- \[Christmas\] Fixed SCP-649 not counting in achievement detection.

## v9.0.1 (??? patch, 2026.06.15)
- Add an easter egg.
- Update Credits.

## v9.0.0 (Multiverse update, 2026.06.15)
### Class system rework
- Different male scientists (thanks to OOD from SL Blender community)
- Add support for different skins
  - All humans
  - Skins can be either randomized or single, the latter is useful for SCPs (SCP-131 will use this).
  - SCP-023
  - SCP-131
  - SCP-173
  - SCP-347
  - SCP-650
  - SCP-939
- Re-implemented season outfits and remove legacy system from `BasePuppetScript`.
- Ragdolls were replaced with short-lived silhouettes.

### New and reworked SCPs
- SCP-080
- SCP-1507 (tied to a variation of Class-D)
- Added second variation of SCP-131 instance
- Optimized SCP-347 (which allowed to reintroduce in Lite/Web version), removed legacy mechanics completely and gave her a room (finally after a year of wandering)
- \[Christmas\] Fixed SCP-649 - increased cold damage and refactored snow spawn, making it easier for programmers to implement.

### Maintenance Zone expansion
- Import some open-source rooms from SCP Echoes, that fit the game style.
- Different door frames in Maintenance Zone

### Game progress system/achievement
- Added achievements for studying SCPs (not necessary the task one, and not all SCPs)

### Other changes
- Added sound effects for completing task and finishing game.
- All scientists are now bald because of new models limitation.
- \[Gameplay AI\] NPC will rotate to the item, while trying to take it.
- \[Lite version\] Completely removed remains of SCP-178-1, SCP-266 and SCP-938, and replaced to dummies.
- \[Debug Console\] \[Regionalization\] Replaced GDSh to [jitspoe's Godot Debug Console](https://github.com/jitspoe/godot-console/tree/master) to minimize legal troubles in some countries. Also Debug Console now won't work for Web.
- \[Halloween\] \[Christmas\] Update some legacy code to work on Halloween and Christmas (preparing for 2026 season)
- \[Surface Zone\] Use darker sky for all seasons, except Spring.
- \[Research Zone\] Updated generic endroom model.

## v8.1.1 (2026.05.30)

- Fix possibility of interrupting SCP-5270-2306 task by NPC scientist, when AI is enabled.
- Increased SCP-5270 using timer to 2.0 (was 1.0)

## v8.1.0 (2026.05.29)
### Inventory refactor
- Refactor inventory system to allow item's custom properties
- \[Debug shell\] Fix add_item command to include item 0 and items more than 14 (a mistake was made)

### New SCPs
- SCP-2306
- SCP-5270

### Other changes
- \[Lite version\] Remove remains of agent (part 2)
- \[Lite version\] Remove nonexistent SCP-983 label on Research Zone checkpoint
- Remove debug cube, left after 8.0 development

## v8.0.2 (2026.05.27)

- Elevators now have sound!
- SCP-131 instances are now smaller.

## v8.0.1 (2026.05.26)

- Update main menu theme to 1.1 version
- Use lower-quality SSAO.
- Hide SCP-131 glass to improve Web performance.
- Disable also Mobile renderer on Android
- Added money indicator

## v8.0.0 ("Expansion update part 4", 2026.05.25)
### Self-learning NPCs
- Self-learning NPCs (currently it affect only picking items)
  - Available for PC and Android, Web version is still experimental.

### Storage Sub-zone
- Storage sub-zone - a reduced Entrance Zone.

### New (and reworked) SCPs
- SCP-131
- SCP-261 (uses new windowed dialogues feature)
- SCP-2028
- SCP-2471
- Reworked SCP-812 task + added sounds.

### Rendering overhaul
- Restored SSAO (use fallback in Mobile and Compatibility (in Godot 4.5), else use native shader)
- Added experimental support for RenderingDevice renderers (PC only).
- Lighting overhaul - 3 lighting modes are available - disabled lights (fastest performance, but bad quality), lightmap mode (from older versions, moderate performance and available only in OpenGL renderer) and realtime (only Forward+, worst performance)
- 2 new shader subsystems - first is intended for advanced effects, the second is based on alpha channel and opeartyes with tint (such as Cold effect)
- Added support for different resolutions (even for large screens)
- \[PC only\] Added advanced sky shader for Surface Zone.

### Windowed dialogues
- Added dialogue support through windows

### Other changes
- Fixed SCP-1223 is showing images while it is removed from inventory.
- Fixed (finally) legacy code, that allowed to complete SCP-162, SCP-173 and SCP-266 tasks without Class-D
- Fixed Chaos Insurgent could not move after arrival to facility.
- Added second cafeteria in Personnel Zone
- Reworked Credits menu, using Hikkan approach.
- Reworked Main Menu and showcase Story mode UI as beta feature (also *something* moved in a new place - find it)
- Updated to Godot 4.5.3.rc.fixed, which fixes security issues.
- Enabled hunger mechanic to all modes, except Safe mode.
- Increased hunger and thirst meter drain
- \[Audio/music\] New Main theme (previous was dull and unfinished, made from scratch).
- \[Full version\] \[Tasks\] Added one more new SCP-914 experiment.
- \[Lite version\] Remove remains of MTF agent
- \[Lite version\] Added a helper collider to the bottom of small elevator to reduce falling-out-elevator problems.
- \[UI\] Rework Main Menu buttons
- \[Debug console\] Fixed spawn_npc and add_item commands accepting incorrect values ~~(and introduce new easter egg)~~
- \[Technical\] Items can now have toggleable or not effects - the only item, that is firing every time is SCP-1223.
- \[Technical\] Implemented combined health type for humans - you can heal, feed and drink by specifying -1 health_type.
- \[Technical\] Reworked ingame dialogue - SCP-067, 1223, 2028 and 2471 started to use new API.

## v7.0.7 (2026.04.26)

- SCP-173 will chase the first human it sees, so... it's now harder to clean SCP-173 chamber 🙂
- Added more sounds for SCP-173:
  - first sound plays when first human comes.
  - second sound plays when someone lefts SCP-173 vision.
- Added missing sound credits.

## v7.0.6 (2026.04.25)

- Updated SCP-458 model again.

## v7.0.5 (2026.04.20)

- \[Lite version\] Second SCP-005 instance now randomly spawns, if spawn room exists (in full version, only first instance is spawned due to presence of SCP-914-005 task)
- \[Web platform\] Fixed security issues with debug console.

## v7.0.4 (2026.04.19)

- \[Full version\] New task - SCP-914-005 cross-experiment (is treated separately from other 914 tasks - both tasks can spawn simultaneously)
- SCP-005 will always spawn, if it's spawn room exists
- Added second SCP-005 instance (only retrievable through SCP-914 or from debug terminal)
- \[Technical\] Added new backend for spawning items, defining array. SCP-173 is using this feature now.
- \[Technical\] \[Lite version\] Removed SCP-173 Lite class, SCP-173 is used instead (with new feature).
- Restore credits button (was accidently deleted at 6.1.0 release)

## v7.0.3 (2026.04.17)

- \[Map Generator\] Updated to v12.0.2

## v7.0.2 (2026.04.15)

- \[Map Generator\] Updated to v12.0.0
- Updated Maintenance Zone wall texture

## v7.0.1 (2026.04.10)

- Optimized animations.
- \[Web version only\] Restored tonemap settings, but only linear and Reinhardt tonemap can be applied on the Web.

## v7.0.0 ("Expansion update part 3", 2026.04.08)
### New zone
- New Personnel Zone.
- Some SCP changed their place:
  - SCP-266 is now in Maintenance Zone, instead of Research Zone.
  - SCP-446 and SCP-1223 are now in Personnel Zone instead of Maintenance Zone.
  - SCP-067 is now in Personnel Zone, instead of Research Zone.
- Re-introduce custom Scientist's offices.
- Increased max Reflection Probes amount (since there can be more than 64 rooms)

### New SCP
- SCP-018 (fun fact: it's item ID is 18th)

### Misc
- \[Web version only\] Tonemap settings are hidden, since they caused lags.
- \[Web version only\] disable ragdoll updating if it is persistent (used in SCP-446)
- Reworked Settings subwindow - now long infomation is hidden in foldable containers.
- \[Technical\] Player now spawns in NPC node - fixed inventory not working, while spawned outside Surface Zone.

## v6.1.0 ("Forgotten memories" update, 2026.03.30)
### New SCP

- SCP-1223 - first non-Series-1 SCP in the game.

### Misc changes

- \[Android\] Fix annoying keyboard bug.
- \[Full version only\] New better-quality SCP-914 room.
- SCP-939 cannot call elevator now (as well, as other NPC SCPs, except 178-1 and 347)🙂.
- Added queue for item status effects (used by SCP-1223)
- Added timer for item status effects
- \[Settings\] Add tonemap setting.
- Fixed collision in Maintenance Tunnel shelf.
- Fixed collision in Cafeteria room.
- Fixed WC noise shader go out of bounds in both zones.
- \[Technical\] Dialogues text will disappear automatically after 2 seconds.

## v6.0.3 (2026.03.23)

- \[Touchscreen / Android\] Fixed long-standing rare issue, when double tapping lead to soft lock.

## v6.0.2 (2026.03.22)

- Corrected translations to the current state of the game.
- Remove the strange message in Maintenance Zone tunnel. (it was useless)

## v6.0.1 (Emergency fix, 2026.03.21)

- Hid the strange message in Maintenance Zone tunnel.

## v6.0.0 ("Cleanlight update", 2026.03.21)
### Zone-wide update
- Revamped (again) Research Zone lighting.
- Fully reworked Maintenance Zone (all room models were made in 3 days🙂)
- Added new props to all available zones.

### Smarter NPCs
- NPCs can now call and ride elevators by themselves

### CI vs MTF event rework
- Now both spawn in Surface Zone. *Comment: previous behavior has deep roots down to SCP: Unstable Dimensions*
- Now have avoidance enabled by-default.
- Fixed bug, where Chaos Insurgent behaved as MTF.
- CI event will never activate on Hard Mode, because such event can make round impassable.

### Hard mode
- Time limited game became Hard Mode.
- Properly introduced hunger mechanic to Hard Mode.

### New SCP
- \[Full version only\] SCP-791 (with task)
- SCP-249 (with task)
- SCP-005 (mostly useless in this game, except ███-███)
- Made SCP-938 more lore-compliant.

### Optimizations
- Optimized SCP-458 model.
- Optimized light models
- Optimized some meshes' LOD, which means lesser polygons on screen.
- Rigid bodies and items now will freeze, when they are outside of vision capsule.
- \[Lite version only\] Removed SCP-983 item from Research Zone testroom due to high poly amount in a few pixels. (can still be spawned)
- Replaced shelf prop in Maintenace Zone due to high poly amount.

### Misc changes
- Added photomode, which just hides all UI.
- \[UI\] SCP-914 Refine button and elevator call button now hide these dialogues.
- Fixed possibility to get stuck in a wall (added fallback option, which is used for D-Class, CI and MTF).
- \[Task system\] Fixed rare bug, where one rejected task counts as two or more, leading to possibility to have 1 or no tasks at all.
- Fixed possibility to hold invalid item.
- Fixed "ghost item in hand" bug, where item remains in hand after removing item.
- Replaced blur shader in WC room in favor of noise shader.
- Updated and hidden Help - if you are not afraid of spoilers, type `spoilers` into `Seed` input.
- Updated lights in large maintenance hallway.
- Applied new doors for Surface Zone / Facility elevators
- Removed Entrance Zone due to poor implementation.
- Removed SCP-347 task and event.
- Updated SCP-686 texture: Replaced Bauhaus font with Sans Normalcy.
- Added Cafeteria room to Research zone with non-functional SCP-261 prop (planned for future)
- Fixed Surface / Facility environment transition resetting post-effects.
- Save 10 seconds of loading.
- \[Full version only\] Updated SCP-812 chamber to include SCP-791
- \[Lite version only\] Updated legacy SCP-812 chamber to include new lights.
- \[Lite version only\] SCP-347 is not available by-default, but still spawnable.
- \[Technical\] Added beta function API.
- \[Technical\] Item spawner rework (previously was *SCP: Unstable Dimensions* remnant, and spawned only in Maintenance Zone endroom) - Season spawner is based on this spawner now.
- \[Technical\] Organized assets and removed unused legacy ones.
- \[Technical\] Remove historical variables (one of them is dating back to *SCP: Unstable Dimensions*) to optimize the game.
- \[Technical\] Documented code
- \[Technical\] \[Lite version only\] Removed remains of Entrance Zone (which are kept in Full version for future reintegration)

## v5.8.3 ("Downgraded carpet", 2026.03.01)

- Downgrade to Godot 4.5 for more stability.\*
- Apply navigation map offset.
- Fixed GPU FPS being max value for platforms, where GPU FPS is not available.
- Fixed SCP-522 chamber position.
- Fixed SCP-938/939 hallway lightmap.
- Fixed ability to move inside shelves in SCP-939 sublevel.
- \[Technical\] Move SCP-522 model only to OriginalModels folder.\*\*

\*There are plenty issues for 4.6 on Godot Github, so SSAO in GLES3, which is 4.6 feature, should wait for a while, until 4.6 became more stable...

\*\* Since I made SCP-522 model, but not the textures (taken directly from SCP-Wiki), textures will be in External folder and model in Original folder.

## v5.8.2 ("Patched carpet" mini-update, 2026.02.27)
### Add code improvements from [Hikkan game, a non-scp story game by Yni](https://github.com/Yni-Viar/Hikkan)
- Loading Screen is now offloaded to Settings singleton
- Vectorized close buttons for \(now-forgotten\) Help and Settings section.
- Improved Hikkan easter egg, added in 5.8.0.
### Misc changes
- Improved UI interaction - camera now stops moving when inventory is opened.
- Improve elevator logic and fix broken SCP-938/939 elevators.
- Updated Map Generator to 11.3.5

## v5.8.1 (Emergency update, 2026.02.08)

- Fixed elevator bug (I hope completely)

## v5.8.0 ("Carnivorous Carpet" update, 2026.02.07)
### New SCP
- SCP-522 + task

### New mechanics
- Replaced (fake) Loading screen with a proper one.

### Lite version changes
- Reinstated SCP-162 and SCP-939 to Lite version.
- Reduced visible range to 60.0 (from 64.0) and fog max distance to 56.0 (from 60.0), reducing lag on Web platform.
- Removed SCP-266 and SCP-914 in Lite version (Lag issue)

### Misc changes
- Optimized game even more!
- Upgraded to Godot 4.6 + added SSAO setting.
- Fixed Web platform not using "Lowest" setting preset
- Now all SCP-914 tasks are treated as one (no more annoying 914-only rounds)
- SCP-266 fire is now (partly) computed on GPU.
- Partially fixed fall-out-from-elevator bug.
- Returned back on-screen buttons for non-touchscreen platforms.

## v5.7.3 (2026.01.23)

- \[Emergency fix\] Fix map generator unable to generate random layouts - updated to v11.3.3

## v5.7.2 (2026.01.23)

- Fixed (again) uselessness of specific seed.
- Fixed *SCP: Unity* variation of SCP-173 not spawning in generic mode.
- Increased edge connection margin because of rare scenarios, where rooms were not connected.

## v5.7.1 (2026.01.18)
- \[Map Generator\] Updated to 11.3.1
- Re-branded to SCP: Continued Procedures
- Updated 3D model of SCP-458
- Fixed "elevator escape" long-standing bug.
- \[Web only\] Fixed elevator working only to 1 direction

## v5.7.0 ("Mini update", 2026.01.09, last version under name SCP: Containment Procedures)
### Minified build profile
- Add Lite build profile
- Add Web support using Lite profile.
### New features
- Now you can safely disable Reflection probe setting if there is not much performance - implemented fallback mechanism.
### Other changes
- port SCP-650 bugfix from 6.0
- Update map generator to 11.1.0
- Fix Surface Zone not having fog.

## v5.6.5 (2025.12.31)
- Updated NavMeshes - fixing noclip bugs.
- Extended Christmas season to January 3rd.

## v5.6.4 (2025.12.31)
- Fixed Entrance Subzone unloading, when player moves to the end of personnel offices.

## v5.6.3 (2025.12.25)
- Fixed Gate B Christmas decorations

## v5.6.2 (2025.12.23)
- \[Clutter system\] Ragdolls are now affected to Clutter System.
- Reduced scale of SCP-347.

## v5.6.1 (2025.12.23)
- \[Clutter system\] Use clutter system for Class-D pumpkin, instead of using specific script for handling that.
- Reduced scale of humans due to being too large (all human classes except of Agent and SCP-347)
- Added HLOD to Agent.

## v5.6.0 (Winter solstice 2025 update, 2025.12.21)
### Add season spirit to current puppet classes
- Add skins to most of puppet classes (except SCP-173 (because they already have randomization and Christmas face), SCP-178-1, SCP-650 (they have only Christmas skin) and SCP-938)
### New features
- SCP-266 VFX overhaul.
- Agents now have a visual flashlight on their vest.
- Began AI rework - add SCP-939 (and Scientists since 5.6.0) style of wandering to MovableNpc *Yni Viar's comment: originally, it was 6.0 feature, but I decided to do it for 5.6*
- Researchers no longer spawn in Entrance subzone
- Added slight-visible doors for Research Zone (Maintenance Zone have doors since 5.5.0)
### Bugfixes
- Fix CI event crash - also change CI logic.

## v5.5.1 (2025.12.16)

- Fix credits tab being out of bounds

## v5.5.0 (Cold as Ice update, 2025.12.15)
### New SCPs
- SCP-939 (actually, a Christmas gift 🙂) + Amnesia status effect + Task
- SCP-649 (will spawn only at December (for Christmas))
### New features
- Add interactable props
- New Maintenance Zone rooms: Warehouse and testroom. Find it out!
- Added ventilation for Maintenance Zone
- Snow on surface or in facility (for SCP-649)
- SCP-173 has now in-house movement sound
- Chaos Insurgency now spawns once per game.
- Guards now do not spawn at Surface Zone at Halloween and Christmas
- Reworked clutter system - now it has simple API + added ability for season-only prefabs.
- Checkpoints now contain information about actual SCPs in the facility.
- Updated map generator to 9.1.2 and require doors spawn for Maintenance Zone
### Bugfixes
- Fixed third-person camera position
- Reduce Christmas tree amount because of optimization
- Make sure, that Status Effect is correctly unloaded.
- Remove placeholder SCP-178-1 sprites
- \[Technical\] ResourceStorage: support dictionaries inside Resource.
- \[Technical\] StatusEffectCommand: support player-only status commands

## v5.3.5 (2025.11.23)

- Same as 5.3.4, but use custom Godot build because of security issues.

## v5.3.4 and v5.4.2 (2025.11.17)

- Display GPU FPS to determine real FPS (used from Godot Engine code)
- Fix rz_exit1_gatea model.

## v5.3.3 (2025.11.16)

- backport changes from 5.4.1 to 5.3.x

## v5.4.1 (2025.11.14)

- Fixed some Research Zone rooms having different door sizes.
- Changed room spawn order in Research zone - instead of having too much Class-D chambers, they become mandatory to spawn and become single.

## v5.4.0 (2025.11.14)

- **Re-bake lightmaps with custom Godot build to increase quality of graphics**

## v5.3.2 (2025.11.13)
- Make christmas lights have random color
- Add lightmap to Entrance zone.
- Add seasonal clutter to SCP-266 and Class-D containment chamber and unused testroom (both Halloween and Christmas ones)

## v5.3.1 (2025.11.11)
- Fixed testroom texture.
- Fixed SCP-914 position.
- Added Christmas decoration to SCP-162 chamber.
- Fixed a typo in RagdollManager.

## v5.3.0 - (? update, 2025.11.09)
### New SCP
- SCP-446
### ? changes
- Clutter system - finish Christmas decorations.
- Where did Octobergine Avo go?
- Added falling snow VFX for Christmas season, make rain VFX available on all regular seasons, except Halloween and Christmas.
### Bugfixes and other
- Added footstep sounds to Guard, Agent and Chaos Insurgent.
- Fixed hole in the wall in some Research Zone rooms. 

## v5.2.1 (2025.11.06)
- Fix duplicate item click. (this commit was made on Android editor 🙂)
- Fix crash when removing an invalid status effect (reproducible at 5.2.0 by using SCP-067 too fast).
- Add lore to SCP-067 + new mechanic to the game.

## v5.2.0 (2025.11.05)
### New SCP items
- SCP-067 + task
- SCP-178 (WANTED 3D MODEL FOR SCP-178-1)
### Cutscene system (used by SCP-067)
- Added cutscene and dialogue system
### Bugfixes and other
- Fixed possibility on crash by adding out-of-bound item id.
- Fixed documents falling through floor
- Fixed MTF error spam due to missing animation
- Bugfix: clicking on the item in the Inventory, click ALL the items...
- Implemented removing status effects
- Now you cannot enter Scientists' offices (again)


## v5.1.3 (Hotfix, 2025.11.02)
- Fix first-start crash (a regression from 5.0.0)
- \[Technical\] Update map generator to 9.1.1 to improve performance

## v5.1.2 (2025.10.30)
- Make walk and interact sound louder.
- Fixed SCP-173 not crunching + not playing a sound.

## v5.1.1 (2025.10.29)
- Fix Credits being too wide

## v5.1.0 (2025.10.29)
### New SCP items
- SCP-686 (3d model borrowed from pop_pop_icard, a family-friendly implementation)
- SCP-458
### Status effect system
- Add thirst and hunger indication
- Make Freeze effect in StaticPlayer a StatusEffect
- Status effect system
### Bugfixes and other
- Fix item duplication bug
- \[Technical\] Health system now uses that order: 0 - general health, 1 - cold, 2 - thirst, 3 - hunger meters. SCP-266 was modified to use new system.

## v5.0.2 (2025.10.22)

- Add Halloween props in SCP-162 and SCP-173 CC.
- Add second check on SeasonSwitcher
- Fix SCP-938 CC elevator lightmap brightness.

## v5.0.1 (2025.10.21)

- Fixed serious visibility bug on Surface Zone

## v5.0.0 (Expansion update part 2, 2025.10.21)
### New SCP - SCP-938 with Containment Sublevel
- Lantern item
### New features
- Added clutter system + Halloween (and partly Christmas) decorations
- Expose Gate A
- Add ragdolls to humans (except SCP-347 and Site Director)
- Surface Zone for Gate B and C (SZ and elevators are borrowed from pop_pop_icard).
- Expose Gate B
- CB-styled doors (for elevators)
- Remake Gate C room
- Camera Rework: Enable hotkeys for moving - looks like, that camera rotation is not so easy.
- Camera Rework: Add Third-person view + toggle API and remove scroll zoom
- Keybind settings (FINALLY DONE!!!)
- Add "real" weapon to Mobile Task Force, Agents and Chaos Insurgency
- Rework item usage to a safe method caller
- Add hunger and thirst HP layers to humans (currently unused)
- Add props to Class-D room
- Add Settings to Main Menu
- Apply Glow and ReflectionProbe for all platforms (previously, Web and Android platforms had this setting disabled)
- Moved to POT translation file instead of CSV, making translation to other languages easier.
- Added special interact support for NPC ~~(you can see this new system with SCP-023 - click on it to repair it's eyes).~~ Also removed `automatic` flag.
- Moved Inventory to Puppet from Game UI - separated inventories are good for future multiplayer
- SCP-109 and 983 Containment Chamber (Instead of regular Testroom)
- Upgrade to Godot 4.5, and thus remove Windows 7/8.0 support (see https://yniviar.neocities.org/blog_september-2025-news)
### General fixes and small enhancements
- Added fake loading screen.
- Inventory button is now hidden, if there is no touchscreen (click Tab buttton to open your inventory)
- Add debug console
- Better organize Main Menu
- Add more Scientists spawns in Research Zone
- Enable SCP-023 in Safe mode (through it will just walk around).
- You cannot enter WC now (because of possible *strange situations*)
- Removed old lighting hack from non-lightmap era.
- Removed time scale after finish game
- Fixed situation, where NPCs following player, that went to SCP-162, were playing "walk" animation, while stay.

## v4.3.0 (2025.08.23, **⚠️ Last version, that natively supports Windows 7-8.0!!!**)

- Added WC rooms for Maintenance and Research zones.
- Returned fully-functional SCP-109 - it can be used as healing item, due to new API. ~~Use the cube in SCP-914 to make it with 33% chance.~~
- Changed texture to Research Zone ceiling (except 914 room).

## v4.2.0 (2025.08.20)
- Improve Maintenance Zone graphics.

## v4.1.0 (2025.08.19)
- Add omnidot plush to Yni Viar's room
- Remove omnidot plush from items and replace with Knitted sphere
- Reduce amount of Scientist to match personnel offices amount.
- Add new SCP Cage prop (my model, that was reused from SCP: Site Online) - spawns on Gates A and B.
- Added more light to SCP-914 room - because SCP-914 was too dark.

## v4.0.0 (Expansion update part 1, 2025.08.18)
- Elevator support
- New sublevel (Entrance subzone) with researcher's offices and exit to new Research Zone room
- Added scriptable researcher's offices + add Yni office (with returned Internal Eternal easter egg)
- Added Site Director Octobergine Avo + office.
- Changed protagonist's spawn point.
- Moved SCP-347 task to Maintenance Zone Gate B.
- Main Menu UI refresh
- Fixed annoying bug on Android, when if you rotate screen, player began to move. (FINALLY!!!)
- Added new human class - Agent. (currently looks like SCP: Unity guard)
- Fixed navigation mesh connection between rooms
- Added second SCP-173 variation - the model will be randomly selected at the round start (between original and SCP:Unity model)
- Added new Main Menu theme.
- Improved Research Zone graphics.

## v3.1.0 (2025.08.02)

- Removed SCP:SL pre-14.0 rooms entirely because of licensing issues.
- Added a tint to Credits screen

## v3.0.0 (2025.08.01)

- Reworked existing Maintenance zone (room3_pit will be temporarily removed)
- Added modified SCP: SL pre-14.0 rooms as an easter egg for Maintenance Zone. (removed in 3.1.0 because of licensing issues)
- Reduced human classes and SCP-347 size to fit into a new Maintenance Zone
- Really added an ability to disable music
- SCP-023 containment chamber in Maintenance Zone (both regular and SL version (latter was removed in 3.1.0 because of licensing issues))
- SCP-023 NPC + task.
- Added disarmer for SCP-914 craft (unusable, need to refine cube on Very Fine).

## v2.0.2 (2025.07.23)

- Updated Credits list.

## v2.0.1 (2025.07.22)

- Increase optimization on Android by reducing visible area
- Scientists at SCP-650 containment chamber now have IK disabled (previously they looked strange)
- You cannot pick-to-follow MTFs, Chaos Insurgency, hostile SCPs and scientists at SCP-650 chamber
- Labels at checkpoints are supporting translations!
- Made color of SCP-812 waterfall more realistic
- Tried to fix bug, where Chaos Insurgency event was not called if there was SCP-347 MTF task.
- Disabled Glow and Reflection probe on all of Android

## v2.0.0 (2025.07.21)

- SCP-914 and new tasks.
- Various items
- Maintenance zone re-introduction (previously being hidden in 1.0.0 files)
- Checkpoints between zones.
- Items and NPC are now picked by ShapeCast
- Removed Internal Eternal easter egg - since Internal Eternal Demo 1 already includes this toy.
- ~~Added ability to disable music~~ Was not working until 3.0.0, because only button toggle was implemented.

## v1.0.0 (2025.06.09)
- Android support
- SCP-162
- SCP-173
- SCP-266
- SCP-347
- SCP-650
- SCP-812
- Foundation tasks and gameover
- Chaos Insurgency event, MTF call + exit