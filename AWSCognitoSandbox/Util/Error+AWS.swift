//
//  Error+AWS.swift
//  AWSCognitoSandbox
//
//  Created by Kelton Person on 1/8/18.
//

import Foundation
import UIKit

extension NSError {
    
    func handleAWSError(controller: UIViewController) {
        if
            let errorType = userInfo["__type"] as? String,
            let message = userInfo["message"] as? String {
            let alertController = UIAlertController(title: errorType, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            controller.present(alertController, animated: true, completion: nil)
        }
    }
    
}
