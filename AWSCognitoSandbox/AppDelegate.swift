//
//  AppDelegate.swift
//  AWSCognitoSandbox
//
//  Created by Kelton Person on 1/5/18.
//

import UIKit
import AWSCognito
import AWSCognitoIdentityProvider

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static var authManager: AuthManager!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        AppDelegate.authManager = AuthManager(window: window, appDelegate: self)
        return true
    }

}
