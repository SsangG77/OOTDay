import Foundation
import RxSwift
import RxCocoa
import RealmSwift

class ClosetViewModel {
    // MARK: - Input
    let selectedCategory = BehaviorRelay<Category?>(value: nil)
    
    // MARK: - Output
    let items: Driver<[ClothingItem]>
    
    // MARK: - Private
    private let disposeBag = DisposeBag()
    private let realm = try! Realm() // AppDelegate에서 설정한 기본 설정 사용
    let itemsRelay = BehaviorRelay<[ClothingItem]>(value: [])
    private var notificationToken: NotificationToken?
    
    // Add a relay to notify when items are deleted
    let itemsDeleted = PublishRelay<Void>()
    
    init() {
        items = itemsRelay.asDriver()
        
        // Observe category changes and update items
        selectedCategory
            .subscribe(onNext: { [weak self] category in
                self?.loadItems(for: category)
            })
            .disposed(by: disposeBag)
        
        // Initial load
        loadItems(for: nil)
        
        // Observe Realm changes
        notificationToken = realm.objects(ClothingItem.self).observe { [weak self] changes in
            self?.loadItems(for: self?.selectedCategory.value)
        }
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    private func loadItems(for category: Category?) {
        var items = realm.objects(ClothingItem.self)
        
        if let category = category {
            items = items.filter("category == %@", category.rawValue)
        }
        
        itemsRelay.accept(Array(items))
    }
    
    // Notify when an item is deleted
    func deleteItem(at index: Int) {
        var currentItems = itemsRelay.value
        guard index < currentItems.count else { return }
        
        // Remove the item from Realm
        let itemToDelete = currentItems[index]
        try? realm.write {
            realm.delete(itemToDelete)
        }
        
        // Update the itemsRelay
        currentItems.remove(at: index)
        itemsRelay.accept(currentItems)
        
        // Notify that items have been deleted
        itemsDeleted.accept(())
        
        // Print statement for debugging
        print("Item deleted")
    }
    
    // Add a method to check if the closet is empty
    func isClosetEmpty() -> Bool {
        return itemsRelay.value.isEmpty
    }
    
    // Add a method to get clothes for a specific season
    func getClothesForSeason(_ season: Season) -> [ClothingItem] {

        let seasonRawValue = season.rawValue
        
        // 모든 아이템 출력
        let allItems = realm.objects(ClothingItem.self)

        
        // 임시 해결책 제거 - 자동으로 Spring 추가하지 않음
        
        // 시즌으로 필터링
        let items = realm.objects(ClothingItem.self).filter("ANY seasons == %@", seasonRawValue)
        
        
        // 디버깅을 위해 모든 아이템의 시즌 정보 출력
//        for item in allItems {
//            print("Item: \(item.id), Seasons: \(Array(item.seasons))")
//        }
        
        return Array(items)
    }
} 
