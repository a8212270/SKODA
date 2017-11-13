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
}

class TryAndLookViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var pickerViewList = [String]()
    var toolBar:UIToolbar!
    var carList:JSON = []
    var allCar = [String]()
    
    let placeholders = ["目前車款", "車齡", "性別", "姓名", "電話", "請選擇試駕車款", "請選擇展示地點", "方便聯繫時間"]
    let sk_maintenances = ["請選擇展示地點", "SKODA 中和新車銷售據點", "SKODA 新莊新車銷售據點", "SKODA 中和服務廠"]
    let vw_maintenances = ["請選擇展示地點", "VW LCV 土城服務廠"]
    let times = ["請選擇聯繫時間", "8:30", "9:30", "10:30", "11:30", "12:30", "13:30", "14:30", "15:30"]
    
    //顯示資料
    var time = ""
    var maintenance = ""
    var testCar = ""

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
        
        let brand = GlobalVar.mode == "skoda" ? "1" : "2"
        
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
            cell.backgroundColor = UIColor.clear
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TryAndLookViewControllerCell
            
            cell.input.placeholder = placeholders[indexPath.row]
            
            if indexPath.row == 5 || indexPath.row == 6 || indexPath.row == 7 {
                let pickerView = UIPickerView()
                pickerView.delegate = self
                pickerView.tag = indexPath.row
                cell.input.inputView = pickerView
                cell.input.inputAccessoryView = toolBar

                if indexPath.row == 5 && (maintenance != "" || maintenance != "請選擇試駕車款") {
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
        case 5:
            testCar = pickerViewList[row]
        case 6:
            maintenance = pickerViewList[row]
        case 7:
            time = pickerViewList[row]
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
//        switch(textField.tag) {
//        case 0:
//            plate_number = textField.text!
//        case 2:
//            car_owner = textField.text!
//        case 3:
//            VIN = textField.text!
//        case 5:
//            other_car = textField.text!
//        case 6:
//            authday = textField.text!
//        case 7:
//            user_name = textField.text!
//        case 8:
//            user_tel = textField.text!
//        case 9:
//            user_address = textField.text!
//        default:
//            print("none")
//        }
    }
}
