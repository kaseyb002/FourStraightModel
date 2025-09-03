# Four Straight AI Engine

This AI engine provides three difficulty levels for playing Four Straight (Connect Four) against the computer.

## Features

- **Three Difficulty Levels**: Easy, Medium, and Hard
- **Intelligent Move Selection**: Uses minimax algorithm with alpha-beta pruning
- **Board Evaluation**: Sophisticated position evaluation for better gameplay
- **Easy Integration**: Simple API for adding AI to your game

## Difficulty Levels

### Easy
- **Depth**: 1 move ahead
- **Strategy**: Mostly random moves with basic blocking
- **Best for**: Beginners and casual players

### Medium
- **Depth**: 3 moves ahead
- **Strategy**: Uses minimax algorithm with basic evaluation
- **Best for**: Intermediate players

### Hard
- **Depth**: 5 moves ahead
- **Strategy**: Advanced minimax with alpha-beta pruning and sophisticated evaluation
- **Best for**: Experienced players

## Usage

### Basic AI Engine Usage

```swift
import FourStraightModel

// Create an AI engine with desired difficulty
let ai = AIEngine(difficulty: .medium)

// Create a game round
let player1 = Player(id: "human", name: "Human", imageURL: nil, checkerColor: .red)
let player2 = Player(id: "ai", name: "AI", imageURL: nil, checkerColor: .yellow)
var round = Round(players: [player1, player2])

// Get AI's best move
if let bestMove = ai.getBestMove(for: round, playerId: "ai") {
    try round.drop(in: bestMove)
}
```

### Using AI Players

```swift
// Create an AI player
let aiPlayer = Player.aiPlayer(
    name: "Smart AI",
    difficulty: .hard,
    checkerColor: .yellow
)

// Create a game with AI player
let humanPlayer = Player(id: "human", name: "Human", imageURL: nil, checkerColor: .red)
var round = Round(players: [humanPlayer, aiPlayer.asPlayer])

// AI makes a move
if let move = aiPlayer.makeMove(in: round) {
    try round.drop(in: move)
}
```

### Using Round Extensions

```swift
// Make an AI move directly on the round
try round.makeAIMove(difficulty: .medium, playerId: "ai")
```

### AI vs AI Games

```swift
// Create an AI vs AI game
var round = Round.createAIGame(
    player1Difficulty: .easy,
    player2Difficulty: .hard
)

// Play AI turns
while case .waitingForPlayer = round.state {
    try round.playAITurn()
}
```

## API Reference

### AIEngine

```swift
public struct AIEngine {
    public init(difficulty: AIDifficulty)
    public func getBestMove(for round: Round, playerId: String) -> Int?
}
```

### AIDifficulty

```swift
public enum AIDifficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}
```

### AIPlayer

```swift
public struct AIPlayer: Equatable, Codable {
    public let id: PlayerID
    public var name: String
    public var imageURL: URL?
    public let checkerColor: CheckerColor
    public let difficulty: AIDifficulty
    
    public func makeMove(in round: Round) -> Int?
    public var asPlayer: Player
}
```

### Round Extensions

```swift
extension Round {
    public mutating func makeAIMove(difficulty: AIDifficulty, playerId: String) throws
    public static func createAIGame(player1Difficulty: AIDifficulty, player2Difficulty: AIDifficulty) -> Round
    public mutating func playAITurn() throws
}
```

## Algorithm Details

### Minimax Algorithm
The AI uses the minimax algorithm to evaluate possible moves:

1. **Tree Search**: Explores possible move sequences up to the specified depth
2. **Position Evaluation**: Scores board positions based on:
   - Winning/losing positions
   - Number of consecutive pieces
   - Blocking opportunities
   - Strategic positions

### Alpha-Beta Pruning
The hard difficulty uses alpha-beta pruning to improve performance by:
- Skipping branches that won't affect the final decision
- Reducing the number of positions evaluated
- Allowing deeper search within the same time constraints

### Board Evaluation
The evaluation function considers:
- **Winning Lines**: 1000 points for 4-in-a-row
- **Threats**: 100 points for 3-in-a-row with space
- **Blocks**: 50 points for blocking opponent's 3-in-a-row
- **Connections**: 20 points for 2-in-a-row with space
- **Single Pieces**: 5 points for isolated pieces with potential

## Performance Characteristics

| Difficulty | Search Depth | Typical Response Time | Recommended Use |
|------------|--------------|----------------------|-----------------|
| Easy       | 1 move       | < 1ms                | Casual games    |
| Medium     | 3 moves      | 10-50ms              | Normal gameplay |
| Hard       | 5 moves      | 100-500ms            | Competitive play |

## Testing

Run the test suite to verify AI functionality:

```bash
swift test
```

The tests cover:
- AI initialization and configuration
- Move generation for all difficulty levels
- Winning and blocking scenarios
- Edge cases (full columns, invalid moves)
- Integration with the Round system

## Example Game Flow

```swift
// 1. Create players
let human = Player(id: "human", name: "Human", imageURL: nil, checkerColor: .red)
let ai = Player.aiPlayer(difficulty: .medium, checkerColor: .yellow)

// 2. Start game
var round = Round(players: [human, ai.asPlayer])

// 3. Game loop
while case .waitingForPlayer(let currentPlayerId) = round.state {
    if currentPlayerId == "human" {
        // Human makes move (UI interaction)
        let column = getUserInput()
        try round.drop(in: column)
    } else {
        // AI makes move
        try round.makeAIMove(difficulty: .medium, playerId: currentPlayerId)
    }
}

// 4. Game complete
switch round.state {
case .complete(let winnerId, _):
    print("Winner: \(winnerId)")
case .tie:
    print("It's a tie!")
default:
    break
}
```

## Contributing

To improve the AI engine:

1. **Adjust Evaluation Function**: Modify scoring in `scoreLine()` method
2. **Change Search Depth**: Update `maxDepth` values in `AIEngine.init()`
3. **Add New Strategies**: Implement additional move selection logic
4. **Optimize Performance**: Improve pruning or evaluation efficiency

## License

This AI engine is part of the FourStraightModel package and follows the same licensing terms.

