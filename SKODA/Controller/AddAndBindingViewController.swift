//
//  AddAndBindingViewController.swift
//  SKODA
//
//  Created by 孫 鈺驊 on 2017/9/28.
//  Copyright © 2017年 孫 鈺驊. All rights reserved.
//

import UIKit
import SwiftyJSON

class AddAndBindingViewControllerCell: UITableViewCell {
    @IBOutlet weak var input: UITextField!
    @IBOutlet weak var submit: UIButton!
    @IBOutlet weak var cancel: UIButton!
}

class AddAndBindingViewController: BaseViewController {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var count = [String]()
    var toolBar:UIToolbar!
    var carListData:JSON! = []
    var isShow = false
    
    var defaultApi = "api/v1/car/Add/Record"
    
    let binding = ["車牌號碼", "出廠年月(日期可無視)", "牌照登記人"]
    let add = ["車牌號碼", "出廠年月(日期可無視)", "牌照登記人", "車身號碼", "請選擇車款", "請輸入車款", "領牌日", "車輛使用人", "車輛使用人電話", "車輛使用人地址"]
    var carList = ["請選擇車型", "找不到車型請選我"]
    
    //資料
    var plate_number = ""
    var date = ""
    var car_owner = ""
    var VIN = ""
    var model_no = ""
    var other_car = ""
    var authday = ""
    var user_name = ""
    var user_tel = ""
    var user_address = ""
    
    //本地資料
    var l_plate_number = ""
    var l_date = ""
    var l_car_owner = ""
    var l_VIN = ""
    var l_model_no = ""
    var l_other_car = ""
    var l_authday = ""
    var l_user_name = ""
    var l_user_tel = ""
    var l_user_address = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setFooter()
        addSlideMenuButton()
        setBackgroundColor()
        clearBackTitle()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorStyle = .none
        
        count = add
        
        //pickerview出現後上方的bar條
        toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.barStyle = UIBarStyle.blackTranslucent
        toolBar.tintColor = UIColor.white
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.donePressed(sender:)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        toolBar.setItems([flexSpace, flexSpace, flexSpace, flexSpace, doneButton], animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getCarList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCarList() {
        
        let brand = GlobalVar.mode == "skoda" ? "2" : "1"
        
        Public.getRemoteData("\(GlobalVar.serverIp)api/v1/car/model_list", parameters: ["brand" : brand as AnyObject]) { (response, error) in
            if error {
                
            } else {
                self.carListData = response["result"]
                
                for i in 0..<self.carListData.count {
                    self.carList.append(self.carListData[i]["model"].stringValue)
                }
            }
        }
    }
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        
        if sender.tag == 6 {
            dateFormatter.dateFormat = "YYYY-MM-dd"
            authday = dateFormatter.string(from: sender.date)
        } else {
            dateFormatter.dateFormat = "YYYY-MM"
            date = dateFormatter.string(from: sender.date)
        }
    }
    
    @objc func donePressed(sender: UIBarButtonItem) {
        tableView.reloadData()
        
        self.view.endEditing(true)
        
    }
    
