## ADDED Requirements

### Requirement: Core gameplay loop
The game SHALL implement a core loop: enter dream → explore scene → collect memory fragments → solve puzzles/avoid enemies → advance story → wake up or continue.

#### Scenario: Complete one dream cycle
- **WHEN** player enters a dream, collects all memory fragments in the scene, solves all puzzles, and reaches the end
- **THEN** player advances to the next story segment and can choose to wake up or continue to the next sleep stage

#### Scenario: Partial completion
- **WHEN** player doesn't collect all memory fragments or solve all puzzles
- **THEN** player can still advance to the next stage, but misses some story content

### Requirement: Memory fragment collection
The game SHALL allow players to collect memory fragments scattered throughout dream scenes.

#### Scenario: Collect fragment
- **WHEN** player approaches a memory fragment and presses E/space
- **THEN** the fragment is added to the player's collection and a small story snippet is shown

#### Scenario: View collected fragments
- **WHEN** player opens the memory journal (during awake phase)
- **THEN** all collected fragments are displayed in chronological order
