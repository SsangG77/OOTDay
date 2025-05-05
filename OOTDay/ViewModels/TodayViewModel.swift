import Foundation
import RxSwift
import RxCocoa
import UIKit
import RealmSwift

class TodayViewModel {
    // MARK: - Input
    let seeAnotherTapped = PublishRelay<Void>()
    let favoriteTapped = PublishRelay<Void>()
    
    // MARK: - Output
    let currentOutfit: Driver<Outfit?>
    
    // MARK: - Private
    private let disposeBag = DisposeBag()
    private let outfitRelay = BehaviorRelay<Outfit?>(value: nil)
    let closetViewModel = ClosetViewModel()
    private let imageStorage = ImageStorageService.shared
    private let realm = try! Realm()
    private var selectedStyle: Style = .casual
    
    init() {
        currentOutfit = outfitRelay.asDriver()
        
        seeAnotherTapped
            .subscribe(onNext: { [weak self] in
                self?.generateNewOutfit()
            })
            .disposed(by: disposeBag)
        
        favoriteTapped
            .subscribe(onNext: { [weak self] in
                self?.toggleFavorite()
            })
            .disposed(by: disposeBag)
        
        // Initial outfit
        generateNewOutfit()
        
        // Subscribe to itemsDeleted to update outfit when items are deleted
        closetViewModel.itemsDeleted
            .subscribe(onNext: { [weak self] in
                print("itemsDeleted received")
                self?.generateNewOutfit()
            })
            .disposed(by: disposeBag)
    }
    
    private func generateNewOutfit() {
        print("generateNewOutfit called")
        if closetViewModel.isClosetEmpty() {
            print("옷장이 비어 있습니다.")
            outfitRelay.accept(nil)
        } else {
            let currentSeason = getCurrentSeason()
            let availableClothes = closetViewModel.getClothesForSeason(currentSeason)
            print("Available clothes for season: \(currentSeason): \(availableClothes.count)")
            
            // Debug: Print each item's style
            for item in availableClothes {
                print("Item ID: \(item.id), Style: \(item.style)")
            }
            
            // Define color palettes
            let neutralColors = [UIColor.white, UIColor.black, UIColor.gray]
            let warmColors = [UIColor.red, UIColor.orange, UIColor.yellow]
            let coolColors = [UIColor.blue, UIColor.green, UIColor.purple]
            let pastelColors = [UIColor.systemPink, UIColor.systemTeal, UIColor.systemYellow]
            
            // Function to calculate color distance
            func colorDistance(_ color1: UIColor, _ color2: UIColor) -> CGFloat {
                var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
                var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
                color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
                color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
                return sqrt(pow(r2 - r1, 2) + pow(g2 - g1, 2) + pow(b2 - b1, 2))
            }
            
            // Function to convert hex string to UIColor
            func colorFromHex(_ hex: String) -> UIColor {
                var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
                hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

                var rgb: UInt64 = 0
                Scanner(string: hexSanitized).scanHexInt64(&rgb)

                let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
                let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
                let blue = CGFloat(rgb & 0x0000FF) / 255.0

                return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
            }

            // Filter clothes by category and selected style
            let tops = availableClothes.filter { $0.category == Category.top.rawValue && $0.styleEnum == selectedStyle }
            let bottoms = availableClothes.filter { $0.category == Category.bottom.rawValue && $0.styleEnum == selectedStyle }
            let shoes = availableClothes.filter { $0.category == Category.shoes.rawValue && $0.styleEnum == selectedStyle }
            let outers = availableClothes.filter { $0.category == Category.outer.rawValue && $0.styleEnum == selectedStyle }
            
            print("Filtered tops: \(tops.count), bottoms: \(bottoms.count), shoes: \(shoes.count), outers: \(outers.count)")
            
            // Generate outfits based on color combinations
            var outfits: [Outfit] = []
            for top in tops {
                for bottom in bottoms {
                    for shoe in shoes {
                        let outer = outers.first
                        
                        // Convert first color from hex to UIColor
                        let topColor = top.colors.first.map { colorFromHex($0) } ?? UIColor.clear
                        let bottomColor = bottom.colors.first.map { colorFromHex($0) } ?? UIColor.clear
                        let shoeColor = shoe.colors.first.map { colorFromHex($0) } ?? UIColor.clear

                        // Example: Neutral + Point Color
                        if neutralColors.contains(topColor) || neutralColors.contains(bottomColor) {
                            outfits.append(Outfit(top: top, bottom: bottom, shoes: shoe, outer: outer, temperature: 20.0, weather: "Sunny"))
                            print("Added outfit with neutral + point color")
                        }
                        
                        // Example: Analogous Colors
                        if colorDistance(topColor, bottomColor) < 0.2 {
                            outfits.append(Outfit(top: top, bottom: bottom, shoes: shoe, outer: outer, temperature: 20.0, weather: "Sunny"))
                            print("Added outfit with analogous colors")
                        }
                        
                        // Example: Complementary Colors
                        if colorDistance(topColor, shoeColor) > 0.5 {
                            outfits.append(Outfit(top: top, bottom: bottom, shoes: shoe, outer: outer, temperature: 20.0, weather: "Sunny"))
                            print("Added outfit with complementary colors")
                        }
                        
                        // Example: Tone-on-Tone
                        if colorDistance(topColor, bottomColor) < 0.1 {
                            outfits.append(Outfit(top: top, bottom: bottom, shoes: shoe, outer: outer, temperature: 20.0, weather: "Sunny"))
                            print("Added outfit with tone-on-tone colors")
                        }
                        
                        // Example: Pastel Colors
                        if pastelColors.contains(topColor) && pastelColors.contains(bottomColor) {
                            outfits.append(Outfit(top: top, bottom: bottom, shoes: shoe, outer: outer, temperature: 20.0, weather: "Sunny"))
                            print("Added outfit with pastel colors")
                        }
                    }
                }
            }
            
            // Randomly select one outfit from the generated outfits
            if let randomOutfit = outfits.randomElement() {
                outfitRelay.accept(randomOutfit)
            } else {
                print("적절한 코디를 생성할 수 없습니다.")
                outfitRelay.accept(nil)
            }
        }
    }
    
    // Helper methods to get current season and selected style
    private func getCurrentSeason() -> Season {
        // Example logic to determine current season
        return .spring
    }
    
    private func toggleFavorite() {
        guard let outfit = outfitRelay.value else { return }
        outfit.isFavorite.toggle()
        // TODO: Save to Realm
    }
    
    // Update saveItem to use colors array
    func saveItem(
        image: UIImage,
        category: Category,
        colors: [String], // Change to array
        style: Style, // Change to Style type
        seasons: [Season]
    ) -> Completable {
        return Completable.create { [weak self] completable in
            guard let self = self else {
                completable(.error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "ViewModel is nil"])))
                return Disposables.create()
            }
            
            // Save image first
            do {
                let imageId = UUID().uuidString
                try self.imageStorage.saveImage(image, withName: imageId)
                
                // Create and save ClothingItem
                let item = ClothingItem()
                item.id = imageId
                item.category = category.rawValue
                item.colors.append(objectsIn: colors) // Use array
                item.style = style.rawValue // Store as String
                item.seasons.append(objectsIn: seasons.map { $0.rawValue })
                
                try self.realm.write {
                    self.realm.add(item)
                }
                
                completable(.completed)
            } catch {
                completable(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    private func getSelectedStyle() -> Style {
        return selectedStyle
    }
    
    func updateSelectedStyle(_ style: Style) {
        selectedStyle = style
    }
} 
