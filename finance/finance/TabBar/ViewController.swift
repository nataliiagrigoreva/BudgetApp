//
//  ViewController.swift
//  finance
//
//  Created by Nataly on 13.05.2023.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBarController = UITabBarController()
        tabBarController.tabBar.barTintColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)

        let incomesViewController = IncomesViewController()
        let chartViewController = ChartViewController()
        let expensesViewController = ExpensesViewController()

        incomesViewController.title = "Доходы"
        chartViewController.title = "График"
        expensesViewController.title = "Расходы"

        incomesViewController.tabBarItem.image = UIImage(systemName: "ring.circle")
        chartViewController.tabBarItem.image = UIImage(systemName: "ring.circle")
        expensesViewController.tabBarItem.image = UIImage(systemName: "ring.circle")
        
        let tabBarList = [incomesViewController, chartViewController, expensesViewController]
        tabBarController.viewControllers = tabBarList.map { UINavigationController(rootViewController: $0) }
        
        self.view.addSubview(tabBarController.view)
        self.addChild(tabBarController)
        tabBarController.didMove(toParent: self)
    }
}

