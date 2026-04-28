## ADDED Requirements

### Requirement: Patrol enemy type
The game SHALL implement patrol enemies that follow fixed paths.

#### Scenario: Enemy patrols
- **WHEN** game is running and no player is detected
- **THEN** enemy moves back and forth along a predefined path

#### Scenario: Player detected by patrol enemy
- **WHEN** player enters enemy's vision cone
- **THEN** enemy stops patrolling and starts chasing player

### Requirement: Chase enemy type
The game SHALL implement chase enemies that pursue player when detected.

#### Scenario: Chase mechanics
- **WHEN** enemy has detected player and started chasing
- **THEN** enemy moves toward player's last known position

#### Scenario: Lose player
- **WHEN** player stays out of enemy vision for 5 seconds after being detected
- **THEN** enemy gives up chase and returns to original behavior

### Requirement: Ambush enemy type
The game SHALL implement ambush enemies that stay hidden until triggered.

#### Scenario: Ambush trigger
- **WHEN** player gets too close to an ambush enemy's hiding spot
- **THEN** enemy jumps out suddenly, causing a startle effect and increasing fear value

### Requirement: No combat system
The game SHALL NOT implement any combat mechanics.

#### Scenario: Player can't fight enemies
- **WHEN** player encounters an enemy
- **THEN** player's only options are to hide, run away, or solve a puzzle to pass
