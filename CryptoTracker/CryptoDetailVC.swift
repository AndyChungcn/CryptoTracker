//
//  CryptoDetailVC.swift
//  CryptoTracker
//
//  Created by 钟汇杭 on 2018/10/23.
//  Copyright © 2018 钟汇杭. All rights reserved.
//

import UIKit
import SwiftChart

private let chartHeight : CGFloat = 300.0
private let imageSize : CGFloat = 80.0
private let priceLabelHeight : CGFloat = 30.0

class CryptoDetailVC: UIViewController, CoinDataDelegate {

    var coin: Coin?
    var chart = Chart()
    var priceLabel = UILabel()
    var youOwnLabel = UILabel()
    var worthLabel = UILabel()
    var thirtydaysXCoordinate: [Double]  = [0, 5, 10, 15, 20, 25, 30]
    var sixtydaysXCoordinate:[Double]    = [0, 10, 20, 30, 40, 50, 60]
    var ninetydaysXCoordinate:[Double]   = [0, 15, 30, 45, 60, 75, 90]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CoinData.shared.delegate = self
        edgesForExtendedLayout = []
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        title = coin?.symbol
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "编辑", style: .plain, target: self, action: #selector(editTapped))
        
        
        chart.yLabelsFormatter = { CoinData.shared.doubleToMoneyString(double: $1) }
        chart.xLabels = thirtydaysXCoordinate
        
        chart.xLabelsFormatter = { String(Int(round((self.chart.xLabels?.last)! - $1))) + "d" }
        chart.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: chartHeight)
        view.addSubview(chart)
        
        // Initialize
        let items = ["30天", "60天", "90天"]
        let historicalDailySC = UISegmentedControl(items: items)
        historicalDailySC.selectedSegmentIndex = 0
        // Set up Frame and SegmentedControl
        historicalDailySC.frame = CGRect(x: view.frame.width / 2 - 80, y: chartHeight + 15, width: 160, height: 30.0)
        // Style the Segmented Control
        historicalDailySC.layer.cornerRadius = 7.0  // Don't let background bleed
        historicalDailySC.backgroundColor = UIColor.blue
        historicalDailySC.tintColor = UIColor.white
        // Add target action method
        historicalDailySC.addTarget(self, action: #selector(dailyLimitChanged), for: .valueChanged)
        view.addSubview(historicalDailySC)
        
        let imageView = UIImageView(frame: CGRect(x: view.frame.size.width / 2 - imageSize / 2, y: chartHeight + 70, width: imageSize, height: imageSize))
        imageView.image = coin?.image
        view.addSubview(imageView)
        
        priceLabel.frame = CGRect(x: 0, y: chartHeight + imageSize + 70, width: view.frame.size.width, height: priceLabelHeight)
        priceLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        priceLabel.textAlignment = .center
        view.addSubview(priceLabel)
        
        youOwnLabel.frame = CGRect(x: 0, y: chartHeight + imageSize + priceLabelHeight * 2 + 50, width: view.frame.size.width, height: priceLabelHeight)
        youOwnLabel.textAlignment = .center
        youOwnLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        view.addSubview(youOwnLabel)
        
        worthLabel.frame = CGRect(x: 0, y: chartHeight + imageSize + priceLabelHeight * 3 + 50, width: view.frame.size.width, height: priceLabelHeight)
        worthLabel.textAlignment = .center
        worthLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        view.addSubview(worthLabel)
        
        coin?.getHistoricalData()
        newPrices()
    }
    
    @objc func dailyLimitChanged(sender: UISegmentedControl) {
        chart.removeAllSeries()
        switch sender.selectedSegmentIndex {
        case 0:
            coin?.dailyLimit = 30
        case 1:
            coin?.dailyLimit = 60
        case 2:
            coin?.dailyLimit = 90
        default:
            print("error")
        }
        
        switch coin?.dailyLimit {
        case 30:
            chart.xLabels = thirtydaysXCoordinate
        case 60:
            chart.xLabels = sixtydaysXCoordinate
        default:
            chart.xLabels = ninetydaysXCoordinate
        }
    }
    
    @objc func editTapped() {
        
        if let coin = coin {
            let alert = UIAlertController(title: "你拥有的\(coin.symbol)个数:", message: nil, preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "0.5"
                textField.keyboardType = .decimalPad
                if self.coin?.amount != 0.0 {
                    textField.text = String(coin.amount)
                }
            }
            
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
                if let text = alert.textFields?[0].text {
                    if let amount = Double(text) {
                        self.coin?.amount = amount
                        UserDefaults.standard.set(amount, forKey: coin.symbol + "amount")
                        self.newPrices()
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    
    }
    
    func newHistory() {
        if let coin = coin {
            let series = ChartSeries(coin.historicalData)            
            series.area = true
            series.color = UIColor.blue
            chart.add(series)
        }
    }
    
    func newPrices() {
        if let coin = coin {
            priceLabel.text = coin.priceAsString()
            worthLabel.text = "总价值：\(coin.amountAsString())"
            youOwnLabel.text = "我有\(coin.amount)个\(coin.symbol)"
        }
    }
}
