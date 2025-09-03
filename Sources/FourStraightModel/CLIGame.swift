import Foundation

public class CLIGame {
    private var round: Round
    private let aiDifficulty: AIDifficulty
    private let humanPlayer: Player
    private let aiPlayer: AIPlayer
    
    public init(aiDifficulty: AIDifficulty = .medium) {
        self.aiDifficulty = aiDifficulty
        self.humanPlayer = Player(
            id: "human",
            name: "You",
            imageURL: nil,
            checkerColor: .red
        )
        self.aiPlayer = Player.aiPlayer(
            name: "AI (\(aiDifficulty.rawValue))",
            difficulty: aiDifficulty,
            checkerColor: .yellow
        )
        self.round = Round(players: [humanPlayer, aiPlayer.asPlayer])
    }
    
    public func start() {
        print("🎮 Welcome to Four Straight!")
        print("=============================")
        print("You are 🔴 (Red)")
        print("AI is 🟡 (Yellow)")
        print("First to get 4 in a row wins!")
        print()
        
        while case .waitingForPlayer(let currentPlayerId) = round.state {
            displayBoard()
            
            if currentPlayerId == humanPlayer.id {
                humanTurn()
            } else {
                aiTurn()
            }
        }
        
        // Game over
        displayBoard()
        displayGameResult()
    }
    
    private func humanTurn() {
        print("\n🎯 Your turn! Choose a column (1-7): ", terminator: "")
        
        guard let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines),
              let column = Int(input) else {
            print("❌ Invalid input. Please enter a number between 1 and 7.")
            return
        }
        
        guard column >= 1 && column <= round.columns else {
            print("❌ Column must be between 1 and 7.")
            return
        }
        
        // Convert 1-based to 0-based
        let columnIndex = column - 1
        
        do {
            try round.drop(in: columnIndex)
            print("✅ You dropped in column \(column)")
        } catch {
            print("❌ Invalid move: \(error)")
        }
    }
    
    private func aiTurn() {
        print("\n🤖 AI is thinking...")
        
        // Add a small delay to make it feel more natural
        Thread.sleep(forTimeInterval: 0.5)
        
        do {
            try round.makeAIMove(difficulty: aiDifficulty, playerId: aiPlayer.id)
            let lastMove = round.log.last!
            print("🤖 AI dropped in column \(lastMove.column + 1)")
        } catch {
            print("❌ AI error: \(error)")
        }
    }
    
    private func displayBoard() {
        print("\n" + round.debugBoardString())
        
        // Column numbers (1-based)
        var columnNumbers = " "
        for i in 1...round.columns {
            columnNumbers += " \(i) "
        }
        print(columnNumbers)
    }
    
    private func displayGameResult() {
        print("\n" + "=" * 40)
        
        switch round.state {
        case .complete(let winnerId, let positions):
            if winnerId == humanPlayer.id {
                print("🎉 Congratulations! You won!")
            } else {
                print("😔 Game over! AI won!")
            }
            print("Winning positions: \(positions.map { "(\($0.row),\($0.column))" }.joined(separator: " "))")
            
        case .tie:
            print("🤝 It's a tie!")
            
        default:
            print("❓ Unexpected game state")
        }
        
        print("=" * 40)
    }
}

// Helper extension for string repetition
extension String {
    static func * (left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}

// Main CLI entry point
public func playFourStraight() {
    print("🎮 Four Straight - Command Line Edition")
    print("=======================================")
    print()
    
    // Choose difficulty
    print("Choose AI difficulty:")
    for (index, difficulty) in AIDifficulty.allCases.enumerated() {
        print("\(index + 1). \(difficulty.rawValue)")
    }
    print("4. Watch AI vs AI")
    print()
    print("Enter your choice (1-4): ", terminator: "")
    
    guard let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines),
          let choice = Int(input) else {
        print("❌ Invalid input. Using Medium difficulty.")
        let game = CLIGame(aiDifficulty: .medium)
        game.start()
        return
    }
    
    switch choice {
    case 1:
        let game = CLIGame(aiDifficulty: .easy)
        game.start()
    case 2:
        let game = CLIGame(aiDifficulty: .medium)
        game.start()
    case 3:
        let game = CLIGame(aiDifficulty: .hard)
        game.start()
    case 4:
        watchAIVsAI()
    default:
        print("❌ Invalid choice. Using Medium difficulty.")
        let game = CLIGame(aiDifficulty: .medium)
        game.start()
    }
}

