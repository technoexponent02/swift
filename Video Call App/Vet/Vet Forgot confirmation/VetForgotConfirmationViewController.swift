//
//  VetForgotConfirmationViewController.swift
//  Video Call App
//
//  Created by IOS MAC5 on 15/01/18.
//  Copyright © 2018 IOS MAC5. All rights reserved.
//

import UIKit

class VetForgotConfirmationViewController: UIViewController {

    // Variable Declaration
    
    var UserType : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(UserType)
        // Do any additional setup after loading the view.
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backToLoginButtonClick(_ sender: Any)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VetSignInViewController = storyboard.instantiateViewController(withIdentifier: "VetSignInViewController") as! VetSignInViewController
        VetSignInViewController.UserType = UserType
        self.navigationController?.pushViewController(VetSignInViewController, animated: true)
    }
    @IBAction func backButtonClick(_ sender: Any)
    {
        _ = navigationController?.popViewController(animated: true)
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
