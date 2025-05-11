import UIKit
import RxSwift
import RxCocoa
import SnapKit
import PhotosUI
import RealmSwift

class AddItemViewController: BaseViewController {
    
    let styleObject = StyleObject()
    
    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.text = "Add Item"
        $0.font = .systemFont(ofSize: 36, weight: .bold)
        $0.textColor = .black
    }
    
    private let photoContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
    }
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    
    private lazy var dashedBorderLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.black.withAlphaComponent(0.2).cgColor
        shapeLayer.fillColor = nil
        shapeLayer.lineDashPattern = [6, 6]
        shapeLayer.lineWidth = 2
        shapeLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 100, height: 100), cornerRadius: 16).cgPath
        return shapeLayer
    }()
    
    private let photoPlaceholderStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.alignment = .center
    }
    
    private let cameraIcon = UIImageView().then {
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .medium)
        $0.image = UIImage(systemName: "camera", withConfiguration: config)
        $0.tintColor = .black.withAlphaComponent(0.3)
    }
    
    private let photoLabel = UILabel().then {
        $0.text = "Photo"
        $0.font = .systemFont(ofSize: 20, weight: .medium)
        $0.textColor = .black.withAlphaComponent(0.3)
    }
    
    private let categoryLabel = UILabel().then {
        $0.text = "Category"
        $0.font = .systemFont(ofSize: 20, weight: .medium)
        $0.textColor = .black
    }
    
    private let categoryButton = UIButton().then {
        $0.setTitle("Select", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let image = UIImage(systemName: "chevron.down", withConfiguration: config)
        $0.setImage(image, for: .normal)
        $0.tintColor = .black
        $0.semanticContentAttribute = .forceRightToLeft
        $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
    }
    
    private let colorLabel = UILabel().then {
        $0.text = "Color(s)"
        $0.font = .systemFont(ofSize: 20, weight: .medium)
        $0.textColor = .black
    }
    
    private let styleContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let styleLabel = UILabel().then {
        $0.text = "Style"
        $0.font = .systemFont(ofSize: 20, weight: .medium)
        $0.textColor = .black
    }
    
    private let styleScrollView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = true
        $0.showsVerticalScrollIndicator = false
    }
    
    private let styleStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.distribution = .fillProportionally
        $0.alignment = .center
    }
    
    private lazy var styleButtons: [UIButton] = ["캐주얼", "포멀", "스포티", "빈티지", "보헤미안", "시크", "프레피", "펑크"].map { style in
        let button = UIButton()
        button.setTitle(style, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        return button
    }
    
    private let seasonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.distribution = .fillEqually
    }
    
    private lazy var seasonButtons: [UIButton] = ["Spring", "Summer", "Fall", "Winter"].map { season in
        let button = UIButton()
        button.setTitle(season, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
        return button
    }
    
    private let saveButton = UIButton().then {
        $0.setTitle("Save", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 25
    }
    
    private let cancelButton = UIButton().then {
        $0.setTitle("Cancel", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 25
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
    }
    
    private let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.distribution = .fillEqually
    }
    
    private let colorPickerButton = UIButton().then {
        $0.setTitle("Select Color", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
    }
    
    // MARK: - Properties
    private let viewModel = AddItemViewModel()
    private let categories = ["Outer", "Top", "Bottom", "Shoes"]
    private var selectedCategory: String? {
        didSet {
            categoryButton.setTitle(selectedCategory ?? "Select", for: .normal)
        }
    }
    
    private var selectedSeasons: Set<String> = []
    private var selectedStyles: Set<String> = []
    private var selectedColors: [String] = []
    private var selectedImage: UIImage?
    
    // Update styles array to use Korean names
    private let styles = ["캐주얼", "포멀", "스포티", "빈티지", "보헤미안", "시크", "프레피", "펑크"]
    
    // Add a property to hold the ClothingItem being edited
    var clothingItem: ClothingItem?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 250/255, green: 245/255, blue: 237/255, alpha: 1)
        navigationController?.setNavigationBarHidden(true, animated: false)
        categoryButton.setTitle("Select", for: .normal)
        
        if let item = clothingItem {
            print(item)
            // 기존 데이터로 UI 초기화
            selectedCategory = item.category
            categoryButton.setTitle(item.category, for: .normal)
            
            if let image = ImageStorageService.shared.loadImage(withName: item.id) {
                
                selectedImage = image
                imageView.image = image
                imageView.isHidden = false
                photoPlaceholderStack.isHidden = true
            }
            
            // 색상 초기화
            selectedColors = Array(item.colors)
            if let firstColor = selectedColors.first {
                colorPickerButton.backgroundColor = UIColor(hex: firstColor)
            }
            
            // 스타일 버튼 초기화
            for style in item.stylesEnum {
                if let index = styles.firstIndex(of: styleObject.changeStyleName(style: style)) {
                    toggleStyleButton(styleButtons[index])
                }
            }
            
            // 시즌 버튼 초기화
            for season in item.seasonsEnum {
                if let index = ["Spring", "Summer", "Fall", "Winter"].firstIndex(of: season.rawValue) {
                    toggleSeasonButton(at: index)
                }
            }
        }
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update dashed border layer path
        dashedBorderLayer.path = UIBezierPath(
            roundedRect: photoContainerView.bounds,
            cornerRadius: 16
        ).cgPath
        
        // 스타일 스크롤뷰의 콘텐츠 크기 설정
        styleStackView.layoutIfNeeded()
        let contentWidth = styleStackView.frame.width
        if contentWidth > styleScrollView.frame.width {
            styleScrollView.contentSize = CGSize(width: contentWidth, height: styleScrollView.frame.height)
        } else {
            styleScrollView.contentSize = CGSize(width: styleScrollView.frame.width, height: styleScrollView.frame.height)
        }
    }
    
    // MARK: - Setup
    override func setupViews() {
        super.setupViews()
        
        // Add dashed border layer
        photoContainerView.layer.addSublayer(dashedBorderLayer)
        
        [titleLabel, photoContainerView, categoryLabel, categoryButton, colorLabel,
         styleContainerView, seasonStackView, buttonStackView, colorPickerButton].forEach {
            view.addSubview($0)
        }
        
        [cancelButton, saveButton].forEach {
            buttonStackView.addArrangedSubview($0)
        }
        
        photoContainerView.addSubview(photoPlaceholderStack)
        photoContainerView.addSubview(imageView)
        
        [cameraIcon, photoLabel].forEach {
            photoPlaceholderStack.addArrangedSubview($0)
        }
        
        styleContainerView.addSubview(styleLabel)
        styleContainerView.addSubview(styleScrollView)
        styleScrollView.addSubview(styleStackView)
        
        styleButtons.forEach {
            styleStackView.addArrangedSubview($0)
        }
        
        seasonButtons.forEach {
            seasonStackView.addArrangedSubview($0)
        }
    }
    
    override func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        photoContainerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(200)
        }
        
        photoPlaceholderStack.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
        
        categoryLabel.snp.makeConstraints {
            $0.top.equalTo(photoContainerView.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(20)
        }
        
        categoryButton.snp.makeConstraints {
            $0.centerY.equalTo(categoryLabel)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.equalTo(180)
            $0.height.equalTo(44)
        }
        
        colorLabel.snp.makeConstraints {
            $0.top.equalTo(categoryLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }
        
        styleContainerView.snp.makeConstraints {
            $0.top.equalTo(colorLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }
        
        styleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.width.equalTo(50)
        }
        
        styleScrollView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(styleLabel.snp.trailing).offset(12)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        styleStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(styleScrollView.snp.height)
        }
        
        seasonStackView.snp.makeConstraints {
            $0.top.equalTo(styleContainerView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(50)
        }
        
        colorPickerButton.snp.makeConstraints {
            $0.centerY.equalTo(colorLabel)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.equalTo(180)
            $0.height.equalTo(44)
        }
    }
    
    override func setupBindings() {
        // Photo container tap gesture
        let tapGesture = UITapGestureRecognizer()
        photoContainerView.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.presentImagePicker()
            })
            .disposed(by: disposeBag)
            
        // Category button
        categoryButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showCategoryActionSheet()
            })
            .disposed(by: disposeBag)
        
        // Season button selection
        seasonButtons.enumerated().forEach { index, button in
            button.rx.tap
                .subscribe(onNext: { [weak self] in
                    self?.toggleSeasonButton(at: index)
                })
                .disposed(by: disposeBag)
        }
        
        // Cancel button
        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
            
        // Save button
        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.saveChanges()
            })
            .disposed(by: disposeBag)
        
        // Color picker button
        colorPickerButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.presentColorPicker()
            })
            .disposed(by: disposeBag)
        
        // Style button
        styleButtons.forEach { button in
            button.rx.tap
                .subscribe(onNext: { [weak self] in
                    self?.toggleStyleButton(button)
                })
                .disposed(by: disposeBag)
        }
    }
    
    // MARK: - Private Methods
    private func presentImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    private func toggleSeasonButton(at index: Int) {
        let button = seasonButtons[index]
        button.isSelected.toggle()
        
        // 시즌 이름은 정확히 enum의 rawValue와 일치해야 함
        let season = ["Spring", "Summer", "Fall", "Winter"][index]
        
        if button.isSelected {
            button.backgroundColor = .black
            button.setTitleColor(.white, for: .normal)
            selectedSeasons.insert(season)
            
        } else {
            button.backgroundColor = .white
            button.setTitleColor(.black, for: .normal)
            selectedSeasons.remove(season)
            
        }
    }
    
    private func toggleStyleButton(_ button: UIButton) {
        button.isSelected.toggle()
        
        guard let styleTitle = button.title(for: .normal) else { return }
        
        if button.isSelected {
            button.backgroundColor = .black
            button.setTitleColor(.white, for: .normal)
            selectedStyles.insert(styleTitle)
        } else {
            button.backgroundColor = .white
            button.setTitleColor(.black, for: .normal)
            selectedStyles.remove(styleTitle)
        }
    }
    
    private func showCategoryActionSheet() {
        let alert = UIAlertController(title: "Select Category", message: nil, preferredStyle: .actionSheet)
        
        categories.forEach { category in
            let action = UIAlertAction(title: category, style: .default) { [weak self] _ in
                self?.selectedCategory = category
                print("category: \(category)")
                print("Selected Category: \(self?.selectedCategory)")
                let category_ = Category(rawValue: self?.selectedCategory ?? "")
                print("Selected Category: \(category_)")
            }
            alert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        // iPad support
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = categoryButton
            popoverController.sourceRect = categoryButton.bounds
        }
        
        present(alert, animated: true)
    }

    @objc private func saveChanges() {
        guard let image = selectedImage,
              let categoryTitle = selectedCategory,
              let category = Category(rawValue: categoryTitle) else {
            print("Missing required fields")
            return
        }
        
        // Convert selected styles to Style enum
        let styles = selectedStyles.compactMap { styleTitle -> Style? in
            switch styleTitle {
            case "캐주얼": return .casual
            case "포멀": return .formal
            case "스포티": return .sporty
            case "빈티지": return .vintage
            case "보헤미안": return .bohemian
            case "시크": return .chic
            case "프레피": return .preppy
            case "펑크": return .punk
            default: return nil
            }
        }
        
        // Convert selected seasons to Season enum
        let seasons = selectedSeasons.compactMap { Season(rawValue: $0) }
        
        
        if let existingItem = clothingItem {
            // Update existing item
            viewModel.updateItem(existingItem, image: image, category: category, colors: selectedColors, styles: styles, seasons: seasons)
                .subscribe(onCompleted: { [weak self] in
                    self?.dismiss(animated: true)
                }, onError: { error in
                    print("Error updating item: \(error)")
                })
                .disposed(by: disposeBag)
        } else {
            // Create new item
            viewModel.saveItem(image: image, category: category, colors: selectedColors, styles: styles, seasons: seasons)
                .subscribe(onCompleted: { [weak self] in
                    self?.dismiss(animated: true)
                }, onError: { error in
                    print("Error saving item: \(error)")
                })
                .disposed(by: disposeBag)
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func presentColorPicker() {
        let colorPicker = UIColorPickerViewController()
        colorPicker.delegate = self
        present(colorPicker, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension AddItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            imageView.isHidden = false
            photoPlaceholderStack.isHidden = true
            selectedImage = image
        }
        picker.dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension AddItemViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UIColorPickerViewControllerDelegate
extension AddItemViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        let selectedColor = viewController.selectedColor
        print("Color selected: \(selectedColor.toHexString())")
        DispatchQueue.main.async {
            // self.colorDisplayView.backgroundColor = selectedColor
            self.colorPickerButton.backgroundColor = selectedColor
        }
        viewController.dismiss(animated: true, completion: nil)
    }
}


#Preview {
    AddItemViewController()
}
