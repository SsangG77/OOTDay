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


    func nameToStyle(name: String) -> Style {
        switch name {
            case "캐주얼":
                return .casual
            case "포멀":
                return .formal
            case "스포티":
                return .sporty
            case "빈티지":
                return .vintage
            case "보헤미안":
                return .bohemian
            case "시크":
                return .chic
            case "프리피":
                return .preppy
            case "펑크":
                return .punk
        default:
            return .casual
        }
    }

}
