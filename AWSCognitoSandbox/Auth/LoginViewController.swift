//
//  LoginViewController.swift
//  AWSCognitoSandbox
//
//  Created by Kelton Person on 1/6/18.
//

import Foundation
import UIKit
import FSwift
import AWSCognitoIdentityProvider


class LoginViewController: UIViewController, AWSCognitoIdentityPasswordAuthentication {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passworField: UITextField!
    
    
    private var challenge: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    private var authManager: AuthManager!
    private var defaultUsername: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Login"
        if let d = defaultUsername {
            emailField.text = d
        }
    }
    
    @IBAction func didTapLogin(_ sender: Any) {
        if let e = emailField.text, let p = passworField.text, !e.isEmpty && !p.isEmpty {
            login(email: e, password: p)
        }
    }
    
    private func login(email: String, password: String) {
        if let c = challenge {
            c.set(result: AWSCognitoIdentityPasswordAuthenticationDetails(username: email, password: password))
        }
        else if let u = authManager.userPool.currentUser() {
            u.getSession(email, password: password, validationData: nil).continueWith { task in
                Dispatch.foreground {
                    if let e = task.error {
                        self.showLoginError(error: e)
                    }
                    else {
                        self.handleSuccessfulLogin()
                    }
                }
                return Void()
            }
        }
    }
    
    private func showLoginError(error: Error) {
        //TODO
    }
    
    private func handleSuccessfulLogin() {
        //TODO - remove spinner
        authManager.loginComplete()
    }
    
    func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        defaultUsername = authenticationInput.lastKnownUsername
    }
    
    func didCompleteStepWithError(_ error: Error?) {
        Dispatch.foreground {
            if let e = error {
                self.showLoginError(error: e)
            }
            else {
                self.handleSuccessfulLogin()
            }
        }
    }
    
    class func create(authManager: AuthManager) -> LoginViewController {
        let vc = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "LoginViewControllerId") as! LoginViewController
        vc.authManager = authManager
        
        return vc
    }
    
}
