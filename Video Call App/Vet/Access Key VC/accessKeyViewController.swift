//
//  accessKeyViewController.swift
//  Video Call App
//
//  Created by IOS MAC5 on 19/01/18.
//  Copyright © 2018 IOS MAC5. All rights reserved.
//

import UIKit

class accessKeyViewController: UIViewController,UITextFieldDelegate {

     // Outlet Declaration
    
    @IBOutlet weak var accessCodeTxt: UITextField!
    
     // Variable Declaration
    var UserType : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func validateButtonClick(_ sender: Any)
    {
        if accessCodeTxt.text != ""
        {
            let outData = UserDefaults.standard.data(forKey: "fcm_token")
            let fcm_token = NSKeyedUnarchiver.unarchiveObject(with: outData!) as! NSString
            
             let postString = "access_code=\(accessCodeTxt.text!)&fcmToken=\(fcm_token)&deviceId=\(APIController.getIMEI())&deviceType=\("I")";
            
            APIManager.sharedInstance.getUsersFromUrl(Type: "POST", serviceUrl: BASE_URL+"verifyaccess", postString: postString){(userJson) -> Void in
                
                if userJson != nil {
                    print(userJson)
                    if userJson["has_error"] as! Int == 0
                    {
                        let user_access_token = userJson["user_access_token"] as! String
                        print(user_access_token)
                        UserDefaults.standard.set(user_access_token, forKey: "user_access_token")
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
        
                }
            }
            
        }else
        {
            APIController.ShowAlert(Title: "Alert", Message: "the Access Key field is required", View: self)
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
