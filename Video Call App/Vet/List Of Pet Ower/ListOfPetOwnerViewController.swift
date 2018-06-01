//
//  ListOfPetOwnerViewController.swift
//  Video Call App
//
//  Created by IOS MAC5 on 10/02/18.
//  Copyright © 2018 IOS MAC5. All rights reserved.
//

import UIKit

class ListOfPetOwnerViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    // Outlet Declaration
    @IBOutlet weak var tableView: UITableView!
    
    // Variable Declaration
    
    var AllDataArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Api_call_for_petList()
        // Do any additional setup after loading the view.
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    // MARK: - Button Action Declaration
    @IBAction func backButtonClick(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: -  Table View Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.AllDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("AcceptedCell", owner: self, options: nil)?.first as! AcceptedCell
        let SelectAllData = self.AllDataArray[indexPath.row] as! NSDictionary
        let SelectValue = SelectAllData["ownerId"] as! NSDictionary
        
        cell.userName.text = SelectValue["userName"] as? String
        if ((SelectValue["profilePicture"] as? String) != nil)
        {
            cell.userImage.layer.borderWidth=1.0
            cell.userImage.layer.borderColor = UIColor.black.cgColor
            
            
            cell.userImage.sd_setImage(with: URL(string: pet_Image_base_url+"\(SelectValue["profilePicture"] as! String)"), placeholderImage: UIImage(named: "user-background.png"))
        }
        cell.userAddress.text = SelectValue["address"] as? String
       // cell.userPhoneNo.text = SelectValue["mobile"] as? String
       // cell.specialization.text = SelectValue["specialization"] as? String
        
        return cell
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 150.0;//Choose your custom row height
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Api call for pet List
    
    func Api_call_for_petList()
    {
        let postString = "user_access_token=\(UserDefaults.standard.string(forKey: "user_access_token")!)"
        print("postString==>\(postString)")
        
        APIManager.sharedInstance.getUsersFromUrl(Type: "POST", serviceUrl: BASE_URL+"chatsearchlist", postString: postString){(userJson) -> Void in
            
            if userJson != nil {
                print(userJson)
                if userJson["has_error"] as! Int == 0
                {
                    self.AllDataArray = userJson["chatList"] as! NSArray
                    self.tableView.reloadData()
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
