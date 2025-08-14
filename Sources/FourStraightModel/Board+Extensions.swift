import Foundation

extension [[Player?]] {
    public static func emptyBoard(
        rows: Int = 6,
        columns: Int = 7
    ) -> [[Player?]] {
        let rowSpots: Array<Player?> = .init(repeating: nil, count: columns)
        return Array(repeating: rowSpots, count: rows)
    }
}
