import Foundation

// MARK: - Pretty descriptions

extension Player: CustomDebugStringConvertible, CustomStringConvertible {
    public var description: String { "\(name) (\(checkerColor.emoji))" }
    public var debugDescription: String {
        "Player(id:\(id), \(name) \(checkerColor.emoji))"
    }
}

extension Round.State: CustomStringConvertible {
    public var description: String {
        switch self {
        case .waitingForPlayer(let id): "Waiting for player id=\(id)"
        case .complete(let winningPlayerID): "Complete — winner id=\(winningPlayerID)"
        case .tie: "Tie"
        }
    }
}

extension Round: CustomDebugStringConvertible, CustomStringConvertible {
    public var description: String {
        "FourStraight \(rows)x\(columns), winLength=\(winLength), state=\(state)"
    }
    
    public var debugDescription: String {
        [
            description,
            debugBoardString(),
            "Players:",
            players.map { " • \($0.debugDescription)" }.joined(separator: "\n")
        ].joined(separator: "\n")
    }
    
    public func debugBoardString() -> String {
        // Map PlayerID -> emoji
        let emojiByID: [PlayerID: String] = Dictionary(uniqueKeysWithValues:
            players.map { ($0.id, $0.checkerColor.emoji) }
        )
        
        let horizontalBorder = String(repeating: "━", count: columns * 3)
        
        let rowsStrings: [String] = (0..<rows).map { r in
            (0..<columns).map { c in
                if let pid = board[r][c] {
                    return emojiByID[pid] ?? "?"
                } else {
                    return "⚫️" // wide blank spot
                }
            }.joined(separator: " ")
        }
        
        return """
        \(horizontalBorder)
        \(rowsStrings.joined(separator: "\n"))
        \(horizontalBorder)
        """
    }
}
