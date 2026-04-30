# Project Overview

This is a Godot Engine 3D game project, version 4.6, using the Jolt Physics engine. The game's internal name is "fart balls game chud evil".

The core gameplay revolves around launching a "White Ball" from a "Cow" into a 3D environment populated with various types of pegs (blue, orange, green). The objective appears to be hitting orange pegs to complete levels, while managing a limited number of balls.

## Key Components:

*   **`project.godot`**: The main configuration file for the Godot project.
*   **`GameManager.gd`**: This script (`extends Node`) manages the overall game state, score, remaining balls, and tracks orange peg hits. It emits signals for `score_changed`, `balls_changed`, `level_complete`, and `game_over`.
*   **`scenes/node_3d.tscn`**: This is the main game scene where the action takes place. It includes the `Camera3D`, `Cow` model with an `UdderSpawnPoint`, `WorldEnvironment`, `OmniLight3D`, and instances of `BluePeg.tscn`. It also handles instancing `WhiteBall.tscn`.
*   **`scenes/node_3d.gd`**: This script (`extends Node3D`) attached to the main scene handles the aiming mechanism based on mouse input and the launching of `WhiteBall` instances.
*   **`WhiteBall.tscn` / `WhiteBall.gd`**: Represents the player-launched ball. It's a `RigidBody3D` that is removed from the scene if it falls too far down.
*   **`BluePeg.tscn` / `peg.gd`**: These scenes/scripts define the pegs in the game. They are `Area3D` nodes that detect collisions. When a peg is hit, it registers the hit, provides points (via `GameManager.gd`), and then despawns. Different `peg_type` values (`blue`, `orange`, `green`) are used to categorize pegs and trigger different game logic.
*   **`main menu.tscn`**: A basic UI scene, likely intended for the game's main menu.

## Assets:

The `Assets/` directory contains various 3D models (GLB and FBX formats) for the game's elements, including:
*   `Cow.fbx`
*   `GREEN BALL (special ability).glb`
*   `GREY BALL (ROCK).glb`
*   `ORANGE BALL (needed to beat level).glb`
*   `TEAL BALL (peg).glb`
*   `WHITE BALL (THE ONE THAT THE UTTER SHOOTS OR SOME).glb`
*   A JPEG image (`wmremove-transformed.jpeg`) used for the sky environment.

# Building and Running

This project is built using the Godot Engine. To run or develop this project, you will need the Godot Engine (version 4.6 or compatible) installed.

1.  **Open in Godot Editor**:
    *   Launch the Godot Engine.
    *   From the project manager, click "Import" and select the `project.godot` file in this directory.
    *   Alternatively, if you open the Godot Editor in the parent directory of this project, it should automatically detect and list the project.
    *   Once imported/opened, you can run the game directly from the editor by pressing the "Play" button (or F5).

2.  **Exporting the Game**:
    *   Within the Godot Editor, navigate to `Project` -> `Export...`
    *   Configure the desired export presets (e.g., Windows Desktop, Web, Android) and export the project.

# Development Conventions

*   **Scripting Language**: GDScript (`.gd` files).
*   **Scene Files**: `.tscn` files define game scenes and their hierarchies.
*   **Physics Engine**: Jolt Physics is configured for 3D physics.
*   **Main Scene**: The game starts with `scenes/node_3d.tscn`.
*   **Game Management**: Core game logic (scoring, ball count, level progression) is centralized in `GameManager.gd`.
*   **Peg Interaction**: Pegs are designed as `Area3D` nodes that react to `RigidBody3D` collisions.
