//
//  DateAxisValueFormatter.swift
//  finance
//
//  Created by Nataly on 16.05.2023.
//

import UIKit
import Charts

class ChartViewController: UIViewController {
    var expenses: [ExpenseManager.Expense] = []
    var incomes: [IncomesViewController.Income] = []
    var chartView: LineChartView!
    var selectDatesButton: UIButton!
    var selectedTimeRange: TimeRange = .allTime
    var noExpensesLabel: UILabel!
    
    
    enum TimeRange {
        case allTime
        case custom(Date, Date)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        expenses = ExpenseManager.shared.expenses
        
        let incomesViewController = IncomesViewController()
        incomes = incomesViewController.loadIncomes()
        
        selectDatesButton = UIButton(type: .system)
        selectDatesButton.setTitle("Выбрать промежуток времени", for: .normal)
        selectDatesButton.addTarget(self, action: #selector(selectDatesButtonTapped), for: .touchUpInside)
        view.addSubview(selectDatesButton)
        selectDatesButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectDatesButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            selectDatesButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        noExpensesLabel = UILabel()
        noExpensesLabel.text = "В данный промежуток времени расходов нет"
        noExpensesLabel.textAlignment = .center
        noExpensesLabel.textColor = .black
        noExpensesLabel.font = UIFont.systemFont(ofSize: 16)
        noExpensesLabel.isHidden = true
        view.addSubview(noExpensesLabel)
        
        noExpensesLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noExpensesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noExpensesLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        chartView = LineChartView(frame: view.frame)
        view.addSubview(chartView)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chartView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            chartView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            chartView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            chartView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
        
        var expenseDataEntries: [ChartDataEntry] = []
        var incomeDataEntries: [ChartDataEntry] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        for (index, expense) in expenses.enumerated() {
            let xValue = Double(index)
            let yValue = expense.amount
            let dataEntry = ChartDataEntry(x: xValue, y: yValue)
            expenseDataEntries.append(dataEntry)
        }
        
        for (index, income) in incomes.enumerated() {
            let xValue = Double(index)
            let yValue = income.amount
            let dataEntry = ChartDataEntry(x: xValue, y: yValue)
            incomeDataEntries.append(dataEntry)
        }
        
        let expenseLineChartDataSet = LineChartDataSet(entries: expenseDataEntries, label: "Расходы")
        expenseLineChartDataSet.setColor(.systemRed)
        expenseLineChartDataSet.setCircleColor(.systemRed)
        
        let incomeLineChartDataSet = LineChartDataSet(entries: incomeDataEntries, label: "Доходы")
        incomeLineChartDataSet.setColor(.systemGreen)
        incomeLineChartDataSet.setCircleColor(.systemGreen)
        
        let lineChartData = LineChartData(dataSets: [expenseLineChartDataSet, incomeLineChartDataSet])
        chartView.data = lineChartData
        
        let xAxis = chartView.xAxis
        xAxis.valueFormatter = IndexAxisValueFormatter(
            values: expenses.map { dateFormatter.string(from: $0.date) }
            + incomes.map { dateFormatter.string(from: $0.date) }
        )
        xAxis.granularity = 1
        
        chartView.animate(xAxisDuration: 0.5)
        
        if expenses.isEmpty && incomes.isEmpty {
            noExpensesLabel.isHidden = false
        } else {
            noExpensesLabel.isHidden = true
        }
    }
    
    @objc private func selectDatesButtonTapped() {
        let alertController = UIAlertController(title: "Выбрать промежуток времени", message: nil, preferredStyle: .actionSheet)
        
        let allTimeAction = UIAlertAction(title: "За все время", style: .default) { [weak self] _ in
            self?.selectedTimeRange = .allTime
            self?.updateChartView()
        }
        alertController.addAction(allTimeAction)
        
        let customTimeRangeAction = UIAlertAction(title: "Выбрать пользовательский промежуток", style: .default) { [weak self] _ in self?.showDatePicker()
        }
        alertController.addAction(customTimeRangeAction)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func showDatePicker() {
        let datePickerViewController = DatePickerViewController { [weak self] startDate, endDate in
            guard let startDate = startDate, let endDate = endDate else {
                return
            }
            self?.selectedTimeRange = .custom(startDate, endDate)
            self?.updateChartView()
        }
        
        present(datePickerViewController, animated: true, completion: nil)
    }
    
    private func updateChartView() {
        var filteredExpenses: [ExpenseManager.Expense] = []
        var filteredIncomes: [IncomesViewController.Income] = []
        
        switch selectedTimeRange {
        case .allTime:
            filteredExpenses = expenses
            filteredIncomes = incomes
        case .custom(let startDate, let endDate):
            filteredExpenses = expenses.filter { $0.date >= startDate && $0.date <= endDate }
            filteredIncomes = incomes.filter { $0.date >= startDate && $0.date <= endDate }
        }
        
        var expenseDataEntries: [ChartDataEntry] = []
        var incomeDataEntries: [ChartDataEntry] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        for (index, expense) in filteredExpenses.enumerated() {
            let xValue = Double(index)
            let yValue = expense.amount
            let dataEntry = ChartDataEntry(x: xValue, y: yValue)
            expenseDataEntries.append(dataEntry)
        }
        
        for (index, income) in filteredIncomes.enumerated() {
            let xValue = Double(index)
            let yValue = income.amount
            let dataEntry = ChartDataEntry(x: xValue, y: yValue)
            incomeDataEntries.append(dataEntry)
        }
        if filteredExpenses.isEmpty && filteredIncomes.isEmpty {
            noExpensesLabel.isHidden = false
            return
        } else {
            noExpensesLabel.isHidden = true
        }
        
        let expenseLineChartDataSet = LineChartDataSet(entries: expenseDataEntries, label: "Расходы")
        expenseLineChartDataSet.setColor(.systemRed)
        expenseLineChartDataSet.setCircleColor(.systemRed)
        
        let incomeLineChartDataSet = LineChartDataSet(entries: incomeDataEntries, label: "Доходы")
        incomeLineChartDataSet.setColor(.systemGreen)
        incomeLineChartDataSet.setCircleColor(.systemGreen)
        
        let lineChartData = LineChartData(dataSets: [expenseLineChartDataSet, incomeLineChartDataSet])
        chartView.data = lineChartData
        
        let xAxis = chartView.xAxis
        xAxis.valueFormatter = IndexAxisValueFormatter(
            values: filteredExpenses.map { dateFormatter.string(from: $0.date) }
            + filteredIncomes.map { dateFormatter.string(from: $0.date) }
        )
        xAxis.granularity = 1
        
        chartView.animate(xAxisDuration: 0.5)
    }
    
}
