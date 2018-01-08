//
//  LoginSignupViewController.swift
//  AWSCognitoSandbox
//
//  Created by Kelton Person on 1/6/18.
//

import Foundation
import UIKit

class LoginSignupViewController: UIViewController {
    
    private var authManager: AuthManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Select an Option"
    }
    
    @IBAction func didTapLogin(_ sender: Any) {
        let vc = LoginViewController.create(authManager: authManager)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didTapSignUp(_ sender: Any) {
        let vc = SignupViewController.create()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    class func create(authManager: AuthManager) -> UIViewController {
        let vc = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "LoginSignupViewControllerId") as! LoginSignupViewController
        vc.authManager = authManager
        
        return vc
    }
    
}
