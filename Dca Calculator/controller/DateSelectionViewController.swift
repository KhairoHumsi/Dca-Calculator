//
//  DateSelectionViewController.swift
//  Dca Calculator
//
//  Created by mohammad khair pk on 25/02/2021.
//

import UIKit

class DateSelectionViewController: UITableViewController {
    
    var timeSeriesMonthlyAdjusted: TimeSeriesMonthlyAdjusted?
    var selectedIdex: Int?
    
    private var monthInfos: [MonthInfo] = []
    
    var didSelectDate: ((Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigation()
        setUpMonthInfo()
    }
    
    private func setUpNavigation() {
        title = "Select date"
    }
    
    private func setUpMonthInfo() {
        monthInfos = timeSeriesMonthlyAdjusted?.getMonthInfos() ?? []
    }
}

extension DateSelectionViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monthInfos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.item
        let monthInfo = monthInfos[index]
        
        let isSelected = index == selectedIdex
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! DateSelectionTableViewCell
        cell.configure(with: monthInfo, index: index, isSelected: isSelected)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectDate?(indexPath.item)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class DateSelectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var monthsAgoLabel: UILabel!
    
    func configure(with monthInfo: MonthInfo, index: Int, isSelected: Bool) {
        accessoryType = isSelected ? .checkmark : .none
        
        monthLabel.text = monthInfo.date.MMYYFormat
        
        if index == 1 {
            monthsAgoLabel.text = "1 month ago"
        } else if index > 1 {
            monthsAgoLabel.text = "\(index) months ago"
        } else {
            monthsAgoLabel.text = "Just invested"
        }
    }
}
