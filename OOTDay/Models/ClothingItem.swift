import Foundation
import RealmSwift

enum Category: String, CaseIterable {
    case outer = "겉옷"
    case top = "상의"
    case bottom = "하의"
    case shoes = "신발"
}

enum Season: String, CaseIterable {
    case spring = "봄"
    case summer = "여름"
    case fall = "가을"
    case winter = "겨울"
}

class ClothingItem: Object {
    @Persisted(primaryKey: true) var id = UUID().uuidString
    @Persisted var category: String // Category의 rawValue
    @Persisted var imageUrl: String
    @Persisted var colors = List<String>()
    @Persisted var style: String // String으로 변경
    @Persisted var seasons = List<String>() // Season의 rawValue
    @Persisted var createdAt = Date()
    
    convenience init(category: Category, imageUrl: String, colors: [String], style: Style, seasons: [Season]) {
        self.init()
        self.category = category.rawValue
        self.imageUrl = imageUrl
        self.colors.append(objectsIn: colors)
        self.style = style.rawValue // Directly assign Style
        self.seasons.append(objectsIn: seasons.map { $0.rawValue })
    }

    // Computed property to get and set Style
    var styleEnum: Style? {
        get {
            return Style(rawValue: style)
        }
        set {
            style = newValue?.rawValue ?? "casual"
        }
    }
} 
