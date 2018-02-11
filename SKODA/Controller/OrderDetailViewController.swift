//
//  OrderDetailViewController.swift
//  SKODA
//
//  Created by 孫 鈺驊 on 2017/9/29.
//  Copyright © 2017年 孫 鈺驊. All rights reserved.
//

import UIKit
import SwiftyJSON

class OrderDetailViewControllerCell: UITableViewCell {
    @IBOutlet weak var input: UITextField!
    @IBOutlet weak var submit: UIButton!
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var textView: UITextView!
}

class OrderDetailViewController: BaseViewController {
    
    @IBOutlet weak var carImg: UIImageView!
    @IBOutlet weak var carModel: UILabel!
    @IBOutlet weak var plateNumber: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    var carImgUrl = ""
    var car_model = ""
    var plate_number = ""
    var brand = ""
    var toolBar:UIToolbar!
    var pickerViewList = [String]()
    var maintenanceList:JSON! = []
    var mealList:JSON! = []
    var orderTypeList:JSON! = []
    var orderTimeList:JSON! = []
    var isShowRemark = false
    var isShowMeals = false
    
    let datePickerView:UIDatePicker = UIDatePicker()
    let placeholder = ["請輸入里程數", "請選擇保養項目", "備註", "請選擇險種", "請選擇保養日期", "請選擇保養時間", "請選擇餐點", "請選擇車廠"]
    let insurance_types = ["請選擇險種", "甲式保險", "乙式保險", "丙式保險", "第三意外險", "竊盜險"]
    var order_types = ["請選擇保養項目"]
    let sk_maintenances = ["請選擇車廠", "SKODA 中和新車銷售據點", "SKODA 新莊新車銷售據點", "SKODA 中和服務廠"]
    let vw_maintenances = ["請選擇車廠", "VW LCV 土城服務廠"]
    var maintenances = ["請選擇車廠"]
    var meals = ["請選擇餐點", "不需要"]
    let maintenances_phone = ["02-82213399", "02-89932272", "02-82213115", "02-22696290"]
    let maintenances_address = ["新北市中和區建康路28號", "新北市新莊區中正路66號", "新北市中和區建康路28號", "新北市土城區中華路二段212號"]
    var times = ["請選擇保養時間"]
    
    //tableView 資料
    var date = ""
    var order_type = ""
    var insurance_type = ""
    var remark = ""
    var maintenance = ""
    var time = ""
    var meal = ""
    var km = ""
    
    //回傳資料
    var s_date = ""
    var s_order_type = ""
    var s_insurance_type = ""
    var s_remark = ""
    var s_maintenance = ""
    var s_time = ""
    var s_car_no = ""
    var s_meal = "0"
    var s_km = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getMaintenanceList()
        getMealsList()
        getOrderTypeList()
        getOrderTimeList()
        setFooter()
        addSlideMenuButton()
        setBackgroundColor()
        clearBackTitle()
//        hideKeyboardWhenTappedAround()
        self.navigationItem.title = "預約保養"
        
        carImg.af_setImage(withURL: URL(string: carImgUrl)!)
        carImg.contentMode = .scaleAspectFit
        
        carModel.text = car_model
        plateNumber.text = plate_number
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorStyle = .none
        
        //pickerview出現後上方的bar條
        toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.barStyle = UIBarStyle.blackTranslucent
        toolBar.tintColor = UIColor.white
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.donePressed(sender:)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        toolBar.setItems([flexSpace, flexSpace, flexSpace, flexSpace, doneButton], animated: true)
        
        //設定datePickerView模式及偵聽
        datePickerView.tag = 99
        datePickerView.minimumDate = NSDate() as Date
        datePickerView.datePickerMode = .date
        datePickerView.addTarget(self, action: #selector(self.datePickerValueChanged(sender:)), for: UIControlEvents.valueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getMaintenanceList() {
        
        let parameters = ["brand": self.brand,
                          "type": "1"]
        
        Public.getRemoteData("\(GlobalVar.serverIp)api/v1/maintenance/List", parameters: parameters as [String : AnyObject]) { (response, error) in
            print(response)
            if error {
                
            } else {
                self.maintenanceList = response["result"]
                
                for i in 0..<self.maintenanceList.count {
                    self.maintenances.append(self.maintenanceList[i]["name"].stringValue)
                }
            }
        }
    }
    
