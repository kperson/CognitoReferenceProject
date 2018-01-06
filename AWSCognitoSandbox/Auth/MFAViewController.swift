//
//  MFAViewController.swift
//  AWSCognitoSandbox
//
//  Created by Kelton Person on 1/6/18.
//

import Foundation
import UIKit
import FSwift
import AWSCognitoIdentityProvider


class MFAViewController: UIViewController, AWSCognitoIdentityMultiFactorAuthentication {

    
    @IBOutlet weak var mfaField: UITextField!
    
    private var challenge: AWSTaskCompletionSource<NSString>?
    private var authManager: AuthManager!
    private var defaultUsername: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Confirm"
    }
    
    @IBAction func didTapConfirm(_ sender: Any) {
        if let code = mfaField.text, !code.isEmpty {
            confirm(code: code)
        }
    }
    
    private func confirm(code: String) {
        challenge?.set(result: code as NSString)
    }
    
    private func showMFAError(error: Error) {
        //TODO
    }
    
    private func handleSuccessfulMFA() {
        authManager.mfaCompleted()
        dismiss(animated: true, completion: nil)
    }
    
    
    func getCode(_ authenticationInput: AWSCognitoIdentityMultifactorAuthenticationInput, mfaCodeCompletionSource: AWSTaskCompletionSource<NSString>) {
        challenge = mfaCodeCompletionSource
    }
    
    func didCompleteMultifactorAuthenticationStepWithError(_ error: Error?) {
        Dispatch.foreground {
            if let e = error {
                self.showMFAError(error: e)
            }
            else {
                self.handleSuccessfulMFA()
            }
        }
    }
    
    class func create(authManager: AuthManager) -> MFAViewController {
        let vc = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "MFAViewControllerId") as! MFAViewController
        vc.authManager = authManager
        
        return vc
    }
    
}
