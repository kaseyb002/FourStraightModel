import Foundation

extension Round {
    public var playerFilledBoard: [[Player?]] {
        board.map { row in
            row.map { id in
                players.first { $0.id == id }
            }
        }
    }
    
    public var winningPositions: Set<BoardPosition> {
        switch state {
        case .complete(_, let positions):
            return Set(positions)
            
        case .tie, .waitingForPlayer:
            return []
        }
    }
    
    public func isPlayersTurn(playerID: String) -> Bool {
        switch state {
        case .waitingForPlayer(let id):
            return playerID == id

        case .complete, .tie:
            return false
        }
    }
    
    public func player(byID id: String) -> Player? {
        players.first(where: { $0.id == id })
    }
    
    public var currentPlayer: Player? {
        switch state {
        case .complete, .tie:
            nil
            
        case .waitingForPlayer(let playerID):
            player(byID: playerID)
        }
    }
    
    public var firstOpenColumn: Int? {
        for row in 0 ..< rows {
            for column in 0 ..< columns {
                if board[row][column] == nil {
                    return column
                }
            }
        }
        return nil
    }
}

extension Round.State {
    public var isComplete: Bool {
        switch self {
        case .complete, .tie:
            return true
            
        case .waitingForPlayer:
            return false
        }
    }
}
