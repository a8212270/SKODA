//
//  WisdomRoomShowViewController.swift
//  SKODA
//
//  Created by 孫 鈺驊 on 2017/11/14.
//  Copyright © 2017年 孫 鈺驊. All rights reserved.
//

import UIKit
import SwiftyJSON
import AlamofireImage

class WisdomRoomShowViewController: BaseViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var titlePic: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var psgeControl: UIPageControl!
    
    var titlePicUrl = ""
    var pic1Url = ""
    var pic2Url = ""
    var pic3Url = ""
    
    var picUrls = [JSON]()
    
//    var imgCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addSlideMenuButton()
        setBackgroundColor()
        setFooter()
        
        titlePic.af_setImage(withURL: URL(string: titlePicUrl)!)
        
        load()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func load() {
        for index in 0 ..< picUrls.count {
            // 5.1.声明一个UIImageView
            let imageView: UIImageView = UIImageView()
            // 5.2.设置UIImageView的Frame
            imageView.frame = CGRect(x: CGFloat(index) * scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.height)
            
            let url = URL(string: picUrls[index]["pic"].stringValue)
            imageView.af_setImage(withURL: url!)
            
            scrollView.addSubview(imageView)
        }
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(picUrls.count), height: 0)
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
        
        
        psgeControl.numberOfPages = picUrls.count
        // Schedule a timer to auto slide to next page
        //timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(ViewController.moveToNextPage), userInfo: nil, repeats: true
    }
    
    @objc func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = 0
        let width = scrollView.frame.width
//        let offsetX = scrollView.contentOffset.x

//        if offsetX == 0 {
//            scrollView.contentOffset = CGPoint(x: width * CGFloat(imgCount), y: 0)
//        }
//        if offsetX == width * CGFloat(imgCount) {
//            scrollView.contentOffset = CGPoint(x: width, y: 0)
//        }

        let currentPage = scrollView.contentOffset.x / width
        self.psgeControl.currentPage = Int(currentPage)
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
