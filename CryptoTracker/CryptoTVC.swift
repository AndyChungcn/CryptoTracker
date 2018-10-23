//
//  CryptoTVC.swift
//  CryptoTracker
//
//  Created by 钟汇杭 on 2018/10/23.
//  Copyright © 2018 钟汇杭. All rights reserved.
//

import UIKit

class CryptoTVC: UITableViewController, CoinDataDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        CoinData.shared.delegate = self
        CoinData.shared.getPrices()
    }
    
    func newPrices() {
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoinData.shared.coins.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let coin = CoinData.shared.coins[indexPath.row]        
        cell.textLabel?.text = "\(coin.symbol) - \(coin.priceAsString())"
        cell.imageView?.image = coin.image
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cryptoDetailVC = CryptoDetailVC()
        cryptoDetailVC.coin = CoinData.shared.coins[indexPath.row]
        navigationController?.pushViewController(cryptoDetailVC, animated: true)
    }

}