private func watchAIVsAI() {
    print("\n🤖 AI vs AI Mode")
    print("================")
    
    // Choose difficulties
    print("Choose AI 1 difficulty (1-3): ", terminator: "")
    guard let input1 = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines),
          let choice1 = Int(input1),
          choice1 >= 1 && choice1 <= 3 else {
        print("❌ Invalid input. Using Easy vs Medium.")
        playAIVsAI(ai1Difficulty: .easy, ai2Difficulty: .medium)
        return
    }
    
    print("Choose AI 2 difficulty (1-3): ", terminator: "")
    guard let input2 = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines),
          let choice2 = Int(input2),
          choice2 >= 1 && choice2 <= 3 else {
        print("❌ Invalid input. Using Easy vs Medium.")
        playAIVsAI(ai1Difficulty: .easy, ai2Difficulty: .medium)
        return
    }
    
    let difficulties: [AIDifficulty] = [.easy, .medium, .hard]
    let ai1Difficulty = difficulties[choice1 - 1]
    let ai2Difficulty = difficulties[choice2 - 1]
    
    playAIVsAI(ai1Difficulty: ai1Difficulty, ai2Difficulty: ai2Difficulty)
}

private func playAIVsAI(ai1Difficulty: AIDifficulty, ai2Difficulty: AIDifficulty) {
    print("\n🤖 \(ai1Difficulty.rawValue) AI vs \(ai2Difficulty.rawValue) AI")
    print("=" * 40)
    
    var round = Round.createAIGame(
        player1Difficulty: ai1Difficulty,
        player2Difficulty: ai2Difficulty
    )
    
    var moveCount = 0
    let maxMoves = round.rows * round.columns
    
    while case .waitingForPlayer(let currentPlayerId) = round.state, moveCount < maxMoves {
        displayAIBoard(round.board, moveCount: moveCount, ai1Id: round.players[0].id)
        
        // Determine which AI is playing
        let isAI1Turn = currentPlayerId == round.players[0].id
        let currentDifficulty = isAI1Turn ? ai1Difficulty : ai2Difficulty
        let aiName = isAI1Turn ? "AI 1 (\(ai1Difficulty.rawValue))" : "AI 2 (\(ai2Difficulty.rawValue))"
        
        print("\n🤖 \(aiName) is thinking...")
        Thread.sleep(forTimeInterval: 1.0) // Slower for watching
        
        do {
            try round.makeAIMove(difficulty: currentDifficulty, playerId: currentPlayerId)
            let lastMove = round.log.last!
            print("🤖 \(aiName) dropped in column \(lastMove.column + 1)")
            moveCount += 1
        } catch {
            print("❌ AI error: \(error)")
            break
        }
    }
    
    // Final board and result
    displayAIBoard(round.board, moveCount: moveCount, ai1Id: round.players[0].id)
    displayAIGameResult(round)
}

private func displayAIBoard(_ board: [[PlayerID?]], moveCount: Int, ai1Id: String) {
    print("\nMove #\(moveCount)")
    
    // Create a simple board display similar to debugBoardString
    let horizontalBorder = String(repeating: "━", count: board[0].count * 3)
    
    let rowsStrings: [String] = (0..<board.count).map { r in
        (0..<board[0].count).map { c in
            if let playerId = board[r][c] {
                if playerId == ai1Id {
                    return "🔴"
                } else {
                    return "🟡"
                }
            } else {
                return "⚫️"
            }
        }.joined(separator: " ")
    }
    
    print(horizontalBorder)
    for rowString in rowsStrings {
        print(rowString)
    }
    print(horizontalBorder)
    
    // Column numbers (1-based)
    var columnNumbers = " "
    for i in 1...board[0].count {
        columnNumbers += " \(i) "
    }
    print(columnNumbers)
}

private func displayAIGameResult(_ round: Round) {
    print("\n" + "=" * 40)
    
    switch round.state {
    case .complete(let winnerId, let positions):
        let winnerName = winnerId == round.players[0].id ? "AI 1" : "AI 2"
        print("🏆 \(winnerName) won!")
        print("Winning positions: \(positions.map { "(\($0.row),\($0.column))" }.joined(separator: " "))")
        
    case .tie:
        print("🤝 It's a tie!")
        
    default:
        print("❓ Unexpected game state")
    }
    
    print("=" * 40)
}
