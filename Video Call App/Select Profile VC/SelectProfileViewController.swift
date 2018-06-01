//
//  SelectProfileViewController.swift
//  Video Call App
//
//  Created by IOS MAC5 on 15/01/18.
//  Copyright © 2018 IOS MAC5. All rights reserved.
//

import UIKit
import DropDown

class SelectProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
       // fetchUsers()
        // Do any additional setup after loading the view.
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func VeterinarianButtonClick(_ sender: Any)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VetSignUpViewController = storyboard.instantiateViewController(withIdentifier: "VetSignUpViewController") as! VetSignUpViewController
        VetSignUpViewController.UserType = "D"
        VetSignUpViewController.fromlink = false
        self.navigationController?.pushViewController(VetSignUpViewController, animated: true)
    }
    
    @IBAction func PetOwnerButtonClick(_ sender: Any)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VetSignUpViewController = storyboard.instantiateViewController(withIdentifier: "VetSignUpViewController") as! VetSignUpViewController
         VetSignUpViewController.UserType = "P"
        VetSignUpViewController.fromlink = false
        self.navigationController?.pushViewController(VetSignUpViewController, animated: true)
    }
    @IBAction func testButton(_ sender: Any)
    {
        let dropDown = DropDown()
        
        // The view to which the drop down will appear on
        dropDown.anchorView = self.view // UIView or UIBarButtonItem
        
        // The list of items to display. Can be changed dynamically
        dropDown.dataSource = ["Car", "Motorcycle", "Truck"]
        dropDown.show()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
     */
    func fetchUsers()
    {
        let postString = "emailAddress=\("")&userPassword=\("")&userType=\("D")&deviceId=\("1234")&deviceType=\("I")&fcmToken=\("123456")";
        print("postString==>\(postString)")
        
        APIManager.sharedInstance.getUsersFromUrl(Type: "POST", serviceUrl: BASE_URL+"loginProcess", postString: postString){(userJson) -> Void in
            
            if userJson != nil {
                print(userJson)
                APIController.ShowAlert(Title: "ALert", Message: "Api responce", View: self)
            }
        }
    }
    
    
    
}
