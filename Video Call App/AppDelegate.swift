//
//  AppDelegate.swift
//  Video Call App
//
//  Created by IOS MAC5 on 15/01/18.
//  Copyright © 2018 IOS MAC5. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Firebase
import FirebaseMessaging
import UserNotifications
import FirebaseInstanceID
import UserNotifications
import UserNotificationsUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,MessagingDelegate,UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
       // AIzaSyDeYWrutbeJXWteFou0LByFx85sPsRj_j0
        GMSPlacesClient.provideAPIKey("AIzaSyD9ZCOhgu8gws5JNsWYqJrlHFypA2juj2w")
        GMSServices.provideAPIKey("AIzaSyD9ZCOhgu8gws5JNsWYqJrlHFypA2juj2w")
        // Override point for customization after application launch.
         
        FirebaseApp.configure()
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        let token = Messaging.messaging().fcmToken
        print("FCM token: \(token ?? "")")
        
        return true
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        print("Device id =====>: \(UIDevice.current.identifierForVendor!.uuidString)")
        UIDevice.current.identifierForVendor!.uuidString
        
        let data = NSKeyedArchiver.archivedData(withRootObject:UIDevice.current.identifierForVendor!.uuidString)
        UserDefaults.standard.set(data, forKey: "device_id")
        
        let data1 = NSKeyedArchiver.archivedData(withRootObject:fcmToken)
        UserDefaults.standard.set(data1, forKey: "fcm_token")
        
    }
    
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Messaging.messaging().apnsToken = deviceToken as Data
    }
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        
        // custom code to handle push while app is in the foreground
        print("Handle push from foreground\(notification.request.content.userInfo)")
        
        completionHandler([.alert, .badge, .sound])
        let dict = notification.request.content.userInfo["aps"] as! NSDictionary
        let noti_type = notification.request.content.userInfo["noti_type"] as! NSString
        print("\(noti_type)")
        if noti_type == "logout"
        {
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
                        let rootViewController = self.window!.rootViewController as! UINavigationController
                        rootViewController.pushViewController(ViewController, animated: true)
                    }
                    else if userJson["has_error"] as! Int == 1
                    {
                        
                    }
                    
                }
            }
            
        }
        
        
    }
    
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // if you set a member variable in didReceiveRemoteNotification, you  will know if this is from closed or background
        print("Handle push from background or closed\(response.notification.request.content.userInfo)")
        let dict = response.notification.request.content.userInfo["aps"] as! NSDictionary
        let noti_type = response.notification.request.content.userInfo["noti_type"] as! NSString
        print("\(noti_type)")
        if noti_type == "logout"
        {
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
                        let rootViewController = self.window!.rootViewController as! UINavigationController
                        rootViewController.pushViewController(ViewController, animated: true)
                        
                    }
                    else if userJson["has_error"] as! Int == 1
                    {
                        
                    }
                    
                }
            }
            
        }
        else if noti_type == "M"
        {
            let chatMessage = response.notification.request.content.userInfo["chatMessage"] as! NSString
            var dictonary:NSDictionary?
            if let data = chatMessage.data(using: String.Encoding.utf8.rawValue) {
                do {
                    dictonary = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    
                    if let myDictionary = dictonary
                    {
                        
                        print("\(myDictionary)")
                        let type = myDictionary["message"] as! NSDictionary
                        print("\(type)")
                        
                        let data = NSKeyedArchiver.archivedData(withRootObject:type)
                        UserDefaults.standard.set(data, forKey: "notificationData")
                        
                        UserDefaults.standard.set(true, forKey: "noti")
                        if UserDefaults.standard.bool(forKey: "AppStatus")
                        {
                            
                        }
                        else
                        {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let ViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                            let rootViewController = self.window!.rootViewController as! UINavigationController
                            rootViewController.pushViewController(ViewController, animated: true)
                        }
                    }
                } catch let error as NSError {
                    print(error)
                }
            }
        }
        else if noti_type == "F"
        {
            let chatMessage = response.notification.request.content.userInfo["chatMessage"] as! NSString
            var dictonary:NSDictionary?
            if let data = chatMessage.data(using: String.Encoding.utf8.rawValue) {
                do {
                    dictonary = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    
                    if let myDictionary = dictonary
                    {
                        
                        print("\(myDictionary)")
                        let type = myDictionary["message"] as! NSDictionary
                        print("\(type)")
                        
                        let data = NSKeyedArchiver.archivedData(withRootObject:type)
                        UserDefaults.standard.set(data, forKey: "notificationData")
                        
                        UserDefaults.standard.set(true, forKey: "noti")
                        if UserDefaults.standard.bool(forKey: "AppStatus")
                        {
                            
                        }
                        else
                        {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let ViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                            let rootViewController = self.window!.rootViewController as! UINavigationController
                            rootViewController.pushViewController(ViewController, animated: true)
                        }
                    }
                } catch let error as NSError {
                    print(error)
                }
            }
        }
        
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        UserDefaults.standard.set(true, forKey: "AppStatus")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
    {
        print("url \(url)")
        let FullUrl: String = url.absoluteString as String
        print("url \(FullUrl)")
        print("url host :\(url.host)")
        let urlHost : String = url.host as String!
        if urlHost == "everification"
        {
           
            APICallForMailActivation(FullUrl: FullUrl)
            
        }
        else if urlHost == "clientReg"
        {
            let storyboard = UIStoryboard(name: "PetOwner", bundle: nil)
            let PetAcceptedViewController = storyboard.instantiateViewController(withIdentifier: "PetAcceptedViewController") as! PetAcceptedViewController
            let rootViewController = self.window!.rootViewController as! UINavigationController
            
            rootViewController.pushViewController(PetAcceptedViewController, animated: true)
        }
        else if urlHost == "clientNotReg"
        {
            let fullNameArr = FullUrl.components(separatedBy: "?")
            print(fullNameArr)
            let str1 = fullNameArr[1]
            let str1Brk = str1.components(separatedBy: "=")
            let userName = str1Brk[1] as! String
            
            let str2 = fullNameArr[2]
            let str2Brk = str2.components(separatedBy: "=")
            let email = str2Brk[1] as! String
            
            let str3 = fullNameArr[3]
            let str3Brk = str3.components(separatedBy: "=")
            let phone = str3Brk[1] as! String
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let VetSignUpViewController = storyboard.instantiateViewController(withIdentifier: "VetSignUpViewController") as! VetSignUpViewController
            let rootViewController = self.window!.rootViewController as! UINavigationController
           // VetSignUpViewController.petSignUpDic = dic
            VetSignUpViewController.fromlink = true
             VetSignUpViewController.UserType = "P"
             VetSignUpViewController.getEmail = email
            VetSignUpViewController.getUserName = userName
            VetSignUpViewController.getPhoneNo = phone
            rootViewController.pushViewController(VetSignUpViewController, animated: true)
        }
        
        
        return true
    }
    func APICallForMailActivation(FullUrl:String)
    {
        let Array1 = FullUrl.components(separatedBy: "?")
        print("\(Array1)")
        let Value = Array1[1]
        let Array2 = Value.components(separatedBy: "&")
        print(Array2)
        let idValue = Array2[0]
        let Array3 = idValue.components(separatedBy: "=")
        let id = Array3[1]
        print(id)
        let vCodeValue = Array2[1]
        let UserTypeValue = Array2[2]
        let Array4 = vCodeValue.components(separatedBy: "=")
        let vCode = Array4[1]
        let Array5 = UserTypeValue.components(separatedBy: "=")
        let userType = Array5[1]
        print(vCode)
        print(userType)
        let postString = "id=\(id)&vCode=\(vCode)";
        print("postString==>\(postString)")
        
        APIManager.sharedInstance.getUsersFromUrl(Type: "POST", serviceUrl: BASE_URL+"everification", postString: postString){(userJson) -> Void in
            
            if userJson != nil {
                print(userJson)
                if userJson["has_error"] as! Int == 0
                {
//                    let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
//                    let VetSignInViewController =  mainStoryBoard.instantiateViewController(withIdentifier: "VetSignInViewController") as! VetSignInViewController
//                    VetSignInViewController.UserType = userType
//                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                    appDelegate.window?.rootViewController = VetSignInViewController
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let VetSignInViewController = storyboard.instantiateViewController(withIdentifier: "VetSignInViewController") as! VetSignInViewController
                    let rootViewController = self.window!.rootViewController as! UINavigationController
                    VetSignInViewController.UserType = userType
                    rootViewController.pushViewController(VetSignInViewController, animated: true)
                    
                }
                else if userJson["has_error"] as! Int == 1
                {
                    let alert = UIAlertView()
                    alert.title = "Alert"
                    alert.message = "\(userJson["errors"] as! String)"
                    alert.addButton(withTitle: "Ok")
                    alert.show()
                    
                }
                
            }
        }
    }

}

