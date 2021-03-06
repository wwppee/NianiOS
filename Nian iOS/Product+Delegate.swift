//
//  Product+Delegate.swift
//  Nian iOS
//
//  Created by Sa on 16/2/25.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

extension Product {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let y = scrollView.contentOffset.y
            imageHead.setY(max(-y, 0))
            viewCover.setY(globalWidth * 3/4 - y)
            let h = globalHeight - globalWidth * 3/4 + y
            viewCover.setHeight(max(h, 0))
        }
    }
    
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if type == ProductType.pro {
            let c: ProductCollectionCell! = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionCell", for: indexPath) as? ProductCollectionCell
            c.data = dataArray[(indexPath as NSIndexPath).row] as! NSDictionary
            c.setup()
            return c
        } else {
            /* 表情 */
            let c: ProductEmojiCollectionCell! = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductEmojiCollectionCell", for: indexPath) as? ProductEmojiCollectionCell
            c.data = dataArray[(indexPath as NSIndexPath).row] as! NSDictionary
            c.num = (indexPath as NSIndexPath).row
            c.imageView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(Product.onGif(_:))))
            c.setup()
            return c
        }
    }
    
    @objc func onGif(_ sender: UILongPressGestureRecognizer) {
        if let view = sender.view {
            let tag = view.tag
            let point = view.convert(view.frame.origin, from: scrollView)
            let x = -point.x
            let y = -point.y
            let xNew = max(x - 20, 0)
            let yNew = y - view.width() - 40 - 8
            let data = dataArray[tag] as! NSDictionary
            let image = data.stringAttributeForKey("image")
            viewEmojiHolder.qs_setGifImageWithURL(URL(string: image), progress: { (a, b) -> Void in
                }, completed: nil)
            viewEmojiHolder.frame = CGRect(x: xNew, y: yNew, width: view.width() + 50, height: view.width() + 50)
            viewEmojiHolder.isHidden = sender.state == UIGestureRecognizerState.ended ? true : false
            if sender.state == UIGestureRecognizerState.ended {
                viewEmojiHolder.animatedImage = nil
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func niAlert(_ niAlert: NIAlert, didselectAtIndex: Int) {
        /* 如果是支付方式选择界面 */
        if niAlert == self.niAlert {
            if type == ProductType.pro {
                if didselectAtIndex == 0 {
                    if let btn = niAlert.niButtonArray.firstObject as? NIButton {
                        btn.startAnimating()
                    }
                    
                    /** 商家向财付通申请的商家id */
                    Api.postWechatMember() { json in
                        if json != nil {
                            if let j = json as? NSDictionary {
                                let data = Data(base64Encoded: j.stringAttributeForKey("data"), options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
                                let base64Decoded = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                                let jsonString = base64Decoded?.data(using: String.Encoding.ascii.rawValue)
                                if let dataResult = try? JSONSerialization.jsonObject(with: jsonString!, options: JSONSerialization.ReadingOptions.allowFragments) {
                                    let request = PayReq()
                                    request.partnerId = (dataResult as AnyObject).stringAttributeForKey("partnerid")
                                    request.prepayId = (dataResult as AnyObject).stringAttributeForKey("prepayid")
                                    request.package = (dataResult as AnyObject).stringAttributeForKey("package")
                                    request.nonceStr = (dataResult as AnyObject).stringAttributeForKey("noncestr")
                                    
                                    let b = (dataResult as AnyObject).stringAttributeForKey("timestamp")
                                    let c = UInt32(b)
                                    request.timeStamp = c!
                                    request.sign = (dataResult as AnyObject).stringAttributeForKey("sign")
                                    WXApi.send(request)
                                }
                            }
                        }
                    }
                } else {
                    /* 支付宝购买念币 */
                    if let btn = niAlert.niButtonArray.lastObject as? NIButton {
                        btn.startAnimating()
                    }
                    Api.postAlipayMember() { json in
                        if json != nil {
                            if let j = json as? NSDictionary {
                                let data = j.stringAttributeForKey("data")
                                AlipaySDK.defaultService().payOrder(data, fromScheme: "nianalipay") { (resultDic) -> Void in
                                    let data = resultDic! as NSDictionary
                                    let resultStatus = data.stringAttributeForKey("resultStatus")
                                    if resultStatus == "9000" {
                                        /* 支付宝：支付成功 */
                                        self.payMemberSuccess()
                                    } else {
                                        /* 支付宝：支付失败 */
                                        self.payMemberCancel()
                                    }
                                }
                            }
                        }
                    }
                }
            } else if type == ProductType.emoji {
                /* 购买表情 */
                if didselectAtIndex == 0 {
                    if let btn = niAlert.niButtonArray.firstObject as? NIButton {
                        btn.startAnimating()
                    }
                    let code = data.stringAttributeForKey("code")
                    Api.postEmojiBuy(code) { json in
                        if json != nil {
                            if let btn = niAlert.niButtonArray.firstObject as? NIButton {
                                btn.startAnimating()
                            }
                            if let j = json as? NSDictionary {
                                let error = j.stringAttributeForKey("error")
                                if error == "0" {
                                    self.niAlertResult = NIAlert()
                                    self.niAlertResult.delegate = self
                                    self.niAlertResult.dict = NSMutableDictionary(objects: [UIImage(named: "pay_result")!, "买好了", "你获得了一组新表情！", [" 嗯！"]], forKeys: ["img" as NSCopying, "title" as NSCopying, "content" as NSCopying, "buttonArray" as NSCopying])
                                    self.niAlert.dismissWithAnimationSwtich(self.niAlertResult)
                                    self.setButtonEnable(Product.btnMainState.hasBought)
                                    /* 修改本地的可能情况 */
                                    if let emojis = Cookies.get("emojis") as? NSMutableArray {
                                        let arr = NSMutableArray()
                                        for _emoji in emojis {
                                            if let emoji = _emoji as? NSDictionary {
                                                let e = NSMutableDictionary(dictionary: emoji)
                                                let newCode = emoji.stringAttributeForKey("code")
                                                if code == newCode {
                                                    e.setValue("1", forKey: "owned")
                                                }
                                                arr.add(e)
                                            }
                                        }
                                        Cookies.set(arr, forKey: "emojis")
                                    }
                                    
                                    self.delegate?.load()
                                    
                                    /* 扣除本地的念币 */
                                    if let data = j.object(forKey: "data") as? NSDictionary {
                                        let cost = data.stringAttributeForKey("cost")
                                        if let _cost = Int(cost) {
                                            if let coin = Cookies.get("coin") as? String {
                                                if let _coin = Int(coin) {
                                                    let coinNew = _coin - _cost
                                                    Cookies.set("\(coinNew)" as AnyObject?, forKey: "coin")
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    self.niAlertResult = NIAlert()
                                    self.niAlertResult.delegate = self
                                    self.niAlertResult.dict = NSMutableDictionary(objects: [UIImage(named: "pay_result")!, "失败了", "你的念币不够...", ["哦"]], forKeys: ["img" as NSCopying, "title" as NSCopying, "content" as NSCopying, "buttonArray" as NSCopying])
                                    self.niAlert.dismissWithAnimationSwtich(self.niAlertResult)
                                }
                            }
                        }
                    }
                }
            } else if type == ProductType.plugin {
                if didselectAtIndex == 0 {
                    let name = data.stringAttributeForKey("name")
                    if name == "请假" {
                        if let btn = niAlert.niButtonArray.firstObject as? NIButton {
                            btn.startAnimating()
                        }
                        Api.postLeave() { json in
                            if json != nil {
                                if let j = json as? NSDictionary {
                                    let error = j.stringAttributeForKey("error")
                                    if error == "0" {
                                        self.niAlertResult = NIAlert()
                                        self.niAlertResult.delegate = self
                                        self.niAlertResult.dict = NSMutableDictionary(objects: [UIImage(named: "pay_result")!, "买好了", "请假好了！早点回来！", [" 嗯！"]], forKeys: ["img" as NSCopying, "title" as NSCopying, "content" as NSCopying, "buttonArray" as NSCopying])
                                        self.niAlert.dismissWithAnimationSwtich(self.niAlertResult)
                                        if let coin = Cookies.get("coin") as? String {
                                            if let _coin = Int(coin) {
                                                let coinNew = _coin - 2
                                                Cookies.set("\(coinNew)" as AnyObject?, forKey: "coin")
                                            }
                                        }
                                    } else {
                                        self.niAlertResult = NIAlert()
                                        self.niAlertResult.delegate = self
                                        self.niAlertResult.dict = NSMutableDictionary(objects: [UIImage(named: "pay_result")!, "失败了", "念币不够...", [" 哦"]], forKeys: ["img" as NSCopying, "title" as NSCopying, "content" as NSCopying, "buttonArray" as NSCopying])
                                        self.niAlert.dismissWithAnimationSwtich(self.niAlertResult)
                                    }
                                }
                            }
                        }
                    } else if name == "毕业证" {
                        if let btn = niAlert.niButtonArray.firstObject as? NIButton {
                            btn.startAnimating()
                        }
                        Api.getGraduate() { json in
                            if json != nil {
                                if let j = json as? NSDictionary {
                                    let error = j.stringAttributeForKey("error")
                                    if error == "0" {
                                        self.niAlertResult = NIAlert()
                                        self.niAlertResult.delegate = self
                                        self.niAlertResult.dict = NSMutableDictionary(objects: [UIImage(named: "pay_result")!, "毕业", "恭喜毕业！\n我们奖励了一颗小星星给你\n重启应用看看", [" 嗯！"]], forKeys: ["img" as NSCopying, "title" as NSCopying, "content" as NSCopying, "buttonArray" as NSCopying])
                                        self.niAlert.dismissWithAnimationSwtich(self.niAlertResult)
                                        if let coin = Cookies.get("coin") as? String {
                                            if let _coin = Int(coin) {
                                                let coinNew = _coin - 100
                                                Cookies.set("\(coinNew)" as AnyObject?, forKey: "coin")
                                            }
                                        }
                                    } else {
                                        /* 念币不够 */
                                        self.niAlertResult = NIAlert()
                                        self.niAlertResult.delegate = self
                                        let message = j.stringAttributeForKey("message")
                                        if message == "you have graduate." {
                                            self.niAlertResult.dict = NSMutableDictionary(objects: [UIImage(named: "pay_result")!, "失败了", "毕业过啦", [" 哦"]], forKeys: ["img" as NSCopying, "title" as NSCopying, "content" as NSCopying, "buttonArray" as NSCopying])
                                        } else {
                                            self.niAlertResult.dict = NSMutableDictionary(objects: [UIImage(named: "pay_result")!, "失败了", "念币不够...", [" 哦"]], forKeys: ["img" as NSCopying, "title" as NSCopying, "content" as NSCopying, "buttonArray" as NSCopying])
                                        }
                                        self.niAlert.dismissWithAnimationSwtich(self.niAlertResult)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else if niAlert == self.niAlertResult {
            /* 如果是支付结果页面 */
            self.niAlert.dismissWithAnimation(.normal)
            self.niAlertResult.dismissWithAnimation(.normal)
        }
    }
    
    /* 移除整个支付界面 */
    func niAlert(_ niAlert: NIAlert, tapBackground: Bool) {
        self.niAlert.dismissWithAnimation(.normal)
        if self.niAlertResult != nil {
            self.niAlertResult.dismissWithAnimation(.normal)
        }
    }
    
    /* 购买会员成功 */
    func payMemberSuccess() {
        niAlertResult = NIAlert()
        niAlertResult.delegate = self
        niAlertResult.dict = NSMutableDictionary(objects: [UIImage(named: "pay_result")!, "支付好了", "获得念的永久会员啦！\n蟹蟹你对念的支持", [" 嗯！"]], forKeys: ["img" as NSCopying, "title" as NSCopying, "content" as NSCopying, "buttonArray" as NSCopying])
        niAlert.dismissWithAnimationSwtich(niAlertResult)
        Cookies.set("1" as AnyObject?, forKey: "member")
        /* 按钮的状态变化 */
        setButtonEnable(Product.btnMainState.hasBought)
    }
    
    /* 购买会员用户取消了操作 */
    func payMemberCancel() {
        if let btn = niAlert.niButtonArray.firstObject as? NIButton {
            btn.stopAnimating()
        }
        if let btn = niAlert.niButtonArray.lastObject as? NIButton {
            btn.stopAnimating()
        }
    }
    
    /* 购买会员失败 */
    func payMemberFailed() {
        niAlertResult = NIAlert()
        niAlertResult.delegate = self
        niAlertResult.dict = NSMutableDictionary(objects: [UIImage(named: "pay_result")!, "支付不成功", "服务器坏了！", ["哦"]], forKeys: ["img" as NSCopying, "title" as NSCopying, "content" as NSCopying, "buttonArray" as NSCopying])
        niAlert.dismissWithAnimationSwtich(niAlertResult)
    }
}
