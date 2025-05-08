import Foundation
import RealmSwift

enum Category: String, CaseIterable {
    case Outer = "Outer"
    case Top = "Top"
    case Bottom = "Bottom"
    case Shoes = "Shoes"
}

enum Season: String, CaseIterable {
    case spring = "Spring"
    case summer = "Summer"
    case fall = "Fall"
    case winter = "Winter"
}

class ClothingItem: Object {
    @Persisted(primaryKey: true) var id = UUID().uuidString
    @Persisted var category: String // Category의 rawValue
    @Persisted var imageUrl: String
    @Persisted var colors = List<String>()
    @Persisted var styles = List<String>() // Style의 rawValue 여러 개 저장
    @Persisted var seasons = List<String>() // Season의 rawValue
    @Persisted var createdAt = Date()
    
    convenience init(category: Category, imageUrl: String, colors: [String], styles: [Style], seasons: [Season]) {
        self.init()
        self.category = category.rawValue
        self.imageUrl = imageUrl
        self.colors.append(objectsIn: colors)
        self.styles.append(objectsIn: styles.map { $0.rawValue })
        self.seasons.append(objectsIn: seasons.map { $0.rawValue })
    }

    // Computed property to get and set Style
//    var styleEnum: Style? {
//        get {
//            return Style(rawValue: style)
//        }
//        set {
//            style = newValue?.rawValue ?? "casual"
//        }
//    }

    // 스타일 문자열 배열을 Style 열거형 배열로 변환하는 계산 속성
    var stylesEnum: [Style] {
        return styles.compactMap { Style(rawValue: $0) }
    }

    var categoryEnum: Category? {
        return Category(rawValue: category)
    }

    var seasonsEnum: [Season] {
        return seasons.compactMap { Season(rawValue: $0) }
    }
} 