    @objc func sendData() {
        view.endEditing(true)
        
        let data_1 = [plate_number, date, car_owner]
        let explanation_1 = ["車牌號碼", "出廠年月(日期可無視)", "牌照登記人"]
        
        guard Public.checkParameters(self, data: data_1, Explanation: explanation_1) else {
            return
        }
        
//        if plate_number == "" {
//            Public.displayAlert(self, title: "提醒！", message: "請輸入車牌號碼")
//            return
//        }
//        if date == "" {
//            Public.displayAlert(self, title: "提醒！", message: "請選擇出廠年月(日期可無視)")
//            return
//        }
//        if car_owner == "" {
//            Public.displayAlert(self, title: "提醒！", message: "請輸入牌照登記人")
//            return
//        }
        
        var parameters = [
            "user_id": GlobalVar.user_id,
            "plate_number": plate_number,
            "date": date,
            "car_owner": car_owner]
        
        if defaultApi == "api/v1/car/Add/Record" {
            
            let data_2 = [VIN, authday, user_name, user_tel, user_address]
            let explanation_2 = ["車身號碼", "領牌日", "車輛使用人", "車輛使用人電話", "車輛使用人地址"]
            
            guard Public.checkParameters(self, data: data_2, Explanation: explanation_2) else {
                return
            }
            
            if model_no == "" ||  model_no == "請選擇車款"{
                Public.displayAlert(self, title: "提醒！", message: "請選擇車款")
                return
            } else {
                parameters.updateValue(model_no, forKey: "model_no")
            }
            if model_no == "0" && other_car == "" {
                Public.displayAlert(self, title: "提醒！", message: "請輸入車款")
                return
            } else {
                parameters.updateValue(other_car, forKey: "other_car")
            }
            
            parameters.updateValue(VIN, forKey: "VIN")
            parameters.updateValue(authday, forKey: "authday")
            parameters.updateValue(user_name, forKey: "user_name")
            parameters.updateValue(user_tel, forKey: "user_tel")
            parameters.updateValue(user_address, forKey: "user_address")
            
            
        }
        
        print(parameters)
        
        Public.getRemoteData("\(GlobalVar.serverIp)\(defaultApi)", parameters: parameters as [String : AnyObject]) { (response, error) in

            if error {
                Public.displayAlert(self, title: "提醒", message: response["Msg"].stringValue)
            } else {
                let alert = UIAlertController(title: "提醒", message: response["Msg"].stringValue, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction((UIAlertAction(title: "確認", style: .default, handler: {(action) -> Void in
                    self.navigationController?.popToRootViewController(animated: true)
                })))
                self.present(alert, animated: true, completion: nil)
            }
            
        }
    }
    
    @IBAction func segmentValueChange(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            count = add
            defaultApi = "api/v1/car/Add/Record"
            tableView.reloadData()
            break
        case 1:
            count = binding
            defaultApi = "api/v1/car/Binding"
            tableView.reloadData()
            break
        default:
            break
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

extension AddAndBindingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == count.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! AddAndBindingViewControllerCell
            
            cell.submit.addTarget(self, action: #selector(self.sendData), for: .touchUpInside)
            cell.backgroundColor = UIColor.clear
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AddAndBindingViewControllerCell
            cell.input.placeholder = count[indexPath.row]
            
            if indexPath.row == 1 || indexPath.row == 6 {
                let datePickerView:UIDatePicker = UIDatePicker()
                datePickerView.tag = indexPath.row
                datePickerView.datePickerMode = .date
                datePickerView.addTarget(self, action: #selector(self.datePickerValueChanged(sender:)), for: UIControlEvents.valueChanged)
                cell.input.inputView = datePickerView
                cell.input.inputAccessoryView = toolBar
                
                if indexPath.row == 1 && date != "" {
                    cell.input.text = date
                }
                
                if indexPath.row == 6 && authday != "" {
                    cell.input.text = authday
                }
            } else if indexPath.row == 4 {
                let pickerView = UIPickerView()
                pickerView.delegate = self
                pickerView.tag = indexPath.row
                cell.input.inputView = pickerView
                cell.input.inputAccessoryView = toolBar
                
                if l_model_no != "" {
                    cell.input.text = l_model_no
                }
            } else {
                cell.input.delegate = self
                cell.input.tag = indexPath.row
            }
            
            cell.backgroundColor = UIColor.clear
            return cell
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == count.count {
            return 70.0
        } else if indexPath.row == 5 && !self.isShow {
            return 0
        } else {
            return 44.0
        }
    }
}

extension AddAndBindingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
        
        print(textField.text!)
        switch(textField.tag) {
        case 0:
            plate_number = textField.text!
        case 2:
            car_owner = textField.text!
        case 3:
            VIN = textField.text!
        case 5:
            other_car = textField.text!
        case 6:
            authday = textField.text!
        case 7:
            user_name = textField.text!
        case 8:
            user_tel = textField.text!
        case 9:
            user_address = textField.text!
        default:
            print("none")
        }
    }
}

extension AddAndBindingViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return carList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return carList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.l_model_no = carList[row]
        
        if carList[row] == "請選擇車型" || carList[row] == "找不到車型請選我" {
            self.model_no = "0"
        } else {
            self.model_no = self.carListData[row - 2]["id"].stringValue
        }
        
        if row == 1 {
            self.isShow = true
        } else {
            self.isShow = false
            self.other_car = ""
        }
    }
}
