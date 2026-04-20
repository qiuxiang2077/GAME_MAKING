## ADDED Requirements

### Requirement: Environment puzzles
The game SHALL implement simple environment-based puzzles.

#### Scenario: Push box puzzle
- **WHEN** player pushes a box onto a pressure plate
- **THEN** a door opens or another mechanism activates

#### Scenario: Switch puzzle
- **WHEN** player flips a switch
- **THEN** something in the environment changes (lights on, platform moves, etc.)

### Requirement: Memory anchor puzzle (light sleep only)
The game SHALL implement memory anchor puzzles during light sleep phase.

#### Scenario: Find memory anchor
- **WHEN** player finds a memory anchor in light sleep phase
- **THEN** that area of the map becomes stable (stops shifting)

#### Scenario: All anchors found
- **WHEN** player has found all memory anchors in the scene
- **THEN** the entire map is stable and player can proceed to deep sleep phase

### Requirement: Emotional resonance puzzle (REM only)
The game SHALL implement emotional resonance puzzles during REM phase.

#### Scenario: Emotional resonance
- **WHEN** player interacts with key objects in REM phase that relate to the boy's memories
- **THEN** the emotional monster is calmed, and the player can progress
