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
    private let realm = try! Realm() // AppDelegate에서 설정한 기본 설정 사용
    private let imageStorage = ImageStorageService.shared
    
    func saveItem(
        image: UIImage,
        category: Category,
        colors: [String],
        styles: [Style],
        seasons: [Season]
    ) -> Completable {
        return Completable.create { [weak self] completable in
            guard let self = self else {
                completable(.error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "ViewModel is nil"])))
                return Disposables.create()
            }
            
            print("DEBUG - saveItem - Seasons: \(seasons)")
            print("DEBUG - saveItem - Seasons raw values: \(seasons.map { $0.rawValue })")
            
            // Save image first
            do {
                let imageId = UUID().uuidString
                try self.imageStorage.saveImage(image, withName: imageId)
                
                // Create and save ClothingItem
                let item = ClothingItem()
                item.id = imageId
                item.category = category.rawValue
                item.colors.append(objectsIn: colors)
                item.styles.append(objectsIn: styles.map { $0.rawValue })
                
                // 확인: seasons 배열이 비어있지 않은지 체크
                if seasons.isEmpty {
                    print("DEBUG - ERROR: seasons array is empty!")
                    completable(.error(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Seasons array is empty"])))
                    return Disposables.create()
                } else {
                    let seasonValues = seasons.map { $0.rawValue }
                    print("DEBUG - Adding seasons: \(seasonValues)")
                    
                    // 시즌이 제대로 추가되었는지 확인
                    for season in seasonValues {
                        item.seasons.append(season)
                        print("DEBUG - Added season: \(season) to item \(item.id)")
                    }
                }
                
                try self.realm.write {
                    self.realm.add(item)
                    print("DEBUG - Item saved with seasons: \(Array(item.seasons))")
                }
                
                completable(.completed)
            } catch {
                print("DEBUG - Error saving item: \(error)")
                completable(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    // MARK: - Validation
    func validateInput(image: UIImage?, category: Category?, colors: [String], styles: [Style]?, seasons: [Season]) -> Bool {
        guard image != nil else { return false }
        guard category != nil else { return false }
        guard !colors.isEmpty else { return false }
        guard let styles = styles, !styles.isEmpty else { return false }
        guard !seasons.isEmpty else { return false }
        
        return true
    }
    
    // MARK: - Helpers
    func parseColors(_ text: String) -> [String] {
        return text.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }


    func changeStyleEnum(style: String) -> Style {
        print(#function, #line)
    switch style {
    case "캐주얼":
        return Style.casual
    case "포멀":
        return Style.formal
    case "스포티":
        return Style.sporty
    case "빈티지":
        return Style.vintage
    case "보헤미안":
        return Style.bohemian
    case "시크":
        return Style.chic
    case "프레피":
        return Style.preppy
    case "펑크":
        return Style.punk
    default:
        return Style.casual
    }

    }

} 
