import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then
import WeatherKit
import CoreLocation

//MARK: - TodayViewController
class TodayViewController: BaseViewController {
    
    let boxSize = 260
    let spacing = 25
    
    // MARK: - Properties
    private let viewModel = TodayViewModel()
    private let styles = ["캐주얼", "포멀", "스포티", "빈티지", "보헤미안", "시크", "프레피", "펑크"]
    
    let headerView = HeaderView()
    private lazy var bottomButtonsView: BottomButtonView = {
        BottomButtonView(
            viewModel: viewModel,
            showStyleActionSheet: { [weak self] in
                guard let self = self else { return }
                let alert = UIAlertController(title: "스타일 선택", message: nil, preferredStyle: .actionSheet)
                for style in self.styles {
                    let action = UIAlertAction(title: style, style: .default) { [weak self] _ in
                        guard let self = self else { return }
                        self.bottomButtonsView.styleButton.setTitle(style, for: .normal)
                        if let styleEnum = Style(rawValue: style) {
                            self.viewModel.updateSelectedStyle(styleEnum)
                        }
                    }
                    alert.addAction(action)
                }
                alert.addAction(UIAlertAction(title: "취소", style: .cancel))
                self.present(alert, animated: true)
            }
        )
    }()
    
    private let outfitView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private let topImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 10
    }
    
    private let topLabel: UILabel = {
        let label = UILabel()
        label.text = "Top"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        return label
    }()
    
    private let bottomImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 10
    }
    
    private let bottomLabel: UILabel = {
        let label = UILabel()
        label.text = "Bottom"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        return label
    }()
    
    private let shoesImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 10
    }
    
    private let shoesLabel: UILabel = {
        let label = UILabel()
        label.text = "Shoes"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        return label
    }()
    
    private let outerImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 10
        $0.isHidden = true
    }
    
    private let outerLabel: UILabel = {
        let label = UILabel()
        label.text = "Outer"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        return label
    }()

    private let emptyOutfitMessageLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.text = "옷장이 비어있어요!"
        $0.font = .systemFont(ofSize: 24, weight: .bold)
        $0.textColor = .black
        $0.textAlignment = .center
        $0.isHidden = true // Initially hidden
    }

    
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupBindings()

        
        view.backgroundColor = UIColor(red: 247/255, green: 143/255, blue: 67/255, alpha: 1)
        
        // 기본 스타일을 캐주얼로 설정
        viewModel.updateSelectedStyle(.casual)
        
        // 디버깅: 모든 이미지뷰를 강제로 표시
