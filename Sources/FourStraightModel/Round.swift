import Foundation

public struct Round: Equatable, Codable {
    public let rows: Int
    public let columns: Int
    public let winLength: Int
    public let started: Date
    public var completed: Date?
    public var log: [DropAction] = []
    public var state: State
    public var players: [Player]
    public var board: [[PlayerID?]]
    
    public init(
        rows: Int = 6,
        columns: Int = 7,
        winLength: Int = 4,
        players: [Player]
    ) {
        self.started = .now
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
        case complete(
            winningPlayerId: String,
            positions: [BoardPosition]
        )
        case tie
    }
    
    public struct DropAction: Equatable, Codable {
        public let playerID: String
        public let column: Int
        public let timestamp: Date
        public let isForced: Bool
        
        public init(
            playerID: String,
            column: Int,
            timestamp: Date,
            isForced: Bool
        ) {
            self.playerID = playerID
            self.column = column
            self.timestamp = timestamp
            self.isForced = isForced
        }
    }
}
