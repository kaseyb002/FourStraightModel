import Foundation

public struct Round: Equatable, Codable {
    public let rows: Int
    public let columns: Int
    public let winLength: Int
    public var state: State
    public var players: [Player]
    public var board: [[PlayerID?]]
    
    public init(
        rows: Int = 6,
        columns: Int = 7,
        winLength: Int = 4,
        players: [Player]
    ) {
        self.rows = rows
        self.columns = columns
        self.winLength = winLength
        self.players = players
        self.players[1] = players[1].changeChecker(color: players[0].checkerColor.opposite)
        self.state = .waitingForPlayer(id: players[0].id)
        self.board = Array(repeating: Array(repeating: nil, count: columns), count: rows)
    }

    public enum State: Equatable, Codable {
        case waitingForPlayer(id: String)
        case complete(winningPlayerID: String)
        case tie
    }
}
