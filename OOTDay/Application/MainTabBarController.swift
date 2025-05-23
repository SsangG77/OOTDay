import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()
        self.selectedIndex = 1
    }
    
    private func setupTabBar() {
        tabBar.tintColor = UIColor(named: "AccentColor")
        tabBar.backgroundColor = .systemBackground
    }
    
    private func setupViewControllers() {
        let todayVC = UINavigationController(rootViewController: TodayViewController())
        todayVC.tabBarItem = UITabBarItem(title: "오늘의 코디", image: UIImage(systemName: "sun.max"), tag: 0)
        
        let closetVC = UINavigationController(rootViewController: ClosetViewController())
        closetVC.tabBarItem = UITabBarItem(title: "내 옷장", image: UIImage(systemName: "tshirt"), tag: 1)
        
        let historyVC = UINavigationController(rootViewController: HistoryViewController())
        historyVC.tabBarItem = UITabBarItem(title: "히스토리", image: UIImage(systemName: "clock"), tag: 2)
        
        let premiumVC = UINavigationController(rootViewController: PremiumViewController())
        premiumVC.tabBarItem = UITabBarItem(title: "프리미엄", image: UIImage(systemName: "star"), tag: 3)
        
        viewControllers = [todayVC, historyVC, closetVC, premiumVC]
    }
} 