//
//  VetSignUpViewController.swift
//  Video Call App
//
//  Created by IOS MAC5 on 15/01/18.
//  Copyright © 2018 IOS MAC5. All rights reserved.
//

import UIKit

class VetSignUpViewController: UIViewController,UITextFieldDelegate {
    
     // Outlet Declaration
    @IBOutlet weak var ScrollView: UIScrollView!
    @IBOutlet weak var userNameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var mobileNoTxt: UITextField!
    @IBOutlet weak var pinTxt: UITextField!
    @IBOutlet weak var confirmPinTxt: UITextField!
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var conPinButton: UIButton!
    
    // Variable Declaration
    var iconClick1 : Bool!
    var iconClick2 : Bool!
    var petSignUpDic = NSDictionary()
    var fromlink = Bool()
    var UserType : String?
    var getUserName : String?
    var getEmail : String?
    var getPhoneNo : String?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if fromlink == true
        {
            let replaced = getUserName?.replacingOccurrences(of: "%20", with: " ")
            emailTxt.text = getEmail
            mobileNoTxt.text = getPhoneNo
            userNameTxt.text = replaced
            emailTxt.isUserInteractionEnabled = false
        }
        iconClick1 = true
        iconClick2 = true
        self.PinGenerate()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        ScrollView.contentSize = CGSize(width: self.view.frame.size.width, height: 800)
        
        // Do any additional setup after loading the view.
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     // MARK: - Text Field Delegate

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if textField == pinTxt || textField == confirmPinTxt
        {
            let textstring = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let length = textstring.characters.count
            if length > 4 {
                return false
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    // End Text Field Delegate
    
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
    
    // End keyboard Will Show And Hide
    
    // MARK: - All Button Action function
    
    @IBAction func pinButtonClick(_ sender: Any) {
        
        if(iconClick1 == true)
        {
            pinButton.setImage(UIImage(named: "show_pass.png"), for: .normal)
            self.pinTxt.isSecureTextEntry = false
            iconClick1 = false
        }
        else
        {
            pinButton.setImage(UIImage(named: "hide_pass.png"), for: .normal)
            self.pinTxt.isSecureTextEntry = true
            iconClick1 = true
        }
        
    }
    @IBAction func conPinbuttonClick(_ sender: Any) {
        if(iconClick2 == true)
        {
            conPinButton.setImage(UIImage(named: "show_pass.png"), for: .normal)
            self.confirmPinTxt.isSecureTextEntry = false
            iconClick2 = false
        }
        else
        {
            conPinButton.setImage(UIImage(named: "hide_pass.png"), for: .normal)
            self.confirmPinTxt.isSecureTextEntry = true
            iconClick2 = true
        }
    }
    @IBAction func pinGenerateButtonClick(_ sender: Any)
    {
        self.PinGenerate()
    }
    @IBAction func SignInButtonClick(_ sender: Any)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VetSignInViewController = storyboard.instantiateViewController(withIdentifier: "VetSignInViewController") as! VetSignInViewController
        VetSignInViewController.UserType = UserType
        self.navigationController?.pushViewController(VetSignInViewController, animated: true)
    }
    @IBAction func signUpButtonClick(_ sender: Any)
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
        else if self.mobileNoTxt.text! == "" {
             APIController.ShowAlert(Title: "ALert", Message: "Mobile number missing", View: self)
        }
        else if self.pinTxt.text! == "" {
             APIController.ShowAlert(Title: "ALert", Message: "Pin missing", View: self)
        }
        else if self.confirmPinTxt.text! == "" {
             APIController.ShowAlert(Title: "ALert", Message: "Confirm Pin missing", View: self)
        }
        else if !(self.pinTxt.text! == self.confirmPinTxt.text!) {
             APIController.ShowAlert(Title: "ALert", Message: "Pin and Confirmpin didn't match", View: self)
        }
        else
        {
            let postString = "userName=\(self.userNameTxt.text!)&email=\(self.emailTxt.text!)&mobile=\(self.mobileNoTxt.text!)&pin=\(self.pinTxt.text!)&userType=\(UserType!)&deviceId=\(APIController.getIMEI())";
            print("postString==>\(postString)")
            
            APIManager.sharedInstance.getUsersFromUrl(Type: "POST", serviceUrl: BASE_URL+"registration", postString: postString){(userJson) -> Void in
                
                if userJson != nil {
                    print(userJson)
                    if userJson["has_error"] as! Int == 0
                    {
                        
                        let alertView = UIAlertController(title: "Alert", message: "\(userJson["process_success"] as! String)", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let VetSignInViewController = storyboard.instantiateViewController(withIdentifier: "VetSignInViewController") as! VetSignInViewController
                            VetSignInViewController.UserType = self.UserType
                            self.navigationController?.pushViewController(VetSignInViewController, animated: true)
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
    
    func PinGenerate()
    {
        let postString = ""
        APIManager.sharedInstance.getUsersFromUrl(Type: "POST", serviceUrl: BASE_URL+"generatePin", postString: postString){(userJson) -> Void in
            
            if userJson != nil {
                print(userJson)
                if userJson["has_error"] as! Int == 0
                {
                    self.pinTxt.text = userJson["pin"] as! String
                    self.confirmPinTxt.text = userJson["pin"] as! String
                }
                else if userJson["has_error"] as! Int == 1
                {
                    APIController.ShowAlert(Title: "ALert", Message: "\(userJson["errors"] as! String)", View: self)
                }
            }
        }
    }
    
    @IBAction func backButtonClick(_ sender: Any)
    {
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    // End Button Action
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
