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
    @IBOutlet weak var label: UILabel!
}

class OrderViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarTopConstrait: NSLayoutConstraint!
    
    var data = [JSON]()
    var searchData = [JSON]()
    
    var isSearch = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addSlideMenuButton()
        setFooter()
        clearBackTitle()
        self.navigationItem.title = "預約保養"
        
        collectionView.delegate = self
        collectionView.dataSource = self
        searchBar.delegate = self
        
        searchBar.placeholder = "搜尋車牌..."
        
        searchBarTopConstrait.constant = 0
        addCollectionViewObserver()
        
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
                self.data = response["result"].arrayValue
                print(self.data)
                self.collectionView.reloadData()
            }
        }
    }
    
    func addCollectionViewObserver() {
        collectionView.addObserver(self, forKeyPath: "contentOffset", options: [.new, .old], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keypath = keyPath, keypath == "contentOffset", let collectionView = object as? UICollectionView {
            searchBarTopConstrait.constant = -1 * collectionView.contentOffset.y
        }
    }
    
    deinit {
        collectionView.removeObserver(self, forKeyPath: "contentOffset")
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
        if isSearch {
            return self.searchData.count
        } else {
            return 1 + self.data.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! OrderViewControllerCell
        
        if !isSearch {
            if indexPath.row == 0 {
                print("is 0")
                cell.image.image = UIImage(named: "add")
                cell.label.text = ""
            } else {
                cell.image.image = nil
                cell.image.af_setImage(withURL: URL(string: self.data[indexPath.row - 1]["img"].stringValue)!)
                cell.image.contentMode = .scaleAspectFit
                cell.label.text = "\(self.data[indexPath.row - 1]["plate_number"].stringValue) \n \(self.data[indexPath.row - 1]["model"].stringValue)"
            }
        } else {
            cell.image.image = nil
            cell.image.af_setImage(withURL: URL(string: self.searchData[indexPath.row]["img"].stringValue)!)
            cell.image.contentMode = .scaleAspectFit
            cell.label.text = "\(self.searchData[indexPath.row]["plate_number"].stringValue) \n \(self.searchData[indexPath.row]["model"].stringValue)"
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
            popOverVC.brand = self.data[indexPath.row - 1]["brand"].stringValue
            
            self.navigationController?.pushViewController(popOverVC, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: (self.searchBar.frame.height) + 10.0, left: 15.0, bottom: 10.0, right: 15.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let width = (ScreenSize.SCREEN_WIDTH / 2) - 20
        let height = width
        return CGSize(width: width, height: height);
    }
}

extension OrderViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            isSearch = false
        } else {
            isSearch = true
            searchData.removeAll()
            for a in data {
                let name = a["plate_number"].stringValue
                let model = a["model"].stringValue
                
                if name.lowercased().contains(searchText.lowercased()) || model.lowercased().contains(searchText.lowercased()) {
                    searchData.append(a)
                }
            }
        }
        
        self.collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        
        self.collectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
}
