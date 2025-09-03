import Foundation

// Example usage of the AI Engine
public class AIExample {
    
    public static func demonstrateAI() {
        print("🎮 Four Straight AI Engine Demo")
        print("================================")
        
        // Create players
        _ = Player(
            id: "human",
            name: "Human Player",
            imageURL: nil,
            checkerColor: .red
        )
        
        let easyAI = Player.aiPlayer(
            name: "Easy AI",
            difficulty: .easy,
            checkerColor: .yellow
        )
        
        let mediumAI = Player.aiPlayer(
            name: "Medium AI",
            difficulty: .medium,
            checkerColor: .yellow
        )
        
        let hardAI = Player.aiPlayer(
            name: "Hard AI",
            difficulty: .hard,
            checkerColor: .yellow
        )
        
        // Demonstrate different AI difficulties
        demonstrateDifficulty(easyAI, "Easy")
        demonstrateDifficulty(mediumAI, "Medium")
        demonstrateDifficulty(hardAI, "Hard")
    }
    
    private static func demonstrateDifficulty(_ aiPlayer: AIPlayer, _ difficultyName: String) {
        print("\n🤖 \(difficultyName) AI Demonstration")
        print("--------------------------------")
        
        let humanPlayer = Player(
            id: "human",
            name: "Human Player",
            imageURL: nil,
            checkerColor: .red
        )
        
        var round = Round(players: [humanPlayer, aiPlayer.asPlayer])
        
        print("Initial board state:")
        printBoard(round.board)
        
        // Make a few moves to set up an interesting position
        try! round.drop(in: 3) // Human moves
        try! round.drop(in: 2) // AI moves
        try! round.drop(in: 3) // Human moves
        try! round.drop(in: 2) // AI moves
        try! round.drop(in: 3) // Human moves
        
        print("\nAfter 5 moves:")
        printBoard(round.board)
        
        // Get AI's next move
        let aiMove = aiPlayer.makeMove(in: round)
        print("\(difficultyName) AI chooses column: \(aiMove ?? -1)")
        
        if let move = aiMove {
            try! round.drop(in: move)
            print("\nAfter AI move:")
            printBoard(round.board)
        }
    }
    
    private static func printBoard(_ board: [[PlayerID?]]) {
        for row in board {
            var rowString = "|"
            for cell in row {
                if let playerId = cell {
                    rowString += playerId == "human" ? " 🔴" : " 🟡"
                } else {
                    rowString += " ⚪"
                }
                rowString += "|"
            }
            print(rowString)
        }
        print(" 0  1  2  3  4  5  6")
    }
}

// Extension to make it easier to create AI vs AI games
extension Round {
    public static func createAIGame(
        player1Difficulty: AIDifficulty,
        player2Difficulty: AIDifficulty
    ) -> Round {
        let player1 = Player.aiPlayer(
            name: "AI Player 1 (\(player1Difficulty.rawValue))",
            difficulty: player1Difficulty,
            checkerColor: .red
        )
        
        let player2 = Player.aiPlayer(
            name: "AI Player 2 (\(player2Difficulty.rawValue))",
            difficulty: player2Difficulty,
            checkerColor: .yellow
        )
        
        return Round(players: [player1.asPlayer, player2.asPlayer])
    }
    
    public mutating func playAITurn() throws {
        guard case .waitingForPlayer(let currentPlayerId) = state else {
            throw FourStraightError.triedDroppingInFullColumn
        }
        
        // Find the AI player
        if players.first(where: { $0.id == currentPlayerId }) != nil {
            // For now, we'll use medium difficulty for all AI players
            // In a real implementation, you'd store the difficulty with the player
            try makeAIMove(difficulty: .medium, playerId: currentPlayerId)
        }
    }
}
