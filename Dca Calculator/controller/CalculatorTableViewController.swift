//
//  CalculatorTableViewController.swift
//  Dca Calculator
//
//  Created by mohammad khair pk on 25/02/2021.
//

import UIKit
import Combine

class CalculatorTableViewController: UITableViewController {
    
    @IBOutlet weak var initialInvestmentAmountTextField: UITextField!
    @IBOutlet weak var monthlyDollrtCostAveragingTextField: UITextField!
    @IBOutlet weak var initialDateOfInvestmentTextField: UITextField!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet var currencyLabels: [UILabel]!
    @IBOutlet weak var investmentAmountCurrencyLabel: UILabel!
    @IBOutlet weak var dateSlider: UISlider!
    
    var asset: Asset?
    
    @Published private var initialDateOfInvestmentIndex : Int?
    
    private var subsicribers = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        setUpTextFields()
        setUpDateSlider()
        observeForm()
    }
    
    private func setUpViews() {
        symbolLabel.text = asset?.searchResult.symbol
        nameLabel.text = asset?.searchResult.name
        investmentAmountCurrencyLabel.text = asset?.searchResult.currency
        currencyLabels.forEach { (label) in
            label.text = asset?.searchResult.currency.addBrackets()
        }
    }
    
    private func setUpTextFields() {
        initialInvestmentAmountTextField.addDoneButton()
        monthlyDollrtCostAveragingTextField.addDoneButton()
        initialDateOfInvestmentTextField.delegate = self
        
    }
    
    private func setUpDateSlider() {
        if let count = asset?.timeSeriesMonthlyAdjusted.getMonthInfos().count {
            dateSlider.maximumValue = count.floatValue
        }
    }
    
    private func observeForm() {
        $initialDateOfInvestmentIndex.sink { [weak self] (index) in
            guard let index = index else { return }
            self?.dateSlider.value = index.floatValue
            
            if let dateString = self?.asset?.timeSeriesMonthlyAdjusted.getMonthInfos()[index].date.MMYYFormat {
                self?.initialDateOfInvestmentTextField.text = dateString
            }
        }.store(in: &subsicribers)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDateSelection", let destination = segue.destination as? DateSelectionViewController, let timeSeriesMonthlyAdjusted = sender as? TimeSeriesMonthlyAdjusted {
            destination.timeSeriesMonthlyAdjusted = timeSeriesMonthlyAdjusted
            destination.selectedIdex = initialDateOfInvestmentIndex
            destination.didSelectDate = { [weak self] index in
                self?.handleDateSelection(at: index)
            }
        }
    }
    
    private func handleDateSelection(at index: Int) {
        guard navigationController?.visibleViewController is DateSelectionViewController else { return }
        navigationController?.popViewController(animated: true)
        if let monthInfos = asset?.timeSeriesMonthlyAdjusted.getMonthInfos() {
            initialDateOfInvestmentIndex = index
            let monthInfo = monthInfos[index]
            let dateString = monthInfo.date.MMYYFormat
            initialDateOfInvestmentTextField.text = dateString
        }
    }
    
    @IBAction func dateSliderDidChange(_sender: UISlider) {
        initialDateOfInvestmentIndex = Int(_sender.value)
    }
}

extension CalculatorTableViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == initialDateOfInvestmentTextField {
            performSegue(withIdentifier: "showDateSelection", sender: asset?.timeSeriesMonthlyAdjusted)
        }
        return false
    }
}