    func getMealsList() {
        
        let parameters = ["brand": self.brand]
        
        Public.getRemoteData("\(GlobalVar.serverIp)api/v1/order/Get_Meals_List", parameters: parameters as [String : AnyObject]) { (response, error) in
            print(response)
            if error {
                
            } else {
                self.mealList = response["result"]
                
                for i in 0..<self.mealList.count {
                    self.meals.append(self.mealList[i]["name"].stringValue)
                }
            }
        }
    }
    
    func getOrderTypeList() {

        Public.getRemoteData("\(GlobalVar.serverIp)api/v1/PANEL/order/List_select", parameters: [:]) { (response, error) in
            print(response)
            if error {
                
            } else {
                self.orderTypeList = response["result"]
                
                for i in 0..<self.orderTypeList.count {
                    self.order_types.append(self.orderTypeList[i]["name"].stringValue)
                }
            }
        }
    }
    
    func getOrderTimeList() {
         let parameters = ["brand": self.brand]
        Public.getRemoteData("\(GlobalVar.serverIp)api/v1/order/Get_Time_List", parameters: parameters as [String : AnyObject]) { (response, error) in
            print(response)
            if error {
                
            } else {
                self.orderTimeList = response["result"]
                
                for i in 0..<self.orderTimeList.count {
                    self.times.append(self.orderTimeList[i]["time"].stringValue)
                }
            }
        }
    }
    
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateFormat = "YYYY-MM-dd"
        
        date = dateFormatter.string(from: sender.date)
        s_date = date
    }
    
    @objc func donePressed(sender: UIBarButtonItem) {
        
        if !self.isShowRemark {
            self.remark = ""
        }
        tableView.reloadData()
        
        self.view.endEditing(true)
        
    }
    
    @objc func sendData() {
        
        var parameters = [
            "user_id": GlobalVar.user_id,
            "date": s_date,
            "time": s_time,
            "car_no": s_car_no,
            "maintenance_plant_no": s_maintenance,
            "insurance_type": s_insurance_type,
            "order_type": s_order_type,
            "meals": s_meal,
            "km": s_km]
        
        if remark != "" {
            parameters.updateValue(s_remark, forKey: "remarks")
        }
        print(parameters)
        
        Public.getRemoteData("\(GlobalVar.serverIp)api/v1/order/Add", parameters: parameters as [String : AnyObject]) { (response, error) in
            
            if error {
                Public.displayAlert(self, title: "提醒！", message: response["Msg"].stringValue)
            } else {
                let alert = UIAlertController(title: "提醒", message: "預約成功", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction((UIAlertAction(title: "確認", style: .default, handler: {(action) -> Void in
                    self.navigationController?.popToRootViewController(animated: true)
                })))
                self.present(alert, animated: true, completion: nil)
//                let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OrderFinishViewController") as! OrderFinishViewController
//
//                popOverVC.carImgUrl = self.carImgUrl
//                popOverVC.car_Model = self.car_model
//                popOverVC.plate_Number = self.plate_number
//                popOverVC.time_t = response["result"]["time"].stringValue
//                popOverVC.orderTime_t = "\(self.date) \(self.time)"
//                popOverVC.place_t = self.maintenance
//                popOverVC.place_address_t = self.maintenances_address[Int(self.s_maintenance)!]
//                popOverVC.place_tel_t = self.maintenances_phone[Int(self.s_maintenance)!]
//
//                self.navigationController?.pushViewController(popOverVC, animated: true)
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

extension OrderDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeholder.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 8 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! OrderDetailViewControllerCell
            
            cell.submit.addTarget(self, action: #selector(self.sendData), for: .touchUpInside)
            
            cell.backgroundColor = UIColor.clear
            return cell
        } else if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OrderDetailViewControllerCell
            
            cell.input.placeholder = placeholder[indexPath.row]
            cell.tag = indexPath.row
            
            cell.input.inputView = datePickerView
            cell.input.inputAccessoryView = toolBar
            
            if date != "" {
                cell.input.text = date
            }
            
            cell.backgroundColor = UIColor.clear
            return cell
        } else if indexPath.row == 1 || indexPath.row == 3 || indexPath.row == 5 || indexPath.row == 6 || indexPath.row == 7 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OrderDetailViewControllerCell
            cell.input.placeholder = placeholder[indexPath.row]
            cell.tag = indexPath.row
            
            let pickerView = UIPickerView()
            pickerView.delegate = self
            pickerView.tag = indexPath.row
            cell.input.inputView = pickerView
            cell.input.inputAccessoryView = toolBar
            
            if indexPath.row == 1 && (order_type != "" || order_type != "請選擇保養項目") {
                cell.input.text = order_type
            }
            
            if indexPath.row == 3 && (insurance_type != "" || insurance_type != "請選擇險種"){
                cell.input.text = insurance_type
            }
            
            if indexPath.row == 5 && (time != "" || time != "請選擇保養時間"){
                cell.input.text = time
            }
            
            if indexPath.row == 6 && (meal != "" || meal != "請選擇餐點"){
                cell.input.text = meal
            }
            
            if indexPath.row == 7 && (maintenance != "" || maintenance != "請選擇車廠") {
                cell.input.text = maintenance
            }
            
            cell.backgroundColor = UIColor.clear
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "remarkCell", for: indexPath) as! OrderDetailViewControllerCell
            
            cell.textView.text = placeholder[indexPath.row]
            cell.textView.textColor = UIColor.lightGray
            cell.textView.delegate = self
            
            if remark != "" {
                cell.textView.text = remark
                cell.textView.textColor = UIColor.black
            }
            
            cell.backgroundColor = UIColor.clear
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OrderDetailViewControllerCell
            
            cell.input.placeholder = placeholder[indexPath.row]
            cell.input.tag = indexPath.row
            cell.input.delegate = self
            cell.tag = indexPath.row
            
            if indexPath.row == 0 && (km != "") {
                cell.input.text = km
            }
            
            cell.backgroundColor = UIColor.clear
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 8 {
            return 70.0
        } else if indexPath.row == 2 && self.isShowRemark {
            return 140.0
        } else if indexPath.row == 2 && !self.isShowRemark {
            return 0
        } else if indexPath.row == 6 && self.isShowMeals {
            return 44.0
        } else if indexPath.row == 6 && !self.isShowMeals {
            return 0
        } else {
            return 44.0
        }
    }
}

