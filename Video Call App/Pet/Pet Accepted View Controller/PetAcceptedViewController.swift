//
//  PetAcceptedViewController.swift
//  Video Call App
//
//  Created by IOS MAC5 on 06/02/18.
//  Copyright © 2018 IOS MAC5. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire

class PetAcceptedViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var menuScrollview: UIScrollView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var blockedButtonOutlet: UIButton!
    @IBOutlet weak var pendingButtonOutlet: UIButton!
    @IBOutlet weak var invitationsButtonOutlet: UIButton!
    @IBOutlet weak var acceptedButtonOutlet: UIButton!
    @IBOutlet weak var textVWSearch: UITextField!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var containTavleView: UIView!
    @IBOutlet weak var petTableView: UITableView!
    
    var tableView1 = UITableView()
    var tableView2 = UITableView()
    var tableView3 = UITableView()
    var tableView4 = UITableView()
    var AcceptList = NSArray()
    var InvitationsList = NSArray()
    var PndingList = NSArray()
    var BlockList = NSArray()
    var status = String()
    var requestStatus = String()
    var petList = NSArray()
    var SelectPetOwnerId = String()
    var SelectPetDetails = NSDictionary()
    var SelectPetOwnerDetails = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapBlurButton(_:)))
        backView.addGestureRecognizer(tapGesture)
        containTavleView.isHidden = true
        backView.isHidden = true
        
        status = "Y"
        ApiCall()
        //1
        self.scrollView.frame = CGRect(x:0, y:self.scrollView.frame.origin.y, width:self.view.frame.width, height:self.scrollView.frame.height)
        let scrollViewWidth:CGFloat = self.scrollView.frame.width
        let scrollViewHeight:CGFloat = self.scrollView.frame.height
        
        tableView1 = UITableView(frame: CGRect(x:0, y:0,width:scrollViewWidth, height:scrollViewHeight))
        tableView1.backgroundColor = UIColor.clear
        self.tableView1.separatorStyle = UITableViewCellSeparatorStyle.none
        
        tableView2 = UITableView(frame: CGRect(x:scrollViewWidth, y:0,width:scrollViewWidth, height:scrollViewHeight))
        tableView2.backgroundColor = UIColor.clear
        self.tableView2.separatorStyle = UITableViewCellSeparatorStyle.none
        
        tableView3 = UITableView(frame: CGRect(x:scrollViewWidth*2, y:0,width:scrollViewWidth, height:scrollViewHeight))
        tableView3.backgroundColor = UIColor.clear
        self.tableView3.separatorStyle = UITableViewCellSeparatorStyle.none
        
        tableView4 = UITableView(frame: CGRect(x:scrollViewWidth*3, y:0,width:scrollViewWidth, height:scrollViewHeight))
        tableView4.backgroundColor = UIColor.clear
        self.tableView4.separatorStyle = UITableViewCellSeparatorStyle.none
        
        self.scrollView.addSubview(tableView1)
        self.scrollView.addSubview(tableView2)
        self.scrollView.addSubview(tableView3)
        self.scrollView.addSubview(tableView4)
        
        tableView1.dataSource = self
        tableView1.delegate = self
        
        tableView2.dataSource = self
        tableView2.delegate = self
        
        tableView3.dataSource = self
        tableView3.delegate = self
        
        tableView4.dataSource = self
        tableView4.delegate = self
        
        //4
        self.scrollView.contentSize = CGSize(width:self.scrollView.frame.width * 4, height:self.scrollView.frame.height)
        self.menuScrollview.contentSize = CGSize(width:411, height:self.menuScrollview.frame.height)
        
        self.scrollView.delegate = self
        
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            self.UserAdd()
            self.SendUserIdForEmit()
        }
        
        socket.connect()
        
        // Do any additional setup after loading the view.
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    @objc func tapBlurButton(_ sender: UITapGestureRecognizer) {
        containTavleView.isHidden = true
        backView.isHidden = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
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
    
    func UserAdd()
    {
        socket.on("user joined") { ( dataArray, ack) -> Void in
            print("user joined ===>\(dataArray)")
            let dict = dataArray[0] as! NSDictionary
            
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == petTableView
        {
            return petList.count
        }
        else if tableView == tableView1
        {
            return AcceptList.count
        }
        else if tableView == tableView2
        {
            return InvitationsList.count
           // return 6
        }
        else if tableView == tableView3
        {
            return PndingList.count
           // return 4
        }
        return BlockList.count
       // return 3
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == petTableView
        {
            return 100
        }
        else if tableView == tableView1
        {
            return 140
        }
        else if tableView == tableView2
        {
            return 150
        }
        else if tableView == tableView3
        {
            return 150
        }
        return 140
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == petTableView
        {
            let cell = tableView.dequeueReusableCell(withIdentifier:"Cell", for: indexPath)as! petCell
            var SelectValue = self.petList[indexPath.row] as! NSDictionary
            cell.petName.text = SelectValue["petName"] as? String
            if let profilePicture = SelectValue["petPicture"] as? String
            {
                cell.petImage.sd_setImage(with: URL(string:pet_Image_base_url+profilePicture), placeholderImage: UIImage(named: "my_profile.png"))
            }
            cell.chatButton.addTarget(self,action:#selector(chat(sender:)), for: .touchUpInside)
            cell.chatButton.tag=indexPath.row
            return cell
        }
        else if tableView == tableView1
        {
            
            let cell = Bundle.main.loadNibNamed("PetAcceptedCell", owner: self, options: nil)?.first as! PetAcceptedCell
            let SelectValue = self.AcceptList[indexPath.row] as! NSDictionary
            
            cell.userName.text = SelectValue["userName"] as? String
            if ((SelectValue["profilePicture"] as? String) != nil)
            {
                cell.userImage.layer.borderWidth=1.0
                cell.userImage.layer.borderColor = UIColor.black.cgColor
                
                
                cell.userImage.sd_setImage(with: URL(string: user_base_url+"\(SelectValue["profilePicture"] as! String)"), placeholderImage: UIImage(named: "user-background.png"))
            }
            cell.userAddress.text = SelectValue["address"] as? String
            cell.specialization.text = SelectValue["specialization"] as? String
            cell.chatPage.addTarget(self,action:#selector(chatPageButtonClick(sender:)), for: .touchUpInside)
            cell.chatPage.tag=indexPath.row
            
            return cell
            
        }
        else if tableView == tableView2
        {
            let cell = Bundle.main.loadNibNamed("PetInvitationsCell", owner: self, options: nil)?.first as! PetInvitationsCell
            let SelectValue = self.InvitationsList[indexPath.row] as! NSDictionary
            
            cell.userName.text = SelectValue["userName"] as? String
            if ((SelectValue["profilePicture"] as? String) != nil)
            {
                cell.userImage.layer.borderWidth=1.0
                cell.userImage.layer.borderColor = UIColor.black.cgColor
                
                
                cell.userImage.sd_setImage(with: URL(string: user_base_url+"\(SelectValue["profilePicture"] as! String)"), placeholderImage: UIImage(named: "user-background.png"))
            }
            cell.userDetails.text = SelectValue["specialization"] as? String
            
            cell.acceptButtonClick.addTarget(self,action:#selector(acceptButtonClick(sender:)), for: .touchUpInside)
            cell.acceptButtonClick.tag=indexPath.row
            
            cell.rejectButton.addTarget(self,action:#selector(rejectButtonClick(sender:)), for: .touchUpInside)
            cell.rejectButton.tag=indexPath.row
            
            return cell
        }
        else if tableView == tableView3
        {
            let cell = Bundle.main.loadNibNamed("PetPendingCell", owner: self, options: nil)?.first as! PetPendingCell
            
            let SelectValue = self.PndingList[indexPath.row] as! NSDictionary
            
            cell.userName.text = SelectValue["userName"] as? String
            if ((SelectValue["profilePicture"] as? String) != nil)
            {
                cell.userImage.layer.borderWidth=1.0
                cell.userImage.layer.borderColor = UIColor.black.cgColor
                
                
                cell.userImage.sd_setImage(with: URL(string: user_base_url+"\(SelectValue["profilePicture"] as! String)"), placeholderImage: UIImage(named: "user-background.png"))
            }
            cell.specialization.text = SelectValue["specialization"] as? String
            
            cell.delete.addTarget(self,action:#selector(deleteRequest(sender:)), for: .touchUpInside)
            cell.delete.tag=indexPath.row
            
            return cell
        }
        let cell = Bundle.main.loadNibNamed("BlockedCell", owner: self, options: nil)?.first as! BlockedCell
        
        let SelectValue = self.BlockList[indexPath.row] as! NSDictionary
        
        cell.userName.text = SelectValue["userName"] as? String
        if ((SelectValue["profilePicture"] as? String) != nil)
        {
            cell.userImage.layer.borderWidth=1.0
            cell.userImage.layer.borderColor = UIColor.black.cgColor
            
            
            cell.userImage.sd_setImage(with: URL(string: user_base_url+"\(SelectValue["profilePicture"] as! String)"), placeholderImage: UIImage(named: "user-background.png"))
        }
        cell.userAddress.text = SelectValue["address"] as? String
        cell.specialization.text = SelectValue["specialization"] as? String
        
        cell.unblock.addTarget(self,action:#selector(UnblockButtonClick(sender:)), for: .touchUpInside)
        cell.unblock.tag=indexPath.row
        
        return cell
        
    }
    @objc func UnblockButtonClick(sender:UIButton)
    {
        let SelectData = self.BlockList[sender.tag] as! NSDictionary
        print(SelectData)
        APICallForBlockUser(reqTo: SelectData["id"] as! String)
    }
    @objc func chat(sender:UIButton)
    {
        
        SelectPetDetails = self.petList[sender.tag] as! NSDictionary
        let petId = SelectPetDetails["id"] as! String
        ApiCallForChatId(petOwnerId: SelectPetOwnerId, petId: petId)
        containTavleView.isHidden = true
        backView.isHidden = true
    }
    @objc func chatPageButtonClick(sender:UIButton)
    {
        SelectPetOwnerDetails = self.AcceptList[sender.tag] as! NSDictionary
        SelectPetOwnerId = SelectPetOwnerDetails["id"] as! String
       
        containTavleView.isHidden = false
        backView.isHidden = false
        
        
    }
    @objc func deleteRequest(sender:UIButton)
    {
        
        var selectDic = self.PndingList[sender.tag] as! NSDictionary
        let id = selectDic["id"] as! String
        requestStatus = "N"
        ApiCallForChatRequest(reqId: id)
        
    }
    @objc func acceptButtonClick(sender:UIButton)
    {
       
        var selectDic = self.InvitationsList[sender.tag] as! NSDictionary
        let id = selectDic["id"] as! String
        requestStatus = "Y"
        ApiCallForChatRequest(reqId: id)
        
    }
    @objc func rejectButtonClick(sender:UIButton)
    {
        
        var selectDic = self.InvitationsList[sender.tag] as! NSDictionary
        let id = selectDic["id"] as! String
        requestStatus = "R"
        ApiCallForChatRequest(reqId: id)
    }
    
    //MARK :- All Button Action
    
    @IBAction func btnBackAction(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func tableOneButtonClick(_ sender: Any)
    {
        self.scrollView.scrollRectToVisible(CGRect(x:0, y:0, width:self.view.frame.size.width, height:self.scrollView.frame.height), animated: true)
        
        acceptedButtonOutlet.setBackgroundImage(UIImage(named: "selectBtn.png"), for: UIControlState.normal)
        invitationsButtonOutlet.setBackgroundImage(UIImage(named: ""), for: UIControlState.normal)
        pendingButtonOutlet.setBackgroundImage(UIImage(named: ""), for: UIControlState.normal)
        blockedButtonOutlet.setBackgroundImage(UIImage(named: ""), for: UIControlState.normal)
        status = "Y"
        ApiCall()
        
    }
    @IBAction func tableTwoButtonClick(_ sender: Any)
    {
        self.scrollView.scrollRectToVisible(CGRect(x:self.view.frame.size.width, y:0, width:self.view.frame.size.width, height:self.scrollView.frame.height), animated: true)
        
        acceptedButtonOutlet.setBackgroundImage(UIImage(named: ""), for: UIControlState.normal)
        invitationsButtonOutlet.setBackgroundImage(UIImage(named: "selectBtn.png"), for: UIControlState.normal)
        pendingButtonOutlet.setBackgroundImage(UIImage(named: ""), for: UIControlState.normal)
        blockedButtonOutlet.setBackgroundImage(UIImage(named: ""), for: UIControlState.normal)
        
        status = "I"
        ApiCall()
        
    }
    @IBAction func tableThreeButtonClick(_ sender: Any)
    {
        self.scrollView.scrollRectToVisible(CGRect(x:self.view.frame.size.width*2, y:0, width:self.view.frame.size.width, height:self.scrollView.frame.height), animated: true)
        
        acceptedButtonOutlet.setBackgroundImage(UIImage(named: ""), for: UIControlState.normal)
        invitationsButtonOutlet.setBackgroundImage(UIImage(named: ""), for: UIControlState.normal)
        pendingButtonOutlet.setBackgroundImage(UIImage(named: "selectBtn.png"), for: UIControlState.normal)
        blockedButtonOutlet.setBackgroundImage(UIImage(named: ""), for: UIControlState.normal)
        
        status = "P"
        ApiCall()
        
    }
    @IBAction func tableBlockButtonClick(_ sender: Any)
    {
        self.scrollView.scrollRectToVisible(CGRect(x:self.view.frame.size.width*3, y:0, width:self.view.frame.size.width, height:self.scrollView.frame.height), animated: true)
        
        acceptedButtonOutlet.setBackgroundImage(UIImage(named: ""), for: UIControlState.normal)
        invitationsButtonOutlet.setBackgroundImage(UIImage(named: ""), for: UIControlState.normal)
        pendingButtonOutlet.setBackgroundImage(UIImage(named: ""), for: UIControlState.normal)
        blockedButtonOutlet.setBackgroundImage(UIImage(named: "selectBtn.png"), for: UIControlState.normal)
        
        status = "B"
        ApiCall()
        
    }
    @IBAction func searchButtonClick(_ sender: Any) {
        self.ApiCall()
    }
    func APICallForBlockUser(reqTo: String)
    {
        SVProgressHUD.show()
        let myUrl = URL(string:BASE_URL+"chatrequest");
        var request = URLRequest(url:myUrl!)
        request.httpMethod = "POST"
        let postString = "user_access_token=\(UserDefaults.standard.string(forKey: "user_access_token")!)&reqTo=\(reqTo)&status=\("")&blocked=\("U")&endTime=\("")"
        print("postString==>\(postString)")
        request.httpBody = postString.data(using: String.Encoding.utf8);
        Alamofire.request(request)
            
            .responseJSON { response in
                
                guard let json = response.result.value as? [String: Any] else {
                    
                    print("didn't get todo object as JSON from API")
                    
                    // print("Error: \(response.result.error as! NSString)")
                    
                    SVProgressHUD.dismiss()
                    
                    return
                    
                }
                
                //   print(json)
                SVProgressHUD.dismiss()
                print("JSON: \(json)")
                if (json["has_error"] as? Int) == 1
                {
                    let alert = UIAlertController(title: "Alert", message: json["errors"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                }
                else if (json["has_error"] as? Int) == 0
                {
                    
                    let uiAlertController = UIAlertController(// create new instance alert  controller
                        title: "Alert",
                        message: "\(json["request_success"] as! String)",
                        preferredStyle:.alert)
                    
                    uiAlertController.addAction(// add Custom action on Event is Cancel
                        UIAlertAction.init(title: "Ok", style: .default, handler: { (UIAlertAction) in
                            //TO DO code
                            self.ApiCall()
                            uiAlertController.dismiss(animated: true, completion: nil)//dismiss show You alert, on click is Cancel
                        }))
                    //show You alert
                    self.present(uiAlertController, animated: true, completion: nil)
                }
                
        }
        
    }
    func ApiCall()
    {
        let postString = "user_access_token=\(UserDefaults.standard.string(forKey: "user_access_token")!)&status=\(status)&keyword=\(self.textVWSearch.text!)"
        print("postString==>\(postString)")
        
        APIManager.sharedInstance.getUsersFromUrl(Type: "POST", serviceUrl: BASE_URL+"chatlist", postString: postString){(userJson) -> Void in
            
            if userJson != nil {
                print(userJson)
                if userJson["has_error"] as! Int == 0
                {
                    if self.status == "Y"
                    {
                        self.AcceptList = userJson["userList"] as! NSArray
                        self.tableView1.reloadData()
                        self.petList = userJson["petList"] as! NSArray
                        self.petTableView.reloadData()
                    }
                    else if self.status == "I"
                    {
                        self.InvitationsList = userJson["userList"] as! NSArray
                        self.tableView2.reloadData()
                    }
                    else if self.status == "P"
                    {
                        self.PndingList = userJson["userList"] as! NSArray
                        self.tableView3.reloadData()
                    }
                    else if self.status == "B"
                    {
                        self.BlockList = userJson["userList"] as! NSArray
                        self.tableView4.reloadData()
                    }
                }
                else if userJson["has_error"] as! Int == 1
                {
                    APIController.ShowAlert(Title: "ALert", Message: "\(userJson["errors"] as! String)", View: self)
                }
                
            }
        }
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
                    
                    VetChatViewController.ChatID = userJson["chatId"] as! String
                    VetChatViewController.PetDetails = self.SelectPetDetails
                    VetChatViewController.GetReceiverData = self.SelectPetOwnerDetails
                    self.navigationController?.pushViewController(VetChatViewController, animated: true)
                }
                else if userJson["has_error"] as! Int == 1
                {
                    APIController.ShowAlert(Title: "ALert", Message: "\(userJson["errors"] as! String)", View: self)
                }
                
            }
        }
    }
    func ApiCallForChatRequest(reqId:String)
    {
        
        let outData = UserDefaults.standard.data(forKey: "user_details")
        let dict = NSKeyedUnarchiver.unarchiveObject(with: outData!) as! NSDictionary
        print(dict)
        
        let postString = "user_access_token=\(UserDefaults.standard.string(forKey: "user_access_token")!)&reqTo=\(reqId)&status=\(requestStatus)&blocked=\("")";
        
        print("postString==>\(postString)")
        
        APIManager.sharedInstance.getUsersFromUrl(Type: "POST", serviceUrl: BASE_URL+"chatrequest", postString: postString){(userJson) -> Void in
            
            if userJson != nil {
                print(userJson)
                if userJson["has_error"] as! Int == 0
                {
                    self.ApiCall()
                    if self.requestStatus == "R"
                    {
                        APIController.ShowAlert(Title: "ALert", Message: "chat request rejected", View: self)
                    }
                    else if self.requestStatus == "Y"
                    {
                        APIController.ShowAlert(Title: "ALert", Message: "chat request accepted", View: self)
                        
                    }
                    else if self.requestStatus == "N"
                    {
                        APIController.ShowAlert(Title: "ALert", Message: "delete invitations", View: self)
                    }
                    
                }
                else if userJson["has_error"] as! Int == 1
                {
                    APIController.ShowAlert(Title: "ALert", Message: "\(userJson["errors"] as! String)", View: self)
                }
                
            }
        }
    }
    func scrollViewDidEndDecelerating(_ scroll: UIScrollView)
    {
        print("====================================>  \(scrollView.contentOffset.x)")
        let width = scrollView.frame.width
        let page = Int(round(scrollView.contentOffset.x/width))
        print("CurrentPage:\(page)")
        if page == 0
        {
            acceptedButtonOutlet.setBackgroundImage(UIImage(named: "selectBtn.png"), for: UIControlState.normal)
            invitationsButtonOutlet.setBackgroundImage(UIImage(named: ""), for: UIControlState.normal)
            pendingButtonOutlet.setBackgroundImage(UIImage(named: ""), for: UIControlState.normal)
            blockedButtonOutlet.setBackgroundImage(UIImage(named: ""), for: UIControlState.normal)
            status = "Y"
            ApiCall()
        }
        else if page == 1
        {
            acceptedButtonOutlet.setBackgroundImage(UIImage(named: ""), for: UIControlState.normal)
            invitationsButtonOutlet.setBackgroundImage(UIImage(named: "selectBtn.png"), for: UIControlState.normal)
            pendingButtonOutlet.setBackgroundImage(UIImage(named: ""), for: UIControlState.normal)
            blockedButtonOutlet.setBackgroundImage(UIImage(named: ""), for: UIControlState.normal)
            
            status = "I"
            ApiCall()
        }
        else if page == 2
        {
            acceptedButtonOutlet.setBackgroundImage(UIImage(named: ""), for: UIControlState.normal)
            invitationsButtonOutlet.setBackgroundImage(UIImage(named: ""), for: UIControlState.normal)
            pendingButtonOutlet.setBackgroundImage(UIImage(named: "selectBtn.png"), for: UIControlState.normal)
            blockedButtonOutlet.setBackgroundImage(UIImage(named: ""), for: UIControlState.normal)
            
            status = "P"
            ApiCall()
        }
        else if page == 3
        {
            acceptedButtonOutlet.setBackgroundImage(UIImage(named: ""), for: UIControlState.normal)
            invitationsButtonOutlet.setBackgroundImage(UIImage(named: ""), for: UIControlState.normal)
            pendingButtonOutlet.setBackgroundImage(UIImage(named: ""), for: UIControlState.normal)
            blockedButtonOutlet.setBackgroundImage(UIImage(named: "selectBtn.png"), for: UIControlState.normal)
            
            status = "P"
            ApiCall()
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

