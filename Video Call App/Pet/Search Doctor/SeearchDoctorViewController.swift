//
//  SeearchDoctorViewController.swift
//  Video Call App
//
//  Created by IOS MAC5 on 02/02/18.
//  Copyright © 2018 IOS MAC5. All rights reserved.
//

import UIKit
import CoreLocation
import McPicker
import GoogleMaps
import GooglePlaces

class SeearchDoctorViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,CLLocationManagerDelegate, UITextFieldDelegate,GMSAutocompleteViewControllerDelegate {

    // Outlet Declaration
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containTavleView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var radiusText: UITextField!
    @IBOutlet weak var petTableView: UITableView!
    @IBOutlet weak var searchButton: UIButton!
    
    
    // Variable Declaration
    let locationManager = CLLocationManager()
    var address = ""
    var lat = Double()
    var lon = Double()
    var AllDoctorList = NSArray()
    var petList = NSArray()
    var pickerController = UIImagePickerController()
    var currentLocation = CLLocation()
    var Latitude = Double()
    var Longitude = Double()
    var SelectPetOwnerId = String()
    var SelectPetDetails = NSDictionary()
    var SelectPetOwnerDetails = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapBlurButton(_:)))
        backView.addGestureRecognizer(tapGesture)
        containTavleView.isHidden = true
        backView.isHidden = true
        
        radiusText.text = "5mi"
        searchButton.layer.borderWidth = 2
        searchButton.layer.borderColor = UIColor.white.cgColor
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }

        // Do any additional setup after loading the view.
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
     
        manager.stopUpdatingLocation()
        manager.delegate = nil
        lat = userLocation.coordinate.latitude
        lon = userLocation.coordinate.longitude
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        self.getAddressFromLatLon(pdblLatitude: String(lat), withLongitude: String(lon))
        let location = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude) //changed!!!
        print(location)
        
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            print(location)
            
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
        })
    }
    
    func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(pdblLatitude)")!
        //21.228124
        let lon: Double = Double("\(pdblLongitude)")!
        //72.833770
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    print(pm.country)
                    print(pm.locality)
                    print(pm.subLocality)
                    print(pm.thoroughfare)
                    print(pm.postalCode)
                    print(pm.subThoroughfare)
                    var addressString : String = ""
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }
                    print(addressString)
                    self.locationText.text = addressString
                    self.ApiCallForSearchDoctor()
                }
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
   
    
    @IBAction func searchDoctorButtonClick(_ sender: Any)
    {
        self.ApiCallForSearchDoctor()
    }
    @IBAction func backBtn(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    //MARK :- Table view Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == petTableView
        {
            return petList.count
        }
        return self.AllDoctorList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == petTableView
        {
           return 100
        }
        return 165
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
        let cell = tableView.dequeueReusableCell(withIdentifier:"Cell", for: indexPath)as! SearchDoctorCell
        var SelectValue = self.AllDoctorList[indexPath.row] as! NSDictionary
        
        cell.doctorName.text = SelectValue["userName"] as? String
        cell.doctorSpecialization.text = SelectValue["specialization"] as? String
        if let str = SelectValue["experience"] as? String
        {
            cell.doctorExpreiance.text = "\(SelectValue["experience"] as! String) years expreiance,Veterinarian"
        }
        
        cell.doctorDescription.text = SelectValue["description"] as? String
        cell.doctorAddress.text = SelectValue["address"] as! String
        
        if let profilePicture = SelectValue["profilePicture"] as? String
        {
           cell.doctorImage.sd_setImage(with: URL(string:Profile_Image_base_url+profilePicture), placeholderImage: UIImage(named: "my_profile.png"))
        }
        cell.chatNowButton.addTarget(self,action:#selector(chatNow(sender:)), for: .touchUpInside)
        cell.chatNowButton.tag=indexPath.row
        
        cell.doctorDetails.addTarget(self,action:#selector(doctorDetailsButtonClick(sender:)), for: .touchUpInside)
        cell.doctorDetails.tag=indexPath.row
        
        return cell
    }
    @objc func doctorDetailsButtonClick(sender:UIButton)
    {
        
        let storyboard = UIStoryboard(name: "PetOwner", bundle: nil)
        let DoctorDetailsViewController = storyboard.instantiateViewController(withIdentifier: "DoctorDetailsViewController") as! DoctorDetailsViewController
        DoctorDetailsViewController.GetDoctorDetails = self.AllDoctorList[sender.tag] as! NSDictionary
         DoctorDetailsViewController.petList = self.petList
        self.navigationController?.pushViewController(DoctorDetailsViewController, animated: true)
    }
    @objc func chatNow(sender:UIButton)
    {
        let SelectValue = self.AllDoctorList[sender.tag] as! NSDictionary
        let chatstatus = SelectValue["chatstatus"] as! String
        let doc_Id = SelectValue["id"] as! String
        if chatstatus == "Y"
        {
            containTavleView.isHidden = false
            backView.isHidden = false
            
            SelectPetOwnerDetails = self.AllDoctorList[sender.tag] as! NSDictionary
            SelectPetOwnerId = SelectPetOwnerDetails["id"] as! String
            
        }
        else if chatstatus == "N"
        {
            containTavleView.isHidden = false
            backView.isHidden = false
            SelectPetOwnerDetails = self.AllDoctorList[sender.tag] as! NSDictionary
            SelectPetOwnerId = SelectPetOwnerDetails["id"] as! String
        }
        else if chatstatus == "D"
        {
            let alertController = UIAlertController(title: "Alert", message: "do you want to send chat request", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                
                print("Ok button tapped");
                self.ApiCallForChatRequest(docId: doc_Id)
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
            SelectPetOwnerDetails = self.AllDoctorList[sender.tag] as! NSDictionary
            SelectPetOwnerId = SelectPetOwnerDetails["id"] as! String
        }
        else if chatstatus == "B"
        {
            APIController.ShowAlert(Title: "Alert", Message: "Doctor Block", View: self)
        }
        
    }
    @objc func chat(sender:UIButton)
    {
        SelectPetDetails = self.petList[sender.tag] as! NSDictionary
        let petId = SelectPetDetails["id"] as! String
        ApiCallForChatId(petOwnerId: SelectPetOwnerId, petId: petId)
        containTavleView.isHidden = true
        backView.isHidden = true
    }
    @objc func tapBlurButton(_ sender: UITapGestureRecognizer) {
        containTavleView.isHidden = true
        backView.isHidden = true
    }
    //MARK :- API call 
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
                    VetChatViewController.GetReceiverData = self.SelectPetOwnerDetails
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
    func ApiCallForSearchDoctor()
    {
        let postString = "user_access_token=\(UserDefaults.standard.string(forKey: "user_access_token")!)&lat=\(lat)&lng=\(lon)&radius=\(radiusText.text!)&docName=\(searchText.text!)&index=\("0")";
        
        print("postString==>\(postString)")
        
        APIManager.sharedInstance.getUsersFromUrl(Type: "POST", serviceUrl: BASE_URL+"doctorlist", postString: postString){(userJson) -> Void in
            
            if userJson != nil {
                print(userJson)
                if userJson["has_error"] as! Int == 0
                {
                    self.AllDoctorList = userJson["result"] as! NSArray
                    self.petList = userJson["petList"] as! NSArray
                    self.tableView.reloadData()
                    self.petTableView.reloadData()
                }
                else if userJson["has_error"] as! Int == 1
                {
                    APIController.ShowAlert(Title: "ALert", Message: "\(userJson["errors"] as! String)", View: self)
                }
                
            }
        }
    }
    func ApiCallForChatRequest(docId:String)
    {
        let outData = UserDefaults.standard.data(forKey: "user_details")
        let dict = NSKeyedUnarchiver.unarchiveObject(with: outData!) as! NSDictionary
        print(dict)
        
        let postString = "user_access_token=\(UserDefaults.standard.string(forKey: "user_access_token")!)&reqTo=\(docId)&status=\("P")&blocked=\("")";
        
        print("postString==>\(postString)")
        
        APIManager.sharedInstance.getUsersFromUrl(Type: "POST", serviceUrl: BASE_URL+"chatrequest", postString: postString){(userJson) -> Void in
            
            if userJson != nil {
                print(userJson)
                if userJson["has_error"] as! Int == 0
                {
                    self.ApiCallForSearchDoctor()
                    APIController.ShowAlert(Title: "ALert", Message: "Requested Successfully", View: self)
                }
                else if userJson["has_error"] as! Int == 1
                {
                    APIController.ShowAlert(Title: "ALert", Message: "\(userJson["errors"] as! String)", View: self)
                }
                
            }
        }
    }
    // MARK: - Text Field Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if textField == self.radiusText
        {
            textField.resignFirstResponder();
            McPicker.show(data: [["5mi", "10mi","15mi","20mi","25mi"]]) {  (selections: [Int : String]) -> Void in
                if let name = selections[0] {
                    
                    self.radiusText.text = name
                    
                }
            }
        }
        else if textField == self.locationText
        {
            self.CallAutoCompleteView()
        }
    }
    
    //MARK: - Google Place Auto Complete
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \((place.formattedAddress)!)")
        //print("Place attributions: \((place.attributions)!)")
        self.locationText.text = place.formattedAddress!
        dismiss(animated: true, completion: nil)
        
        lat = place.coordinate.latitude
        lon = place.coordinate.longitude
        
        print("\(place.coordinate.latitude) ===== \(place.coordinate.longitude)")
        
        
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
        dismiss(animated: true, completion: nil)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
        self.locationText.resignFirstResponder()
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
