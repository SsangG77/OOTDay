import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then
import WeatherKit
import CoreLocation


//MARK: - HeaderViewController
class HeaderView: UIView {
 
    //MARK: - View
    private let dateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 24, weight: .bold)
        $0.textColor = .black
    }
    
    private let weatherLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 24, weight: .bold)
        $0.textColor = .black
    }
    
    private let weatherIcon = UIImageView().then {
        $0.image = UIImage(systemName: "sun.max.fill")
        $0.tintColor = .black
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 36, weight: .bold)
        $0.text = "Today's Outfit"
        $0.textColor = .black
    }
    
    
    private let weatherManager = WeatherManager()
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMM d"
        dateLabel.text = dateFormatter.string(from: Date())
        
        
        [dateLabel, weatherIcon, weatherLabel, titleLabel].forEach {
            addSubview($0)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }
        
        weatherIcon.snp.makeConstraints {
            $0.centerY.equalTo(dateLabel)
            $0.trailing.equalTo(weatherLabel.snp.leading).offset(-4)
            $0.width.height.equalTo(24)
        }
        
        weatherLabel.snp.makeConstraints {
            $0.centerY.equalTo(dateLabel)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
        }
        
        updateWeatherInfo()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Private Methods
    private func updateWeatherInfo() {
        weatherManager.fetchWeather { [weak self] weather in
            guard let self = self, let weather = weather else { return }
            DispatchQueue.main.async {
                let temperature = weather.currentWeather.temperature.value
                let roundedTemp = round(temperature * 10) / 10  // 소수점 한 자리까지 반올림
                
                self.weatherLabel.text = "\(roundedTemp)°"
            }
        }
    }
}

//MARK: - BottomButtonViewController
class BottomButtonView: UIView {
    
    var viewModel: TodayViewModel
    
//    private let styles = ["캐주얼", "포멀", "스포티", "빈티지", "보헤미안", "시크", "프레피", "펑크"]
    
    //MARK: - properties
    let disposeBag = DisposeBag()
    
    var showStyleActionSheet: () -> Void
    
    
    //MARK: - View
    private let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.distribution = .fill
    }
    
    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.tintColor = .systemYellow
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.1
        return button
    }()
    
    private let seeAnotherButton = UIButton(type: .system).then {
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        $0.setImage(UIImage(systemName: "arrow.clockwise", withConfiguration: config), for: .normal)
        $0.tintColor = .white
        $0.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        $0.layer.cornerRadius = 20
    }
    
    let styleButton = UIButton(type: .system).then {
        $0.setTitle("캐주얼", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        $0.layer.cornerRadius = 20
    }
    
    
    
    init(viewModel: TodayViewModel, showStyleActionSheet: @escaping () -> Void) {
        
        self.viewModel = viewModel
        self.showStyleActionSheet = showStyleActionSheet
        super.init(frame: .zero)
        
        
        addSubview(buttonStackView)
        
        [styleButton, favoriteButton, seeAnotherButton].forEach {
            buttonStackView.addArrangedSubview($0)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-20)
            $0.height.equalTo(60)
        }
        
        // 각 버튼의 크기 비율 설정 (간격 12포인트 고려)
        let totalSpacing: CGFloat = 24 // 버튼 사이 간격 2개 (12 * 2)
        
        styleButton.snp.makeConstraints {
            $0.width.equalTo(buttonStackView.snp.width).multipliedBy(0.5).offset(-totalSpacing * 0.5) // 전체 너비의 50%에서 간격의 절반만큼 빼기
        }
        
        favoriteButton.snp.makeConstraints {
            $0.width.equalTo(buttonStackView.snp.width).multipliedBy(0.25).offset(-totalSpacing * 0.25) // 전체 너비의 25%에서 간격의 1/4만큼 빼기
        }
        
        seeAnotherButton.snp.makeConstraints {
            $0.width.equalTo(buttonStackView.snp.width).multipliedBy(0.25).offset(-totalSpacing * 0.25) // 전체 너비의 25%에서 간격의 1/4만큼 빼기
        }
        
        
        
        seeAnotherButton.rx.tap
            .bind(to: viewModel.seeAnotherTapped)
            .disposed(by: disposeBag)
        
        styleButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showStyleActionSheet()
            })
            .disposed(by: disposeBag)
        
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        
        
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
//    private func showStyleActionSheet() {
//        let alert = UIAlertController(title: "스타일 선택", message: nil, preferredStyle: .actionSheet)
//        
//        for style in styles {
//            let action = UIAlertAction(title: style, style: .default) { [weak self] _ in
//                self?.styleButton.setTitle(style, for: .normal)
//                // Update selected style in view model
//                if let styleEnum = Style(rawValue: style) {
//                    self?.viewModel.updateSelectedStyle(styleEnum)
//                }
//            }
//            alert.addAction(action)
//        }
//        
//        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
//        alert.addAction(cancelAction)
//        
//        present(alert, animated: true)
//    }
    
    @objc private func favoriteButtonTapped() {
        viewModel.favoriteTapped.accept(())
    }
}

//MARK: - TodayViewController
class TodayViewController: BaseViewController {
    
    let boxSize = 260
    let spacing = 25
    
    // MARK: - Properties
    private let viewModel = TodayViewModel()
    private let styles = ["캐주얼", "포멀", "스포티", "빈티지", "보헤미안", "시크", "프레피", "펑크"]
    
    let headerView = HeaderView()
    var bottomButtonsView: BottomButtonView!
    
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
        view.backgroundColor = UIColor(red: 247/255, green: 143/255, blue: 67/255, alpha: 1)
        // Initialize bottomButtonsView now that self is available
        bottomButtonsView = BottomButtonView(
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
                let cancelAction = UIAlertAction(title: "취소", style: .cancel)
                alert.addAction(cancelAction)
                self.present(alert, animated: true)
            }
        )
        self.bottomButtonsView.viewModel = self.viewModel

        
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
            $0.top.leading.trailing.equalToSuperview().offset(10)
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
                self?.emptyOutfitMessageLabel.isHidden = outfit != nil
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

