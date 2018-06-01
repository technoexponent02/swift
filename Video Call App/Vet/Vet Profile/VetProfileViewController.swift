//
//  VetProfileViewController.swift
//  Video Call App
//
//  Created by IOS MAC5 on 15/01/18.
//  Copyright © 2018 IOS MAC5. All rights reserved.
//

import UIKit
import SDWebImage

class VetProfileViewController: UIViewController {

     // Outlet Declaration
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ScrollView: UIScrollView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPhoneNo: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var specializationLbl: UILabel!
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
        backView.isHidden = true
        logOutView.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapBlurButton(_:)))
        backView.addGestureRecognizer(tapGesture)
        self.imageView.layer.borderWidth = 1
        self.imageView.layer.borderColor = UIColor.init(red:255/255.0, green:255/255.0, blue:255/255.0, alpha: 1.0).cgColor
        
        ScrollView.contentSize = CGSize(width: self.view.frame.size.width, height: 600)
        
        // Do any additional setup after loading the view.
    }
    //MARK :- Tap Gesture Function
    func SendUserIdForEmit()
    {
        //   let socketData = ["userId":"15"]
        let outData = UserDefaults.standard.data(forKey: "user_details")
        let dict = NSKeyedUnarchiver.unarchiveObject(with: outData!) as! NSDictionary
        print(dict)
        
        let MyId = dict["id"] as! String
        let str = "{\"userId\":\"\(MyId)\"}"
        
        print("Emit Call for add user ==========> \(str)")
        socket.emit("add user",str)
    }
    @objc func tapBlurButton(_ sender: UITapGestureRecognizer) {
       
        backView.isHidden = true
        logOutView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        Api_call_for_userDetalis()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button Action Declaration
    
    @IBAction func accountButtonClick(_ sender: Any)
    {
        let storyboard = UIStoryboard(name: "Veterinarian", bundle: nil)
        let VetUpdateProfileViewController = storyboard.instantiateViewController(withIdentifier: "VetUpdateProfileViewController") as! VetUpdateProfileViewController
        VetUpdateProfileViewController.UserDetails = UserData
        self.navigationController?.pushViewController(VetUpdateProfileViewController, animated: true)
    }
    @IBAction func addPetsButtonClick(_ sender: Any)
    {
        let storyboard = UIStoryboard(name: "Veterinarian", bundle: nil)
        let addClientViewController = storyboard.instantiateViewController(withIdentifier: "addClientViewController") as! addClientViewController
        
        self.navigationController?.pushViewController(addClientViewController, animated: true)
    }
    
    @IBAction func chatPageButtonClick(_ sender: Any)
    {
        let storyboard = UIStoryboard(name: "Veterinarian", bundle: nil)
        let VetAcceptedViewController = storyboard.instantiateViewController(withIdentifier: "VetAcceptedViewController") as! VetAcceptedViewController
        
        self.navigationController?.pushViewController(VetAcceptedViewController, animated: true)
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
   
    
    //End Button Action Declaration
    
    //MARK:- Api call for get user data
    
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
                    self.specializationLbl.text = self.UserData["specialization"] as? String

                }
                else if userJson["has_error"] as! Int == 1
                {
                    APIController.ShowAlert(Title: "ALert", Message: "\(userJson["errors"] as! String)", View: self)
                }
                
            }
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
