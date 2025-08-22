import Foundation
import Testing
@testable import FourStraightModel

// MARK: - Helpers for tests

private func makePlayers() -> [Player] {
    let p1 = Player(id: "alice", name: "Alice", imageURL: nil, checkerColor: .red)
    let p2 = Player(id: "bob", name: "Bob",   imageURL: nil, checkerColor: .yellow)
    return [p1, p2]
}

private func currentPlayer(_ round: Round) -> Player? {
    switch round.state {
    case .waitingForPlayer(let id):
        return round.players.first(where: { $0.id == id })

    case .complete, .tie:
        return nil
    }
}

private func winnerID(_ round: Round) -> PlayerID? {
    if case .complete(let winningPlayerId, _) = round.state { return winningPlayerId }
    return nil
}

private func winningPositions(_ round: Round) -> [BoardPosition]? {
    if case .complete(_, let positions) = round.state { return positions }
    return nil
}

private func playerName(for id: PlayerID, in players: [Player]) -> String {
    players.first(where: { $0.id == id })?.name ?? id
}

// MARK: - Test: Simulated game with animated console output

@Test
func animatedDiagonalWinDemo() async throws {
    var round = Round(rows: 6, columns: 7, winLength: 4, players: makePlayers())
    print("\n=== New Round ===")
    print(round.debugDescription)

    // Helper to perform a move with 1s delay and print state/board
    func play(_ column: Int) async throws {
        let before = round
        try round.drop(in: column)
        // Print only if state changed or board changed
        print("\nMove: column \(column)")
        if let player = currentPlayer(before) {
            print("Played by: \(player.name) \(player.checkerColor.emoji)")
        }
        print(round.debugBoardString())
        print("State: \(round.state)")
        // try await Task.sleep(for: .seconds(1))
    }

    // Sequence that yields a ↘ diagonal win for Player 1 (Alice):
    // Columns: 3,2,2,1,1,1,0
    // P1,P2,P1,P2,P1,P2,P1
    try await play(3) // P1
    try await play(2) // P2
    try await play(2) // P1
    try await play(1) // P2
    try await play(1) // P1
    try await play(1) // P2
    try await play(0) // P1 -> should complete diagonal
    try await play(4)
    try await play(3)
    try await play(0)
    try await play(4)

    // Assert winner is Player 1
    #expect(winnerID(round) == "alice")
    print("\n🎉 Winner: \(playerName(for: winnerID(round)!, in: round.players))")
}

// MARK: - Test: Full column throws error

@Test
func droppingIntoFullColumnThrows() async throws {
    var round = Round(rows: 2, columns: 2, winLength: 2, players: makePlayers())
    // Fill the only column
    try round.drop(in: 0) // P1
    try round.drop(in: 0) // P2
    do {
        try round.drop(in: 0)
        Issue.record("Expected error, but drop succeeded")
    } catch FourStraightError.triedDroppingInFullColumn {
        // expected
        #expect(true)
    } catch {
        Issue.record("Unexpected error: \(error)")
    }
}

// MARK: - Test: Tie detection on small board

@Test
func tieOnSmallBoard() async throws {
    var round = Round(rows: 2, columns: 2, winLength: 3, players: makePlayers())
    // No one can reach 3 in a 2x2; fill board:
    try round.drop(in: 0) // P1
    try round.drop(in: 1) // P2
    try round.drop(in: 0) // P1
    try round.drop(in: 1) // P2
    #expect({
        if case .tie = round.state { return true }
        return false
    }())
}

// MARK: - Test: Winning positions are captured

@Test
func winningPositionsAreCaptured() async throws {
    var round = Round(rows: 6, columns: 7, winLength: 4, players: makePlayers())
    
    // Create a horizontal win for Player 1 (Alice)
    // Columns: 0,1,1,2,2,3,3
    // P1,P2,P1,P2,P1,P2,P1
    try round.drop(in: 0) // P1
    try round.drop(in: 6) // P2
    try round.drop(in: 1) // P1
    try round.drop(in: 5) // P2
    try round.drop(in: 2) // P1
    try round.drop(in: 4) // P2
    try round.drop(in: 3) // P1 -> should complete horizontal win
    print(round.debugDescription)
    
    // Assert winner is Player 1
    #expect(winnerID(round) == "alice")
    
    // Assert winning positions are captured
    guard let positions = winningPositions(round) else {
        struct MissingPositions: Error {}
        throw MissingPositions()
    }
    #expect(positions.count >= 4) // Should have at least 4 positions for a win
    
    // Verify the winning positions are all in the same row (row 5, which is the bottom row)
    let winningRow = positions.first!.row
    #expect(positions.allSatisfy { $0.row == winningRow })
    
    print("\n🎉 Winner: \(playerName(for: winnerID(round)!, in: round.players))")
    print("Winning positions: \(positions.map { "(\($0.row),\($0.column))" }.joined(separator: " "))")
    print("Log: \(round.debugLog())")
}

@Test
func firstEmptyColumn() async throws {
    let rows: Int = 6
    let columns: Int = 7
    var round = Round(
        rows: rows,
        columns: columns,
        winLength: 8,
        players: makePlayers()
    )
    #expect(round.firstOpenColumn == 0)
    for column in 0 ..< columns - 1 {
        for _ in 0 ..< rows {
            try round.drop(in: column)
        }
        #expect(round.firstOpenColumn == column + 1)
    }
}

import Foundation

enum JSONPrettyError: Error { case utf8EncodingFailed }

extension Encodable {
    /// Get pretty JSON as a non-optional String (throws on failure)
    func prettyJSON() throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(self)
        guard let s = String(data: data, encoding: .utf8) else { throw JSONPrettyError.utf8EncodingFailed }
        return s
    }

    /// Print pretty JSON directly (avoids LLDB escaping)
    func printPrettyJSON() {
        do { print(try prettyJSON()) }
        catch { print("❌ prettyJSON failed: \(error)") }
    }
}
