//
//  Public.swift
//  SKODA
//
//  Created by 孫 鈺驊 on 2017/9/28.
//  Copyright © 2017年 孫 鈺驊. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class Public {
    //下載網路資料
    class func getRemoteData(_ url: String , parameters: [String : AnyObject] , completionHandler : @escaping ((_ response : JSON, _ error : Bool) -> Void)){
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()
            .responseJSON { (response:DataResponse<Any>) in
                switch(response.result) {
                case .success(_):
                    if let value = response.result.value {
                        let json = JSON(value)
                        let retCode = json["status"].stringValue
                        
                        if retCode == "1" {
                            completionHandler(json, false)
                        } else {
                            completionHandler(json, true)
                        }
                        
                    }
                    break
                    
                case .failure(_):
                    print(response.result.error!)
                    break
                    
                }
        }
    }
    
    //提醒視窗
    class func displayAlert(_ targetVC: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "確認", style: .default, handler: {(action) -> Void in
        })))
        targetVC.present(alert, animated: true, completion: nil)
    }
    
    class func progressBarDisplayer(_ view: UIView, indicator: Bool) {
        if indicator {
            let maskView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
            //            maskView.backgroundColor = UIColor.whiteColor()
            maskView.tag = 100
            var backgroudView = UIView()
            var activityIndicator = UIActivityIndicatorView()
            let xx = view.frame.size.width / 2
            let yy = view.frame.size.height / 2
            backgroudView = UIView(frame: CGRect(x: view.frame.midX, y: view.frame.midY , width: 75, height: 75))
            backgroudView.layer.cornerRadius = 15
            backgroudView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            backgroudView.center = CGPoint(x: xx, y: yy)
            
            
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 75, height: 75)
            activityIndicator.startAnimating()
            
            backgroudView.addSubview(activityIndicator)
            maskView.addSubview(backgroudView)
            view.addSubview(maskView)
        } else {
            if let viewWithTag = view.viewWithTag(100) {
                viewWithTag.removeFromSuperview()
            } else {
                print("tag not found")
            }
        }
    }
    
}

extension JSON{
    mutating func appendIfArray(json:JSON){
        if var arr = self.array{
            arr.append(json)
            self = JSON(arr);
        }
    }
    
    mutating func appendIfDictionary(key:String,json:JSON){
        if var dict = self.dictionary{
            dict[key] = json;
            self = JSON(dict);
        }
    }
}

struct ScreenSize
{
    static let SCREEN_WIDTH = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}
