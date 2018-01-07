//
//  ViewController.swift
//  AWSCognitoSandbox
//
//  Created by Kelton Person on 1/5/18.
//

import UIKit

class ViewController: UIViewController {

    private var authManager: AuthManager!
    private var hasAppeared = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasAppeared {
            authManager = AppDelegate.authManager
            hasAppeared = true
            let _ = authManager.fetchIsSignedIn().onSuccess { isSignedIn in
                if isSignedIn {
                    self.loadFeatureArea()
                }
                else {
                    self.startAuthFlow()
                }
            }
        }
    }
    
    private func startAuthFlow() {
        let _ = authManager.startAuth().onSuccess { _ in
            print("done")
        }
    }
    
    private func loadFeatureArea() {
    }

}
