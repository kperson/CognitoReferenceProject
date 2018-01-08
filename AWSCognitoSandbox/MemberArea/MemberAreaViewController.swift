//
//  MemberAreaViewController.swift
//  AWSCognitoSandbox
//
//  Created by Kelton Person on 1/7/18.
//

import Foundation
import UIKit

class MemberAreaViewController: UIViewController {
    
    private var authManager: AuthManager!
    
    class func create(authManager: AuthManager) -> UIViewController {
        let vc = UIStoryboard(name: "MemberArea", bundle: nil).instantiateViewController(withIdentifier: "MemberAreaViewControllerId") as! MemberAreaViewController
        return vc
    }
    
}
