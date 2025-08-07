import Foundation

extension Round {
    public var playerFilledBoard: [[Player?]] {
        board.map { row in
            row.map { id in
                players.first { $0.id == id }
            }
        }
    }
}
