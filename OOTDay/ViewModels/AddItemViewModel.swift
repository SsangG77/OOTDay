import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import UIKit

class AddItemViewModel {
    // MARK: - Input
    let selectedImage = BehaviorRelay<UIImage?>(value: nil)
    
    // MARK: - Private
    private let disposeBag = DisposeBag()
    private let realm = try! Realm()
    private let imageStorage = ImageStorageService.shared
    
    func saveItem(
        image: UIImage,
        category: Category,
        colors: [String],
        style: Style,
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
                item.colors.append(objectsIn: colors)
                item.styleEnum = style
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
    
    // MARK: - Validation
    func validateInput(image: UIImage?, category: Category?, colors: [String], style: Style?, seasons: [Season]) -> Bool {
        guard image != nil else { return false }
        guard category != nil else { return false }
        guard !colors.isEmpty else { return false }
        guard style != nil else { return false }
        guard !seasons.isEmpty else { return false }
        
        return true
    }
    
    // MARK: - Helpers
    func parseColors(_ text: String) -> [String] {
        return text.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
} 
