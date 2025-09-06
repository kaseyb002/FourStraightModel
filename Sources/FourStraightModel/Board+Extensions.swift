import Foundation

extension [[Player?]] {
    public static func emptyBoard(
        rows: Int = 6,
        columns: Int = 7
    ) -> [[Player?]] {
        let rowSpots: Array<Player?> = .init(repeating: nil, count: columns)
        return Array(repeating: rowSpots, count: rows)
    }
    
    public func isFilled(column: Int) -> Bool {
        guard !self.isEmpty,
              column >= 0,
              column < self[0].count else {
            return false
        }
        return self[0][column] != nil
    }
}
