## ADDED Requirements

### Requirement: Sleep stage progression
The game SHALL implement four distinct sleep stages with automatic progression.

#### Scenario: Awake phase
- **WHEN** player starts the game or wakes up from previous dream
- **THEN** player is in awake phase and can select which dream to enter

#### Scenario: Light sleep phase
- **WHEN** player enters a dream
- **THEN** player starts in light sleep phase (10 minutes duration) with exploration and simple puzzles

#### Scenario: Deep sleep phase
- **WHEN** player completes light sleep phase
- **THEN** player enters deep sleep phase (10 minutes duration) with fear management and tense avoidance

#### Scenario: REM phase
- **WHEN** player completes deep sleep phase
- **THEN** player enters REM phase (15 minutes duration) with emotional climax and final puzzle

### Requirement: Fear system (deep sleep only)
The game SHALL implement a fear value system during deep sleep phase.

#### Scenario: Fear increases over time
- **WHEN** player is in deep sleep phase
- **THEN** fear value increases slowly over time

#### Scenario: High fear effects
- **WHEN** fear value reaches 60% or higher
- **THEN** screen gets blurry, vision narrows, and movement becomes slightly erratic

#### Scenario: Safe point reduces fear
- **WHEN** player reaches a safe point and stays there for 2 seconds
- **THEN** fear value is reduced by 30%
