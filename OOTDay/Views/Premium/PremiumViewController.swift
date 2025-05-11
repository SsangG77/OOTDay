import UIKit
import RxSwift
import RxCocoa
import SnapKit

class PremiumViewController: BaseViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel = UILabel().then {
        $0.text = "프리미엄 기능"
        $0.font = .systemFont(ofSize: 28, weight: .bold)
    }
    
    private let featureStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 24
    }
    
    private lazy var features: [(icon: String, title: String, description: String)] = [
        ("wand.and.stars", "AI 기반 코디 추천", "인공지능이 당신의 스타일을 분석하여 최적의 코디를 추천해드립니다."),
        ("cloud.sun", "날씨 기반 추천", "오늘의 날씨에 맞는 완벽한 코디를 제안해드립니다."),
        ("star", "스타일 분석", "당신의 옷장을 분석하여 부족한 아이템을 추천해드립니다.")
    ]
    
    private let subscribeButton = UIButton(type: .system).then {
        $0.setTitle("구독하기 (월 ₩2,000)", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.backgroundColor = .systemBlue
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 12
    }
    
    // MARK: - Setup
    override func setupViews() {
        super.setupViews()
        title = "프리미엄"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [titleLabel, featureStackView, subscribeButton].forEach {
            contentView.addSubview($0)
        }
        
        setupFeatures()
    }
    
    override func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(20)
        }
        
        featureStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        subscribeButton.snp.makeConstraints {
            $0.top.equalTo(featureStackView.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(54)
            $0.bottom.equalToSuperview().offset(-24)
        }
    }
    
    override func setupBindings() {
        subscribeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.handleSubscription()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private Methods
    private func setupFeatures() {
        features.forEach { feature in
            let featureView = FeatureView()
            featureView.configure(
                icon: feature.icon,
                title: feature.title,
                description: feature.description
            )
            featureStackView.addArrangedSubview(featureView)
        }
    }
    
    private func handleSubscription() {
        // TODO: Implement subscription logic
    }
}

// MARK: - FeatureView
class FeatureView: UIView {
    private let iconView = UIImageView().then {
        $0.tintColor = .systemBlue
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        [iconView, titleLabel, descriptionLabel].forEach {
            addSubview($0)
        }
        
        iconView.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
            $0.width.height.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(iconView)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(iconView.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func configure(icon: String, title: String, description: String) {
        iconView.image = UIImage(systemName: icon)
        titleLabel.text = title
        descriptionLabel.text = description
    }
} 