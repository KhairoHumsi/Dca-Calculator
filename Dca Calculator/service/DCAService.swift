//
//  DCAService.swift
//  Dca Calculator
//
//  Created by mohammad khair pk on 26/02/2021.
//

import Foundation

struct DCAService {
    
    func calculate(asset: Asset, initialInvestmentAmount: Double, monthlyDollerCostAvaregingAmount: Double, initialDateOfInvestmentIndex: Int) -> DCAResult {
        
        let investmentAmount = getInvestmentAmount(initialInvestmentAmount: initialInvestmentAmount, monthlyDollerCostAvaregingAmount: monthlyDollerCostAvaregingAmount, initialDateOfInvestmentIndex: initialDateOfInvestmentIndex)
        
        let latestSharePrice = getLatestSharePrice(asset: asset)
        
        let numberOfShares = getNumberOfShares(asset: asset, initialInvestmentAmount: initialInvestmentAmount, monthlyDollerCostAvaregingAmount: monthlyDollerCostAvaregingAmount, initialDateOfInvestmentIndex: initialDateOfInvestmentIndex)
        
        let currentValue = getCurrentValue(numberOfShares: numberOfShares, latestSharePrice: latestSharePrice)
        
        let isProfitable = currentValue > investmentAmount
        
        let gain = currentValue - investmentAmount
        
        let yield = gain / investmentAmount
        
        let annualReturn = getAnnualReturn(currentValue: currentValue,
                                           investmentAmount: investmentAmount,
                                           initialDateOfInvestmentIndex: initialDateOfInvestmentIndex)
        
        return .init(currentValue: currentValue, investmentAmount: investmentAmount, gainAmount: gain, yield: yield, annualReturn: annualReturn, isProfitable: isProfitable)
    }
    
    private func getInvestmentAmount(initialInvestmentAmount: Double, monthlyDollerCostAvaregingAmount: Double, initialDateOfInvestmentIndex: Int) -> Double {
        
        var totalAmount = Double()
        totalAmount += initialInvestmentAmount
        let dollerCostAveragingAmount = initialDateOfInvestmentIndex.doubleValue * monthlyDollerCostAvaregingAmount
        totalAmount += dollerCostAveragingAmount
        return totalAmount
    }
    
    private func getCurrentValue(numberOfShares: Double, latestSharePrice: Double) -> Double {
        return numberOfShares * latestSharePrice
    }
    
    private func getLatestSharePrice(asset: Asset) -> Double {
        return asset.timeSeriesMonthlyAdjusted.getMonthInfos().first?.adjustedClose ?? 0
    }
    
    private func getNumberOfShares(asset: Asset, initialInvestmentAmount: Double, monthlyDollerCostAvaregingAmount: Double, initialDateOfInvestmentIndex: Int) -> Double {
        
        var totalShares = Double()
        let initialInvestmentOpenPrice = asset.timeSeriesMonthlyAdjusted.getMonthInfos()[initialDateOfInvestmentIndex].adjustedOpen
        let initialInvestmentShares = initialInvestmentAmount / initialInvestmentOpenPrice
        totalShares += initialInvestmentShares
        asset.timeSeriesMonthlyAdjusted.getMonthInfos().prefix(initialDateOfInvestmentIndex).forEach { (monthInfo) in
            let dcaInvestmentShares = monthlyDollerCostAvaregingAmount / monthInfo.adjustedClose
            
            totalShares += dcaInvestmentShares
        }
        
        return totalShares
    }
    
    private func getAnnualReturn(currentValue: Double, investmentAmount: Double, initialDateOfInvestmentIndex: Int) -> Double {
        let rate = currentValue / investmentAmount
        let years = (initialDateOfInvestmentIndex.doubleValue + 1) / 12
        let result = pow(rate, (1 / years)) - 1
        return result
    }
}

struct DCAResult {
    let currentValue: Double
    let investmentAmount: Double
    let gainAmount: Double
    let yield: Double
    let annualReturn: Double
    let isProfitable: Bool
}
