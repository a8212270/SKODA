//
//  SignAndLoginViewController.swift
//  SKODA
//
//  Created by 孫 鈺驊 on 2017/10/2.
//  Copyright © 2017年 孫 鈺驊. All rights reserved.
//

import UIKit

class SignAndLoginViewControllerCell: UITableViewCell {
    @IBOutlet weak var input: UITextField!
    @IBOutlet weak var submit: UIButton!
    @IBOutlet weak var cancel: UIButton!
}

class SignAndLoginViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var count = [String]()
    var toolBar:UIToolbar!
    var placeholder = ["郵件", "密碼", "密碼確認", "車主姓名", "手機", "性別"]
    var placeholder_login = ["郵件", "密碼"]
    var pickerViewList = ["請選擇性別", "男", "女"]
    var defaultApi = "api/v1/member/Register/Member"
    
    //資料
    var user_name = ""
    var password = ""
    var password_confirm = ""
    var email = ""
    var phone = ""
    var token = ""
    var gender = ""
    var s_gender = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorStyle = .none
        
        count = placeholder
        
        setFooter()
        setBackgroundColor()
        
        //pickerview出現後上方的bar條
        toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.barStyle = UIBarStyle.blackTranslucent
        toolBar.tintColor = UIColor.white
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.donePressed(sender:)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        toolBar.setItems([flexSpace, flexSpace, flexSpace, flexSpace, doneButton], animated: true)
        
        self.navigationItem.title = "登入/註冊"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func sendData() {
        self.view.endEditing(true)
        var parameters = [
            "password": password,
            "email": email,
            "token": token,
            "birth": "1991-01-01"]
        
        if defaultApi == "api/v1/member/Register/Member" {
            
            if password != password_confirm {
                Public.displayAlert(self, title: "提醒！", message: "密碼與密碼確認不符")
                return
            }
            
            if password.characters.count < 5 {
                Public.displayAlert(self, title: "提醒！", message: "密碼長度過短，必須大於五位數")
                return
            }
            
            
            if user_name == "" {
                Public.displayAlert(self, title: "提醒！", message: "請輸入姓名")
                return
            } else {
                parameters.updateValue(user_name, forKey: "user_name")
            }
            if phone == "" {
                Public.displayAlert(self, title: "提醒！", message: "請輸入電話")
                return
            } else {
                parameters.updateValue(phone, forKey: "phone")
            }
            if s_gender == "" {
                Public.displayAlert(self, title: "提醒！", message: "請選則性別")
                return
            } else {
                parameters.updateValue(s_gender, forKey: "gender")
            }
        }
        
        print(parameters)
        
        Public.getRemoteData("\(GlobalVar.serverIp)\(defaultApi)", parameters: parameters as [String : AnyObject]) { (response, error) in
            print(response)
            if error {
                Public.displayAlert(self, title: "提醒！", message: response["Msg"].stringValue)
                return
            } else {
                GlobalVar.user_id = response["result"]["user_id"].stringValue
                let defaults = UserDefaults.standard
                defaults.setValue(response["result"]["user_id"].stringValue, forKey: "id")
                defaults.setValue(response["result"]["username"].stringValue, forKey: "name")
                
                self.performSegue(withIdentifier: "mainView", sender: self)
            }
        }
    }
    
    @objc func donePressed(sender: UIBarButtonItem) {
        
        tableView.reloadData()
        
        self.view.endEditing(true)
        
    }
    
    @objc func cancaelPressed(sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func segmentValueChange(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            count = placeholder
            defaultApi = "api/v1/member/Register/Member"
            tableView.reloadData()
            break
        case 1:
            count = placeholder_login
            defaultApi = "api/v1/member/Login/Member"
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

extension SignAndLoginViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.row == count.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! SignAndLoginViewControllerCell
            
            cell.submit.addTarget(self, action: #selector(self.sendData), for: .touchUpInside)
            cell.cancel.addTarget(self, action: #selector(self.cancaelPressed), for: .touchUpInside)
            cell.backgroundColor = UIColor.clear
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SignAndLoginViewControllerCell
            
            
            if indexPath.row != 5 {
                cell.input.delegate = self
                cell.input.tag = indexPath.row
            } else {
                let pickerView = UIPickerView()
                pickerView.delegate = self
                pickerView.tag = indexPath.row
                cell.input.inputView = pickerView
                cell.input.inputAccessoryView = toolBar
            }
            
            cell.input.placeholder = placeholder[indexPath.row]
            
            
            if indexPath.row == 1 || indexPath.row == 2 {
                cell.input.isSecureTextEntry = true
            }
            
            if indexPath.row == 0 && (email != "") {
                cell.input.text = email
            }
            
            if indexPath.row == 1 && (password != "") {
                cell.input.text = password
            }
            
            if indexPath.row == 2 && (password_confirm != "") {
                cell.input.text = password_confirm
            }
            
            if indexPath.row == 3 && (user_name != "") {
                cell.input.text = user_name
            }
            
            if indexPath.row == 4 && (phone != "") {
                cell.input.text = phone
            }
            
            if indexPath.row == 5 && (gender != "" || gender != "請選擇性別") {
                cell.input.text = gender
            }
            
            cell.backgroundColor = UIColor.clear
            
            return cell
        }
        
        
    }
}

extension SignAndLoginViewController: UITextFieldDelegate {
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
            email = textField.text!
        case 1:
            password = textField.text!
        case 2:
            password_confirm = textField.text!
        case 3:
            user_name = textField.text!
        case 4:
            phone = textField.text!
        case 5:
            gender = textField.text!
        default:
            print("none")
        }
    }
}

extension SignAndLoginViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        return pickerViewList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return pickerViewList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        gender = pickerViewList[row]
        
        if row == 1 {
            s_gender = "1"
        } else {
            s_gender = "2"
        }
    }
}
