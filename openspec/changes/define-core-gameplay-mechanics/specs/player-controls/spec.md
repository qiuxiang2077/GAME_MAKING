## ADDED Requirements

### Requirement: Basic movement
The player SHALL control the shadow character with standard movement controls.

#### Scenario: WASD movement
- **WHEN** player presses WASD or arrow keys
- **THEN** shadow character moves in corresponding direction

#### Scenario: Shift to run
- **WHEN** player holds Shift while moving
- **THEN** shadow runs faster but makes more noise (attracts enemies more easily

### Requirement: Interaction
The player SHALL interact with the environment using a single interaction key.

#### Scenario: Collect item
- **WHEN** player is near an interactive object and presses E/space
- **THEN** interaction occurs based on object type (collect, push, pull, etc.)

#### Scenario: No interaction prompt
- **WHEN** player is near an interactive object
- **THEN** a small prompt appears showing E/space key appears on screen

### Requirement: Hiding mechanic
The player SHALL be able to hide from enemies behind objects.

#### Scenario: Hide behind object
- **WHEN** player approaches a large object and presses Ctrl
- **THEN** shadow hides behind the object and becomes invisible to enemies

#### Scenario: Can't be seen while hiding
- **WHEN** enemy passes near hidden player
- **THEN** enemy doesn't detect player as long as they stay hidden and quiet
