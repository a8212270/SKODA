//
//  ChooseLoginTypeViewController.swift
//  SKODA
//
//  Created by 孫 鈺驊 on 2017/10/10.
//  Copyright © 2017年 孫 鈺驊. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import SwiftyJSON

class ChooseLoginTypeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
        
//        let defaults = UserDefaults.standard
//        let hasSetId = defaults.value(forKey: "id") as? String
//
//        if hasSetId != nil {
//            print("auto login")
//            performSegue(withIdentifier: "mainView", sender: self)
//        } else {
//            print("not login")
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickFBLogin() {
        Public.progressBarDisplayer(self.view, indicator: true)
        var gender = 0
        var fbId = ""
        var name = ""
        
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                Public.progressBarDisplayer(self.view, indicator: false)
                return
            }
            
            //            print(result.)
            
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                Public.progressBarDisplayer(self.view, indicator: false)
                return
            }
            
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, gender, name"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    //everything works print the user data
                    let data = JSON(result!)
                    print(data)
                    
                    switch data["gender"].stringValue {
                    case "male":
                        gender = 1
                    case "femal":
                        gender = 2
                    default:
                        gender = 0
                    }

                    fbId = data["id"].stringValue
                    name = data["name"].stringValue
                    
                    let parameters = ["user_name": name, "email": "\(fbId)@fb.me", "password": fbId, "gender": gender] as [String : Any]
                    print(parameters)
                    Public.getRemoteData("\(GlobalVar.serverIp)api/v1/member/Login/FB", parameters: parameters as [String : AnyObject], completionHandler: { (response, error) in
                        print(response)
                        GlobalVar.user_id = response["result"]["user_id"].stringValue
                        let defaults = UserDefaults.standard
                        defaults.setValue(response["result"]["user_id"].stringValue, forKey: "id")
                        defaults.setValue(response["result"]["username"].stringValue, forKey: "name")
                        self.registerDevice()
                        Public.progressBarDisplayer(self.view, indicator: false)
                        self.performSegue(withIdentifier: "mainView", sender: self)
                    })
                }
            })
        }
    }
    
    func registerDevice() {
        let parameters = [
            "id": GlobalVar.user_id,
            "token": GlobalVar.deviceToken]
        
        print(parameters)
        Public.getRemoteData("\(GlobalVar.serverIp)api/v1/updateToken", parameters: parameters as [String : AnyObject]) { (response, error) in
            if error {
                let errorMsg = response["Msg"].string
                print(errorMsg!)
            } else {
                print(response)
            }
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
