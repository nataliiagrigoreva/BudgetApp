//
//  ExpensesByCategoryViewController.swift
//  finance
//
//  Created by Nataly on 15.05.2023.
//

import Foundation
import UIKit

class ExpensesByCategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let category: String
    var expenses: [ExpenseManager.Expense] = []
    let tableView = UITableView()
    
    init(category: String) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
        title = category
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        tableView.frame = CGRect(x: 0, y: 150, width: view.frame.width, height: view.frame.height - 200)
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        let chartsButton = UIButton(frame: CGRect(x: view.frame.width / 2 - 100, y: 110, width: 200, height: 30))
        chartsButton.setTitle("График платежей", for: .normal)
        chartsButton.setTitleColor(.white, for: .normal)
        chartsButton.backgroundColor = .systemBlue
        chartsButton.layer.cornerRadius = 15
        chartsButton.addTarget(self, action: #selector(showGraph), for: .touchUpInside)
        view.addSubview(chartsButton)
        
        let addButton = UIButton(frame: CGRect(x: view.frame.width / 2 - 100, y: view.frame.height - 50, width: 200, height: 30))
        addButton.setTitle("Добавить расход", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.backgroundColor = .systemBlue
        addButton.layer.cornerRadius = 15
        addButton.addTarget(self, action: #selector(addExpense), for: .touchUpInside)
        view.addSubview(addButton)
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.widthAnchor.constraint(equalToConstant: 200),
            addButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        if let loadedExpenses = ExpenseManager.shared.loadExpenses() {
            expenses = loadedExpenses
        } else {
            tableView.reloadData()
        }
    }
    
    @objc func showGraph() {
        let filteredExpenses = expenses.filter { $0.category == category }
        let graphViewController = GraphViewController(category: category, expenses: filteredExpenses)
        navigationController?.pushViewController(graphViewController, animated: true)
    }
    
    @objc func addExpense() {
        let alertController = UIAlertController(title: "Добавить расход", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Наименование"
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Сумма"
            textField.keyboardType = .decimalPad
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Дата"
            textField.inputView = self.createDatePicker()
        }
        
        let addAction = UIAlertAction(title: "Добавить", style: .default) { _ in
            guard let title = alertController.textFields?[0].text,
                  let amountText = alertController.textFields?[1].text,
                  let amount = Double(amountText),
                  let dateText = alertController.textFields?[2].text,
                  let date = self.getDateFromString(dateText)
            else {
                return
            }
            
            ExpenseManager.shared.addExpense(title: title, amount: amount, category: self.category, date: date)
            ExpenseManager.shared.saveExpenses()
            
            self.expenses = ExpenseManager.shared.expenses
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let filteredExpenses = expenses.filter { $0.category == category }
        return filteredExpenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        let filteredExpenses = expenses.filter { $0.category == category }
        let expense = filteredExpenses[indexPath.row]
        cell.textLabel?.text = expense.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let dateString = dateFormatter.string(from: expense.date)
        
        cell.detailTextLabel?.text = "\(dateString), \(expense.amount) руб."
        
        return cell
    }
    
    func getDateFromString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.date(from: dateString)
    }
    
    func createDatePicker() -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        let datePickerHeight: CGFloat = 216
        datePicker.frame = CGRect(x: 0, y: view.frame.height - datePickerHeight - 250, width: view.frame.width, height: datePickerHeight)
        
        return datePicker
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let dateString = dateFormatter.string(from: sender.date)
        if let presentedViewController = presentedViewController as? UIAlertController,
           let datePickerTextField = presentedViewController.textFields?.last {
            datePickerTextField.text = dateString
        }
    }
    
    
}
