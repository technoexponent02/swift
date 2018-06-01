//
//  petChangePinViewController.swift
//  Video Call App
//
//  Created by IOS MAC5 on 22/01/18.
//  Copyright © 2018 IOS MAC5. All rights reserved.
//

import UIKit

class petChangePinViewController: UIViewController,UITextFieldDelegate {
    
    // Outlet Declaration
    
    @IBOutlet weak var oldPinTxt: UITextField!
    @IBOutlet weak var newPinTxt: UITextField!
    @IBOutlet weak var confirmPinTxt: UITextField!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var logOutView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backView.isHidden = true
        logOutView.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapBlurButton(_:)))
        backView.addGestureRecognizer(tapGesture)
        
        // Do any additional setup after loading the view.
    }
    
    //MARK :- Tap Gesture Function
    @objc func tapBlurButton(_ sender: UITapGestureRecognizer) {
        
        backView.isHidden = true
        logOutView.isHidden = true
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Button Action Declaration
    
    @IBAction func ChangePasswordButtonClick(_ sender: Any)
    {
        if self.oldPinTxt.text! == "" {
            APIController.ShowAlert(Title: "ALert", Message: "Old pin missing", View: self)
        }
        else if self.newPinTxt.text! == "" {
            APIController.ShowAlert(Title: "ALert", Message: "New pin missing", View: self)
        }
        else if self.confirmPinTxt.text! == "" {
            APIController.ShowAlert(Title: "ALert", Message: "Confirm pin missing", View: self)
        }
        else if self.newPinTxt.text != self.confirmPinTxt.text
        {
            
            APIController.ShowAlert(Title: "ALert", Message: "new pin and confirm pin do not match", View: self)
        }
        else
        {
            let postString = "user_access_token=\(UserDefaults.standard.string(forKey: "user_access_token")!)&oldpin=\(self.oldPinTxt.text!)&newpin=\(self.newPinTxt.text!)";
            
            print("postString==>\(postString)")
            
            APIManager.sharedInstance.getUsersFromUrl(Type: "POST", serviceUrl: BASE_URL+"changepin", postString: postString){(userJson) -> Void in
                
                if userJson != nil {
                    print(userJson)
                    if userJson["has_error"] as! Int == 0
                    {
                        
                        let alertView = UIAlertController(title: "Alert", message: "\(userJson["process_success"] as! String)", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                            self.navigationController?.popViewController(animated: true)
                        })
                        alertView.addAction(action)
                        self.present(alertView, animated: true, completion: nil)
                    }
                    else if userJson["has_error"] as! Int == 1
                    {
                        APIController.ShowAlert(Title: "ALert", Message: "\(userJson["errors"] as! String)", View: self)
                    }
                    
                }
            }
        }
    }
    
    @IBAction func backButtonClick(_ sender: Any)
    {
        _ = navigationController?.popViewController(animated: true)
    }
    @IBAction func leftMenuOpenButtonClick(_ sender: Any)
    {
        backView.isHidden = false
        logOutView.isHidden = false
    }
    @IBAction func logOutButtonClick(_ sender: Any)
    {
        backView.isHidden = true
        logOutView.isHidden = true
        
        let outData = UserDefaults.standard.data(forKey: "fcm_token")
        let fcm_token = NSKeyedUnarchiver.unarchiveObject(with: outData!) as! NSString
        let postString = "fcmToken=\(fcm_token)";
        print("postString==>\(postString)")
        
        APIManager.sharedInstance.getUsersFromUrl(Type: "POST", serviceUrl: BASE_URL+"logout", postString: postString){(userJson) -> Void in
            
            if userJson != nil {
                print(userJson)
                if userJson["has_error"] as! Int == 0
                {
                    UserDefaults.standard.set(false, forKey: "login")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let ViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                    self.navigationController?.pushViewController(ViewController, animated: true)
                }
                else if userJson["has_error"] as! Int == 1
                {
                    APIController.ShowAlert(Title: "ALert", Message: "\(userJson["errors"] as! String)", View: self)
                }
                
            }
        }
    }
    // MARK: - Text Field Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder();
        return true;
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

