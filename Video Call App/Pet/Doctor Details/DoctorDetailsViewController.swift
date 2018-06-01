//
//  DoctorDetailsViewController.swift
//  Video Call App
//
//  Created by IOS MAC5 on 06/02/18.
//  Copyright © 2018 IOS MAC5. All rights reserved.
//

import UIKit

class DoctorDetailsViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var doctorDescription: UITextView!
    @IBOutlet weak var doctorAddress: UILabel!
    @IBOutlet weak var doctorExperience: UILabel!
    @IBOutlet weak var doctorSpecialization: UILabel!
    @IBOutlet weak var doctorName: UILabel!
    @IBOutlet weak var doctorImage: UIImageView!
    @IBOutlet weak var ScrollView: UIScrollView!
    @IBOutlet weak var petTableView: UITableView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var containTavleView: UIView!
    
    var GetDoctorDetails: NSDictionary?
    var petList: NSArray?
    var reqTo = String()
    var SelectPetOwnerId = String()
    var SelectPetDetails = NSDictionary()
    var SelectPetOwnerDetails = NSDictionary()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(GetDoctorDetails)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapBlurButton(_:)))
        backView.addGestureRecognizer(tapGesture)
        containTavleView.isHidden = true
        backView.isHidden = true
        
        ScrollView.contentSize = CGSize(width: self.view.frame.size.width, height: 650)

        if let profilePicture = GetDoctorDetails!["profilePicture"] as? String
        {
            print("\(profilePicture)")
            doctorImage.sd_setImage(with: URL(string:Profile_Image_base_url+profilePicture), placeholderImage: UIImage(named: "my_profile.png"))
        }
        doctorName.text = GetDoctorDetails!["userName"] as? String
        doctorSpecialization.text = GetDoctorDetails!["specialization"] as? String
        doctorSpecialization.text = GetDoctorDetails!["specialization"] as? String
        if let str = GetDoctorDetails!["experience"] as? String
        {
            doctorExperience.text = "\(GetDoctorDetails!["experience"] as! String) Years expreiance"
        }
        doctorAddress.text = GetDoctorDetails!["address"] as? String
        doctorDescription.text = GetDoctorDetails!["description"] as? String
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func backBtn(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func chatNowButtonClick(_ sender: Any) {
        let chatstatus = GetDoctorDetails!["chatstatus"] as! String
        if chatstatus == "Y"
        {
            
            containTavleView.isHidden = false
            backView.isHidden = false
            //SelectPetOwnerDetails = self.AllDoctorList[sender.tag] as! NSDictionary
            SelectPetOwnerId = GetDoctorDetails!["id"] as! String
            
           
        }
        else if chatstatus == "N"
        {
            containTavleView.isHidden = false
            backView.isHidden = false
           // SelectPetOwnerDetails = self.AllDoctorList[sender.tag] as! NSDictionary
           SelectPetOwnerId = GetDoctorDetails!["id"] as! String
            
            
        }
        else if chatstatus == "D"
        {
            let alertController = UIAlertController(title: "Alert", message: "do you want to send chat request", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                
                print("Ok button tapped");
                self.ApiCallForChatRequest()
            }
            alertController.addAction(OKAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
                print("Cancel button tapped");
            }
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion:nil)
        }
        else if chatstatus == "P"
        {
            APIController.ShowAlert(Title: "Alert", Message: "chat request is pending", View: self)
        }
        else if chatstatus == "PP"
        {
            containTavleView.isHidden = false
            backView.isHidden = false
          //  SelectPetOwnerDetails = self.AllDoctorList[sender.tag] as! NSDictionary
            SelectPetOwnerId = GetDoctorDetails!["id"] as! String
            
        }
        else if chatstatus == "B"
        {
            APIController.ShowAlert(Title: "Alert", Message: "Doctor Block", View: self)
        }
    }
    
    //MARK :- Table view Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return petList!.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        
        return 100
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier:"Cell", for: indexPath)as! petCell
        var SelectValue = self.petList![indexPath.row] as! NSDictionary
        cell.petName.text = SelectValue["petName"] as? String
        if let profilePicture = SelectValue["petPicture"] as? String
        {
            cell.petImage.sd_setImage(with: URL(string:pet_Image_base_url+profilePicture), placeholderImage: UIImage(named: "my_profile.png"))
        }
        cell.chatButton.addTarget(self,action:#selector(chat(sender:)), for: .touchUpInside)
        cell.chatButton.tag=indexPath.row
        return cell
    }
    @objc func chat(sender:UIButton)
    {
        SelectPetDetails = self.petList![sender.tag] as! NSDictionary
        let petId = SelectPetDetails["id"] as! String
        ApiCallForChatId(petOwnerId: SelectPetOwnerId, petId: petId)
        containTavleView.isHidden = true
        backView.isHidden = true
    }
    @objc func tapBlurButton(_ sender: UITapGestureRecognizer) {
        containTavleView.isHidden = true
        backView.isHidden = true
    }
    func ApiCallForChatId(petOwnerId: String, petId:String)
    {
        let postString = "user_access_token=\(UserDefaults.standard.string(forKey: "user_access_token")!)&req_To=\(petOwnerId)&petId=\(petId)"
        print("postString==>\(postString)")
        
        APIManager.sharedInstance.getUsersFromUrl(Type: "POST", serviceUrl: BASE_URL+"getChatId", postString: postString){(userJson) -> Void in
            
            if userJson != nil {
                print(userJson)
                if userJson["has_error"] as! Int == 0
                {
                    let storyboard = UIStoryboard(name: "Veterinarian", bundle: nil)
                    let VetChatViewController = storyboard.instantiateViewController(withIdentifier: "VetChatViewController") as! VetChatViewController
                    print(userJson)
                    print(self.SelectPetDetails)
                    print(self.SelectPetOwnerDetails)
                    
                    VetChatViewController.ChatID = userJson["chatId"] as! String
                    VetChatViewController.PetDetails = self.SelectPetDetails
                    VetChatViewController.GetReceiverData = self.GetDoctorDetails
                    VetChatViewController.GetBlockStatus = userJson["blockStatus"] as! String
                    
                    self.navigationController?.pushViewController(VetChatViewController, animated: true)
                }
                else if userJson["has_error"] as! Int == 1
                {
                    APIController.ShowAlert(Title: "ALert", Message: "\(userJson["errors"] as! String)", View: self)
                }
                
            }
        }
    }
    func ApiCallForChatRequest()
    {
        let outData = UserDefaults.standard.data(forKey: "user_details")
        let dict = NSKeyedUnarchiver.unarchiveObject(with: outData!) as! NSDictionary
        print(dict)
        
        let postString = "user_access_token=\(UserDefaults.standard.string(forKey: "user_access_token")!)&reqTo=\(GetDoctorDetails!["id"] as! String)&status=\("P")&blocked=\("")";
        
        print("postString==>\(postString)")
        
        APIManager.sharedInstance.getUsersFromUrl(Type: "POST", serviceUrl: BASE_URL+"chatrequest", postString: postString){(userJson) -> Void in
            
            if userJson != nil {
                print(userJson)
                if userJson["has_error"] as! Int == 0
                {
                    
                    let alertView = UIAlertController(title: "Alert", message: "Requested Successfully", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                        self.navigationController?.popViewController(animated: true)
                    })
                    alertView.addAction(action)
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
