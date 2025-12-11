import Foundation

extension Player {
    public static func aiPlayer(
        id: String = UUID().uuidString,
        name: String = "AI Player",
        difficulty: AIDifficulty,
        checkerColor: CheckerColor
    ) -> AIPlayer {
        return AIPlayer(
            id: id,
            name: name,
            imageURL: nil,
            checkerColor: checkerColor,
            difficulty: difficulty
        )
    }
}

public struct AIPlayer: Equatable, Codable, Sendable {
    public let id: PlayerID
    public var name: String
    public var imageURL: URL?
    public let checkerColor: CheckerColor
    public let difficulty: AIDifficulty
    
    public enum CodingKeys: String, CodingKey {
        case id
        case name
        case imageURL = "imageUrl"
        case checkerColor
        case difficulty
    }
    
    public init(
        id: String,
        name: String,
        imageURL: URL?,
        checkerColor: CheckerColor,
        difficulty: AIDifficulty
    ) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.checkerColor = checkerColor
        self.difficulty = difficulty
    }
    
    public func changeChecker(color: CheckerColor) -> AIPlayer {
        AIPlayer(
            id: id,
            name: name,
            imageURL: imageURL,
            checkerColor: color,
            difficulty: difficulty
        )
    }
    
    public func makeMove(in round: Round) -> Int? {
        let ai = AIEngine(difficulty: difficulty)
        return ai.getBestMove(for: round, playerId: id)
    }
}

// Extension to convert between Player and AIPlayer
extension AIPlayer {
    public var asPlayer: Player {
        Player(
            id: id,
            name: name,
            imageURL: imageURL,
            checkerColor: checkerColor
        )
    }
}

extension Player {
    public var asAIPlayer: AIPlayer? {
        // This would need to be implemented if you want to convert regular players to AI
        // For now, return nil since we don't have difficulty information
        return nil
    }
}

