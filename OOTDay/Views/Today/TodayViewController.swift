import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

class TodayViewController: BaseViewController {
    
    // MARK: - UI Components
    private let dateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 24, weight: .bold)
        $0.textColor = .black
        $0.text = "Tue, Apr23"
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
    
    private let outfitView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let topImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    private let bottomImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    private let shoesImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    private let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.distribution = .fillEqually
    }
    
    private let seeAnotherButton = UIButton(type: .system).then {
        $0.setTitle("See Another\nOutfit", for: .normal)
        $0.titleLabel?.numberOfLines = 2
        $0.titleLabel?.textAlignment = .center
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        $0.layer.cornerRadius = 20
    }
    
    private let favoriteButton = UIButton(type: .system).then {
        $0.setTitle("Favorite", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        $0.layer.cornerRadius = 20
    }
    
    // MARK: - Properties
    private let viewModel = TodayViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 247/255, green: 143/255, blue: 67/255, alpha: 1)
        updateWeatherInfo()
    }
    
    // MARK: - Setup
    override func setupViews() {
        super.setupViews()
        
        [dateLabel, weatherIcon, weatherLabel, titleLabel, outfitView, buttonStackView].forEach {
            view.addSubview($0)
        }
        
        [topImageView, bottomImageView, shoesImageView].forEach {
            outfitView.addSubview($0)
        }
        
        [seeAnotherButton, favoriteButton].forEach {
            buttonStackView.addArrangedSubview($0)
        }
        
        // Set temporary images for testing
        topImageView.image = UIImage(named: "jacket")
        bottomImageView.image = UIImage(named: "pants")
        shoesImageView.image = UIImage(named: "shoes")
    }
    
    override func setupConstraints() {
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
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
        
        outfitView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(400)
        }
        
        topImageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(160)
        }
        
        bottomImageView.snp.makeConstraints {
            $0.top.equalTo(topImageView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(160)
        }
        
        shoesImageView.snp.makeConstraints {
            $0.top.equalTo(bottomImageView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(60)
        }
    }
    
    override func setupBindings() {
        seeAnotherButton.rx.tap
            .bind(to: viewModel.seeAnotherTapped)
            .disposed(by: disposeBag)
        
        favoriteButton.rx.tap
            .bind(to: viewModel.favoriteTapped)
            .disposed(by: disposeBag)
        
        viewModel.currentOutfit
            .drive(onNext: { [weak self] outfit in
                self?.updateOutfit(outfit)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private Methods
    private func updateWeatherInfo() {
        weatherLabel.text = "22°"
    }
    
    private func updateOutfit(_ outfit: Outfit?) {
        // Update outfit images
    }
} 


#Preview {
    TodayViewController()
}
