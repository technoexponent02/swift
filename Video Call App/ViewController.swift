//
//  ViewController.swift
//  Video Call App
//
//  Created by IOS MAC5 on 15/01/18.
//  Copyright © 2018 IOS MAC5. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Hello")
        UserDefaults.standard.set(false, forKey: "AppStatus")
        if UserDefaults.standard.bool(forKey: "login")
        {
            ApiCallForCheckDevice()
           
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    func ApiCallForCheckDevice()
    {
        let postString = "user_access_token=\(UserDefaults.standard.string(forKey: "user_access_token")!)&deviceId=\(APIController.getIMEI())";
        print("postString==>\(postString)")
        
        APIManager.sharedInstance.getUsersFromUrl(Type: "POST", serviceUrl: BASE_URL+"chkdevice", postString: postString){(userJson) -> Void in
            
            if userJson != nil {
                print(userJson)
                if userJson["has_error"] as! Int == 0
                {
                    let Chk = userJson["chk"] as! String
                    if Chk == "ok"
                    {
                        if (UserDefaults.standard.string(forKey: "user_type")!) == "D"
                        {
                            let storyboard: UIStoryboard = UIStoryboard(name: "Veterinarian", bundle: nil)
                            let VetProfileViewController = storyboard.instantiateViewController(withIdentifier: "VetProfileViewController") as! VetProfileViewController
                            self.show(VetProfileViewController, sender: self)
                        }
                        else if (UserDefaults.standard.string(forKey: "user_type")!) == "P"
                        {
                            let storyboard: UIStoryboard = UIStoryboard(name: "PetOwner", bundle: nil)
                            let PetProfileViewController = storyboard.instantiateViewController(withIdentifier: "PetProfileViewController") as! PetProfileViewController
                            self.show(PetProfileViewController, sender: self)
                        }
                    }
                }
                else if userJson["has_error"] as! Int == 1
                {
                    APIController.ShowAlert(Title: "ALert", Message: "\(userJson["errors"] as! String)", View: self)
                }
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

