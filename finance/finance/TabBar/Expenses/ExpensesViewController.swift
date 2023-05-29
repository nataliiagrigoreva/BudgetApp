//
//  ExpensesViewController.swift
//  finance
//
//  Created by Nataly on 13.05.2023.
//

import Foundation
import UIKit

class ExpensesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var categories2: [String] = []
    
    let tableView2 = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Расходы"
        view.backgroundColor = .white
        
        tableView2.frame = CGRect(x: 0, y: 150, width: view.frame.width, height: view.frame.height - 200)
        tableView2.dataSource = self
        tableView2.delegate = self
        view.addSubview(tableView2)
        
        let addButton2 = UIButton(frame: CGRect(x: view.frame.width / 2 - 100, y: view.frame.height - 50, width: 200, height: 30))
        addButton2.setTitle("Добавить расход", for: .normal)
        addButton2.setTitleColor(.white, for: .normal)
        addButton2.backgroundColor = .systemBlue
        addButton2.layer.cornerRadius = 15
        addButton2.addTarget(self, action: #selector(addExpense), for: .touchUpInside)
        view.addSubview(addButton2)
        
        addButton2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addButton2.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton2.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton2.widthAnchor.constraint(equalToConstant: 200),
            addButton2.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        let clearButton2 = UIButton(frame: CGRect(x: view.frame.width / 2 - 100, y: view.frame.height - 100, width: 200, height: 30))
        clearButton2.setTitle("Очистить", for: .normal)
        clearButton2.setTitleColor(.white, for: .normal)
        clearButton2.backgroundColor = .systemRed
        clearButton2.layer.cornerRadius = 15
        clearButton2.addTarget(self, action: #selector(clearIncomes2), for: .touchUpInside)
        view.addSubview(clearButton2)
        
        clearButton2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            clearButton2.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            clearButton2.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            clearButton2.widthAnchor.constraint(equalToConstant: 200),
            clearButton2.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        if let savedCategories2 = UserDefaults.standard.array(forKey: "expenseCategories2") as? [String] {
            categories2 = savedCategories2
        }
        
        tableView2.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories2.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell2 = UITableViewCell(style: .default, reuseIdentifier: "Cell2")
        cell2.textLabel?.text = categories2[indexPath.row]
        let arrowView = UIImageView(image: UIImage(systemName: "chevron.right"))
        cell2.accessoryView = arrowView
        return cell2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categories2[indexPath.row]
        let expensesByCategoryVC = ExpensesByCategoryViewController(category: category)
        navigationController?.pushViewController(expensesByCategoryVC, animated: true)
    }
    
    @objc func addExpense() {
        let alert = UIAlertController(title: "Добавить расход", message: "Введите новую категорию расхода", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Новая категория"
        })
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Добавить", style: .default, handler: { action in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                self.categories2.append(text)
                UserDefaults.standard.set(self.categories2, forKey: "expenseCategories2")
                self.tableView2.reloadData()
            }
        }))
        present(alert, animated: true)
    }
    @objc func clearIncomes2() {
        let alert = UIAlertController(title: "Удалить все расходы?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { action in
            self.categories2.removeAll()
            UserDefaults.standard.set(self.categories2, forKey: "expenseCategories2")
            self.tableView2.reloadData()
        }))
        present(alert, animated: true)
    }
    
}


