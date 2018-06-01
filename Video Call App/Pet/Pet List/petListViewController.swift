//
//  petListViewController.swift
//  Video Call App
//
//  Created by IOS MAC5 on 22/01/18.
//  Copyright © 2018 IOS MAC5. All rights reserved.
//

import UIKit

class petListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    // Outlet Declaration
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var logOutView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
 // Variable Declaration
    
    var AllDataArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backView.isHidden = true
        logOutView.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapBlurButton(_:)))
        backView.addGestureRecognizer(tapGesture)

        
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        Api_call_for_petList()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK :- Tap Gesture Function
    @objc func tapBlurButton(_ sender: UITapGestureRecognizer) {
        
        backView.isHidden = true
        logOutView.isHidden = true
    }
    
    // MARK: - Button Action Declaration
    @IBAction func addPetButtonClick(_ sender: Any)
    {
        let storyboard = UIStoryboard(name: "PetOwner", bundle: nil)
        let addPetViewController = storyboard.instantiateViewController(withIdentifier: "addPetViewController") as! addPetViewController
        
        self.navigationController?.pushViewController(addPetViewController, animated: true)
    }
    
    @IBAction func backButtonClick(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
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
    // MARK: -  Table View Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.AllDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PetListCell
        let selectValue = self.AllDataArray[indexPath.row] as! NSDictionary
        
         cell.PetImage.sd_setImage(with: URL(string:pet_Image_base_url+"\(selectValue["petPicture"] as! String)"), placeholderImage: UIImage(named: "my_profile.png"))
        cell.PetName.text = selectValue["petName"] as! String
        cell.PetDetails.text = "Type: \(selectValue["petType"] as! String), Gender: \(selectValue["petSex"] as! String), Age: \(selectValue["petAge"] as! String) Month"
        
        let temp = selectValue["petColor"] as! String
        //     print(temp)
        var color1 = hexStringToUIColor(hex: temp)
        //     print(color1)
        cell.ColorView.backgroundColor = color1
        
        cell.editButton.addTarget(self,action:#selector(petEdit(sender:)), for: .touchUpInside)
        cell.editButton.tag=indexPath.row
        
        cell.deleteButton.addTarget(self,action:#selector(petDelete(sender:)), for: .touchUpInside)
        cell.deleteButton.tag=indexPath.row
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 124.0;//Choose your custom row height
    }
    
    // MARK: - Api call For get all pet list
    @objc func petDelete(sender:UIButton)
    {
        let buttonRow = sender.tag
        var selectDic = self.AllDataArray[sender.tag] as! NSDictionary
        let PetId = selectDic["id"] as! String
        let alertController = UIAlertController(title: "Alert", message: "do you want to delete", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            let postString = "user_access_token=\(UserDefaults.standard.string(forKey: "user_access_token")!)&petId=\(PetId)"
            print("postString==>\(postString)")
            
            APIManager.sharedInstance.getUsersFromUrl(Type: "POST", serviceUrl: BASE_URL+"petdelete", postString: postString){(userJson) -> Void in
                
                if userJson != nil {
                    print(userJson)
                    if userJson["has_error"] as! Int == 0
                    {
                        self.Api_call_for_petList()
                    }
                    else if userJson["has_error"] as! Int == 1
                    {
                        APIController.ShowAlert(Title: "ALert", Message: "\(userJson["errors"] as! String)", View: self)
                    }
                    
                }
            }
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            
        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    @objc func petEdit(sender:UIButton)
    {
        let buttonRow = sender.tag
        var selectDic = self.AllDataArray[sender.tag] as! NSDictionary
        let storyboard = UIStoryboard(name: "PetOwner", bundle: nil)
        let addPetViewController = storyboard.instantiateViewController(withIdentifier: "addPetViewController") as! addPetViewController
        addPetViewController.GetData = selectDic
        addPetViewController.check = "Edit"
        self.navigationController?.pushViewController(addPetViewController, animated: true)
    }
    
    func Api_call_for_petList()
    {
        let postString = "user_access_token=\(UserDefaults.standard.string(forKey: "user_access_token")!)&index=\("0")&count=\("10")"
        print("postString==>\(postString)")
        
        APIManager.sharedInstance.getUsersFromUrl(Type: "POST", serviceUrl: BASE_URL+"petlist", postString: postString){(userJson) -> Void in
            
            if userJson != nil {
                print(userJson)
                if userJson["has_error"] as! Int == 0
                {
                    self.AllDataArray = userJson["pet_details"] as! NSArray
                    self.tableView.reloadData()
                    self.tableView.contentSize.height = CGFloat(124*3)
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
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
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
