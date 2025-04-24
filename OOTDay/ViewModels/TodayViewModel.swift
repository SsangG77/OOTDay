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
    private var selectedStyle: Style = .casual
    private let imageStorage = ImageStorageService.shared
    private let realm = try! Realm()
    
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
            // Example: Implement outfit generation logic
            let currentSeason = getCurrentSeason()
            let availableClothes = closetViewModel.getClothesForSeason(currentSeason)
            let selectedStyle = getSelectedStyle()
            let filteredClothes = availableClothes.filter { $0.style == selectedStyle.rawValue }
            
            // Define color palettes
            let neutralColors = [UIColor.white, UIColor.black, UIColor.gray]
            let warmColors = [UIColor.red, UIColor.orange, UIColor.yellow]
            let coolColors = [UIColor.blue, UIColor.green, UIColor.purple]
            
            // Function to calculate color distance
            func colorDistance(_ color1: UIColor, _ color2: UIColor) -> CGFloat {
                var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
                var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
                color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
                color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
                return sqrt(pow(r2 - r1, 2) + pow(g2 - g1, 2) + pow(b2 - b1, 2))
            }
            
            // Select clothes based on color combination
            let top = filteredClothes.min { colorDistance(UIColor(hex: $0.color), neutralColors[0]) < colorDistance(UIColor(hex: $1.color), neutralColors[0]) }
            let bottom = filteredClothes.min { colorDistance(UIColor(hex: $0.color), coolColors[0]) < colorDistance(UIColor(hex: $1.color), coolColors[0]) }
            let shoes = filteredClothes.min { colorDistance(UIColor(hex: $0.color), warmColors[0]) < colorDistance(UIColor(hex: $1.color), warmColors[0]) }
            
            // Example temperature and weather
            let temperature = 20.0 // Example temperature
            let weather = "Sunny" // Example weather
            
            if let top = top, let bottom = bottom, let shoes = shoes {
                let outfit = Outfit(top: top, bottom: bottom, shoes: shoes, temperature: temperature, weather: weather)
                outfitRelay.accept(outfit)
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
    
    private func getSelectedStyle() -> Style {
        return selectedStyle
    }
    
    func updateSelectedStyle(_ style: Style) {
        selectedStyle = style
    }
    
    private func toggleFavorite() {
        guard let outfit = outfitRelay.value else { return }
        outfit.isFavorite.toggle()
        // TODO: Save to Realm
    }
    
    // Update saveItem to use the color property
    func saveItem(
        image: UIImage,
        category: Category,
        color: String, // Change to single color
        style: String,
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
                item.color = color // Set single color
                item.style = style
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
} 
