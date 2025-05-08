//
//  AppDelegate.swift
//  OOTDay
//
//  Created by 차상진 on 4/4/25.
//

import UIKit
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Realm 스키마 버전 설정
        setupRealm()
        return true
    }

    private func setupRealm() {
        // 현재 스키마 버전을 3으로 설정하여 기존 데이터베이스와 호환되도록 함
        let config = Realm.Configuration(
            schemaVersion: 4,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 2 {
                    // 버전 1에서 2로 마이그레이션 로직
                    migration.enumerateObjects(ofType: Outfit.className()) { oldObject, newObject in
                        newObject!["outer"] = nil
                    }
                }
                
                if oldSchemaVersion < 3 {
                    // 버전 2에서 3으로 마이그레이션 로직
                    // 여기에는 style에서 styles로 변경하는 로직이 필요할 수 있음
                    migration.enumerateObjects(ofType: ClothingItem.className()) { oldObject, newObject in
                        if let oldStyle = oldObject?["style"] as? String {
                            let styles = newObject!["styles"] as? List<String> ?? List<String>()
                            styles.append(oldStyle)
                        }
                    }
                }

                if oldSchemaVersion < 4 {
                    // 시즌 한글에서 영어로 변경하는 마이그레이션 로직
                    migration.enumerateObjects(ofType: ClothingItem.className()) { oldObject, newObject in
                        let seasons = newObject!["seasons"] as? List<String> ?? List<String>()
                        let newSeasons = List<String>()
                        
                        for season in seasons {
                            switch season {
                            case "봄":
                                newSeasons.append("Spring")
                            case "여름":
                                newSeasons.append("Summer")
                            case "가을":
                                newSeasons.append("Fall")
                            case "겨울":
                                newSeasons.append("Winter")
                            default:
                                newSeasons.append(season)
                            }
                        }
                        
                        newObject!["seasons"] = newSeasons
                    }
                }
            }
        )
        
        // 기본 설정을 지정
        Realm.Configuration.defaultConfiguration = config
        
        // 마이그레이션이 성공적으로 수행되었는지 확인
        do {
            let _ = try Realm()
            print("Realm 마이그레이션 완료 - 스키마 버전: 4")
        } catch let error {
            print("Realm 마이그레이션 실패: \(error.localizedDescription)")
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

