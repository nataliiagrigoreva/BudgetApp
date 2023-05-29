//
//  GraphViewController.swift
//  finance
//
//  Created by Nataly on 16.05.2023.
//

import UIKit
import Charts

class GraphViewController: UIViewController {
    var category: String
    var expenses: [ExpenseManager.Expense]
    var chartView: LineChartView!
    var noExpensesLabel: UILabel!
    var selectedTimeRange: TimeRange = .allTime
    
    enum TimeRange {
        case allTime
        case custom(Date, Date)
    }
    
    init(category: String, expenses: [ExpenseManager.Expense]) {
        self.category = category
        self.expenses = expenses
        super.init(nibName: nil, bundle: nil)
        title = "График расходов"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupChartView()
    }
    
    private func setupChartView() {
        chartView = LineChartView(frame: view.frame)
        view.addSubview(chartView)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chartView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            chartView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            chartView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            chartView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])        
        
        var dataEntries: [ChartDataEntry] = []
        let filteredExpenses = expenses.filter { $0.category == category }
        let sortedExpenses = filteredExpenses.sorted { $0.date < $1.date }
        for i in 0..<sortedExpenses.count {
            let expense = sortedExpenses[i]
            let dataEntry = ChartDataEntry(x: Double(i), y: expense.amount)
            dataEntries.append(dataEntry)
        }
        
        let dataSet = LineChartDataSet(entries: dataEntries, label: "Расходы")
        dataSet.setColor(.systemBlue)
        dataSet.setCircleColor(.systemBlue)
        dataSet.circleRadius = 5
        dataSet.drawCircleHoleEnabled = false
        
        let data = LineChartData(dataSet: dataSet)
        chartView.data = data
        chartView.animate(xAxisDuration: 0.5)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: sortedExpenses.map { dateFormatter.string(from: $0.date) })
        
        chartView.xAxis.granularity = 1
        chartView.xAxis.labelRotationAngle = -45
        
        let selectTimeRangeButton = UIButton()
        selectTimeRangeButton.setTitle("Выбрать промежуток времени", for: .normal)
        selectTimeRangeButton.setTitleColor(.systemBlue, for: .normal)
        selectTimeRangeButton.addTarget(self, action: #selector(selectTimeRange), for: .touchUpInside)
        view.addSubview(selectTimeRangeButton)
        
        selectTimeRangeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectTimeRangeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectTimeRangeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
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
    }
    
    @objc private func selectTimeRange() {
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
        var filteredExpenses = expenses
        
        switch selectedTimeRange {
        case .allTime:
            break
        case .custom(let startDate, let endDate):
            filteredExpenses = expenses.filter { expense in
                return expense.date >= startDate && expense.date <= endDate
            }
        }
        
        if filteredExpenses.isEmpty {
            chartView.isHidden = true
            noExpensesLabel.isHidden = false
        } else {
            chartView.isHidden = false
            noExpensesLabel.isHidden = true
            
            let values = filteredExpenses.map { expense in
                return ChartDataEntry(x: expense.date.timeIntervalSince1970, y: expense.amount)
            }
            
            let set = LineChartDataSet(entries: values, label: category)
            set.colors = [UIColor.blue]
            
            let data = LineChartData(dataSet: set)
            chartView.data = data
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        chartView.xAxis.valueFormatter = DateAxisValueFormatter()
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelRotationAngle = -45
        chartView.xAxis.labelFont = UIFont.systemFont(ofSize: 12)
        
        chartView.leftAxis.labelFont = UIFont.systemFont(ofSize: 12)
        chartView.rightAxis.enabled = false
        
        chartView.legend.font = UIFont.systemFont(ofSize: 14)
        
        chartView.animate(xAxisDuration: 0.5)
    }
}
