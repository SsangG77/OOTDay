import Foundation
import RxSwift
import RxCocoa
import RealmSwift

class HistoryViewModel {
    // MARK: - Output
    let outfits: Driver<[Outfit]>
    
    // MARK: - Private
    private let outfitsRelay = BehaviorRelay<[Outfit]>(value: [])
    private let realm = try! Realm()
    
    init() {
        outfits = outfitsRelay.asDriver()
        loadOutfits()
    }
    
    private func loadOutfits() {
        let outfits = realm.objects(Outfit.self).sorted(byKeyPath: "createdAt", ascending: false)
        print("DEBUG - HistoryViewModel: Loaded \(outfits.count) outfits")
        for outfit in outfits {
            print("DEBUG - Outfit ID: \(outfit.id), Created at: \(outfit.createdAt)")
        }
        outfitsRelay.accept(Array(outfits))
    }
} 