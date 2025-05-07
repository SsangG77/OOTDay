import Foundation
import RealmSwift

enum Category: String, CaseIterable {
    case Outer = "Outer"
    case Top = "Top"
    case Bottom = "Bottom"
    case Shoes = "Shoes"
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
    @Persisted var styles = List<String>() // Store multiple styles
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
} 
