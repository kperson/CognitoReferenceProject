//
//  ViewController.swift
//  AWSCognitoSandbox
//
//  Created by Kelton Person on 1/5/18.
//

import UIKit

class ViewController: UIViewController, AuthManagerDelegate {

    private var authManager: AuthManager!
    private var hasAppeared = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasAppeared {
            authManager = AppDelegate.authManager
            hasAppeared = true
            authManager.registerAuthMonitor(delegate: self)
        }
    }
    
    func willSignOut() {
    }
    
    func didSignOut() {
    }
    
    func authConfirmed() {
        print("authorized")
    }
    
    func unAuthConfirmed() {
        print("unauth")
    }

}

