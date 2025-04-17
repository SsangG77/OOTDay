import Foundation
import RxSwift
import RxCocoa

class TodayViewModel {
    // MARK: - Input
    let seeAnotherTapped = PublishRelay<Void>()
    let favoriteTapped = PublishRelay<Void>()
    
    // MARK: - Output
    let currentOutfit: Driver<Outfit?>
    
    // MARK: - Private
    private let disposeBag = DisposeBag()
    private let outfitRelay = BehaviorRelay<Outfit?>(value: nil)
    
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
    }
    
    private func generateNewOutfit() {
        // TODO: Implement outfit generation logic
        // This should consider:
        // 1. Current weather
        // 2. User's clothing items
        // 3. Style matching
    }
    
    private func toggleFavorite() {
        guard let outfit = outfitRelay.value else { return }
        outfit.isFavorite.toggle()
        // TODO: Save to Realm
    }
} 