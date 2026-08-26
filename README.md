# Guard Patrolling Pathfinding System

A highly modular, scalable Finite State Machine (FSM) for a Guard Patrolling System.

Utilises the Roblox PathfindingService.

NPCs move between nodes given to them (Patrolling State), and if a player is in range, they switch to the Chasing State, moving towards the player. When the player is far enough away, the NPC returns to the nodes and begins patrolling once again.  

## Features

* **Pure OOP Architecture:** Managed via a centralised `GuardManager` orchestrator, with all states inheriting from a robust `StateClass` superclass.
* **Smooth State Transitions:** Logic flows between the Patrolling State and Chasing State. 
* **Memory Safe:** Strict adherence to `:Enter()` and `:Exit()` methods ensures previous states unbind inputs, and clean up connections before the next state initialises.

## 📂 Architecture overview

The system utilizes a standard Roblox folder hierarchy:
```text
GuardFSM/
├── GuardMananger (ModuleScript)
├── StateClass (ModuleScript)
└── States (Folder)
    ├── ChaseState.luau
    ├── PatrolState.luau
```

## 🛠️ Installation & Setup

1. Download the `.rbxm` release from this repository.
2. Drag and drop the `.rbxm` file into Roblox Studio.
3. Place the `GuardFSM` folder directly into `ReplicatedStorage`.