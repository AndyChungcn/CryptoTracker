//
//  CryptoTVC.swift
//  CryptoTracker
//
//  Created by 钟汇杭 on 2018/10/23.
//  Copyright © 2018 钟汇杭. All rights reserved.
//

import UIKit
import LocalAuthentication

private let headerHeight : CGFloat = 100.0
private let netWorthHeight : CGFloat = 45.0

class CryptoTVC: UITableViewController, CoinDataDelegate {

    var amountLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CoinData.shared.getPrices()
        
        if LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            updateSecurebutton()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        CoinData.shared.delegate = self
        tableView.reloadData()
        displayNetWorth()
    }
    
    func updateSecurebutton() {
        if UserDefaults.standard.bool(forKey: "secure") {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "解锁", style: .plain, target: self, action: #selector(secureTapped))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "加密", style: .plain, target: self, action: #selector(secureTapped))
        }
    }
    
    @objc func secureTapped() {
        if UserDefaults.standard.bool(forKey: "secure") {
            UserDefaults.standard.set(false, forKey: "secure")
        } else {
            UserDefaults.standard.set(true, forKey: "secure")
        }
        updateSecurebutton()
    }
    
    func newPrices() {
        displayNetWorth()
        tableView.reloadData()
    }
    
    func createHeaderView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: headerHeight))
        headerView.backgroundColor = UIColor.white
        let networthLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: netWorthHeight))
        networthLabel.text = "My Crypto Net Worth"
        networthLabel.textAlignment = .center
        headerView.addSubview(networthLabel)
        
        amountLabel.frame = CGRect(x: 0, y: netWorthHeight, width: view.frame.size.width, height: headerHeight - netWorthHeight)
        amountLabel.textAlignment = .center
        amountLabel.font = UIFont.boldSystemFont(ofSize: 60.0)
        headerView.addSubview(amountLabel)
        
        displayNetWorth()
        
        return headerView
    }
    
    func displayNetWorth() {
        amountLabel.text = CoinData.shared.netWorthAsString()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return createHeaderView()
    }

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
