import Foundation

public struct BoardPosition: Equatable, Codable {
    public let row: Int
    public let column: Int
    
    public init(
        row: Int,
        column: Int
    ) {
        self.row = row
        self.column = column
    }
}
