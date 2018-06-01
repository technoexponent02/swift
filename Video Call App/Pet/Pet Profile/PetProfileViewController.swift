//
//  PetProfileViewController.swift
//  Video Call App
//
//  Created by IOS MAC5 on 15/01/18.
//  Copyright © 2018 IOS MAC5. All rights reserved.
//

import UIKit

class PetProfileViewController: UIViewController {

    // Outlet Declaration
    
    @IBOutlet weak var ScrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPhoneNo: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var logOutView: UIView!
    
    // Variable Declaration
    
    var UserData = NSDictionary()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.bool(forKey: "noti")
        {
            let outData = UserDefaults.standard.data(forKey: "notificationData")
            let dict = NSKeyedUnarchiver.unarchiveObject(with: outData!) as! NSDictionary
            
            let storyboard = UIStoryboard(name: "Veterinarian", bundle: nil)
            let VetChatViewController = storyboard.instantiateViewController(withIdentifier: "VetChatViewController") as! VetChatViewController
            let ChatId = dict["id"] as! Int
            VetChatViewController.ChatID = String(ChatId)
            VetChatViewController.PetDetails = dict["pet"] as! NSDictionary
            VetChatViewController.GetReceiverData = dict["sender"] as! NSDictionary
            VetChatViewController.GetBlockStatus = dict["blockStatus"] as! String
            
            
            self.navigationController?.pushViewController(VetChatViewController, animated: true)
        }
        
        self.imageView.layer.borderWidth = 1
        self.imageView.layer.borderColor = UIColor.init(red:255/255.0, green:255/255.0, blue:255/255.0, alpha: 1.0).cgColor
         ScrollView.contentSize = CGSize(width: self.view.frame.size.width, height: 700)
        backView.isHidden = true
        logOutView.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapBlurButton(_:)))
        backView.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool)
    {
        Api_call_for_userDetalis()
    }
    
    //MARK :- Tap Gesture Function
    
    @objc func tapBlurButton(_ sender: UITapGestureRecognizer) {
        
        backView.isHidden = true
        logOutView.isHidden = true
    }
    // MARK: - Button Action Declaration
    
    @IBAction func accountButtonClick(_ sender: Any)
    {
        let storyboard = UIStoryboard(name: "PetOwner", bundle: nil)
        let PetUpdateProfileViewController = storyboard.instantiateViewController(withIdentifier: "PetUpdateProfileViewController") as! PetUpdateProfileViewController
        PetUpdateProfileViewController.UserDetails = UserData
        self.navigationController?.pushViewController(PetUpdateProfileViewController, animated: true)
    }
    @IBAction func petListButtonClick(_ sender: Any) {
        let storyboard = UIStoryboard(name: "PetOwner", bundle: nil)
        let petListViewController = storyboard.instantiateViewController(withIdentifier: "petListViewController") as! petListViewController
        
        self.navigationController?.pushViewController(petListViewController, animated: true)
        
    }
    @IBAction func searchDoctorButtonClick(_ sender: Any)
    {
        let storyboard = UIStoryboard(name: "PetOwner", bundle: nil)
        let SeearchDoctorViewController = storyboard.instantiateViewController(withIdentifier: "SeearchDoctorViewController") as! SeearchDoctorViewController
        
        self.navigationController?.pushViewController(SeearchDoctorViewController, animated: true)
        
    }
    @IBAction func ChatPageButtonClick(_ sender: Any) {
        let storyboard = UIStoryboard(name: "PetOwner", bundle: nil)
        let PetAcceptedViewController = storyboard.instantiateViewController(withIdentifier: "PetAcceptedViewController") as! PetAcceptedViewController
        
        self.navigationController?.pushViewController(PetAcceptedViewController, animated: true)
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
    //MARK :- API call for user detalis 
    
    func Api_call_for_userDetalis()
    {
        let postString = "user_access_token=\(UserDefaults.standard.string(forKey: "user_access_token")!)";
        print("postString==>\(postString)")
        
        APIManager.sharedInstance.getUsersFromUrl(Type: "POST", serviceUrl: BASE_URL+"userdetails", postString: postString){(userJson) -> Void in
            
            if userJson != nil {
                print(userJson)
                if userJson["has_error"] as! Int == 0
                {
                   
                    self.UserData = userJson["user_details"] as! NSDictionary
                    if let profilePicture = self.UserData["profilePicture"] as? String
                    {
                        self.imageView.sd_setImage(with: URL(string:user_base_url+profilePicture), placeholderImage: UIImage(named: "my_profile.png"))
                    }
                    self.userName.text = self.UserData["userName"] as? String
                    self.userPhoneNo.text = self.UserData["mobile"] as? String
                    self.userEmail.text = self.UserData["email"] as? String
                    
                }
                else if userJson["has_error"] as! Int == 1
                {
                    APIController.ShowAlert(Title: "ALert", Message: "\(userJson["errors"] as! String)", View: self)
                }
                
            }
        }
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
