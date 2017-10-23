//
//  OrderFinishViewController.swift
//  SKODA
//
//  Created by 孫 鈺驊 on 2017/9/29.
//  Copyright © 2017年 孫 鈺驊. All rights reserved.
//

import UIKit

class OrderFinishViewController: BaseViewController {
    
    @IBOutlet weak var carImg: UIImageView!
    @IBOutlet weak var carModel: UILabel!
    @IBOutlet weak var plateNumber: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var orderTime: UILabel!
    @IBOutlet weak var place: UILabel!
    @IBOutlet weak var place_address: UILabel!
    @IBOutlet weak var place_tel: UILabel!
    
    var carImgUrl = ""
    var car_Model = ""
    var plate_Number = ""
    var time_t = ""
    var orderTime_t = ""
    var place_t = ""
    var place_address_t = ""
    var place_tel_t = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addSlideMenuButton()
        setFooter()
        setBackgroundColor()
        clearBackTitle()
        
        carImg.af_setImage(withURL: URL(string: carImgUrl)!)
        carImg.contentMode = .scaleAspectFit
        carModel.text = "您的車號 \(car_Model)"
        plateNumber.text = "車款 \(plate_Number)"
        time.text = "已於 \(time_t) 完成預約保養"
        orderTime.text = orderTime_t
        place.text = place_t
        place_address.text = place_address_t
        place_tel.text = place_tel_t
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
