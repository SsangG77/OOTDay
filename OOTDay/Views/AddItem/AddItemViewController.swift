import UIKit
import RxSwift
import RxCocoa
import SnapKit
import PhotosUI

class AddItemViewController: BaseViewController {
    
    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.text = "Add Item"
        $0.font = .systemFont(ofSize: 36, weight: .bold)
        $0.textColor = .black
    }
    
    private let photoContainerView = UIView().then {
        $0.backgroundColor = .clear
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
    
    private let photoImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    
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
    
    private let styleLabel = UILabel().then {
        $0.text = "Style"
        $0.font = .systemFont(ofSize: 20, weight: .medium)
        $0.textColor = .black
    }
    
    private let styleTextField = UITextField().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        $0.leftViewMode = .always
        $0.font = .systemFont(ofSize: 18)
        $0.textAlignment = .center
        $0.returnKeyType = .done
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 250/255, green: 245/255, blue: 237/255, alpha: 1)
        navigationController?.setNavigationBarHidden(true, animated: false)
        categoryButton.setTitle("Select", for: .normal)
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Set text field delegates
        styleTextField.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update dashed border layer path
        dashedBorderLayer.path = UIBezierPath(
            roundedRect: photoContainerView.bounds,
            cornerRadius: 16
        ).cgPath
    }
    
    // MARK: - Setup
    override func setupViews() {
        super.setupViews()
        
        // Add dashed border layer
        photoContainerView.layer.addSublayer(dashedBorderLayer)
        
        [titleLabel, photoContainerView, categoryLabel, categoryButton, colorLabel,
         styleLabel, styleTextField, seasonStackView, buttonStackView, colorPickerButton].forEach {
            view.addSubview($0)
        }
        
        [cancelButton, saveButton].forEach {
            buttonStackView.addArrangedSubview($0)
        }
        
        photoContainerView.addSubview(photoPlaceholderStack)
        photoContainerView.addSubview(photoImageView)
        
        [cameraIcon, photoLabel].forEach {
            photoPlaceholderStack.addArrangedSubview($0)
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
        
        photoImageView.snp.makeConstraints {
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
        
        styleLabel.snp.makeConstraints {
            $0.top.equalTo(colorLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }
        
        styleTextField.snp.makeConstraints {
            $0.centerY.equalTo(styleLabel)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.equalTo(180)
            $0.height.equalTo(44)
        }
        
        seasonStackView.snp.makeConstraints {
            $0.top.equalTo(styleLabel.snp.bottom).offset(24)
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
                self?.saveItem()
            })
            .disposed(by: disposeBag)
        
        // Color picker button
        colorPickerButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.presentColorPicker()
            })
            .disposed(by: disposeBag)
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
    
    private func showCategoryActionSheet() {
        let alert = UIAlertController(title: "Select Category", message: nil, preferredStyle: .actionSheet)
        
        categories.forEach { category in
            let action = UIAlertAction(title: category, style: .default) { [weak self] _ in
                self?.selectedCategory = category
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
    
    private func saveItem() {
        // Validate inputs
        guard let image = photoImageView.image else {
            showAlert(message: "Please select a photo")
            return
        }
        
        guard let category = selectedCategory else {
            showAlert(message: "Please select a category")
            return
        }
        
        guard let colors = colorDisplayView.backgroundColor?.toHexString(), !colors.isEmpty else {
            showAlert(message: "Please select a color")
            return
        }
        
        guard let style = styleTextField.text, !style.isEmpty else {
            showAlert(message: "Please enter style")
            return
        }
        
        guard !selectedSeasons.isEmpty else {
            showAlert(message: "Please select at least one season")
            return
        }
        
        // Convert category string to Category enum
        let categoryEnum: Category
        switch category.lowercased() {
        case "outer":
            categoryEnum = .outer
        case "top":
            categoryEnum = .top
        case "bottom":
            categoryEnum = .bottom
        case "shoes":
            categoryEnum = .shoes
        default:
            showAlert(message: "Invalid category")
            return
        }
        
        // Convert season strings to Season enum array
        let seasonEnums = selectedSeasons.compactMap { seasonStr -> Season? in
            switch seasonStr.lowercased() {
            case "spring": return .spring
            case "summer": return .summer
            case "fall": return .fall
            case "winter": return .winter
            default: return nil
            }
        }
        
        // Save item using view model
        viewModel.saveItem(
            image: image,
            category: categoryEnum,
            colors: [colors],
            style: style,
            seasons: Array(seasonEnums)
        )
        .subscribe(
            onCompleted: { [weak self] in
                self?.showAlert(message: "Item saved successfully") { _ in
                    self?.dismiss(animated: true)
                }
            },
            onError: { [weak self] error in
                self?.showAlert(message: "Failed to save item: \(error.localizedDescription)")
            }
        )
        .disposed(by: disposeBag)
    }
    
    private func showAlert(message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: completion)
        alert.addAction(okAction)
        present(alert, animated: true)
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
            photoImageView.image = image
            photoImageView.isHidden = false
            photoPlaceholderStack.isHidden = true
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
