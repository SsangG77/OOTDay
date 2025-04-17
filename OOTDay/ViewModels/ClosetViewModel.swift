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
} 
