//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit
import GoogleMobileAds

class MeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, GADInterstitialDelegate {
    
    var tableView:UITableView!
    var dataArray = NSMutableArray()
    var Id:String = ""
    var numLeft: String = ""
    var numMiddel: String = ""
    var numRight: String = ""
    var labelNav = UILabel()
    
    var interstitial: GADInterstitial!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
        setupRefresh()
    }
    
    @objc func noticeShare() {
        self.tableView.headerBeginRefreshing()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "noticeShare"), object:nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "Letter"), object: nil)
        navShow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(MeViewController.noticeShare), name: NSNotification.Name(rawValue: "noticeShare"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MeViewController.Letter(_:)), name: NSNotification.Name(rawValue: "Letter"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navHide()
        self.navigationController!.interactivePopGestureRecognizer!.isEnabled = false
        load()
    }
    
    @objc func Letter(_ noti: Notification) {
        self.load()
    }
    
    func setupViews() {
        let navView = UIView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: 64))
        navView.backgroundColor = UIColor.NavColor()
        labelNav.frame = CGRect(x: 0, y: 20, width: globalWidth, height: 44)
        labelNav.textColor = UIColor.white
        labelNav.font = UIFont.systemFont(ofSize: 17)
        labelNav.text = "消息"
        labelNav.textAlignment = NSTextAlignment.center
        navView.addSubview(labelNav)
        self.view.addSubview(navView)
        
        self.tableView = UITableView(frame:CGRect(x: 0, y: 64, width: globalWidth, height: globalHeight - 64 - 49))
        self.tableView!.delegate = self;
        self.tableView!.dataSource = self;
        self.tableView!.backgroundColor = BGColor
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.none
        let nib = UINib(nibName:"LetterCell", bundle: nil)
        let nib2 = UINib(nibName:"MeCellTop", bundle: nil)
        
        self.tableView!.register(nib, forCellReuseIdentifier: "LetterCell")
        self.tableView!.register(nib2, forCellReuseIdentifier: "MeCellTop")
        self.tableView!.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: 20))
        self.view.addSubview(self.tableView!)
        let a = UIView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: 300))
        let b = UIView(frame: CGRect(x: (globalWidth - 120) / 2, y: 180, width: 120, height: 120))
        b.backgroundColor = UIColor.green
        b.isUserInteractionEnabled = true
        b.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onAd)))
        a.addSubview(b)
        a.backgroundColor = UIColor.yellow
        self.tableView!.tableFooterView = a
        
        interstitial = createAndLoadInterstitial()
        let request = GADRequest()
        interstitial.load(request)
    }
    
    @objc func onAd() {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
//            self.tableView!.tableFooterView = nil
        }
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-4401117476228272/8783898267")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }
    
    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }

    
    func SALoadData() {
        Api.postLetter() { json in
            self.tableView.headerEndRefreshing()
            if json != nil {
                if let data = json as? NSDictionary {
                    self.numLeft = data.stringAttributeForKey("notice_reply")
                    self.numMiddel = data.stringAttributeForKey("notice_like")
                    self.numRight = data.stringAttributeForKey("notice_news")
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func load(){
        self.dataArray.removeAllObjects()
        back {
            self.tableView.reloadData()
        }
    }
    
    @objc func onBtnGoClick() {
        let LikeVC = LikeViewController()
        LikeVC.Id = SAUid()
        LikeVC.urlIdentify = 1
        self.navigationController!.pushViewController(LikeVC, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            return self.dataArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath as NSIndexPath).section == 0 {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let data = self.dataArray[(indexPath as NSIndexPath).row] as! NSDictionary
        let id = data.stringAttributeForKey("id")
//        RCIMClient.shared().clearMessages(RCConversationType.ConversationType_PRIVATE, targetId: id)
//        RCIMClient.shared().remove(RCConversationType.ConversationType_PRIVATE, targetId: id)
        load()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MeCellTop", for: indexPath) as? MeCellTop
            cell!.numLeft.text = self.numLeft
            cell!.numMiddle.text = self.numMiddel
            cell!.numRight.text = self.numRight
            cell!.numLeft.setColorful()
            cell!.numMiddle.setColorful()
            cell!.numRight.setColorful()
            cell!.viewLeft.tag = 1
            cell!.viewMiddle.tag = 2
            cell!.viewRight.tag = 3
            cell!.viewLeft.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MeViewController.onTopClick(_:))))
            cell!.viewMiddle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MeViewController.onTopClick(_:))))
            cell!.viewRight.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MeViewController.onTopClick(_:))))
            return cell!
        }else{
            let c: LetterCell! = tableView.dequeueReusableCell(withIdentifier: "LetterCell", for: indexPath) as? LetterCell
            if dataArray.count > (indexPath as NSIndexPath).row {
                c.data = dataArray[(indexPath as NSIndexPath).row] as! NSDictionary
                c.setup()
            }
            return c
        }
    }
    
    @objc func onTopClick(_ sender: UIGestureRecognizer) {
        let MeNextVC = MeNextViewController()
        
        if let tag = sender.view?.tag {
            if tag == 1 {
                self.numLeft = "0"
                MeNextVC.msgType = "reply"  /* 回应 */
            }else if tag == 2 {
                self.numMiddel = "0"
                MeNextVC.msgType = "like"  /* 按赞 */
            }else if tag == 3 {
                self.numRight = "0"
                MeNextVC.msgType = "notify" /* 通知 */
            }
            MeNextVC.tag = tag
            self.navigationController?.pushViewController(MeNextVC, animated: true)
        }
        if let v = sender.view {
            let views:NSArray = v.subviews as NSArray
            for view in views {
                if NSStringFromClass((view as AnyObject).classForCoder) == "UILabel"  {
                    let l = view as! UILabel
                    if l.frame.origin.y == 25 {
                        l.text = "0"
                        l.textColor = UIColor.black
                    }
                }
            }
        }
    }
    
    func onUserClick(_ sender:UIGestureRecognizer) {
        let tag = sender.view!.tag
        let UserVC = PlayerViewController()
        UserVC.Id = "\(tag)"
        self.navigationController?.pushViewController(UserVC, animated: true)
    }
    
    func onDreamClick(_ sender:UIGestureRecognizer){
        let tag = sender.view!.tag
        let dreamVC = DreamViewController()
        dreamVC.Id = "\(tag)"
        self.navigationController!.pushViewController(dreamVC, animated: true)
    }
    
    func userclick(_ sender:UITapGestureRecognizer){
        let UserVC = PlayerViewController()
        UserVC.Id = "\(sender.view!.tag)"
        self.navigationController!.pushViewController(UserVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            return 75
        }else{
            return 81
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 1 {
            let data = self.dataArray[(indexPath as NSIndexPath).row] as! NSDictionary
            let mutableData = NSMutableDictionary(dictionary: data)
            mutableData.setValue("0", forKey: "unread")
            dataArray.replaceObject(at: (indexPath as NSIndexPath).row, with: mutableData)
            tableView.reloadData()
            let vc = CircleController()
            if let id = Int(data.stringAttributeForKey("id")) {
                let title = data.stringAttributeForKey("title")
                vc.id = id
                vc.name = title
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func setupRefresh() {
        self.tableView.addHeaderWithCallback {
            self.SALoadData()
        }
    }
}

extension UILabel {
    func setColorful(){
        if let content = Int(self.text!) {
            if content == 0 {
                self.textColor = UIColor.black
            }else{
                self.textColor = UIColor.HighlightColor()
            }
        }else{
            self.textColor = UIColor.black
        }
    }
}
