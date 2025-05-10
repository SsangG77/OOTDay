import Foundation

// Define the Style enum with various style options
enum Style: String {
    case casual = "Casual"
    case formal = "Formal"
    case sporty = "Sporty"
    case vintage = "Vintage"
    case bohemian = "Bohemian"
    case chic = "Chic"
    case preppy = "Preppy"
    case punk = "Punk"
} 



class StyleObject {
    func changeStyleName(style: Style) -> String {
        switch style {
            case .casual:
                return "캐주얼"
            case .formal:
                return "포멀"
            case .sporty:
                return "스포티"
            case .vintage:
                return "빈티지"
            case .bohemian:
                return "보헤미안"
            case .chic:
                return "시크"
            case .preppy:
                return "프리피"
            case .punk:
                return "펑크"
        }
    }
}