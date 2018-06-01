//
//  VetUpdateProfileViewController.swift
//  Video Call App
//
//  Created by IOS MAC5 on 17/01/18.
//  Copyright © 2018 IOS MAC5. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
import GoogleMaps
import GooglePlaces

class VetUpdateProfileViewController: UIViewController, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate,UITextFieldDelegate,GMSAutocompleteViewControllerDelegate {
     // Outlet Declaration
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var userNameTxt: UITextField!
    @IBOutlet weak var phoneNumberTxt: UITextField!
    @IBOutlet weak var specializationTextView: UITextView!
    @IBOutlet weak var clinicNameTxt: UITextField!
    @IBOutlet weak var addressTxt: UITextField!
    @IBOutlet weak var ScrollView: UIScrollView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var logOutView: UIView!
    
    // Variable Declaration
    
    var UserDetails:NSDictionary?
    var pickerController = UIImagePickerController()
    var ImageView = UIImage()
    var currentLocation = CLLocation()
    var Latitude = Double()
    var Longitude = Double()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        ScrollView.contentSize = CGSize(width: self.view.frame.size.width, height: 950)
        
        self.imageView.layer.borderWidth = 1
        self.imageView.layer.borderColor = UIColor.init(red:22/255.0, green:110/255.0, blue:222/255.0, alpha: 1.0).cgColor
       
        if let profilePicture = UserDetails!["profilePicture"] as? String
        {
            self.imageView.sd_setImage(with: URL(string:user_base_url+profilePicture), placeholderImage: UIImage(named: "my_profile.png"))
        }
        self.userNameTxt.text = UserDetails!["userName"] as? String
        self.phoneNumberTxt.text = UserDetails!["mobile"] as? String
        self.addressTxt.text = UserDetails!["address"] as? String
        self.clinicNameTxt.text = UserDetails!["clinicName"] as? String
        self.specializationTextView.text = UserDetails!["specialization"] as? String
        
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
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK :- Tap Gesture Function
    
    @objc func tapBlurButton(_ sender: UITapGestureRecognizer) {
        
        backView.isHidden = true
        logOutView.isHidden = true
    }
     // MARK: - Text Field Delegate
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if textField == self.addressTxt
        {
            self.CallAutoCompleteView()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder();
        return true;
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
    
    // MARK: - Text View Delegate
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    //End Text Field Delegate
    
    // MARK: - Button Action Declaration
    
    @IBAction func changePinButtonClick(_ sender: Any)
    {
        let storyboard = UIStoryboard(name: "Veterinarian", bundle: nil)
        let changePinViewController = storyboard.instantiateViewController(withIdentifier: "changePinViewController") as! changePinViewController
    
        self.navigationController?.pushViewController(changePinViewController, animated: true)
    }
    
    @IBAction func backButtonClick(_ sender: Any)
    {
        _ = navigationController?.popViewController(animated: true)
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
        let testEmail = UserDetails!["email"] as! String
        let postString = "user_access_token=\(UserDefaults.standard.string(forKey: "user_access_token")!)&userName=\(self.userNameTxt.text!)&email=\(testEmail)&mobile=\(self.phoneNumberTxt.text!)&clinicName=\(self.clinicNameTxt.text!)&address=\(self.addressTxt.text!)&specialization=\(self.specializationTextView.text!)&lat=\(Latitude)&lng=\(Longitude)";
        print("postString==>\(postString)")
        
        APIManager.sharedInstance.getUsersFromUrl(Type: "POST", serviceUrl: BASE_URL+"updatedoctorprofile", postString: postString){(userJson) -> Void in
            
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
    
    // MARK :- Google Auto Complete Delegate
    
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

}
