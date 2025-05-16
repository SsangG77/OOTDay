import UIKit
import RxSwift
import RxCocoa
import SnapKit

class HistoryViewController: BaseViewController {
    
    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 46, weight: .bold)
        $0.text = "History"
        $0.textColor = .black
    }
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.register(OutfitHistoryCell.self, forCellReuseIdentifier: "OutfitHistoryCell")
        return tv
    }()
    
    // MARK: - Properties
    private let viewModel = HistoryViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 250/255, green: 245/255, blue: 237/255, alpha: 1)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // 테이블뷰 설정
        tableView.delegate = self
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    // MARK: - Setup
    override func setupViews() {
        super.setupViews()
        
        [titleLabel, tableView].forEach {
            view.addSubview($0)
        }
    }
    
    override func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func setupBindings() {
        viewModel.outfits
            .drive(tableView.rx.items(cellIdentifier: "OutfitHistoryCell", cellType: OutfitHistoryCell.self)) { index, outfit, cell in
                print("DEBUG - Configuring cell for outfit at index: \(index)")
                cell.configure(with: outfit)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - OutfitHistoryCell
class OutfitHistoryCell: UITableViewCell {
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 4
        $0.layer.shadowOpacity = 0.1
    }
    
    private let dateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .black
    }
    
    private let clothesStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.distribution = .fillEqually
    }
    
    private let topImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 8
    }
    
    private let bottomImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 8
    }
    
    private let shoesImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 8
    }
    
    private let outerImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 8
    }
    
    private let infoLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .darkGray
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        [dateLabel, clothesStackView, infoLabel].forEach {
            containerView.addSubview($0)
        }
        
        [topImageView, bottomImageView, shoesImageView, outerImageView].forEach {
            clothesStackView.addArrangedSubview($0)
        }
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20))
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(12)
        }
        
        clothesStackView.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(80)
        }
        
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(clothesStackView.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(12)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
    
    func configure(with outfit: Outfit) {
        print("DEBUG - Configuring cell with outfit ID: \(outfit.id)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        dateLabel.text = dateFormatter.string(from: outfit.createdAt)
        print("DEBUG - Date: \(dateLabel.text ?? "nil")")
        
        // 옷 이미지 설정
        if let top = outfit.top {
            topImageView.image = ImageStorageService.shared.loadImage(withName: top.id)
            print("DEBUG - Top image loaded: \(topImageView.image != nil)")
        }
        
        if let bottom = outfit.bottom {
            bottomImageView.image = ImageStorageService.shared.loadImage(withName: bottom.id)
            print("DEBUG - Bottom image loaded: \(bottomImageView.image != nil)")
        }
        
        if let shoes = outfit.shoes {
            shoesImageView.image = ImageStorageService.shared.loadImage(withName: shoes.id)
            print("DEBUG - Shoes image loaded: \(shoesImageView.image != nil)")
        }
        
        if let outer = outfit.outer {
            outerImageView.image = ImageStorageService.shared.loadImage(withName: outer.id)
            print("DEBUG - Outer image loaded: \(outerImageView.image != nil)")
        }
        
        // 계절과 스타일 정보 설정
        let seasons = [outfit.top?.seasons, outfit.bottom?.seasons, outfit.shoes?.seasons, outfit.outer?.seasons]
            .compactMap { $0 }
            .flatMap { Array($0) }
//            .map { $0.rawValue }
        
        let styles = [outfit.top?.styles, outfit.bottom?.styles, outfit.shoes?.styles, outfit.outer?.styles]
            .compactMap { $0 }
            .flatMap { Array($0.map { $0 }) }
        
        let uniqueSeasons = Array(Set(seasons)).joined(separator: ", ")
        let uniqueStyles = Array(Set(styles)).joined(separator: ", ")
        
        infoLabel.text = "\(uniqueSeasons) • \(uniqueStyles)"
    }
}

// MARK: - UITableViewDelegate
extension HistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
} 
