//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class DreamCommentViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate, UITextFieldDelegate{
    
    let identifier = "comment"
    var tableview:UITableView!
    var dataArray = NSMutableArray()
    var page :Int = 0
    var replySheet:UIActionSheet?
    var deleteCommentSheet:UIActionSheet?
    var deleteId:Int = 0        //删除按钮的tag，进展编号
    var deleteViewId:Int = 0    //删除按钮的View的tag，indexPath
    var navView:UIView!
    var dataTotal:Int = 0
    var viewTop:UIView!
    
    var dreamID:Int = 0
    var stepID:Int = 0
    
    var dreamowner:Int = 0 //如果是0，就不是主人，是1就是主人
    
    var ReplyContent:String = ""
    var ReplyRow:Int = 0
    var ReplyCid:String = ""
    var ReplyUserName:String = ""
    
    var ReturnReplyContent:String = ""
    
    var animating:Int = 0   //加载顶部内容的开关，默认为0，初始为1，当为0时加载，1时不动
    var activityIndicatorView:UIActivityIndicatorView!
    
    var desHeight:CGFloat = 0
    var inputKeyboard:UITextField!
    var keyboardView:UIView!
    var viewBottom:UIView!
    var isKeyboardResign:Int = 0 //为了解决评论会收起键盘的BUG创建的开关，当提交过程中变为1，0时才收起键盘
    var keyboardHeight:CGFloat = 0
    var lastContentOffset:CGFloat?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
        SAReloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.viewLoadingHide()
        keyboardEndObserve()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        keyboardStartObserve()
    }
    
    func setupViews()
    {
        self.viewBack()
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = BarColor
        self.view.addSubview(self.navView)
        
        self.tableview = UITableView(frame:CGRectMake(0,64,globalWidth,globalHeight - 64 - 56))
        self.tableview.backgroundColor = UIColor.clearColor()
        self.tableview.delegate = self;
        self.tableview.dataSource = self;
        self.tableview.separatorStyle = UITableViewCellSeparatorStyle.None
        let nib3 = UINib(nibName:"CommentCell", bundle: nil)
        
        self.tableview.registerNib(nib3, forCellReuseIdentifier: identifier)
        let pan = UIPanGestureRecognizer(target: self, action: "onCellClick:")
        pan.delegate = self
        self.tableview.addGestureRecognizer(pan)
        self.tableview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onCellTap:"))
        self.view.addSubview(self.tableview)
        
        self.viewTop = UIView(frame: CGRectMake(0, 0, globalWidth, 56))
        self.activityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(globalWidth / 2 - 10, 21, 20, 20))
        self.activityIndicatorView.hidden = false
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.color = SeaColor
        self.tableview.tableHeaderView = self.viewTop
        self.viewBottom = UIView(frame: CGRectMake(0, 0, globalWidth, 20))
        self.tableview.tableFooterView = self.viewBottom
        
        //输入框
        keyboardView = UIView()
        inputKeyboard = UITextField()
        inputKeyboard.delegate = self
        keyboardView.setTextField(inputKeyboard)
        self.view.addSubview(keyboardView)
        
        //标题颜色
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.text = "回应"
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        self.viewLoadingShow()
    }
    
    //按下发送后调用此函数
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let contentComment = self.inputKeyboard.text
        if contentComment != "" {
            commentFinish(contentComment!)
        }
        return true
    }
    
    func commentFinish(replyContent:String){
        self.isKeyboardResign = 1
        self.inputKeyboard.text = ""
        let name = Cookies.get("user") as? String
        let commentReplyRow = self.dataArray.count
        let newinsert = NSDictionary(objects: [replyContent, "\(commentReplyRow)" , "sending", "\(SAUid())", "\(name!)"], forKeys: ["content", "id", "lastdate", "uid", "user"])
        self.dataArray.insertObject(newinsert, atIndex: 0)
        self.tableview.reloadData()
        //当提交评论后滚动到最新评论的底部
        let offset = self.tableview.contentSize.height - self.tableview.bounds.size.height
        if offset > 0 {
            self.tableview.setContentOffset(CGPointMake(0, offset), animated: true)
        }
        
        //  提交到服务器
        let content = SAEncode(SAHtml(replyContent))
        Api.postDreamStepComment("\(self.dreamID)", step: "\(self.stepID)", content: content) { json in
            if json != nil {
                if let status = json!.objectForKey("status") as? NSNumber {
                    if status == 200 {
                        let newinsert = NSDictionary(objects: [replyContent, "\(commentReplyRow)" , "0s", "\(SAUid())", "\(name!)"], forKeys: ["content", "id", "lastdate", "uid", "user"])
                        self.dataArray.replaceObjectAtIndex(0, withObject: newinsert)
                        self.tableview.reloadData()
                    } else {
                        self.view.showTipText("对方设置了不被回应...", delay: 2)
                        self.inputKeyboard.text = replyContent
                    }
                } else {
                    self.view.showTipText("服务器坏了...", delay: 2)
                    self.inputKeyboard.text = replyContent
                }
            }
        }
    }
    
    func SAloadData() {
        let heightBefore = self.tableview.contentSize.height
        let url = "http://nian.so/api/comment_step.php?page=\(page)&id=\(stepID)"
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as! NSObject != NSNull() {
                let arr = data.objectForKey("items") as! NSArray
                let total = data.objectForKey("total") as! NSString!
                self.dataTotal = Int("\(total)")!
                for data : AnyObject  in arr {
                    self.dataArray.addObject(data)
                }
                self.tableview.reloadData()
                let heightAfter = self.tableview.contentSize.height
                let heightChange = heightAfter > heightBefore ? heightAfter - heightBefore : 0
                self.tableview.setContentOffset(CGPointMake(0, heightChange), animated: false)
                self.page++
                self.animating = 0
            }
        })
    }
    
    func SAReloadData(){
        let url = "http://nian.so/api/comment_step.php?page=0&id=\(stepID)"
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as! NSObject != NSNull(){
                let arr = data.objectForKey("items") as! NSArray
                let total = data.objectForKey("total") as! NSString!
                self.dataTotal = Int("\(total)")!
                self.dataArray.removeAllObjects()
                for data : AnyObject  in arr {
                    self.dataArray.addObject(data)
                }
                if self.dataTotal < 15 {
                    self.tableview.tableHeaderView = UIView(frame: CGRectMake(0, 0, globalWidth, 0))
                }
                self.tableview.reloadData()
                self.viewLoadingHide()
                self.tableview.headerEndRefreshing()
                if self.tableview.contentSize.height > self.tableview.bounds.size.height {
                    self.tableview.setContentOffset(CGPointMake(0, self.tableview.contentSize.height-self.tableview.bounds.size.height), animated: false)
                }
                self.page = 1
                self.isKeyboardResign = 0
            }
        })
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        if self.dataTotal == 15 {
            self.viewTop.addSubview(self.activityIndicatorView)
            if y < 40 {
                if self.animating == 0 {
                    self.animating = 1
                    delay(0.5, closure: { () -> () in
                        self.SAloadData()
                    })
                }
            }
        }else{
            self.activityIndicatorView.hidden = true
            self.tableview.tableHeaderView = UIView(frame: CGRectMake(0, 0, globalWidth, 0))
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func onBubbleClick(sender:UIGestureRecognizer) {
        inputKeyboard.resignFirstResponder()
        let index = sender.view!.tag
        let data = self.dataArray[index] as! NSDictionary
        let user = data.stringAttributeForKey("user") as String
        let uid = data.stringAttributeForKey("uid")
        let content = data.stringAttributeForKey("content") as String
        let cid = data.stringAttributeForKey("id") as String
        self.ReplyRow = self.dataArray.count - 1 - index
        self.ReplyContent = content
        self.ReplyCid = cid
        self.ReplyUserName = user
        self.replySheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        if self.dreamowner == 1 {   //主人
            self.replySheet!.addButtonWithTitle("回应@\(user)")
            self.replySheet!.addButtonWithTitle("复制")
            self.replySheet!.addButtonWithTitle("删除")
            self.replySheet!.addButtonWithTitle("取消")
            self.replySheet!.cancelButtonIndex = 3
            self.replySheet!.showInView(self.view)
        }else{  //不是主人
            let safeuid = SAUid()
            if uid == safeuid {
                self.replySheet!.addButtonWithTitle("回应@\(user)")
                self.replySheet!.addButtonWithTitle("复制")
                self.replySheet!.addButtonWithTitle("删除")
                self.replySheet!.addButtonWithTitle("取消")
                self.replySheet!.cancelButtonIndex = 3
                self.replySheet!.showInView(self.view)
            }else{
                self.replySheet!.addButtonWithTitle("回应@\(user)")
                self.replySheet!.addButtonWithTitle("复制")
                self.replySheet!.addButtonWithTitle("举报")
                self.replySheet!.addButtonWithTitle("取消")
                self.replySheet!.cancelButtonIndex = 3
                self.replySheet!.showInView(self.view)
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        let c = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! CommentCell
        let index = indexPath.row
        let data = self.dataArray[dataArray.count - 1 - index] as! NSDictionary
        c.data = data
        c.avatarView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
        c.imageContent.tag = dataArray.count - 1 - index
        c.imageContent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onBubbleClick:"))
        c.View.tag = index
        c._layoutSubviews()
        cell = c
        return cell
    }
    

    func onCellClick(sender:UIPanGestureRecognizer){
        if sender.state == UIGestureRecognizerState.Changed {
            let distanceX = sender.translationInView(self.view).x
            let distanceY = sender.translationInView(self.view).y
            if fabs(distanceY) > fabs(distanceX) {
                self.inputKeyboard.resignFirstResponder()
            }
        }
    }
    
    func onCellTap(sender:UITapGestureRecognizer) {
        self.inputKeyboard.resignFirstResponder()
    }
    
    func userclick(sender:UITapGestureRecognizer){
        self.inputKeyboard.resignFirstResponder()
        let UserVC = PlayerViewController()
        UserVC.Id = "\(sender.view!.tag)"
        self.navigationController?.pushViewController(UserVC, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let index = indexPath.row
        let data = self.dataArray[self.dataArray.count - 1 - index] as! NSDictionary
        return  CommentCell.cellHeightByData(data)
    }
    
    func commentVC(){
        //这里是回应别人
        self.inputKeyboard.text = "@\(self.ReplyUserName) "
        delay(0.3, closure: {
            self.inputKeyboard.becomeFirstResponder()
            return
        })
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
        let safeuid = SAUid()
        let safeshell = uidKey.objectForKey(kSecValueData) as! String
        
        if actionSheet == self.replySheet {
            if buttonIndex == 0 {
                self.commentVC()
            }else if buttonIndex == 1 { //复制
                let pasteBoard = UIPasteboard.generalPasteboard()
                pasteBoard.string = self.ReplyContent
            }else if buttonIndex == 2 {
                let data = self.dataArray[self.ReplyRow] as! NSDictionary
                let uid = data.stringAttributeForKey("uid")
                if (( uid == safeuid ) || ( self.dreamowner == 1 )) {
                    self.deleteCommentSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
                    self.deleteCommentSheet!.addButtonWithTitle("确定删除")
                    self.deleteCommentSheet!.addButtonWithTitle("取消")
                    self.deleteCommentSheet!.cancelButtonIndex = 1
                    self.deleteCommentSheet!.showInView(self.view)
                }else{
                    UIView.showAlertView("谢谢", message: "如果这个回应不合适，我们会将其移除。")
                }
            }
        }else if actionSheet == self.deleteCommentSheet {
            if buttonIndex == 0 {
                self.isKeyboardResign = 1
                let row = self.dataArray.count - 1 - self.ReplyRow
                self.dataArray.removeObjectAtIndex(row)
                self.tableview.beginUpdates()
                self.tableview.deleteRowsAtIndexPaths([NSIndexPath(forRow: row, inSection: 0)], withRowAnimation: .Fade)
                self.tableview.reloadData()
                self.tableview.endUpdates()
                go {
                    SAPost("uid=\(safeuid)&shell=\(safeshell)&cid=\(self.ReplyCid)", urlString: "http://nian.so/api/delete_comment.php")
                    self.isKeyboardResign = 0
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func keyboardWasShown(notification: NSNotification) {
        var info: Dictionary = notification.userInfo!
        let keyboardSize: CGSize = (info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size)!
        self.keyboardHeight = keyboardSize.height
        self.keyboardView.setY( globalHeight - self.keyboardHeight - 56 )
        let heightScroll = globalHeight - 56 - 64 - self.keyboardHeight
        let contentOffsetTableView = self.tableview.contentSize.height >= heightScroll ? self.tableview.contentSize.height - heightScroll : 0
        self.tableview.setHeight( heightScroll )
        self.tableview.setContentOffset(CGPointMake(0, contentOffsetTableView ), animated: false)
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        let heightScroll = globalHeight - 56 - 64
        self.keyboardView.setY( globalHeight - 56 )
        self.tableview.setHeight( heightScroll )
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UIScreenEdgePanGestureRecognizer) {
            return false
        }else{
            return true
        }
    }
}

