//
//  AuthManager.swift
//  AWSCognitoSandbox
//
//  Created by Kelton Person on 1/6/18.
//

import Foundation
import UIKit
import FSwift
import AWSCognito
import AWSCognitoIdentityProvider

protocol AuthManagerDelegate: class {

    func willSignOut()
    func didSignOut()
    func authConfirmed()
    func unAuthConfirmed()
    
}
class AuthManager: NSObject, AWSCognitoIdentityInteractiveAuthenticationDelegate {

    static let userPoolKey = "UserPool"
    private var appDelegate: AppDelegate
    private var window: UIWindow?
    private (set) var credentialsProvider: AWSCognitoCredentialsProvider
    private (set) var userPool: AWSCognitoIdentityUserPool
    private var navigtationController: UINavigationController?
    
    weak var delegate: AuthManagerDelegate?
    
    init(window: UIWindow?, appDelegate: AppDelegate) {
        self.window = window
        self.appDelegate = appDelegate
        let userPoolConfiguration = AWSCognitoIdentityUserPoolConfiguration (
            clientId: Constants.appId,
            clientSecret: Constants.appSecret,
            poolId: Constants.userPoolId
        )
        let userPoolDefaultServiceConfig = AWSServiceConfiguration (
            region: Constants.regionType,
            credentialsProvider: nil
        )
        AWSCognitoIdentityUserPool.register (
            with: userPoolDefaultServiceConfig,
            userPoolConfiguration: userPoolConfiguration,
            forKey: AuthManager.userPoolKey
        )
        userPool = AWSCognitoIdentityUserPool(forKey: AuthManager.userPoolKey)
        credentialsProvider = AuthManager.createCredentialsProvider(up: userPool)
        credentialsProvider.clearCredentials()
        let configuration = AWSServiceConfiguration (
            region: Constants.regionType,
            credentialsProvider: credentialsProvider
        )
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    func registerAuthMonitor(delegate: AuthManagerDelegate) {
        self.delegate = delegate
        credentialsProvider.getIdentityId().continueWith { task in
            Dispatch.foreground {
                if let cu = self.userPool.currentUser(), cu.isSignedIn {
                    self.delegate?.authConfirmed()
                }
                else {
                    self.delegate?.unAuthConfirmed()
                }
            }
        }
    }
    
    func signOut() {
        delegate?.willSignOut()
        credentialsProvider.clearKeychain()
        userPool.clearAll()
        credentialsProvider = AuthManager.createCredentialsProvider(up: userPool)
        let configuration = AWSServiceConfiguration (
            region: Constants.regionType,
            credentialsProvider: credentialsProvider
        )
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        //force a refresh
        credentialsProvider.getIdentityId().continueWith { task in
            Dispatch.foreground {
                self.delegate?.didSignOut()
                self.delegate?.unAuthConfirmed()
            }
        }
    }
    
    func startAuth() {
        userPool.delegate = self
        if userPool.currentUser() == nil {
            launchSignUpOrLogin()
        }
        else if let u = userPool.currentUser(), !u.isSignedIn {
            launchSignUpOrLogin()
        }
    }
    
    private class func createCredentialsProvider(up: AWSCognitoIdentityUserPool) -> AWSCognitoCredentialsProvider {
        if let cu = up.currentUser(), cu.isSignedIn {
            return AWSCognitoCredentialsProvider (
                regionType: Constants.regionType,
                identityPoolId: Constants.identityPoolId,
                identityProviderManager: up
            )
        }
        else {
            return AWSCognitoCredentialsProvider (
                regionType: Constants.regionType,
                identityPoolId: Constants.identityPoolId
            )
        }
    }

    
    func startPasswordAuthentication() -> AWSCognitoIdentityPasswordAuthentication {
        let vc = LoginViewController.create(authManager: self)
        Dispatch.foreground {
            if let rootVC = self.window?.rootViewController {
                let nv = UINavigationController(rootViewController: vc)
                self.navigtationController = nv
                rootVC.present(nv, animated: true, completion: nil)
            }
        }
        return vc
    }
    
    func startMultiFactorAuthentication() -> AWSCognitoIdentityMultiFactorAuthentication {
        let vc = MFAViewController.create(authManager: self)
        Dispatch.foreground {
            if let nc = self.navigtationController {
                //replace the last view controller to avoid being able to go back
                var childNCs = nc.childViewControllers
                childNCs[childNCs.count - 1] = vc
                nc.setViewControllers(childNCs, animated: true)
            }
            else if let rootVC = self.window?.rootViewController {
                //this just a random challenge, not part of any flow in particular, show controller
                let nv = UINavigationController(rootViewController: vc)
                self.navigtationController = nv
                rootVC.present(nv, animated: true, completion: nil)
            }
        }
        return vc
    }
    
    func mfaCompleted() {
        navigtationController = nil
        credentialsProvider.clearKeychain()
        credentialsProvider = AuthManager.createCredentialsProvider(up: userPool)
        let configuration = AWSServiceConfiguration (
            region: Constants.regionType,
            credentialsProvider: credentialsProvider
        )
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        //force a refresh
        credentialsProvider.getIdentityId().continueWith { task in
            Dispatch.foreground {
                self.delegate?.authConfirmed()
            }
        }
    }
    
    func loginComplete() {
        //we don't need this in our implementation
    }
    
    func launchSignUpOrLogin() {
        if let rootVC = window?.rootViewController {
            let vc = LoginSignupViewController.create(authManager: self)
            let nv = UINavigationController(rootViewController: vc)
            navigtationController = nv
            rootVC.present(nv, animated: true, completion: nil)
        }
    }

}
