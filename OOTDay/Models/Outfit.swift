import Foundation
import RealmSwift

class Outfit: Object {
    @Persisted(primaryKey: true) var id = UUID().uuidString
    @Persisted var top: ClothingItem?
    @Persisted var bottom: ClothingItem?
    @Persisted var shoes: ClothingItem?
    @Persisted var temperature: Double
    @Persisted var weather: String
    @Persisted var createdAt = Date()
    @Persisted var isFavorite = false
    
    convenience init(top: ClothingItem?, bottom: ClothingItem?, shoes: ClothingItem?, temperature: Double, weather: String) {
        self.init()
        self.top = top
        self.bottom = bottom
        self.shoes = shoes
        self.temperature = temperature
        self.weather = weather
    }
} 