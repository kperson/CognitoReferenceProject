//
//  SignupViewController.swift
//  AWSCognitoSandbox
//
//  Created by Kelton Person on 1/6/18.
//

import Foundation
import UIKit

class SignupViewController: UIViewController {
    
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passworField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Sign Up"
    }
    
    
    @IBAction func didTapSignUp(_ sender: Any) {
    }
    
    class func create() -> UIViewController {
        let vc = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "SignupViewControllerId") as! SignupViewController
        
        return vc
    }
    
}
