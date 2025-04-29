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
            // Example: Implement outfit generation logic
            let currentSeason = getCurrentSeason()
            let availableClothes = closetViewModel.getClothesForSeason(currentSeason)
            
            // Filter clothes by category
            let tops = availableClothes.filter { $0.category == Category.top.rawValue }
            let bottoms = availableClothes.filter { $0.category == Category.bottom.rawValue }
            let shoes = availableClothes.filter { $0.category == Category.shoes.rawValue }
            let outers = availableClothes.filter { $0.category == Category.outer.rawValue }
            
            // Generate multiple outfits by creating combinations
            var outfits: [Outfit] = []
            for top in tops.prefix(3) { // Select top 3 tops
                for bottom in bottoms.prefix(3) { // Select top 3 bottoms
                    for shoe in shoes.prefix(3) { // Select top 3 shoes
                        let outer = outers.first // Select the first outer if available
                        let temperature = 20.0 // Example temperature
                        let weather = "Sunny" // Example weather
                        let outfit = Outfit(top: top, bottom: bottom, shoes: shoe, outer: outer, temperature: temperature, weather: weather)
                        outfits.append(outfit)
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
                item.colors.append(objectsIn: colors) // Use array
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
    
    private func getSelectedStyle() -> Style {
        return selectedStyle
    }
    
    func updateSelectedStyle(_ style: Style) {
        selectedStyle = style
    }
} 
