//
//  CalculatorTableViewController.swift
//  Dca Calculator
//
//  Created by mohammad khair pk on 25/02/2021.
//

import UIKit
import Combine

class CalculatorTableViewController: UITableViewController {
    
    @IBOutlet weak var currentValueLabel: UILabel!
    @IBOutlet weak var investmentAmountLabel: UILabel!
    @IBOutlet weak var gainLabel: UILabel!
    @IBOutlet weak var yieldLabel: UILabel!
    @IBOutlet weak var annualReturnLabel: UILabel!
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
    @Published private var initialInvestmentAmount : Int?
    @Published private var monthlyDollrtCostAveraging : Int?
    
    private var subsicribers = Set<AnyCancellable>()
    private let dcaService = DCAService()
    
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
            let dateSliderCount = count - 1
            dateSlider.maximumValue = dateSliderCount.floatValue
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
        
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: initialInvestmentAmountTextField).compactMap({
            ($0.object as? UITextField)?.text
        }).sink { [weak self] (text) in
            self?.initialInvestmentAmount = Int(text) ?? 0
            print("initialInvestmentAmountTextField: \(text)")
        }.store(in: &subsicribers)
        
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: monthlyDollrtCostAveragingTextField).compactMap({
            ($0.object as? UITextField)?.text
        }).sink { [weak self] (text) in
            self?.monthlyDollrtCostAveraging = Int(text) ?? 0
            print("monthlyDollrtCostAveragingTextField: \(text)")
        }.store(in: &subsicribers)
        
        Publishers.CombineLatest3($initialInvestmentAmount, $monthlyDollrtCostAveraging, $initialDateOfInvestmentIndex).sink { [weak self] (initialInvestmentAmount, monthlyDollrtCostAveraging, initialDateOfInvestmentIndex) in
            
            guard let asset = self?.asset,
                  let initialInvestmentAmount = initialInvestmentAmount,
                  let monthlyDollrtCostAveraging = monthlyDollrtCostAveraging,
                  let initialDateOfInvestmentIndex = initialDateOfInvestmentIndex
            else { return }
            
            let result = self?.dcaService.calculate(asset: asset, initialInvestmentAmount: initialInvestmentAmount.doubleValue, monthlyDollerCostAvaregingAmount: monthlyDollrtCostAveraging.doubleValue, initialDateOfInvestmentIndex: initialDateOfInvestmentIndex)
            
            self?.currentValueLabel.text = result?.currentValue.stringValue
            self?.investmentAmountLabel.text = result?.investmentAmount.stringValue
            self?.gainLabel.text = result?.gainAmount.stringValue
            self?.yieldLabel.text = result?.yield.stringValue
            self?.annualReturnLabel.text = result?.annualReturn.stringValue
            
            
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
            return false
        }
        return true
    }
}
