//
//  IncomesViewController.swift
//  finance
//
//  Created by Nataly on 13.05.2023.
//

import Foundation
import UIKit
import Charts

class IncomesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var categories: [String] = []
    var incomeDictionary: [String: Double] = [:]
    var selectedDate: Date?
    var incomeArray: [Income] = []
    struct Income: Codable {
        let name: String
        let amount: Double
        let date: Date
    }
    
    var balance: Double = 0
    let balanceLabel = UILabel()
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Доходы"
        view.backgroundColor = .white
        
        balanceLabel.text = "Текущий баланс: \(balance) руб."
        balanceLabel.textAlignment = .center
        balanceLabel.frame = CGRect(x: 0, y: 100, width: view.frame.width, height: 50)
        view.addSubview(balanceLabel)
        tableView.frame = CGRect(x: 0, y: 150, width: view.frame.width, height: view.frame.height - 200)
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        let addButton = UIButton(frame: CGRect(x: view.frame.width / 2 - 100, y: view.frame.height - 50, width: 200, height: 30))
        addButton.setTitle("Добавить доход", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.backgroundColor = .systemBlue
        addButton.layer.cornerRadius = 15
        addButton.addTarget(self, action: #selector(addIncome), for: .touchUpInside)
        view.addSubview(addButton)
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.widthAnchor.constraint(equalToConstant: 200),
            addButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        if let savedBalance = UserDefaults.standard.value(forKey: "balance") as? Double {
            balance = savedBalance
            balanceLabel.text = "Текущий баланс: \(balance) руб."
        }
        
        if let savedCategories = UserDefaults.standard.array(forKey: "incomeCategories") as? [String] {
            categories = savedCategories
        }
        
        if let incomeDictionaryData = UserDefaults.standard.value(forKey: "incomeDictionary") as? Data {
            let decoder = JSONDecoder()
            if let incomeDictionary = try? decoder.decode([String: Double].self, from: incomeDictionaryData) {
                self.incomeDictionary = incomeDictionary
            }
        }
        
        if let incomeArrayData = UserDefaults.standard.value(forKey: "incomeArray") as? Data {
            let decoder = PropertyListDecoder()
            if let incomeArray = try? decoder.decode([Income].self, from: incomeArrayData) {
                self.incomeArray = incomeArray
            }
        }
        incomeArray = loadIncomes()
        tableView.reloadData()
        
        let clearButton = UIButton(frame: CGRect(x: view.frame.width / 2 - 100, y: view.frame.height - 100, width: 200, height: 30))
        clearButton.setTitle("Очистить", for: .normal)
        clearButton.setTitleColor(.white, for: .normal)
        clearButton.backgroundColor = .systemRed
        clearButton.layer.cornerRadius = 15
        clearButton.addTarget(self, action: #selector(clearIncomes), for: .touchUpInside)
        view.addSubview(clearButton)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            clearButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            clearButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            clearButton.widthAnchor.constraint(equalToConstant: 200),
            clearButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        saveData()
        if let chartViewController = navigationController?.viewControllers.first(where: { $0 is ChartViewController }) as? ChartViewController {
            chartViewController.incomes = self.incomeArray
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveData()
        if let chartViewController = navigationController?.viewControllers.first(where: { $0 is ChartViewController }) as? ChartViewController {
            chartViewController.incomes = self.incomeArray
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return incomeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "incomeCell")
        let income = incomeArray[indexPath.row]
        cell.textLabel?.text = income.name
        cell.detailTextLabel?.text = "\(income.amount) руб."
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let income = incomeArray[indexPath.row]
        let alertController = UIAlertController(title: income.name, message: "Сумма: \(income.amount) руб.\nДата: \(income.date)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func loadIncomes() -> [Income] {
        if let data = UserDefaults.standard.value(forKey: "incomeArray") as? Data,
           let incomes = try? PropertyListDecoder().decode([Income].self, from: data) {
            return incomes
        }
        return []
    }
    
    
    func saveData() {
        UserDefaults.standard.set(balance, forKey: "balance")
        UserDefaults.standard.set(categories, forKey: "incomeCategories")
        let encoder = JSONEncoder()
        if let incomeDictionaryData = try? encoder.encode(incomeDictionary) {
            UserDefaults.standard.set(incomeDictionaryData, forKey: "incomeDictionary")
        }
        let incomeArrayData = try? PropertyListEncoder().encode(incomeArray)
        UserDefaults.standard.set(incomeArrayData, forKey: "incomeArray")
    }
    
    @objc func addIncome() {
        let alertController = UIAlertController(title: "Добавить доход", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Название"
        }
        alertController.addTextField { textField in
            textField.placeholder = "Сумма"
            textField.keyboardType = .decimalPad
        }
        alertController.addTextField { textField in
            textField.placeholder = "Дата (в формате ДД.ММ.ГГГГ)"
        }
        alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Добавить", style: .default, handler: { [self] _ in
            guard let category = alertController.textFields?[0].text,
                  let amountString = alertController.textFields?[1].text,
                  let amount = Double(amountString),
                  let dateString = alertController.textFields?[2].text,
                  let date = self.dateFromString(dateString) else {
                      return
                  }
            let income = Income(name: category, amount: amount, date: date)
            self.incomeArray.append(income)
            self.incomeDictionary[category] = amount
            self.balance += amount
            self.balanceLabel.text = "Текущий баланс: \(self.balance) руб."
            UserDefaults.standard.set(self.balance, forKey: "balance")
            UserDefaults.standard.set(Array(self.incomeDictionary.keys), forKey: "incomeCategories")
            let encoder = JSONEncoder()
            if let incomeDictionaryData = try? encoder.encode(self.incomeDictionary) {
                UserDefaults.standard.set(incomeDictionaryData, forKey: "incomeDictionary")
            }
            let encoder2 = PropertyListEncoder()
            if let incomeArrayData = try? encoder2.encode(self.incomeArray) {
                UserDefaults.standard.set(incomeArrayData, forKey: "incomeArray")
            }
            self.tableView.reloadData()
            saveData()
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    func dateFromString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.date(from: dateString)
    }
    
    func createCategory(name: String) {
        categories.append(name)
        tableView.reloadData()
        UserDefaults.standard.set(categories, forKey: "incomeCategories")
    }
    
    func saveIncomeDictionary() {
        let encoder = JSONEncoder()
        if let incomeDictionaryData = try? encoder.encode(incomeDictionary) {
            UserDefaults.standard.set(incomeDictionaryData, forKey: "incomeDictionary")
        }
    }
    
    @objc func clearIncomes() {
        let alert = UIAlertController(title: "Удалить все доходы?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { action in
            self.categories.removeAll()
            self.incomeDictionary.removeAll()
            self.incomeArray.removeAll()
            self.balance = 0
            self.balanceLabel.text = "Текущий баланс: \(self.balance) руб."
            self.tableView.reloadData()
            self.saveData()
        }))
        present(alert, animated: true)
    }
    
}

