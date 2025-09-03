import XCTest
@testable import FourStraightModel

final class AIEngineTests: XCTestCase {
    
    func testAIDifficultyInitialization() {
        let easyAI = AIEngine(difficulty: .easy)
        let mediumAI = AIEngine(difficulty: .medium)
        let hardAI = AIEngine(difficulty: .hard)
        
        // Test that all difficulties can be created
        XCTAssertNotNil(easyAI)
        XCTAssertNotNil(mediumAI)
        XCTAssertNotNil(hardAI)
    }
    
    func testEasyAIMove() {
        let ai = AIEngine(difficulty: .easy)
        let player1 = Player(id: "player1", name: "Player 1", imageURL: nil, checkerColor: .red)
        let player2 = Player.aiPlayer(difficulty: .easy, checkerColor: .yellow)
        
        let round = Round(players: [player1, player2.asPlayer])
        
        // Easy AI should always return a valid move
        let move = ai.getBestMove(for: round, playerId: player2.id)
        XCTAssertNotNil(move)
        XCTAssertTrue(move! >= 0 && move! < round.columns)
    }
    
    func testMediumAIMove() {
        let ai = AIEngine(difficulty: .medium)
        let player1 = Player(id: "player1", name: "Player 1", imageURL: nil, checkerColor: .red)
        let player2 = Player.aiPlayer(difficulty: .medium, checkerColor: .yellow)
        
        let round = Round(players: [player1, player2.asPlayer])
        
        // Medium AI should return a valid move
        let move = ai.getBestMove(for: round, playerId: player2.id)
        XCTAssertNotNil(move)
        XCTAssertTrue(move! >= 0 && move! < round.columns)
    }
    
    func testHardAIMove() {
        let ai = AIEngine(difficulty: .hard)
        let player1 = Player(id: "player1", name: "Player 1", imageURL: nil, checkerColor: .red)
        let player2 = Player.aiPlayer(difficulty: .hard, checkerColor: .yellow)
        
        let round = Round(players: [player1, player2.asPlayer])
        
        // Hard AI should return a valid move
        let move = ai.getBestMove(for: round, playerId: player2.id)
        XCTAssertNotNil(move)
        XCTAssertTrue(move! >= 0 && move! < round.columns)
    }
    
    func testAIMoveWithFullColumn() {
        let ai = AIEngine(difficulty: .hard)
        let player1 = Player(id: "player1", name: "Player 1", imageURL: nil, checkerColor: .red)
        let player2 = Player.aiPlayer(difficulty: .hard, checkerColor: .yellow)
        
        var round = Round(players: [player1, player2.asPlayer])
        
        // Fill the first column
        for _ in 0..<round.rows {
            try! round.drop(in: 0)
        }
        
        // AI should not return column 0 as it's full
        let move = ai.getBestMove(for: round, playerId: player2.id)
        XCTAssertNotNil(move)
        XCTAssertNotEqual(move, 0)
    }
    
    func testAIMoveWithWinningOpportunity() {
        let ai = AIEngine(difficulty: .hard)
        let player1 = Player(id: "player1", name: "Player 1", imageURL: nil, checkerColor: .red)
        let player2 = Player.aiPlayer(difficulty: .hard, checkerColor: .yellow)
        
        var round = Round(players: [player1, player2.asPlayer])
        
        // Create a scenario where AI can win in one move
        // Player 1 drops in column 0
        try! round.drop(in: 0)
        // Player 2 drops in column 1
        try! round.drop(in: 1)
        // Player 1 drops in column 0
        try! round.drop(in: 0)
        // Player 2 drops in column 1
        try! round.drop(in: 1)
        // Player 1 drops in column 0
        try! round.drop(in: 0)
        
        // Now AI should win by dropping in column 1
        let move = ai.getBestMove(for: round, playerId: player2.id)
        XCTAssertEqual(move, 1)
    }
    
    func testAIMoveWithBlockingOpportunity() {
        let ai = AIEngine(difficulty: .hard)
        let player1 = Player(id: "player1", name: "Player 1", imageURL: nil, checkerColor: .red)
        let player2 = Player.aiPlayer(difficulty: .hard, checkerColor: .yellow)
        
        var round = Round(players: [player1, player2.asPlayer])
        
        // Create a scenario where player 1 can win next move
        // Player 1 drops in column 0
        try! round.drop(in: 0)
        // Player 2 drops in column 1
        try! round.drop(in: 1)
        // Player 1 drops in column 0
        try! round.drop(in: 0)
        // Player 2 drops in column 1
        try! round.drop(in: 1)
        // Player 1 drops in column 0
        try! round.drop(in: 0)
        
        // Now AI should block by dropping in column 0
        let move = ai.getBestMove(for: round, playerId: player2.id)
        XCTAssertEqual(move, 0)
    }
    
    func testRoundExtensionWithAI() {
        let player1 = Player(id: "player1", name: "Player 1", imageURL: nil, checkerColor: .red)
        let player2 = Player.aiPlayer(difficulty: .medium, checkerColor: .yellow)
        
        var round = Round(players: [player1, player2.asPlayer])
        
        // Test that AI can make a move using the extension
        XCTAssertNoThrow(try round.makeAIMove(difficulty: .medium, playerId: player2.id))
        
        // Verify the move was made
        XCTAssertEqual(round.log.count, 1)
        XCTAssertEqual(round.log[0].playerId, player2.id)
    }
    
    func testAIPlayerCreation() {
        let aiPlayer = Player.aiPlayer(
            name: "Test AI",
            difficulty: .hard,
            checkerColor: .red
        )
        
        XCTAssertEqual(aiPlayer.name, "Test AI")
        XCTAssertEqual(aiPlayer.difficulty, .hard)
        XCTAssertEqual(aiPlayer.checkerColor, .red)
        XCTAssertNotNil(aiPlayer.id)
    }
    
    func testAIPlayerConversion() {
        let aiPlayer = Player.aiPlayer(difficulty: .medium, checkerColor: .yellow)
        let regularPlayer = aiPlayer.asPlayer
        
        XCTAssertEqual(regularPlayer.id, aiPlayer.id)
        XCTAssertEqual(regularPlayer.name, aiPlayer.name)
        XCTAssertEqual(regularPlayer.checkerColor, aiPlayer.checkerColor)
    }
    
    func testAIPlayerMove() {
        let aiPlayer = Player.aiPlayer(difficulty: .hard, checkerColor: .red)
        let player1 = Player(id: "player1", name: "Player 1", imageURL: nil, checkerColor: .yellow)
        
        let round = Round(players: [player1, aiPlayer.asPlayer])
        
        let move = aiPlayer.makeMove(in: round)
        XCTAssertNotNil(move)
        XCTAssertTrue(move! >= 0 && move! < round.columns)
    }
}

