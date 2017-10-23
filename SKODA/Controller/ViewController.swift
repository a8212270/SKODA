//
//  ViewController.swift
//  SKODA
//
//  Created by 孫 鈺驊 on 2017/9/28.
//  Copyright © 2017年 孫 鈺驊. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.isNavigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onClickBtn(sender: UIButton) {
        if sender.tag == 0 {
            GlobalVar.mode = "skoda"
        } else {
            GlobalVar.mode = "vw"
        }
        
        let defaults = UserDefaults.standard
        let hasSetId = defaults.value(forKey: "id") as? String
        
        if hasSetId != nil {
            performSegue(withIdentifier: "mainView", sender: self)
        } else {
            performSegue(withIdentifier: "chooseLoginType", sender: self)
        }
    }
}

