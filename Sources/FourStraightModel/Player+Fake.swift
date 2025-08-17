import Foundation

extension Player {
    public static func fake(
        id: String = UUID().uuidString,
        name: String = "Fake Player",
        imageURL: URL? = nil,
        checkerColor: CheckerColor = .red
    ) -> Self {
        return Player(
            id: id,
            name: name,
            imageURL: imageURL,
            checkerColor: checkerColor
        )
    }
}
