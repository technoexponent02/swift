//
//  VetSignInViewController.swift
//  Video Call App
//
//  Created by IOS MAC5 on 15/01/18.
//  Copyright © 2018 IOS MAC5. All rights reserved.
//

import UIKit

class VetSignInViewController: UIViewController,UITextFieldDelegate {
    
    // Outlet Declaration
    
    @IBOutlet weak var Txt1: UITextField!
    @IBOutlet weak var Txt2: UITextField!
    @IBOutlet weak var Txt3: UITextField!
    @IBOutlet weak var Txt4: UITextField!
    @IBOutlet weak var imagePassShowOrHide: UIImageView!
    
    // Variable Declaration
    
    var iconClick : Bool!
    var UserType : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
         iconClick = true
       // self.addDoneButtonOnKeyboard()
        // Do any additional setup after loading the view.
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button Action Declaration
    
    @IBAction func SignInButtonClick(_ sender: Any)
    {
        let outData = UserDefaults.standard.data(forKey: "fcm_token")
        let fcm_token = NSKeyedUnarchiver.unarchiveObject(with: outData!) as! NSString
        
        let Pin = "\(Txt1.text!)\(Txt2.text!)\(Txt3.text!)\(Txt4.text!)"
        let postString = "pin=\(Pin)&userType=\(UserType!)&fcmToken=\(fcm_token)&deviceId=\(APIController.getIMEI())&deviceType=\("I")";
        
        print("postString==>\(postString)")
        
        APIManager.sharedInstance.getUsersFromUrl(Type: "POST", serviceUrl: BASE_URL+"login", postString: postString){(userJson) -> Void in
            
            if userJson != nil {
                print(userJson)
                if userJson["has_error"] as! Int == 0
                {
                    let user_access_token = userJson["user_access_token"] as! String
                    print(user_access_token)
                    UserDefaults.standard.set(user_access_token, forKey: "user_access_token")
                    
                    UserDefaults.standard.set(true, forKey: "login")
                    UserDefaults.standard.set(self.UserType, forKey: "user_type")
                    
                    var user_details = userJson["user_details"] as! NSDictionary
                    let data = NSKeyedArchiver.archivedData(withRootObject:user_details)
                    UserDefaults.standard.set(data, forKey: "user_details")
                    
                    if self.UserType == "D"
                    {
                        let storyboard: UIStoryboard = UIStoryboard(name: "Veterinarian", bundle: nil)
                        let VetProfileViewController = storyboard.instantiateViewController(withIdentifier: "VetProfileViewController") as! VetProfileViewController
                        self.show(VetProfileViewController, sender: self)
                    }
                    else if self.UserType == "P"
                    {
                        let storyboard: UIStoryboard = UIStoryboard(name: "PetOwner", bundle: nil)
                        let PetProfileViewController = storyboard.instantiateViewController(withIdentifier: "PetProfileViewController") as! PetProfileViewController
                        self.show(PetProfileViewController, sender: self)
                    }
                }
                else if userJson["has_error"] as! Int == 1
                {
                    APIController.ShowAlert(Title: "ALert", Message: "\(userJson["errors"] as! String)", View: self)
                }
                else if userJson["has_error"] as! Int == 2
                {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let accessKeyViewController = storyboard.instantiateViewController(withIdentifier: "accessKeyViewController") as! accessKeyViewController
                    accessKeyViewController.UserType = self.UserType
                    self.navigationController?.pushViewController(accessKeyViewController, animated: true)
                }
                
            }
        }
    }
    
    @IBAction func ForgetPinNumberButtonClick(_ sender: Any)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VetFotgotPasswordViewController = storyboard.instantiateViewController(withIdentifier: "VetFotgotPasswordViewController") as! VetFotgotPasswordViewController
        VetFotgotPasswordViewController.UserType = UserType
        self.navigationController?.pushViewController(VetFotgotPasswordViewController, animated: true)
    }
    @IBAction func showAndHidePassbuttonClick(_ sender: Any)
    {
        if(iconClick == true) {
            self.Txt1.isSecureTextEntry = false
            self.Txt2.isSecureTextEntry = false
            self.Txt3.isSecureTextEntry = false
            self.Txt4.isSecureTextEntry = false
            self.imagePassShowOrHide.image = UIImage(named: "show_pass")!
            iconClick = false
        } else {
            self.Txt1.isSecureTextEntry = true
            self.Txt2.isSecureTextEntry = true
            self.Txt3.isSecureTextEntry = true
            self.Txt4.isSecureTextEntry = true
            self.imagePassShowOrHide.image = UIImage(named: "hide_pass")!
            iconClick = true
        }
    }
    @IBAction func SignUpNowButtonClick(_ sender: Any)
    {
        _ = navigationController?.popViewController(animated: true)
    }
    

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
   
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // On inputing value to textfield
        print("\(string)")
        if ((textField.text?.characters.count)! < 1  && string.characters.count > 0){
            if(textField == Txt1){
                Txt2.becomeFirstResponder()
            }
            if(textField == Txt2){
                Txt3.becomeFirstResponder()
            }
            if(textField == Txt3){
                Txt4.becomeFirstResponder()
            }
            textField.text = string
            return false
            
        }else if ((textField.text?.characters.count)! >= 1  && string.characters.count == 0){
            // on deleting value from Textfield
            
            if(textField == Txt2){
                Txt1.becomeFirstResponder()
            }
            if(textField == Txt3){
                Txt2.becomeFirstResponder()
            }
            if(textField == Txt4) {
                Txt3.becomeFirstResponder()
            }
            textField.text = ""
            return false
        }else if ((textField.text?.characters.count)! >= 1  ){
            textField.text = string
            return false
        }
        return true
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
