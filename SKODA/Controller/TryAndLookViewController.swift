//
//  TryAndLookViewController.swift
//  SKODA
//
//  Created by 孫 鈺驊 on 2017/9/28.
//  Copyright © 2017年 孫 鈺驊. All rights reserved.
//

import UIKit
import SwiftyJSON

class TryAndLookViewControllerCell: UITableViewCell {
    @IBOutlet weak var input: UITextField!
    @IBOutlet weak var submit: UIButton!
    @IBOutlet weak var cancel: UIButton!
}

class TryAndLookViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleImg: UIImageView!
    
    var pickerViewList = [String]()
    var toolBar:UIToolbar!
    var carList:JSON = []
    var allCar = ["請選擇車款"]
    
    let placeholders = ["目前車款", "車齡", "性別", "姓名", "電話", "請選擇試駕車款", "請選擇展示地點", "方便聯繫時間"]
    let sk_maintenances = ["請選擇展示地點", "SKODA 中和新車銷售據點", "SKODA 新莊新車銷售據點"]
    let d_sk_maintenances = ["", "1", "2"]
    let vw_maintenances = ["請選擇展示地點", "VW LCV 土城服務廠"]
    let d_vw_maintenances = ["", "4"]
    let times = ["請選擇聯繫時間", "8:30", "9:30", "10:30", "11:30", "13:30", "14:30", "15:30"]
    let d_times = ["", "1", "2", "3", "4", "5", "6", "7"]
    let genders = ["請選擇性別", "男", "女"]
    let d_genders = ["0", "1", "2"]
    
    //顯示資料
    var time = ""
    var maintenance = ""
    var testCar = ""
    var gender = ""
    
    //傳送資料
    var d_time = ""
    var d_age = ""
    var d_model_id = ""
    var d_maintenance_plant_no = ""
    var d_nowdrive = ""
    var d_name = ""
    var d_tel = ""
    var d_gender = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addSlideMenuButton()
        setFooter()
        setBackgroundColor()
        clearBackTitle()
        self.navigationItem.title = "預約試駕"
        
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
        getTestCarList()
        
        if GlobalVar.mode == "skoda" {
            titleImg.image = UIImage(named: "testDrive")
        } else {
            titleImg.image = UIImage(named: "testDrive_vw")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func donePressed(sender: UIBarButtonItem) {
    
        tableView.reloadData()
        
        self.view.endEditing(true)
        
    }
    
    func getTestCarList() {
        
        let brand = GlobalVar.mode == "skoda" ? "2" : "1"
        
        let parameters = ["brand": brand]
        
        Public.getRemoteData("\(GlobalVar.serverIp)api/v1/testdrive/model_list", parameters: parameters as [String : AnyObject]) { (response, error) in
            print(response)
            if error {
                
            } else {
                self.carList = response["result"]
                for i in 0..<self.carList.count {
                    self.allCar.append(self.carList[i]["model"].stringValue)
                }
            }
        }
    }
    
    @objc func submitTestCarData() {
        
        guard Public.checkParameters(self, data: [d_nowdrive, d_age, d_model_id, d_maintenance_plant_no, d_time], Explanation: ["目前車款", "車齡", "試駕車款", "地點", "時間"]) else { return }
    
        let d_type = GlobalVar.user_id == "0" ? "0" : "1"
        
        var parameters = [
            "type": d_type,
            "nowdrive": d_nowdrive,
            "age": d_age,
            "model_id": d_model_id,
            "maintenance_plant_no": d_maintenance_plant_no,
            "time": d_time]
        
        if GlobalVar.user_id == "0" {

            guard Public.checkParameters(self, data: [d_name, d_tel, d_gender], Explanation: ["姓名", "電話", "性別"]) else { return }
            
            parameters.updateValue(d_name, forKey: "name")
            parameters.updateValue(d_tel, forKey: "tel")
            parameters.updateValue(d_gender, forKey: "gender")

        }
        
        print(parameters)
        
        Public.getRemoteData("\(GlobalVar.serverIp)api/v1/testdrive/Add", parameters: parameters as [String : AnyObject]) { (response, error) in
            print(response)
            if error {

            } else {
                let alert = UIAlertController(title: "提醒", message: "預約成功", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction((UIAlertAction(title: "確認", style: .default, handler: {(action) -> Void in
                    self.navigationController?.popToRootViewController(animated: true)
                })))
                self.present(alert, animated: true, completion: nil)
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

extension TryAndLookViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeholders.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.row == placeholders.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! TryAndLookViewControllerCell
            
            cell.submit.addTarget(self, action: #selector(self.submitTestCarData), for: .touchUpInside)
            cell.backgroundColor = UIColor.clear
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TryAndLookViewControllerCell
            
            cell.input.placeholder = placeholders[indexPath.row]
            
            if indexPath.row == 5 || indexPath.row == 6 || indexPath.row == 7 || indexPath.row == 2 {
                let pickerView = UIPickerView()
                pickerView.delegate = self
                pickerView.tag = indexPath.row
                cell.input.inputView = pickerView
                cell.input.inputAccessoryView = toolBar
                
                if indexPath.row == 2 && (gender != "" || gender != "請選擇性別") {
                    cell.input.text = gender
                }

                if indexPath.row == 5 && (testCar != "" || testCar != "請選擇試駕車款") {
                    cell.input.text = testCar
                }
                
                if indexPath.row == 6 && (maintenance != "" || maintenance != "請選擇展示地點") {
                    cell.input.text = maintenance
                }
                
                if indexPath.row == 7 && (time != "" || time != "請選擇聯繫時間"){
                    cell.input.text = time
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
        if indexPath.row == placeholders.count {
            return 70.0
        } else if GlobalVar.user_id != "0" {
            if indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 4 {
                return 0
            } else {
                return 44.0
            }
        } else {
            return 44.0
        }
    }
}

extension TryAndLookViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerView.tag {
        case 2:
            pickerViewList = genders
        case 5:
            pickerViewList = allCar
        case 6:
            if GlobalVar.mode == "skoda" {
                pickerViewList = sk_maintenances
            } else {
                pickerViewList = vw_maintenances
            }
        case 7:
            pickerViewList = times
        default:
            pickerViewList = []
        }
        
        return pickerViewList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch pickerView.tag {
        case 2:
            pickerViewList = genders
        case 5:
            pickerViewList = allCar
        case 6:
            if GlobalVar.mode == "skoda" {
                pickerViewList = sk_maintenances
            } else {
                pickerViewList = vw_maintenances
            }
        case 7:
            pickerViewList = times
        default:
            pickerViewList = []
        }
        
        return pickerViewList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 2:
            gender = pickerViewList[row]
            d_gender = d_genders[row]
        case 5:
            testCar = pickerViewList[row]
            d_model_id = carList[row - 1]["id"].stringValue
        case 6:
            maintenance = pickerViewList[row]
            if GlobalVar.mode == "skoda" {
                d_maintenance_plant_no = d_sk_maintenances[row]
            } else {
                d_maintenance_plant_no = d_vw_maintenances[row]
            }
        case 7:
            time = pickerViewList[row]
            d_time = d_times[row]
        default:
            break
        }
    }
}

extension TryAndLookViewController: UITextFieldDelegate {
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
            d_nowdrive = textField.text!
        case 1:
            d_age = textField.text!
        case 2:
            d_gender = textField.text!
        case 3:
            d_name = textField.text!
        case 4:
            d_tel = textField.text!
        default:
            print("none")
        }
    }
}
