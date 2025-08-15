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
}
