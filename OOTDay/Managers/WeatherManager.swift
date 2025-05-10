import Foundation
import WeatherKit
import CoreLocation

class WeatherManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var weatherCompletion: ((Weather?) -> Void)?
    private let weatherService: WeatherService
    
    override init() {
        // WeatherService를 명시적으로 초기화
        self.weatherService = WeatherService.shared
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func fetchWeather(completion: @escaping (Weather?) -> Void) {
        print("Fetching weather data...")
        weatherCompletion = completion
        
        // 위치 권한 상태 확인
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            print("Requesting location authorization...")
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("Location access denied")
            completion(nil)
            return
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location access granted, requesting location...")
            locationManager.requestLocation()
        @unknown default:
            print("Unknown authorization status")
            completion(nil)
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Location updated: \(locations.first?.coordinate ?? CLLocationCoordinate2D())")
        guard let location = locations.first else {
            print("위치를 가져올 수 없습니다.")
            weatherCompletion?(nil)
            return
        }
        
        Task {
            do {
                print("Fetching weather for location: \(location.coordinate)")
                let weather = try await weatherService.weather(for: location)
                print("Weather data received successfully")
                await MainActor.run {
                    weatherCompletion?(weather)
                }
            } catch {
                print("Error fetching weather: \(error)")
                print("Error domain: \(error._domain)")
                print("Error code: \(error._code)")
                print("Error description: \(error.localizedDescription)")
                if let nsError = error as NSError? {
                    print("Error user info: \(nsError.userInfo)")
                }
                await MainActor.run {
                    weatherCompletion?(nil)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
        weatherCompletion?(nil)
    }
    
    // 현재 계절 가져오기
    func getCurrentSeason() -> Season {
        let month = Calendar.current.component(.month, from: Date())
        
        switch month {
        case 3...5:
            return .spring
        case 6...8:
            return .summer
        case 9...11:
            return .fall
        default:
            return .winter
        }
    }
} 
