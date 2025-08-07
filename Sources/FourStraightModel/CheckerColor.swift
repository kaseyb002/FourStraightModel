import Foundation

public enum CheckerColor: String, Equatable, Codable {
    case red = "r"
    case yellow = "y"
    
    public var opposite: CheckerColor {
        switch self {
        case .red: .yellow
        case .yellow: .red
        }
    }
    
    public var name: String {
        switch self {
        case .red: "Red"
        case .yellow: "Yellow"
        }
    }
    
    public var emoji: String {
        switch self {
        case .red: "🔴"
        case .yellow: "🟡"
        }
    }
}
