import UIKit
import RxSwift
import RxCocoa
import SnapKit

class ClosetViewController: BaseViewController {
    
    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 36, weight: .bold)
        $0.text = "My Closet"
        $0.textColor = .black
    }
    
    private let addButton = UIButton().then {
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 24
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let image = UIImage(systemName: "plus", withConfiguration: config)
        $0.setImage(image, for: .normal)
        $0.tintColor = .white
    }
    
    private let categoryStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 24
        $0.distribution = .fill
        $0.alignment = .center
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var categories = ["All", "Outer", "Tops", "Bottoms", "Shoes"].map { category in
        let button = UIButton()
        button.setTitle(category, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.black, for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        return button
    }
    
    private let selectedCategoryIndicator = UIView().then {
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 2
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.contentInset = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
        cv.register(ClothingItemCell.self, forCellWithReuseIdentifier: "ClothingItemCell")
        cv.delegate = self
        return cv
    }()
    
    // MARK: - Properties
    private let viewModel = ClosetViewModel()
    private var selectedCategoryIndex = 0 {
        didSet {
            updateSelectedCategory()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 250/255, green: 245/255, blue: 237/255, alpha: 1)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Setup
    override func setupViews() {
        super.setupViews()
        
        [titleLabel, addButton, categoryStackView, selectedCategoryIndicator, collectionView].forEach {
            view.addSubview($0)
        }
        
        categories.forEach {
            categoryStackView.addArrangedSubview($0)
        }
        
        categories[0].isSelected = true
        updateSelectedCategory()
        
        // Add a long press gesture recognizer to the collection view for item deletion
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    override func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        addButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(48)
        }
        
        categoryStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.lessThanOrEqualToSuperview().offset(-20)
            $0.height.equalTo(40)
        }
        
        selectedCategoryIndicator.snp.makeConstraints {
            $0.height.equalTo(4)
            $0.bottom.equalTo(categoryStackView)
            $0.width.equalTo(categories[0].titleLabel?.intrinsicContentSize.width ?? 20)
            $0.centerX.equalTo(categories[0])
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(categoryStackView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
    }
    
    override func setupBindings() {
        // Bind category buttons
        categories.enumerated().forEach { index, button in
            button.rx.tap
                .subscribe(onNext: { [weak self] in
                    self?.selectedCategoryIndex = index
                })
                .disposed(by: disposeBag)
        }
        
        // Bind add button
        addButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.presentAddItemViewController()
            })
            .disposed(by: disposeBag)
        
        // Bind items to collection view
        viewModel.items
            .drive(collectionView.rx.items(cellIdentifier: "ClothingItemCell", cellType: ClothingItemCell.self)) { index, item, cell in
                cell.configure(with: item)
            }
            .disposed(by: disposeBag)
        
        // Modify collectionView didSelectItemAt to present the edit view controller
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
//                let item = self.viewModel.items.value[indexPath.row]
                let item = self.viewModel.itemsRelay.value[indexPath.row]

                self.presentEditItemViewController(with: item)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private Methods
    private func updateSelectedCategory() {
        guard selectedCategoryIndex < categories.count else { return }
        
        UIView.animate(withDuration: 0.3) {
            self.selectedCategoryIndicator.snp.remakeConstraints {
                $0.height.equalTo(4)
                $0.bottom.equalTo(self.categoryStackView)
                $0.width.equalTo(self.categories[self.selectedCategoryIndex].titleLabel?.intrinsicContentSize.width ?? 20)
                $0.centerX.equalTo(self.categories[self.selectedCategoryIndex])
            }
            self.view.layoutIfNeeded()
        }
        
        let category: Category?
        switch selectedCategoryIndex {
        case 0:
            category = nil
        case 1:
            category = .outer
        case 2:
            category = .top
        case 3:
            category = .bottom
        case 4:
            category = .shoes
        default:
            category = nil
        }
        viewModel.selectedCategory.accept(category)
    }
    
    private func presentAddItemViewController() {
        let addItemVC = AddItemViewController()
        let nav = UINavigationController(rootViewController: addItemVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    // Add a method to handle the long press gesture
    @objc private func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: point) else { return }
        
        if gesture.state == .began {
            // Show an alert to confirm deletion
            let alert = UIAlertController(title: "Delete Item", message: "Are you sure you want to delete this item?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                self?.deleteItem(at: indexPath)
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    // Add a method to delete the item from the view model
    private func deleteItem(at indexPath: IndexPath) {
        viewModel.deleteItem(at: indexPath.row)
    }
    
    // Add a method to present AddItemViewController for editing
    private func presentEditItemViewController(with item: ClothingItem) {
        let addItemVC = AddItemViewController()
        addItemVC.clothingItem = item
        navigationController?.pushViewController(addItemVC, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ClosetViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 52) / 2 // 52 = left(20) + right(20) + spacing(12)
        return CGSize(width: width, height: width * 1.2) // 높이를 너비의 1.2배로 설정
    }
}

// MARK: - ClothingItemCell
class ClothingItemCell: UICollectionViewCell {
    private let containerView = UIView().then {
        $0.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        $0.layer.cornerRadius = 16
    }
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .clear
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(imageView)
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
        }
    }
    
    func configure(with item: ClothingItem) {
        if let image = ImageStorageService.shared.loadImage(withName: item.id) {
            imageView.image = image
        }
    }
}

#Preview {
    ClosetViewController()
}
