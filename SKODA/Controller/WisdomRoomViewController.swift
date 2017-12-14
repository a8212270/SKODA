//
//  WisdomRoomViewController.swift
//  SKODA
//
//  Created by 孫 鈺驊 on 2017/10/10.
//  Copyright © 2017年 孫 鈺驊. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation
import CoreBluetooth

class WisdomRoomViewController: BaseViewController {
    
    var btCenteralManager: CBCentralManager?
    var locationManager: CLLocationManager!
    var beacons = [CLBeacon]()
    var beaconRegion:CLBeaconRegion!
    var alrController = UIAlertController()
    var beaconData:JSON! = []
    
    var count = 0
    var beacon_id = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addSlideMenuButton()
        setBackgroundColor()
        setFooter()
        clearBackTitle()
        
        let uuidString = "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"
        let beaconIdentifier = "+Beacon"
        let beaconUUID:NSUUID = NSUUID(uuidString: uuidString)!
        beaconRegion = CLBeaconRegion(proximityUUID: beaconUUID as UUID,
                                      identifier: beaconIdentifier)
        
        locationManager = CLLocationManager()
        
        if(locationManager!.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization))) {
            locationManager!.requestWhenInUseAuthorization()
        }
        
        locationManager!.delegate = self
        locationManager!.pausesLocationUpdatesAutomatically = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        btCenteralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager!.stopMonitoring(for: beaconRegion)
        locationManager!.stopRangingBeacons(in: beaconRegion)
        locationManager!.stopUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getWisdomData() {
        
        let beacon:CLBeacon = beacons[0]
        self.beacon_id = beacon.minor.intValue

//        var closestBeacon: CLBeacon? = beacons[0]
//        for beacon in beacons {
//            if beacon.rssi < 0 && closestBeacon != nil && beacon.rssi > closestBeacon!.rssi {
//                print("here")
//                closestBeacon = beacon as? CLBeacon
//            }
//
//        }
//        print(closestBeacon)
//        self.beacon_id = (closestBeacon?.minor.intValue)!
        
//        if beacon.rssi < -60 {
//            Public.displayAlert(self, title: "Oops!", message: "請再靠近一點！\n再試一次！")
//            return
//        }
        
        Public.getRemoteData("\(GlobalVar.serverIp)api/v1/getWisdomExpo", parameters: ["beacon_id": self.beacon_id as AnyObject]) { (response, error) in
            Public.progressBarDisplayer(self.view, indicator: false)
            print(response)
            if error {
                Public.displayAlert(self, title: "提醒！", message: response["Msg"].stringValue)
            } else {
                self.beaconData = response["result"]
                self.alrController = UIAlertController(title: "請選擇查看車款 \n\n\n\n\n\n\n", message: nil, preferredStyle: .alert)
                
                let margin:CGFloat = 8.0
                let rect = CGRect(x: margin, y: margin * 6, width: self.alrController.view.frame.width * 0.68, height: 150.0)
                let tableView = UITableView(frame: rect)
                tableView.delegate = self
                tableView.dataSource = self
                tableView.backgroundColor = UIColor.clear
                tableView.tableFooterView = UIView(frame: CGRect.zero)
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
                self.alrController.view.addSubview(tableView)
                
                let cancelAction = UIAlertAction(title: "不用了，謝謝", style: .cancel, handler: {(action) -> Void in
                    self.navigationController?.popToRootViewController(animated: true)
                })

                self.alrController.addAction(cancelAction)
                
                self.present(self.alrController, animated: true, completion:{})
//                let alert = UIAlertController(title: "Welcome!", message: "在您身旁的是\n \(response["result"]["model_name"].stringValue) \n 需要為您介紹嗎？", preferredStyle: UIAlertControllerStyle.alert)
//
//                alert.addAction((UIAlertAction(title: "確認", style: .default, handler: {(action) -> Void in
//                    let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "wisdomRoomShow") as! WisdomRoomShowViewController
//
//                    popOverVC.titlePicUrl = response["result"]["titlePic"].stringValue
//
//                    popOverVC.picUrls = response["result"]["pics"].arrayValue
//
//                    self.navigationController?.pushViewController(popOverVC, animated: true)
//
//                })))
//
//                alert.addAction(UIAlertAction(title: "不用了，謝謝", style: .cancel, handler: {(action) -> Void in
//                    self.navigationController?.popToRootViewController(animated: true)
//                }))
//                self.present(alert, animated: true, completion: nil)
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

extension WisdomRoomViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        let knownBeacons = beacons.filter{ $0.proximity != CLProximity.unknown }
        self.beacons = knownBeacons
        
//        print(self.beacons)
        count = count + 1
        if self.beacons.count > 0 {
            locationManager!.stopMonitoring(for: beaconRegion)
            locationManager!.stopRangingBeacons(in: beaconRegion)
            locationManager!.stopUpdatingLocation()
            getWisdomData()
        } else if count >= 5 {
            count = 0
            Public.displayAlert(self, title: "Oops!", message: "附近沒有發現任何iBeacon裝置")
            locationManager!.stopMonitoring(for: beaconRegion)
            locationManager!.stopRangingBeacons(in: beaconRegion)
            locationManager!.stopUpdatingLocation()
            Public.progressBarDisplayer(self.view, indicator: false)
        }
    }
    
}

extension WisdomRoomViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.beaconData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as
        UITableViewCell
        
        cell.textLabel?.text = self.beaconData[indexPath.row]["model_name"].stringValue
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        alrController.dismiss(animated: true, completion: nil)
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "wisdomRoomShow") as! WisdomRoomShowViewController
        
        popOverVC.titlePicUrl = self.beaconData[indexPath.row]["titlePic"].stringValue
        
        popOverVC.picUrls = self.beaconData[indexPath.row]["pics"].arrayValue
        
        self.navigationController?.pushViewController(popOverVC, animated: true)

    }
}

extension WisdomRoomViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("on")
        case .poweredOff:
            print("off")
        case .resetting:
            print("resetting")
        case .unknown:
            print("unknown")
        case .unauthorized:
            print("unknown")
        case .unsupported:
            print("unsupported")
            Public.displayAlert(self, title: "提醒", message: "此裝置不支援藍牙功能")
        }
        
        if central.state == .poweredOn {
            Public.progressBarDisplayer(self.view, indicator: true)
            locationManager!.startMonitoring(for: beaconRegion)
            locationManager!.startRangingBeacons(in: beaconRegion)
            locationManager!.startUpdatingLocation()
        }
        
        if central.state == .poweredOff {
            let alertController = UIAlertController (title: "提醒", message: "請開啟藍芽功能", preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: "設定", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.openURL(URL(string:"App-Prefs:root=Bluetooth")!)
                }
            }
            alertController.addAction(settingsAction)
            let cancelAction = UIAlertAction(title: "確定", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
        }
    }
}
