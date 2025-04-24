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
    private let realm = try! Realm()
    private let itemsRelay = BehaviorRelay<[ClothingItem]>(value: [])
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
        return itemsRelay.value.filter { $0.seasons.contains(season.rawValue) }
    }
} 
