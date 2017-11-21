//
//  MainViewController.swift
//  SKODA
//
//  Created by 孫 鈺驊 on 2017/9/28.
//  Copyright © 2017年 孫 鈺驊. All rights reserved.
//

import UIKit

class MainViewController: BaseViewController {
    
    @IBOutlet weak var news: UIButton!
    @IBOutlet weak var _try: UIButton!
    @IBOutlet weak var order: UIButton!
    @IBOutlet weak var beacon: UIButton!
    @IBOutlet weak var contact: UIButton!
    @IBOutlet weak var footer: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addSlideMenuButton()
        clearBackTitle()
        
        self.navigationItem.title = "金元三專業服務"
        self.navigationItem.hidesBackButton = true
        
        if GlobalVar.mode == "skoda" {
            news.setImage(UIImage(named: "main_news"), for: UIControlState.normal)
            _try.setImage(UIImage(named: "main_try"), for: UIControlState.normal)
            order.setImage(UIImage(named: "main_order"), for: UIControlState.normal)
            beacon.setImage(UIImage(named: "main_beacon"), for: UIControlState.normal)
            contact.setImage(UIImage(named: "main_contact"), for: UIControlState.normal)
            footer.image = UIImage(named: "footer")
        } else {
            news.setImage(UIImage(named: "main_news_vw"), for: UIControlState.normal)
            _try.setImage(UIImage(named: "main_try_vw"), for: UIControlState.normal)
            order.setImage(UIImage(named: "main_order_vw"), for: UIControlState.normal)
            beacon.setImage(UIImage(named: "main_beacon_vw"), for: UIControlState.normal)
            contact.setImage(UIImage(named: "main_contact_vw"), for: UIControlState.normal)
            footer.image = UIImage(named: "footer_vw")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickBtn(sender: UIButton!) {
        if sender.tag == 2 {
            let defaults = UserDefaults.standard
            let hasSetId = defaults.value(forKey: "id") as? String
            
            if hasSetId != nil {
                performSegue(withIdentifier: "orderView", sender: self)
            } else {
                Public.displayAlert(self, title: "提醒！", message: "請先登入！")
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
