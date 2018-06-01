//
//  APIManager.swift
//  Video Call App
//
//  Created by IOS MAC5 on 16/01/18.
//  Copyright © 2018 IOS MAC5. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SVProgressHUD


class APIManager{
    
    
    static let sharedInstance   =   APIManager()
    
    private init(){
        
    }
    
    func getUsersFromUrl(Type:String,serviceUrl:String,postString:String,onCompletion:@escaping (_ response:Dictionary<String, Any>)-> Void) {
        SVProgressHUD.show()
        let myUrl = URL(string:serviceUrl);
        var request = URLRequest(url:myUrl!)
        request.httpMethod = Type
        request.httpBody = postString.data(using: String.Encoding.utf8);
        Alamofire.request(request)
            
            .responseJSON { response in
                
                guard let json = response.result.value as? [String: Any] else {
                    
                    print("didn't get todo object as JSON from API")
                    
                    //print("Error: \(response.result.error as! NSString)")
                    
                    SVProgressHUD.dismiss()
                    
                    return
                    
                }
                
                //print(json)
                SVProgressHUD.dismiss()
                onCompletion(json)
               
                
        }
    }
    
    func getUsersProfilePhotoFromUrl(Type:String,serviceUrl:String,params:NSDictionary,ImageView:UIImage, onCompletion:@escaping (_ response:String)-> Void) {
        
        SVProgressHUD.show()
        let myUrl = URL(string: serviceUrl);
        
        let request = NSMutableURLRequest(url:myUrl! as URL);
        request.httpMethod = "POST";
        let boundary = generateBoundaryString()
        
        print("postString==>\(params)")
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            if let imageData = UIImageJPEGRepresentation(ImageView, 1) {
                
                multipartFormData.append(imageData, withName: "profilePicture", fileName: "profile_picture.jpg", mimeType: "image/png")
                
            }
            for (key, value) in params {
                
                multipartFormData.append(String(describing: value).data(using: String.Encoding.utf8)!, withName: key as! String)
                
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
                    onCompletion("SUCCESS RESPONSE")
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
    
    
    
    class func ShowAlert(Title:String, Message:String, View:UIViewController) {
        
        let alertController = UIAlertController(title: Title, message: Message, preferredStyle: .alert);
        let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(alertAction)
        View.present(alertController, animated: true, completion: nil)
        
    }
    
    
}

