import Foundation

extension [[Player?]] {
    public static func emptyBoard(rows: Int, columns: Int) -> [[Player?]] {
        let rowSpots: Array<Player?> = .init(repeating: nil, count: columns)
        return Array(repeating: rowSpots, count: rows)
    }
}
