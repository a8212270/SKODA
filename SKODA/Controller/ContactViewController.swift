//
//  ContactViewController.swift
//  SKODA
//
//  Created by 孫 鈺驊 on 2017/10/12.
//  Copyright © 2017年 孫 鈺驊. All rights reserved.
//

import UIKit

class ContactViewController: UIViewController {
    
    @IBOutlet weak var img: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if GlobalVar.mode == "skoda" {
            img.image = UIImage(named: "contact_skoda")
        } else {
            img.image = UIImage(named: "contact_vw")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
