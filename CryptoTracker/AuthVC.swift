//
//  AuthVC.swift
//  CryptoTracker
//
//  Created by 钟汇杭 on 2018/10/23.
//  Copyright © 2018 钟汇杭. All rights reserved.
//

import UIKit
import LocalAuthentication

class AuthVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        presentAuth()
    }
    
    func presentAuth() {
        LAContext().evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "请用指纹解锁") { (success, error) in
            if success {
                DispatchQueue.main.async {
                    let cryptoTVC = CryptoTVC()
                    let navController = UINavigationController(rootViewController: cryptoTVC)
                    self.present(navController, animated: true, completion: nil)
                }
            } else {
                self.presentAuth()
            }
        }
    }

}
