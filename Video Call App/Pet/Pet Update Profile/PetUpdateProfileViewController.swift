//
//  PetUpdateProfileViewController.swift
//  Video Call App
//
//  Created by IOS MAC5 on 18/01/18.
//  Copyright © 2018 IOS MAC5. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
import GoogleMaps
import GooglePlaces

class PetUpdateProfileViewController: UIViewController, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextFieldDelegate,GMSAutocompleteViewControllerDelegate {

    // Outlet Declaration
    
    @IBOutlet weak var addressTxt: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var userNameTxt: UITextField!
    @IBOutlet weak var phoneNumberTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var ScrollView: UIScrollView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var logOutView: UIView!
    
    // Variable Declaration
    
    var UserDetails:NSDictionary?
    var pickerController = UIImagePickerController()
    var ImageView = UIImage()
    var Latitude = Double()
    var Longitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        if let profilePicture = UserDetails!["profilePicture"] as? String
        {
            self.imageView.sd_setImage(with: URL(string:user_base_url+profilePicture), placeholderImage: UIImage(named: "my_profile.png"))
        }
        self.userNameTxt.text = UserDetails!["userName"] as? String
        self.phoneNumberTxt.text = UserDetails!["mobile"] as? String
        self.emailTxt.text = UserDetails!["email"] as? String
        self.addressTxt.text = UserDetails!["address"] as? String
        
        ScrollView.contentSize = CGSize(width: self.view.frame.size.width, height: 770)
        
        self.imageView.layer.borderWidth = 1
        self.imageView.layer.borderColor = UIColor.init(red:22/255.0, green:110/255.0, blue:222/255.0, alpha: 1.0).cgColor
        
        // Image picker ===============
        
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapUserPhoto(_:)))
        imageTapGesture.delegate = self
        imageView.addGestureRecognizer(imageTapGesture)
        imageTapGesture.numberOfTapsRequired = 1
        imageView.isUserInteractionEnabled = true
        pickerController.delegate = self
        
        backView.isHidden = true
        logOutView.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapBlurButton(_:)))
        backView.addGestureRecognizer(tapGesture)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK :- Tap Gesture Function
    @objc func tapBlurButton(_ sender: UITapGestureRecognizer) {
        
        backView.isHidden = true
        logOutView.isHidden = true
    }
    // MARK: - Text Field Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder();
        return true;
    }
    // MARK: - Text Field Delegate
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if textField == self.addressTxt
        {
            self.CallAutoCompleteView()
        }
    }
    
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
    
     // MARK: - Button Action Declaration
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
    @IBAction func backButtonClick(_ sender: Any)
    {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changePinButtonClick(_ sender: Any)
    {
        let storyboard = UIStoryboard(name: "PetOwner", bundle: nil)
        let petChangePinViewController = storyboard.instantiateViewController(withIdentifier: "petChangePinViewController") as! petChangePinViewController
        
        self.navigationController?.pushViewController(petChangePinViewController, animated: true)
    }
    
    @IBAction func updateProfilePiButtonClick(_ sender: Any)
    {
        let alertViewController = UIAlertController(title: "", message: "Choose your option", preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default, handler: { (alert) in
            self.openCamera()
        })
        let gallery = UIAlertAction(title: "Gallery", style: .default) { (alert) in
            self.openGallary()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        alertViewController.addAction(camera)
        alertViewController.addAction(gallery)
        alertViewController.addAction(cancel)
        self.present(alertViewController, animated: true, completion: nil)
    }
    @IBAction func UpdateButtonClick(_ sender: Any)
    {
        let postString = "user_access_token=\(UserDefaults.standard.string(forKey: "user_access_token")!)&userName=\(self.userNameTxt.text!)&mobile=\(self.phoneNumberTxt.text!)&address=\(self.addressTxt.text!)&lat=\(Latitude)&lng=\(Longitude)";
        print("postString==>\(postString)")
        
        APIManager.sharedInstance.getUsersFromUrl(Type: "POST", serviceUrl: BASE_URL+"updateprofile", postString: postString){(userJson) -> Void in
            
            if userJson != nil {
                print(userJson)
                if userJson["has_error"] as! Int == 0
                {
                    APIController.ShowAlert(Title: "ALert", Message: "\(userJson["process_success"] as! String)", View: self)
                }
                else if userJson["has_error"] as! Int == 1
                {
                    APIController.ShowAlert(Title: "ALert", Message: "\(userJson["errors"] as! String)", View: self)
                }
                
            }
        }
    }
    
    //End Button Action Declaration
    
    // MARK: - image Picker Func
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            pickerController.delegate = self
            self.pickerController.sourceType = UIImagePickerControllerSourceType.camera
            pickerController.allowsEditing = true
            self .present(self.pickerController, animated: true, completion: nil)
        }
        else {
            let alertWarning = UIAlertView(title:"Warning", message: "You don't have camera", delegate:nil, cancelButtonTitle:"OK", otherButtonTitles:"")
            alertWarning.show()
        }
    }
    func openGallary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            pickerController.delegate = self
            pickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
            pickerController.allowsEditing = true
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        ImageView = info[UIImagePickerControllerEditedImage] as! UIImage
        imageView.contentMode = .scaleAspectFill
        imageView.image = ImageView
        
        let Params: Parameters = ["user_access_token": "\(UserDefaults.standard.string(forKey: "user_access_token")!)"]
        
        APIManager.sharedInstance.getUsersProfilePhotoFromUrl(Type: "POST", serviceUrl: BASE_URL+"updateprofilepic", params: Params as NSDictionary, ImageView: ImageView) {(userJson) -> Void in
            
            print(userJson)
            
        }
        dismiss(animated:true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancel")
    }
    
    @objc func tapUserPhoto(_ sender: UITapGestureRecognizer){
        let alertViewController = UIAlertController(title: "", message: "Choose your option", preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default, handler: { (alert) in
            self.openCamera()
        })
        let gallery = UIAlertAction(title: "Gallery", style: .default) { (alert) in
            self.openGallary()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        alertViewController.addAction(camera)
        alertViewController.addAction(gallery)
        alertViewController.addAction(cancel)
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    //MARK: - Google Place Auto Complete
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \((place.formattedAddress)!)")
        //print("Place attributions: \((place.attributions)!)")
        self.addressTxt.text = place.formattedAddress!
        dismiss(animated: true, completion: nil)
        //        let lat = (place.coordinate.latitude)
        //        let lon = (place.coordinate.longitude)
        //        print(lat)
        //        print(lon)
        Latitude = place.coordinate.latitude
        Longitude = place.coordinate.longitude
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
        dismiss(animated: true, completion: nil)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
        self.addressTxt.resignFirstResponder()
    }
    
    
    func CallAutoCompleteView()
    {
        let autoCompletController = GMSAutocompleteViewController()
        autoCompletController.delegate = self
        
        self.present(autoCompletController, animated: true, completion: nil)
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
