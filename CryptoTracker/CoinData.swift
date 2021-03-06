//
//  CoinData.swift
//  CryptoTracker
//
//  Created by 钟汇杭 on 2018/10/23.
//  Copyright © 2018 钟汇杭. All rights reserved.
//

import UIKit
import Alamofire

class CoinData {
    static let shared = CoinData()
    var coins = [Coin]()
    weak var delegate: CoinDataDelegate?
    
    private init() {
        let symbols = ["BTC", "ETH", "LTC", "XRP", "BCH", "EOS", "ADA", "XLM", "NEO", "IOTX"]
        
        for symbol in symbols {
            let coin = Coin(symbol: symbol)
            coins.append(coin)
        }
    }
    
    func getPrices() {
        
        var listOfSymbols = ""
        for coin in coins {
            listOfSymbols += coin.symbol
            if coin.symbol != coins.last?.symbol {
                listOfSymbols += ","
            }
        }
        
        Alamofire.request("https://min-api.cryptocompare.com/data/pricemulti?fsyms=\(listOfSymbols)&tsyms=USD").responseJSON { (response) in
            if response.result.isSuccess {
                if let json = response.result.value as? [String:Any] {
                    for coin in self.coins {
                        if let coinJSON = json[coin.symbol] as? [String: Double] {
                            if let price = coinJSON["USD"] {
                                coin.price = price                                
                                UserDefaults.standard.set(price, forKey: coin.symbol)
                            }
                        }
                    }
                    self.delegate?.newPrices?()
                }
            } else {
                print("Could not get the data")
            }
        }
        
    }
    
    func html() -> String {
        var html = "<h1>虚拟货币财务报表</h1>"
        html += "<h2>总价值: \(netWorthAsString())</h2>"
        html += "<ul>"
        for coin in coins {
            if coin.amount != 0.0 {
                html += "<li>\(coin.symbol) - 我有: \(coin.amount) - 价值: \(doubleToMoneyString(double: coin.amount * coin.price))</li>"
            }
        }
        html += "</ul>"
        
        return html
    }
    
    func netWorthAsString() -> String {
        var netWorth = 0.0
        for coin in coins {
            netWorth += coin.price * coin.amount
        }
        
        return doubleToMoneyString(double: netWorth)
    }
    
    func doubleToMoneyString(double: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency
        if let fancyPrice = formatter.string(from: NSNumber(floatLiteral: double)) {
            return fancyPrice
        } else {
            return "ERROR"
        }
    }
    
}

@objc protocol CoinDataDelegate: class {
    @objc optional func newPrices()
    @objc optional func newHistory()
}


class Coin {
    var symbol = ""
    var image = UIImage()
    var price = 0.0
    var amount = 0.0
    var historicalData = [Double]()
    var dailyLimit: Double = 30 {
        didSet {
            getHistoricalData()
        }
    }
    
    init(symbol: String) {
        self.symbol = symbol
        if let image = UIImage(named: symbol) {
            self.image = image
        }
        
        self.price = UserDefaults.standard.double(forKey: symbol)
        self.amount = UserDefaults.standard.double(forKey: symbol + "amount")
        if let history = UserDefaults.standard.array(forKey: symbol + "history") as? [Double] {
            self.historicalData = history
        }
    }
    
    func getHistoricalData() {
        Alamofire.request("https://min-api.cryptocompare.com/data/histoday?fsym=\(symbol)&tsym=USD&limit=\(dailyLimit)").responseJSON { (response) in
            if let json = response.result.value as? [String: Any] {
                if let pricesJSON = json["Data"] as? [[String: Double]] {
                    self.historicalData = []
                    for priceJSON in pricesJSON {
                        if let closePrice = priceJSON["close"] {
                            self.historicalData.append(closePrice)
                        }
                    }
                    UserDefaults.standard.set(self.historicalData, forKey: self.symbol + "history")
                    CoinData.shared.delegate?.newHistory?()                    
                }
            }
        }
    }
    
    func priceAsString() -> String {
        if price == 0.0 {
            return "加载中..."
        }
        
        return CoinData.shared.doubleToMoneyString(double: price)
    }
    
    func amountAsString() -> String {
        return CoinData.shared.doubleToMoneyString(double: amount * price)
    }
    
}
