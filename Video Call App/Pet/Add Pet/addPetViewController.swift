//
//  addPetViewController.swift
//  Video Call App
//
//  Created by IOS MAC5 on 23/01/18.
//  Copyright © 2018 IOS MAC5. All rights reserved.
//

import UIKit
import McPicker
import RappleColorPicker
import Alamofire
import SVProgressHUD

class addPetViewController: UIViewController,UITextFieldDelegate, RappleColorPickerDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

     // Outlet Declaration
    
    @IBOutlet weak var petImage: UIImageView!
    @IBOutlet weak var petName: UITextField!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var logOutView: UIView!
    @IBOutlet weak var month: UITextField!
    @IBOutlet weak var years: UITextField!
    @IBOutlet weak var TypeOfPet: UIButton!
    @IBOutlet weak var petColorView: UIView!
    @IBOutlet weak var ScrollView: UIScrollView!
    @IBOutlet weak var sexOfPet: UIButton!
    
     // Variable Declaration
    var selectColorHexCode = String()
    var pickerController = UIImagePickerController()
    var ImageView = UIImage()
    var petAge = String()
    var petType = String()
    var petSex = String()
    var totalAge = Int()
    var imageCheck = Bool()
    var GetData : NSDictionary?
    var check:String?
    var petId = String()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
         imageCheck = false
        if check == "Edit"
        {
            print(GetData)
             petImage.sd_setImage(with: URL(string:pet_Image_base_url+"\(GetData!["petPicture"] as! String)"), placeholderImage: UIImage(named: "my_profile.png"))
            
            
            petId = GetData!["id"] as! String
            petName.text = GetData!["petName"] as! String
            self.TypeOfPet.setTitle("\(GetData!["petType"] as! String)",for: .normal)
            self.petType = GetData!["petType"] as! String
            self.sexOfPet.setTitle("\(GetData!["petSex"] as! String)",for: .normal)
            self.petSex = GetData!["petSex"] as! String
            let petAgeYrs = GetData!["petAge"] as! String
            let year = Int(petAgeYrs as! String)
            selectColorHexCode = GetData!["petColor"] as! String
            
            
            let String1 = petAgeYrs.replacingOccurrences(of: "years", with: " ")
            let String2 = String1.replacingOccurrences(of: "months", with: "")
            print("\(String2)")
            let array = String2.components(separatedBy: " ")
            print(array)
            self.month.text! = array[0] as! String
            self.years.text! = array[1] as! String
            
//            let finalYear = String(year!/12)
//            let finalMonth = String(year!%12)
            imageCheck = true

            let temp = GetData!["petColor"] as! String
            //     print(temp)
            var color1 = hexStringToUIColor(hex: temp)
            //     print(color1)
            petColorView.backgroundColor = color1
            
        }
       
        addDoneButtonOnKeyboard()
        ScrollView.contentSize = CGSize(width: self.view.frame.size.width, height: 800)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.petImage.layer.borderWidth = 1
        self.petImage.layer.borderColor = UIColor.init(red:22/255.0, green:110/255.0, blue:222/255.0, alpha: 1.0).cgColor
        
        // Image picker ===============
        
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapUserPhoto(_:)))
        imageTapGesture.delegate = self
        petImage.addGestureRecognizer(imageTapGesture)
        imageTapGesture.numberOfTapsRequired = 1
        petImage.isUserInteractionEnabled = true
        pickerController.delegate = self
        
        
        backView.isHidden = true
        logOutView.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapBlurButton(_:)))
        backView.addGestureRecognizer(tapGesture)
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool)
    {
        
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
    // MARK: - Button Click action
    
    @IBAction func typeOfPetButtonClick(_ sender: Any)
    {
        McPicker.show(data: [["Dog", "Cat"]]) {  (selections: [Int : String]) -> Void in
            if let name = selections[0] {
                self.petType = name
                self.TypeOfPet.setTitle("\(name)",for: .normal)
            }
        }
    }
    @IBAction func sexOfPetButtonClick(_ sender: Any)
    {
        McPicker.show(data: [["Male", "Female"]]) {  (selections: [Int : String]) -> Void in
            if let name = selections[0] {
                self.petSex = name
                self.sexOfPet.setTitle("\(name)",for: .normal)
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
    
    @IBAction func selectPetImageButtonClick(_ sender: Any)
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
    
    @IBAction func addPetButtonClick(_ sender: Any)
    {
        if imageCheck == false
        {
            APIController.ShowAlert(Title: "Alert", Message: "select Pet Image", View: self)
        }
        else if petName.text == ""
        {
             APIController.ShowAlert(Title: "Alert", Message: "Enter Pet Name", View: self)
        }
        else if petSex == ""
        {
            APIController.ShowAlert(Title: "Alert", Message: "select sex of pet", View: self)
        }
        else if petType == ""
        {
             APIController.ShowAlert(Title: "Alert", Message: "select type of pet", View: self)
        }
        else if years.text == ""
        {
             APIController.ShowAlert(Title: "Alert", Message: "Enter pet year", View: self)
        }
        else if month.text == ""
        {
            APIController.ShowAlert(Title: "Alert", Message: "Enter pet Month", View: self)
        }
        else if selectColorHexCode == ""
        {
            APIController.ShowAlert(Title: "Alert", Message: "Select Pet Color", View: self)
        }
        else
        {
            if check == "Edit"
            {
                imageUploadAndAddUpdate()
            }
            else
            {
                 self.imageUploadAndAddPet()
            }
           
        }
    }
    
    @IBAction func SelectPetColorButtonClick(_ sender: Any)
    {
        
        RappleColorPicker.openColorPallet(title: "Color Picker", tag: 0) { (color, tag) in
            self.petColorView.backgroundColor = color
            self.selectColorHexCode = color.toHex() as! String
            print(self.selectColorHexCode)
            
            RappleColorPicker.close()
        }
    }
    @IBAction func backButtonClick(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Text Field Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder();
        return true;
    }
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        
    }
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(addPetViewController.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.years.inputAccessoryView = doneToolbar
        self.month.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        self.years.resignFirstResponder()
        self.month.resignFirstResponder()
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
        petImage.contentMode = .scaleAspectFill
        petImage.image = ImageView
        imageCheck = true
        
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
    
    //MARK:- Image upload with param function

    func imageUploadAndAddPet()
    {
        
        SVProgressHUD.show()
        
        let myUrl = URL(string: BASE_URL+"addpet");
        let request = NSMutableURLRequest(url:myUrl! as URL);
        request.httpMethod = "POST";
        let boundary = generateBoundaryString()
        let params : Parameters = ["user_access_token":"\(UserDefaults.standard.string(forKey: "user_access_token")!)","petName":"\(self.petName.text!)","petAge":"\(self.years.text!)years\(self.month.text!)months","petType":"\(self.petType)","petSex":"\(self.petSex)","petColor":"\(self.selectColorHexCode)"]
        
        print("postString==>\(params)")

        Alamofire.upload(multipartFormData: { multipartFormData in
            if let imageData = UIImageJPEGRepresentation(self.petImage.image!, 1) {
                
                multipartFormData.append(imageData, withName: "petPicture", fileName: "profile_picture.jpg", mimeType: "image/png")
                
            }

            for (key, value) in params {
                
                multipartFormData.append(String(describing: value).data(using: String.Encoding.utf8)!, withName: key)
                
            }
            
        }, to: myUrl!, method: .post, headers: nil,
           
           encodingCompletion: { encodingResult in
            
            switch encodingResult {
                
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    
                    print("Upload Progress: \(progress.fractionCompleted)")
                    
                })

                upload.responseString { response in
                    debugPrint("SUCCESS RESPONSE: \(response)")
    
                    let uiAlertController = UIAlertController(// create new instance alert  controller
                        title: "Alert",
                        message: "Pet Added Successfully",
                        preferredStyle:.alert)
                    
                    uiAlertController.addAction(// add Custom action on Event is Cancel
                        UIAlertAction.init(title: "Ok", style: .default, handler: { (UIAlertAction) in
                            //TO DO code
                            self.navigationController?.popViewController(animated: true)
                            uiAlertController.dismiss(animated: true, completion: nil)//dismiss show You alert, on click is Cancel
                        }))
                    //show You alert
                    self.present(uiAlertController, animated: true, completion: nil)
                    SVProgressHUD.dismiss()
                    
                }
            case .failure(let encodingError):
                
                print("error:\(encodingError)")
                SVProgressHUD.dismiss()
                
            }
        })
    }
    
    func imageUploadAndAddUpdate()
    {
        
        SVProgressHUD.show()
        totalAge = ((Int(self.years.text!))! * 12) + (Int(self.month.text!))!
        let myUrl = URL(string: BASE_URL+"petupdate");
        let request = NSMutableURLRequest(url:myUrl! as URL);
        request.httpMethod = "POST";
        let boundary = generateBoundaryString()
        let params : Parameters = ["user_access_token":"\(UserDefaults.standard.string(forKey: "user_access_token")!)","id":"\(self.petId)","petName":"\(self.petName.text!)","petAge":"\(self.totalAge)","petType":"\(self.petType)","petSex":"\(self.petSex)","petColor":"\(self.selectColorHexCode)"]
        
        print("postString==>\(params)")
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            if let imageData = UIImageJPEGRepresentation(self.petImage.image!, 1) {
                
                multipartFormData.append(imageData, withName: "petPicture", fileName: "profile_picture.jpg", mimeType: "image/png")
                
            }
            
            for (key, value) in params {
                
                multipartFormData.append(String(describing: value).data(using: String.Encoding.utf8)!, withName: key)
                
            }
            
        }, to: myUrl!, method: .post, headers: nil,
           
           encodingCompletion: { encodingResult in
            
            switch encodingResult {
                
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    
                    print("Upload Progress: \(progress.fractionCompleted)")
                    
                })
                
                upload.responseString { response in
                    debugPrint("SUCCESS RESPONSE: \(response)")
                    
                    let uiAlertController = UIAlertController(// create new instance alert  controller
                        title: "Alert",
                        message: "Pet Updated successfully",
                        preferredStyle:.alert)
                    
                    uiAlertController.addAction(// add Custom action on Event is Cancel
                        UIAlertAction.init(title: "Ok", style: .default, handler: { (UIAlertAction) in
                            //TO DO code
                            self.navigationController?.popViewController(animated: true)
                            uiAlertController.dismiss(animated: true, completion: nil)//dismiss show You alert, on click is Cancel
                        }))
                    //show You alert
                    self.present(uiAlertController, animated: true, completion: nil)
                    SVProgressHUD.dismiss()
                    
                }
            case .failure(let encodingError):
                
                print("error:\(encodingError)")
                SVProgressHUD.dismiss()
                
            }
        })
    }

    func generateBoundaryString() -> String
    {
        
        return "Boundary-\(NSUUID().uuidString)"
        
    }
    //MARK :- Hexcode to UIColor
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
extension UIColor {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        return getRed(&r, green: &g, blue: &b, alpha: &a) ? (r,g,b,a) : nil
    }
}

extension UIColor {
    
    // MARK: - Initialization
    
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt32 = 0
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        
        let length = hexSanitized.characters.count
        
        guard Scanner(string: hexSanitized).scanHexInt32(&rgb) else { return nil }
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
            
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    // MARK: - Computed Properties
    
    var toHex: String? {
        return toHex()
    }
    
    // MARK: - From UIColor to String
    
    func toHex(alpha: Bool = false) -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        
        if components.count >= 4 {
            a = Float(components[3])
        }
        
        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
    
}
