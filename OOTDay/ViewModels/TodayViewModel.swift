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
    private let realm = try! Realm() // AppDelegate에서 설정한 기본 설정 사용
    private var selectedStyle: Style = .casual
    
    // Add a message relay to communicate messages to the view controller
    let messageRelay = BehaviorRelay<String?>(value: nil)
    
    private let weatherManager = WeatherManager()
    private let styleObject = StyleObject()
    
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
        let allClothes = realm.objects(ClothingItem.self)
        
        if allClothes.isEmpty {
            print("옷장이 비어 있습니다.")
            messageRelay.accept("옷장이 비어있어요!")
            outfitRelay.accept(nil)
            return
        }
        
        let currentSeason = getCurrentSeason()
        print("현재 시즌: \(currentSeason.rawValue)")
        
        // 시즌으로 필터링하기 전에 모든 아이템의 시즌 정보 확인
        print("DEBUG - 모든 아이템과 시즌 정보:")
        var itemsWithoutSeasons = 0
        for item in allClothes {
            if item.seasons.isEmpty {
                itemsWithoutSeasons += 1
                print("DEBUG - 시즌이 없는 아이템: \(item.id), Category: \(item.category)")
            } else {
                print("DEBUG - 아이템: \(item.id), Category: \(item.category), Seasons: \(Array(item.seasons))")
            }
        }
        
        if itemsWithoutSeasons > 0 {
            print("DEBUG - 시즌 정보가 없는 아이템이 \(itemsWithoutSeasons)개 있습니다.")
        }
        
        let availableClothes = closetViewModel.getClothesForSeason(currentSeason)
        print("Available clothes for season: \(currentSeason): \(availableClothes.count)")
        
        // Debug: Print each item's seasons and styles
        for item in allClothes {
            print("Item ID: \(item.id), Category: \(item.category), Seasons: \(Array(item.seasons).map { $0 }), Styles: \(Array(item.styles).map { $0 })")
        }
        
        // 시즌 정보가 잘못되었거나 아이템이 없을 경우
        if availableClothes.isEmpty {
            print("DEBUG - 현재 시즌(\(currentSeason.rawValue))에 해당하는 옷이 없습니다.")
            messageRelay.accept("이 계절에 맞는 옷이 없어요!")
            outfitRelay.accept(nil)
            return
        }
        
        // Define color palettes
        let neutralColors = [UIColor.white, UIColor.black, UIColor.gray]
        let warmColors = [UIColor.red, UIColor.orange, UIColor.yellow]
        let coolColors = [UIColor.blue, UIColor.green, UIColor.purple]
        let pastelColors = [UIColor.systemPink, UIColor.systemTeal, UIColor.systemYellow]
        
        // Function to calculate color distance
        func colorDistance(_ color1: UIColor, _ color2: UIColor) -> CGFloat {
            var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
            var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
            color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
            color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
            return sqrt(pow(r2 - r1, 2) + pow(g2 - g1, 2) + pow(b2 - b1, 2))
        }
        
        // Function to convert hex string to UIColor
        func colorFromHex(_ hex: String) -> UIColor {
            var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

            var rgb: UInt64 = 0
            Scanner(string: hexSanitized).scanHexInt64(&rgb)

            let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(rgb & 0x0000FF) / 255.0

            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }

        // Filter clothes by category and selected style
        let tops = availableClothes.filter { $0.category == Category.Top.rawValue && $0.styles.contains(selectedStyle.rawValue) }
        let bottoms = availableClothes.filter { $0.category == Category.Bottom.rawValue && $0.styles.contains(selectedStyle.rawValue) }
        let shoes = availableClothes.filter { $0.category == Category.Shoes.rawValue && $0.styles.contains(selectedStyle.rawValue) }
        let outers = availableClothes.filter { $0.category == Category.Outer.rawValue && $0.styles.contains(selectedStyle.rawValue) }
        
        print("Filtered tops: \(tops.count), bottoms: \(bottoms.count), shoes: \(shoes.count), outers: \(outers.count)")
        

        if availableClothes.isEmpty {
            messageRelay.accept("옷장이비어 있어요!")
            outfitRelay.accept(nil)
            return
        }


        // Update messageRelay with appropriate messages
        if tops.isEmpty || bottoms.isEmpty || shoes.isEmpty {
            let styleMsg = styleObject.changeStyleName(style: selectedStyle)
            var clothesMsgs:[String] = []
            if tops.isEmpty {
                clothesMsgs.append("상의")
            }
            if bottoms.isEmpty {
                clothesMsgs.append("하의")
            }
            if shoes.isEmpty {
                clothesMsgs.append("신발")
            }

            var clothesMsg = clothesMsgs.joined(separator: ",")

            
            messageRelay.accept("\(styleMsg) 스타일에 맞는 옷(\(clothesMsg))이 부족해요!")
            outfitRelay.accept(nil)
            return
        }
        
        // Generate outfits based on color combinations (색상 조합에 맞는 코디)
        var colorMatchedOutfits: [Outfit] = []
        // 모든 가능한 조합의 코디들 (색상 조합과 상관없이)
        var allPossibleOutfits: [Outfit] = []
        
        for top in tops {
            for bottom in bottoms {
                for shoe in shoes {
                    let outer = outers.first
                    
                    // 모든 가능한 조합을 추가
                    let outfit = Outfit(top: top, bottom: bottom, shoes: shoe, outer: outer, temperature: 20.0, weather: "Sunny")
                    allPossibleOutfits.append(outfit)
                    
                    // Convert first color from hex to UIColor
                    let topColor = top.colors.first.map { colorFromHex($0) } ?? UIColor.clear
                    let bottomColor = bottom.colors.first.map { colorFromHex($0) } ?? UIColor.clear
                    let shoeColor = shoe.colors.first.map { colorFromHex($0) } ?? UIColor.clear

                    // Example: Neutral + Point Color
                    if neutralColors.contains(topColor) || neutralColors.contains(bottomColor) {
                        colorMatchedOutfits.append(outfit)
                        print("Added outfit with neutral + point color")
                    }
                    
                    // Example: Analogous Colors
                    else if colorDistance(topColor, bottomColor) < 0.2 {
                        colorMatchedOutfits.append(outfit)
                        print("Added outfit with analogous colors")
                    }
                    
                    // Example: Complementary Colors
                    else if colorDistance(topColor, shoeColor) > 0.5 {
                        colorMatchedOutfits.append(outfit)
                        print("Added outfit with complementary colors")
                    }
                    
                    // Example: Tone-on-Tone
                    else if colorDistance(topColor, bottomColor) < 0.1 {
                        colorMatchedOutfits.append(outfit)
                        print("Added outfit with tone-on-tone colors")
                    }
                    
                    // Example: Pastel Colors
                    else if pastelColors.contains(topColor) && pastelColors.contains(bottomColor) {
                        colorMatchedOutfits.append(outfit)
                        print("Added outfit with pastel colors")
                    }
                }
            }
        }
        
        // 색상 조합에 맞는 코디가 있으면 그 중에서 선택, 없으면 모든 조합 중에서 선택
        let outfitsToChooseFrom = colorMatchedOutfits.isEmpty ? allPossibleOutfits : colorMatchedOutfits
        
        if outfitsToChooseFrom.isEmpty {
            messageRelay.accept("코디를 생성할 수 없어요!")
            outfitRelay.accept(nil)
            return
        }
        
        // Randomly select one outfit from the generated outfits
        if let randomOutfit = outfitsToChooseFrom.randomElement() {
            
            if colorMatchedOutfits.isEmpty {
                print("색상 조합에 맞는 코디가 없어서 임의로 선택했습니다.")
            }
            outfitRelay.accept(randomOutfit)
        } else {
            print("적절한 코디를 생성할 수 없습니다.")
            outfitRelay.accept(nil)
        }
    }
    
    // Helper methods to get current season and selected style
    private func getCurrentSeason() -> Season {
        return weatherManager.getCurrentSeason()
    }
    
    private func toggleFavorite() {
        guard let currentOutfit = outfitRelay.value else { return }
        
        do {
            try realm.write {
                currentOutfit.isFavorite.toggle()
            }
            // 현재 아웃핏 업데이트
            outfitRelay.accept(currentOutfit)
        } catch {
            print("Error toggling favorite: \(error)")
        }
    }
    
    private func getSelectedStyle() -> Style {
        return selectedStyle
    }
    
    func updateSelectedStyle(_ style: Style) {
        selectedStyle = style
    }
} 
