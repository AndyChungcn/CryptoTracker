//
//  CryptoDetailVC.swift
//  CryptoTracker
//
//  Created by 钟汇杭 on 2018/10/23.
//  Copyright © 2018 钟汇杭. All rights reserved.
//

import UIKit
import SwiftChart

private let chartHeight : CGFloat = 330.0
private let imageSize : CGFloat = 80.0
private let priceLabelHeight : CGFloat = 30.0

class CryptoDetailVC: UIViewController, CoinDataDelegate, ChartDelegate {

    var coin: Coin?
    var chart = Chart()
    var priceLabel = UILabel()
    var youOwnLabel = UILabel()
    var worthLabel = UILabel()
    var thirtydaysXCoordinate: [Double]  = [0, 5, 10, 15, 20, 25, 30]
    var sixtydaysXCoordinate:[Double]    = [0, 10, 20, 30, 40, 50, 60]
    var ninetydaysXCoordinate:[Double]   = [0, 15, 30, 45, 60, 75, 90]
    var halfYearXCoordinate:[Double]     = [0, 30, 60, 90, 120, 150, 180]
    var oneYearCoordinate:[Double]       = [0, 60, 120, 180, 240, 300, 360]
    var topLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chart.delegate = self
        CoinData.shared.delegate = self
        edgesForExtendedLayout = []
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        title = coin?.symbol
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "编辑", style: .plain, target: self, action: #selector(editTapped))
        
        
        chart.yLabelsFormatter = { CoinData.shared.doubleToMoneyString(double: $1) }
        chart.xLabels = thirtydaysXCoordinate
        
        chart.xLabelsFormatter = { String(Int(round((self.chart.xLabels?.last)! - $1))) + "d" }
        chart.frame = CGRect(x: 0, y: 25, width: view.frame.size.width, height: chartHeight)
        view.addSubview(chart)
        
        // top Label
        topLabel = UILabel(frame: CGRect(x: 16, y: 4, width: 200, height: 20))
//        topLabel.textAlignment = .center
        topLabel.text = "$28"
        topLabel.font = UIFont.systemFont(ofSize: 14)
        topLabel.textColor = UIColor.red
        topLabel.isHidden = true
        view.addSubview(topLabel)
        
        // Initialize
        let items = ["30天", "60天", "90天", "180天", "360天"]
        let historicalDailySC = UISegmentedControl(items: items)
        historicalDailySC.selectedSegmentIndex = 0
        // Set up Frame and SegmentedControl
        historicalDailySC.frame = CGRect(x: view.frame.width / 2 - 120, y: chartHeight + 40, width: 240, height: 30.0)
        // Style the Segmented Control
        historicalDailySC.layer.cornerRadius = 7.0  // Don't let background bleed
        historicalDailySC.backgroundColor = UIColor.green
        historicalDailySC.tintColor = UIColor.white
        // Add target action method
        historicalDailySC.addTarget(self, action: #selector(dailyLimitChanged), for: .valueChanged)
        view.addSubview(historicalDailySC)
        
        let imageView = UIImageView(frame: CGRect(x: view.frame.size.width / 2 - imageSize / 2, y: chartHeight + 90, width: imageSize, height: imageSize))
        imageView.image = coin?.image
        view.addSubview(imageView)
        
        priceLabel.frame = CGRect(x: 0, y: chartHeight + imageSize + 90, width: view.frame.size.width, height: priceLabelHeight)
        priceLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        priceLabel.textAlignment = .center
        view.addSubview(priceLabel)
        
        youOwnLabel.frame = CGRect(x: 0, y: chartHeight + imageSize + priceLabelHeight * 2 + 65, width: view.frame.size.width, height: priceLabelHeight)
        youOwnLabel.textAlignment = .center
        youOwnLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        view.addSubview(youOwnLabel)
        
        worthLabel.frame = CGRect(x: 0, y: chartHeight + imageSize + priceLabelHeight * 3 + 65, width: view.frame.size.width, height: priceLabelHeight)
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
        case 3:
            coin?.dailyLimit = 180
        case 4:
            coin?.dailyLimit = 360
        default:
            print("error")
        }
        
        switch coin?.dailyLimit {
        case 30:
            chart.xLabels = thirtydaysXCoordinate
        case 60:
            chart.xLabels = sixtydaysXCoordinate
        case 90:
            chart.xLabels = ninetydaysXCoordinate
        case 180:
            chart.xLabels = halfYearXCoordinate
        default:
            chart.xLabels = oneYearCoordinate
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
            chart.minY = 0
            
            series.colors = (
                above: ChartColors.greenColor(),
                below: ChartColors.yellowColor(),
                zeroLevel: coin.historicalData.first!
            )
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
    
    func didTouchChart(_ chart: Chart, indexes: [Int?], x: Double, left: CGFloat) {
        
        for (seriesIndex, dataIndex) in indexes.enumerated() {
            if dataIndex != nil {
                // The series at `seriesIndex` is that which has been touched
                let value = chart.valueForSeries(seriesIndex, atIndex: dataIndex)
                topLabel?.text = "$\(value!)"
                
                topLabel?.isHidden = false
            }
        }
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        topLabel?.isHidden = true
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        //do nothing
    }
}
