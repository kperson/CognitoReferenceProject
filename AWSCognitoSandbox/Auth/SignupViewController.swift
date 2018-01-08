//
//  SignupViewController.swift
//  AWSCognitoSandbox
//
//  Created by Kelton Person on 1/6/18.
//

import Foundation
import UIKit
import AWSCognitoIdentityProvider

class SignupViewController: UIViewController {
    
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    private var authManager: AuthManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Sign Up"
    }
    
    
    @IBAction func didTapSignUp(_ sender: Any) {
        if  let first = firstNameField.text,
            let last = lastNameField.text,
            let phone = phoneField.text,
            let email = emailField.text,
            let password = passwordField.text {
            
            let attributes = [
                AWSCognitoIdentityUserAttributeType(name: "give_name", value: first),
                AWSCognitoIdentityUserAttributeType(name: "family_name", value: last),
                AWSCognitoIdentityUserAttributeType(name: "phone_number", value: phone),
                AWSCognitoIdentityUserAttributeType(name: "email", value: phone),
                AWSCognitoIdentityUserAttributeType(name: "email", value: email)
            ]
            authManager.userPool.signUp(first, password: password, userAttributes: attributes, validationData: nil).continueWith { task in
                if let e = task.error {
                    self.showRegistrationError(error: e)
                }
                return Void()
            }
            
        }
    }
    
    func showRegistrationError(error: Error) {
        (error as NSError).handleAWSError(controller: self)
    }
    

    var firstName: String? {
        return firstNameField.text
    }
    var lastName: String? {
        return lastNameField.text
    }
    
    
    class func create(authManager: AuthManager!) -> UIViewController {
        let vc = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "SignupViewControllerId") as! SignupViewController
        vc.authManager = authManager
        
        return vc
    }
    
}
