import UIKit
import RxSwift
import SnapKit
//import Then

class BaseViewController: UIViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupBindings()
    }
    
    // MARK: - Setup
    func setupViews() {
        view.backgroundColor = .systemBackground
    }
    
    func setupConstraints() {}
    
    func setupBindings() {}
} 
