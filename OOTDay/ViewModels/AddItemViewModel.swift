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
        color: String,
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
                item.color = color
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
    
    // MARK: - Validation
    func validateInput(image: UIImage?, category: Category?, color: String, style: String, seasons: [Season]) -> Bool {
        guard image != nil else { return false }
        guard category != nil else { return false }
        guard !color.isEmpty else { return false }
        guard !style.isEmpty else { return false }
        guard !seasons.isEmpty else { return false }
        
        return true
    }
    
    // MARK: - Helpers
    func parseColor(_ text: String) -> String {
        return text.trimmingCharacters(in: .whitespaces)
    }
} 