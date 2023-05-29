//
//  DateAxisValueFormatter.swift
//  finance
//
//  Created by Nataly on 16.05.2023.
//

import Foundation
import UIKit

class DatePickerViewController: UIViewController {
    var onDateSelection: ((Date?, Date?) -> Void)?
    var startDate: Date?
    var endDate: Date?
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        return datePicker
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Выберите даты"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private let startDateLabel: UILabel = {
        let label = UILabel()
        label.text = "Начало периода"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let endDateLabel: UILabel = {
        let label = UILabel()
        label.text = "Конец периода"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let selectedStartDateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let selectedEndDateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Сохранить", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        return button
    }()
    
    
    init(onDateSelection: ((Date?, Date?) -> Void)?) {
        self.onDateSelection = onDateSelection
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            datePicker.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        view.addSubview(startDateLabel)
        startDateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startDateLabel.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 16),
            startDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            startDateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        view.addSubview(selectedStartDateLabel)
        selectedStartDateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectedStartDateLabel.topAnchor.constraint(equalTo: startDateLabel.bottomAnchor, constant: 8),
            selectedStartDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            selectedStartDateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        view.addSubview(endDateLabel)
        endDateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            endDateLabel.topAnchor.constraint(equalTo: selectedStartDateLabel.bottomAnchor, constant: 8),
            endDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            endDateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        view.addSubview(selectedEndDateLabel)
        selectedEndDateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectedEndDateLabel.topAnchor.constraint(equalTo: endDateLabel.bottomAnchor, constant: 8),
            selectedEndDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            selectedEndDateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        updateSelectedDates()
        
        view.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.topAnchor.constraint(greaterThanOrEqualTo: selectedEndDateLabel.bottomAnchor, constant: 60),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
    }
    
    @objc private func datePickerValueChanged() {
        let selectedDate = datePicker.date
        
        if startDate == nil {
            startDate = selectedDate
        } else if endDate == nil {
            if selectedDate < startDate! {
                endDate = startDate
                startDate = selectedDate
            } else {
                endDate = selectedDate
            }
        } else {
            if selectedDate < startDate! {
                startDate = selectedDate
            } else if selectedDate > endDate! {
                endDate = selectedDate
            }
        }
        
        updateSelectedDates()
    }
    
    private func updateSelectedDates() {
        if let startDate = startDate {
            selectedStartDateLabel.text = formattedDate(startDate)
        } else {
            selectedStartDateLabel.text = "Выберите дату в календаре"
        }
        
        if let endDate = endDate {
            selectedEndDateLabel.text = formattedDate(endDate)
        } else {
            selectedEndDateLabel.text = "Выберите дату в календаре"
        }
    }
    
    
    @objc private func saveTapped() {
        let selectedStartDate = startDate
        let selectedEndDate = endDate
        onDateSelection?(selectedStartDate, selectedEndDate)
        dismiss(animated: true, completion: nil)
    }

    func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: date)
    }
}
