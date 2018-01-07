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

class AuthManager: NSObject, AWSCognitoIdentityInteractiveAuthenticationDelegate {

    private static let initializationKey = "auth_manager_has_been_initialized"
    static let userPoolKey = "UserPool"
    let appDelegate: AppDelegate
    let window: UIWindow?
    let mfaEnabled: Bool
    private (set) var credentialsProvider: AWSCognitoCredentialsProvider
    private (set) var userPool: AWSCognitoIdentityUserPool
    private var navigtationController: UINavigationController?
    private var authPromise: Promise<Void>? = nil
    
    init(window: UIWindow?, appDelegate: AppDelegate, mfaEnabled: Bool = true) {
        self.window = window
        self.appDelegate = appDelegate
        self.mfaEnabled = mfaEnabled
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
        if AuthManager.isFirtInitialization {
            credentialsProvider.clearKeychain()
            userPool.clearAll()
        }
        AuthManager.markInitialized()
        credentialsProvider.clearCredentials()
        let configuration = AWSServiceConfiguration (
            region: Constants.regionType,
            credentialsProvider: credentialsProvider
        )
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    
    //MARK: - public interface
    
    /// Fetches the sign in status
    ///
    /// - Returns: a future (true if signed) triggered upon completion
    func fetchIsSignedIn() -> Future<Bool> {
        let p = Promise<Bool>()
        credentialsProvider.getIdentityId().continueWith { task in
            if let _ = task.result {
                if let cu = self.userPool.currentUser(), cu.isSignedIn, let _ = task.result {
                    p.completeWith(true)
                }
                else if let _ = task.result {
                    p.completeWith(false)
                }
            }
            else if let e = task.error {
                p.completeWith(e as NSError)
            }
            return Void()
        }
        return p.future
    }
    
    /// Signs a user out
    ///
    /// - Returns: a future triggered upon fetch of new identity id
    func signOut() -> Future<Void> {
        let p = Promise<Void>()
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
            if let _ = task.result {
                p.completeWith(Void())
            }
            else if let e = task.error {
                p.completeWith(e as NSError)
            }
            return Void()
        }
        return p.future
    }
    
    /// Starts an authorization flow, if a user is authorization the future will be completed immedidately
    ///
    /// - Returns: returns a future triggered upon completion
    func startAuth() -> Future<Void> {
        userPool.delegate = self
        if userPool.currentUser() == nil {
            let ap = Promise<Void>()
            launchSignUpOrLogin()
            authPromise = ap
            return ap.future
        }
        else if let u = userPool.currentUser(), !u.isSignedIn {
            let ap = Promise<Void>()
            launchSignUpOrLogin()
            authPromise = ap
            return ap.future
        }
        else {
            return future { Try.success(Void()) }
        }
    }
    
    /// Launches the sign up or login screen
    func launchSignUpOrLogin() {
        if let rootVC = window?.rootViewController {
            let vc = LoginSignupViewController.create(authManager: self)
            let nv = UINavigationController(rootViewController: vc)
            navigtationController = nv
            rootVC.present(nv, animated: true, completion: nil)
        }
    }
    
    
    //MARK - static helpers
    
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
    
    private class func markInitialized() {
        UserDefaults.standard.set(true, forKey: AuthManager.initializationKey)
    }
    
    private class var isFirtInitialization: Bool {
        return !UserDefaults.standard.bool(forKey: AuthManager.initializationKey)
    }

    
    //MARK - AWSCognitoIdentityInteractiveAuthenticationDelegate
    
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
    
    
    //MARK - finalization
    
    func mfaCompleted() {
        finalizeAuth()
    }
    
    func loginComplete() {
        if !mfaEnabled {
            finalizeAuth()
        }
    }
    
    private func finalizeAuth() {
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
            if let _ = task.result {
                self.authPromise?.completeWith(Void())
                self.authPromise = nil
            }
            else if let e = task.error {
                self.authPromise?.completeWith(e as NSError)
                self.authPromise = nil
            }
            return Void()
        }
    }
    
}
