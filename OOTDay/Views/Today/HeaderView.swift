//
//  HeaderView.swift
//  OOTDay
//
//  Created by 차상진 on 9/21/25.
//

import Foundation
import UIKit
import Then

//MARK: - HeaderView
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