extension OrderDetailViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerView.tag {
        case 1:
            pickerViewList = order_types
        case 3:
            pickerViewList = insurance_types
        case 5:
            pickerViewList = times
        case 6:
            pickerViewList = meals
        case 7:
            pickerViewList = maintenances
        default:
            pickerViewList = []
        }
        
        return pickerViewList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            pickerViewList = order_types
        case 3:
            pickerViewList = insurance_types
        case 5:
            pickerViewList = times
        case 6:
            pickerViewList = meals
        case 7:
            pickerViewList = maintenances
        default:
            pickerViewList = []
        }
        
        return pickerViewList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        switch pickerView.tag {
        case 1:
            order_type = pickerViewList[row]
            if self.orderTypeList[row - 1]["remarks"].stringValue == "1" {
                self.isShowRemark = true
            } else {
                self.isShowRemark = false
            }
            s_order_type = "\(row)"
        case 3:
            insurance_type = pickerViewList[row]
            s_insurance_type = "\(row)"
        case 5:
            time = pickerViewList[row]
            if self.orderTimeList[row - 1]["hasMeal"].stringValue == "1" {
                print("here")
                self.isShowMeals = true
            } else {
                print("nohere")

                self.isShowMeals = false
            }
            s_time = "\(row)"
        case 6:
            meal = pickerViewList[row]
            s_meal = "\(row - 1)"
        case 7:
            maintenance = pickerViewList[row]
            s_maintenance = self.maintenanceList[row - 1]["id"].stringValue
        default:
            break
        }
    }
}

extension OrderDetailViewController: UITextViewDelegate, UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "備註"
            textView.textColor = UIColor.lightGray
        } else {
            self.remark = textView.text
            s_remark = self.remark
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var text: String!
        //當使用者有輸入文字則加在後面，否則刪除最後一個字元
        if string.characters.count > 0 {
            text = String(format:"%@%@",textField.text!, string);
        } else {
            let string = textField.text! as NSString
            text = string.substring(to: string.length - 1) as String
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch(textField.tag) {
        case 0:
            km = textField.text!
            s_km = km
        default:
            print("none")
        }
    }
}