//        topImageView.isHidden = false
//        bottomImageView.isHidden = false
//        shoesImageView.isHidden = false
        
        print("DEBUG - viewDidLoad completed")
    }
    
    // MARK: - Setup
    override func setupViews() {
        super.setupViews()
        
        // 메인 뷰에 추가되는 뷰들
        [outfitView, emptyOutfitMessageLabel, headerView, bottomButtonsView].forEach {
            view.addSubview($0)
        }
        
        // outfitView에 이미지뷰들과 레이블들 추가
        [topImageView, bottomImageView, shoesImageView, outerImageView,
         topLabel, bottomLabel, shoesLabel, outerLabel].forEach {
            outfitView.addSubview($0)
        }
        
        // 버튼 스택뷰에 버튼들 추가
        
    }
    
    override func setupConstraints() {
       
        
        // 격자형 레이아웃: 상의(왼쪽 위), 하의(오른쪽 위), 신발(왼쪽 아래), 외투(오른쪽 아래)
        let itemSize = (UIScreen.main.bounds.width - 60) / 2 // 화면 너비에서 여백 빼고 2로 나눔
        
        // outfitView 제약조건 변경
        outfitView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.height.equalTo(UIScreen.main.bounds.width - 10)
            $0.width.equalTo(UIScreen.main.bounds.width - 30)
        }
        
        // 상의 (왼쪽 위)
        topImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(8)
            $0.width.height.equalTo(itemSize)
        }
        
        topLabel.snp.makeConstraints {
            $0.top.equalTo(topImageView.snp.bottom).offset(8)
            $0.centerX.equalTo(topImageView)
        }
        
        // 하의 (오른쪽 위)
        bottomImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8)
            $0.trailing.equalToSuperview().inset(8)
            $0.width.height.equalTo(itemSize)
        }
        
        bottomLabel.snp.makeConstraints {
            $0.top.equalTo(bottomImageView.snp.bottom).offset(8)
            $0.centerX.equalTo(bottomImageView)
        }
        
        // 신발 (왼쪽 아래)
        shoesImageView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(8)
            $0.leading.equalToSuperview().inset(8)
            $0.width.height.equalTo(itemSize)
        }
        
        shoesLabel.snp.makeConstraints {
            $0.top.equalTo(shoesImageView.snp.bottom).offset(8)
            $0.centerX.equalTo(shoesImageView)
        }
        
        // 외투 (오른쪽 아래)
        outerImageView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(8)
            $0.trailing.equalToSuperview().inset(8)
            $0.width.height.equalTo(itemSize)
        }
        
        outerLabel.snp.makeConstraints {
            $0.top.equalTo(outerImageView.snp.bottom).offset(8)
            $0.centerX.equalTo(outerImageView)
        }
        
        emptyOutfitMessageLabel.snp.makeConstraints {
            $0.center.equalTo(outfitView)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        headerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100)
            $0.leading.trailing.equalToSuperview().offset(10)
        }
        
        bottomButtonsView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(100)
        }
        
    }
    
    override func setupBindings() {
        
        viewModel.currentOutfit
            .drive(onNext: { [weak self] outfit in
                self?.updateOutfit(outfit)
            })
            .disposed(by: disposeBag)
        
        // Convert messageRelay to Driver to use drive method
        viewModel.messageRelay
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
            .drive(onNext: { [weak self] message in
                self?.emptyOutfitMessageLabel.text = message
                self?.emptyOutfitMessageLabel.isHidden = false
            })
            .disposed(by: disposeBag)
        
        // Hide the message label when an outfit is available
        viewModel.currentOutfit
            .drive(onNext: { [weak self] outfit in
                self?.emptyOutfitMessageLabel.isHidden = outfit == nil
            })
            .disposed(by: disposeBag)
        
    }
    
    
    
    private func updateOutfit(_ outfit: Outfit?) {
        print("DEBUG - updateOutfit called with outfit: \(outfit != nil ? "있음" : "없음")")
        guard let outfit = outfit else {
            print("DEBUG - Outfit is nil, clearing images")
            topImageView.image = nil
            bottomImageView.image = nil
            shoesImageView.image = nil
            outerImageView.isHidden = true
            outerLabel.isHidden = true
            // 임시 주석
//            favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            return
        }
        
        // 즐겨찾기 버튼 상태 업데이트
        let starImage = outfit.isFavorite ? "star.fill" : "star"
        // 임시 주석
//        favoriteButton.setImage(UIImage(systemName: starImage), for: .normal)
        
        // 실제 이미지 로드
        // 상의
        let topImage = ImageStorageService.shared.loadImage(withName: outfit.top?.id ?? "")
        print("DEBUG - Top ID: \(outfit.top?.id ?? "없음"), Image loaded: \(topImage != nil ? "성공" : "실패")")
        topImageView.image = topImage ?? UIImage(systemName: "tshirt")
        topImageView.tintColor = topImage == nil ? .black : .clear
        topImageView.contentMode = .scaleAspectFill
        topImageView.isHidden = false
        
        // 하의
        let bottomImage = ImageStorageService.shared.loadImage(withName: outfit.bottom?.id ?? "")
        print("DEBUG - Bottom ID: \(outfit.bottom?.id ?? "없음"), Image loaded: \(bottomImage != nil ? "성공" : "실패")")
        bottomImageView.image = bottomImage ?? UIImage(systemName: "arrow.down")
        bottomImageView.tintColor = bottomImage == nil ? .black : .clear
        bottomImageView.contentMode = .scaleAspectFill
        bottomImageView.isHidden = false
        
        // 신발
        let shoesImage = ImageStorageService.shared.loadImage(withName: outfit.shoes?.id ?? "")
        print("DEBUG - Shoes ID: \(outfit.shoes?.id ?? "없음"), Image loaded: \(shoesImage != nil ? "성공" : "실패")")
        shoesImageView.image = shoesImage ?? UIImage(systemName: "bag")
        shoesImageView.tintColor = shoesImage == nil ? .black : .clear
        shoesImageView.contentMode = .scaleAspectFill
        shoesImageView.isHidden = false
        
        // 외투 (있는 경우에만)
        if let outer = outfit.outer {
            let outerImage = ImageStorageService.shared.loadImage(withName: outer.id)
            print("DEBUG - Outer ID: \(outer.id), Image loaded: \(outerImage != nil ? "성공" : "실패")")
            outerImageView.image = outerImage ?? UIImage(systemName: "star")
            outerImageView.tintColor = outerImage == nil ? .black : .clear
            outerImageView.contentMode = .scaleAspectFill
            outerImageView.isHidden = false
            outerLabel.isHidden = false
        } else {
            print("DEBUG - No outer available")
            outerImageView.isHidden = true
            outerLabel.isHidden = true
        }
    }
    
} 


#Preview {
    TodayViewController()
}

