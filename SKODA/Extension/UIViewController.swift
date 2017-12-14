//
//  UIViewController.swift
//  SKODA
//
//  Created by 孫 鈺驊 on 2017/9/28.
//  Copyright © 2017年 孫 鈺驊. All rights reserved.
//

import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func clearBackTitle() {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem
    }
    
    func setFooter() {
        let footer = UIImageView()
        footer.frame = CGRect(x: 0, y: ScreenSize.SCREEN_HEIGHT - 20, width: ScreenSize.SCREEN_WIDTH, height: 20)
        
        if GlobalVar.mode == "skoda" {
            footer.image = UIImage(named: "footer")
        } else {
            footer.image = UIImage(named: "footer_vw")
        }
        
        view.addSubview(footer)
    }
    
    func setBackgroundColor() {
        if GlobalVar.mode == "skoda" {
            view.backgroundColor = UIColor(hex: "6fb651")
        } else {
            view.backgroundColor = UIColor(hex: "e4e4e3")
        }
    }
}
