//
//  ExpenseManager.swift
//  finance
//
//  Created by Nataly on 15.05.2023.
//

import Foundation
import UIKit

class ExpenseManager {
    static let shared = ExpenseManager()
    
    struct Expense: Codable {
        let title: String
        let amount: Double
        let category: String
        let date: Date
    }
    
    var expenses: [Expense] = []
    
    init() {
        expenses = loadExpenses() ?? []
    }
    
    func addExpense(title: String, amount: Double, category: String, date: Date) {
        let expense = Expense(title: title, amount: amount, category: category, date: date)
        expenses.append(expense)
        saveExpenses()
    }
    
    let expensesFilename = "expenses.json"
    
    func loadExpenses() -> [Expense]? {
        let decoder = JSONDecoder()
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(expensesFilename),
              let data = try? Data(contentsOf: url),
              let savedExpenses = try? decoder.decode([Expense].self, from: data)
        else { return nil }
        
        return savedExpenses
    }
    
    func saveExpenses() {
        let encoder = JSONEncoder()
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(expensesFilename),
              let data = try? encoder.encode(expenses)
        else { return }
        
        try? data.write(to: url)
    }
}
