//
//  MyBasics.swift
//  Sellora
//
//  Created by Anirudha on 3/26/17.
//  Copyright © 2017 Cravers. All rights reserved.
//

import UIKit

extension UITextField{
    
    func leftPadding(paddingVal:Float, _ AttrPlaceHolder:String?){
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.bounds.size.height))
        self.leftView = view;
        self.leftViewMode = .always
        if AttrPlaceHolder != nil {
            self.attributedPlaceholder = NSAttributedString(string: AttrPlaceHolder!, attributes: [NSAttributedStringKey.foregroundColor:UIColor(white: 0.85, alpha: 1.0)])
        }
        
    }
}



class APIController: NSObject {

    class func ShowAlert(Title:String, Message:String, View:UIViewController) {
        
        let alertController = UIAlertController(title: Title, message: Message, preferredStyle: .alert);
        let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(alertAction)
        View.present(alertController, animated: true, completion: nil)
        
    }
    
    class func isValidEmail(emailStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailStr)
    }
    
   
    
    class func getIMEI() -> String {
        
        return (UIDevice.current.identifierForVendor?.uuidString)!
    }
    
    
}
