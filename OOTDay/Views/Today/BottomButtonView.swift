//
//  BottomButtonView.swift
//  OOTDay
//
//  Created by 차상진 on 9/21/25.
//

import Foundation
import UIKit
import Then
import RxSwift

//MARK: - BottomButtonView
class BottomButtonView: UIView {
    
    var viewModel: TodayViewModel
    
//    private let styles = ["캐주얼", "포멀", "스포티", "빈티지", "보헤미안", "시크", "프레피", "펑크"]
    
    //MARK: - properties
    let disposeBag = DisposeBag()
    
    var showStyleActionSheet: () -> Void
    
    // 각 버튼의 크기 비율 설정 (간격 12포인트 고려)
    let totalSpacing: CGFloat = 24 // 버튼 사이 간격 2개 (12 * 2)
    
    
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
        
        setupLayout()
        setupBinding()
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


extension BottomButtonView {
    
    func setupLayout() {
        
        buttonStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-20)
            $0.height.equalTo(60)
        }
        
        styleButton.snp.makeConstraints {
            $0.width.equalTo(buttonStackView.snp.width).multipliedBy(0.5).offset(-totalSpacing * 0.5) // 전체 너비의 50%에서 간격의 절반만큼 빼기
        }
        
        favoriteButton.snp.makeConstraints {
            $0.width.equalTo(buttonStackView.snp.width).multipliedBy(0.25).offset(-totalSpacing * 0.25) // 전체 너비의 25%에서 간격의 1/4만큼 빼기
        }
        
        seeAnotherButton.snp.makeConstraints {
            $0.width.equalTo(buttonStackView.snp.width).multipliedBy(0.25).offset(-totalSpacing * 0.25) // 전체 너비의 25%에서 간격의 1/4만큼 빼기
        }
        
    }
    
    func setupBinding() {
        seeAnotherButton.rx.tap
            .bind(to: viewModel.seeAnotherTapped)
            .disposed(by: disposeBag)
        
        styleButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showStyleActionSheet()
            })
            .disposed(by: disposeBag)
    }
}
