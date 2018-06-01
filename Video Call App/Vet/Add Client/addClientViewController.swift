//
//  addClientViewController.swift
//  Video Call App
//
//  Created by IOS MAC5 on 22/01/18.
//  Copyright © 2018 IOS MAC5. All rights reserved.
//

import UIKit

class addClientViewController: UIViewController,UITextFieldDelegate {
    
    // Outlet Declaration
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var userNameTxt: UITextField!
    @IBOutlet weak var phoneNumberTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var ScrollView: UIScrollView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var logOutView: UIView!
    
     // Variable Declaration
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backView.isHidden = true
        logOutView.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapBlurButton(_:)))
        backView.addGestureRecognizer(tapGesture)
        ScrollView.contentSize = CGSize(width: self.view.frame.size.width, height: 700)
        
       // keyboard Will Show And Hide
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Do any additional setup after loading the view.
    }
    //MARK :- Tap Gesture Function
    
    @objc func tapBlurButton(_ sender: UITapGestureRecognizer) {
        
        backView.isHidden = true
        logOutView.isHidden = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
     // MARK: - Button Action Declaration
    
    @IBAction func backButtonClick(_ sender: Any)
    {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func SendButtonClick(_ sender: Any)
    {
        if self.userNameTxt.text! == "" {
            APIController.ShowAlert(Title: "ALert", Message: "User Name missing", View: self)
        }
        else if self.emailTxt.text! == "" {
            APIController.ShowAlert(Title: "ALert", Message: "Email missing", View: self)
        }
        else if APIController.isValidEmail(emailStr: self.emailTxt.text!) == false
        {
            APIController.ShowAlert(Title: "ALert", Message: "Email address is not valid format", View: self)
        }
        else if self.phoneNumberTxt.text! == "" {
            APIController.ShowAlert(Title: "ALert", Message: "Mobile number missing", View: self)
        }
        else
        {
            let postString = "user_access_token=\(UserDefaults.standard.string(forKey: "user_access_token")!)&cuserName=\(self.userNameTxt.text!)&cemail=\(self.emailTxt.text!)&cmobile=\(self.phoneNumberTxt.text!)";
            print("postString==>\(postString)")
            
            APIManager.sharedInstance.getUsersFromUrl(Type: "POST", serviceUrl: BASE_URL+"clientinvite", postString: postString){(userJson) -> Void in
                
                if userJson != nil {
                    print(userJson)
                    if userJson["has_error"] as! Int == 0
                    {
                        
                        let alertView = UIAlertController(title: "Alert", message: "\(userJson["process_success"] as! String)", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                             self.navigationController?.popViewController(animated: true)
                        })
                        alertView.addAction(action)
                        self.present(alertView, animated: true, completion: nil)
                    }
                    else if userJson["has_error"] as! Int == 1
                    {
                        APIController.ShowAlert(Title: "ALert", Message: "\(userJson["errors"] as! String)", View: self)
                    }
                    
                }
            }
        }
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
    
    
     //End :- Button Action Declaration
    
    // MARK: - Text Field Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder();
        return true;
    }
    
    
     //End :- Text Field Delegate

    // MARK: - keyboard Will Show And Hide
    
    @objc func keyboardWillShow(notification:NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.ScrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height+40
        ScrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        ScrollView.contentInset = contentInset
    }
    
     // MARK: - Api call Declaration
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
