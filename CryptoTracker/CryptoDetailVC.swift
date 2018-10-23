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
private let imageSize : CGFloat = 100.0
private let priceLabelHeight : CGFloat = 25.0

class CryptoDetailVC: UIViewController, CoinDataDelegate {

    var coin: Coin?
    var chart = Chart()
    var priceLabel = UILabel()
    var youOwnLabel = UILabel()
    var worthLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CoinData.shared.delegate = self
        edgesForExtendedLayout = []
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        title = coin?.symbol
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "编辑", style: .plain, target: self, action: #selector(editTapped))
        
        
        chart.yLabelsFormatter = { CoinData.shared.doubleToMoneyString(double: $1) }
        chart.xLabels = [0, 5, 10, 15, 20, 25, 30]
        chart.xLabelsFormatter = { String(Int(round(30 - $1))) + "d" }
        chart.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: chartHeight)
        view.addSubview(chart)
        
        let imageView = UIImageView(frame: CGRect(x: view.frame.size.width / 2 - imageSize / 2, y: chartHeight + 50, width: imageSize, height: imageSize))
        imageView.image = coin?.image
        view.addSubview(imageView)
        
        priceLabel.frame = CGRect(x: 0, y: chartHeight + imageSize + 50, width: view.frame.size.width, height: priceLabelHeight)
        priceLabel.textAlignment = .center
        view.addSubview(priceLabel)
        
        youOwnLabel.frame = CGRect(x: 0, y: chartHeight + imageSize + priceLabelHeight * 2 + 30, width: view.frame.size.width, height: priceLabelHeight)
        youOwnLabel.textAlignment = .center
        youOwnLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        view.addSubview(youOwnLabel)
        
        worthLabel.frame = CGRect(x: 0, y: chartHeight + imageSize + priceLabelHeight * 3 + 30, width: view.frame.size.width, height: priceLabelHeight)
        worthLabel.textAlignment = .center
        worthLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        view.addSubview(worthLabel)
        
        coin?.getHistoricalData()
        newPrices()
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
            chart.add(series)
        }
    }
    
    func newPrices() {
        if let coin = coin {
            priceLabel.text = coin.priceAsString()
            worthLabel.text = "总价值：\(coin.amountAsString())"
            youOwnLabel.text = "你有\(coin.amount)个\(coin.symbol)"
        }
    }
}
