//
//  ServiceRecordViewController.swift
//  SKODA
//
//  Created by 孫 鈺驊 on 2017/11/21.
//  Copyright © 2017年 孫 鈺驊. All rights reserved.
//

import UIKit
import SwiftyJSON

class ServiceRecordViewControllerCell: UITableViewCell {
    @IBOutlet weak var bkImg: UIImageView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var plate_no: UILabel!
    @IBOutlet weak var order_type: UILabel!
}

class ServiceRecordViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var recordData:JSON! = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addSlideMenuButton()
        setFooter()
        setBackgroundColor()
        self.navigationItem.title = "服務紀錄"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        getData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getData() {
        Public.getRemoteData("\(GlobalVar.serverIp)api/v1/order/Get_List", parameters: ["user_id" : GlobalVar.user_id as AnyObject]) { (response, error) in
            if error {
                
            } else {
                self.recordData = response["result"]
                self.tableView.reloadData()
            }
        }
    }
    
    func orderType(type: String) -> String {
        switch type {
        case "1":
            return "小型保養"
        case "2":
            return "中型保養"
        case "3":
            return "大型保養"
        case "4":
            return "特殊保養"
        default:
            return "特殊保養"
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

extension ServiceRecordViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recordData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ServiceRecordViewControllerCell
        
        let fileName = GlobalVar.mode == "skoda" ? "sk_service_" : "vw_service_"
        
        cell.bkImg.image = UIImage(named: "\(fileName)\(recordData[indexPath.row]["order"]["order_status"])")
        cell.time.text = recordData[indexPath.row]["order"]["order_date"].stringValue
        cell.plate_no.text = recordData[indexPath.row]["car"]["plate_number"].stringValue
        cell.order_type.text = orderType(type: recordData[indexPath.row]["order"]["order_type"].stringValue)
        
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
}
