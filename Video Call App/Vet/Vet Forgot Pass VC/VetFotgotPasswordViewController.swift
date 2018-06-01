//
//  VetFotgotPasswordViewController.swift
//  Video Call App
//
//  Created by IOS MAC5 on 15/01/18.
//  Copyright © 2018 IOS MAC5. All rights reserved.
//

import UIKit

class VetFotgotPasswordViewController: UIViewController,UITextFieldDelegate {
    
    // Outlet Declaration
    
    @IBOutlet weak var emailText: UITextField!
    
    // Variable Declaration
    
    var UserType : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        print(UserType)
        
        
        
        
        // Do any additional setup after loading the view.
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     // MARK: - Text Field Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    // MARK :- Button Action
    
    @IBAction func SignInButtonClick(_ sender: Any)
    {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resetButtonClick(_ sender: Any)
    {
        if emailText.text != ""
        {
            if APIController.isValidEmail(emailStr: emailText.text!)
            {
                let postString = "email=\(emailText.text!)";
                print("postString==>\(postString)")
                
                APIManager.sharedInstance.getUsersFromUrl(Type: "POST", serviceUrl: BASE_URL+"forgetpassword", postString: postString){(userJson) -> Void in
                    
                    if userJson != nil {
                        print(userJson)
                        if userJson["has_error"] as! Int == 0
                        {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let VetForgotConfirmationViewController = storyboard.instantiateViewController(withIdentifier: "VetForgotConfirmationViewController") as! VetForgotConfirmationViewController
                            VetForgotConfirmationViewController.UserType = self.UserType
                            self.navigationController?.pushViewController(VetForgotConfirmationViewController, animated: true)
                        }
                        else if userJson["has_error"] as! Int == 1
                        {
                            APIController.ShowAlert(Title: "ALert", Message: "\(userJson["errors"] as! String)", View: self)
                        }
                        
                    }
                }
            }
            else
            {
                APIController.ShowAlert(Title: "ALert", Message: "", View: self)
            }
        }
        else
        {
            APIController.ShowAlert(Title: "ALert", Message: "", View: self)
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
