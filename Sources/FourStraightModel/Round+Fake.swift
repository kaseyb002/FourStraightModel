import Foundation

extension Round {
    public static func fake(
        rows: Int = 6,
        columns: Int = 7,
        winLength: Int = 4,
        players: [Player] = [Player.fake(), Player.fake()]
    ) -> Self {
        return Round(
            rows: rows,
            columns: columns,
            winLength: winLength,
            players: players
        )
    }
}