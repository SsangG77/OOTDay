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
    let closetViewModel = ClosetViewModel()
    
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
            // TODO: Implement outfit generation logic
        }
    }
    
    private func toggleFavorite() {
        guard let outfit = outfitRelay.value else { return }
        outfit.isFavorite.toggle()
        // TODO: Save to Realm
    }
} 