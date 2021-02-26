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
        
        let currentVale = getCurrentValue(numberOfShares: numberOfShares, latestSharePrice: latestSharePrice)
        
        return .init(currentValue: currentVale, investmentAmount: investmentAmount, gainAmount: 0, yield: 0, annualReturn: 0)
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
}

struct DCAResult {
    let currentValue: Double
    let investmentAmount: Double
    let gainAmount: Double
    let yield: Double
    let annualReturn: Double
}
