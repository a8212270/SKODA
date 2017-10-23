//
//  OrderViewController.swift
//  SKODA
//
//  Created by 孫 鈺驊 on 2017/9/28.
//  Copyright © 2017年 孫 鈺驊. All rights reserved.
//

import UIKit
import SwiftyJSON
import AlamofireImage

class OrderViewControllerCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
}

class OrderViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var data:JSON! = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addSlideMenuButton()
        setFooter()
        clearBackTitle()
        self.navigationItem.title = "預約保養"
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getCarListData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCarListData() {
        
        let parameters = ["user_id": GlobalVar.user_id]
        
        Public.getRemoteData("\(GlobalVar.serverIp)api/v1/car/List", parameters: parameters as [String : AnyObject]) { (response, error) in
            if error {
                print("error")
            } else {
                self.data = response["result"]
                self.collectionView.reloadData()
            }
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
//        if segue.identifier == "OrderDetail" {
//            let destinationController = segue.destination as! OrderDetailViewController
//            destinationController
//        }
    }
 

}

extension OrderViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + self.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! OrderViewControllerCell
        
        if indexPath.row == 0 {
            cell.image.image = UIImage(named: "add")
        } else {
            cell.image.af_setImage(withURL: URL(string: self.data[indexPath.row - 1]["img"].stringValue)!)
            cell.image.contentMode = .scaleAspectFit
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            performSegue(withIdentifier: "AddAndBinding", sender: self)
        } else {
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OrderDetailViewController") as! OrderDetailViewController
            
            popOverVC.carImgUrl = self.data[indexPath.row - 1]["img"].stringValue
            popOverVC.car_model = self.data[indexPath.row - 1]["model"].stringValue
            popOverVC.plate_number = self.data[indexPath.row - 1]["plate_number"].stringValue
            popOverVC.s_car_no = self.data[indexPath.row - 1]["id"].stringValue
            
            self.navigationController?.pushViewController(popOverVC, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let width = (ScreenSize.SCREEN_WIDTH / 2) - 20
        let height = width
        return CGSize(width: width, height: height);
    }
}