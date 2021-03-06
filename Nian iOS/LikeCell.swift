//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class LikeCell: UITableViewCell {
    
    @IBOutlet var avatarView:UIImageView!
    @IBOutlet var nickLabel:UILabel!
    @IBOutlet var View:UIView!
    @IBOutlet var btnFollow:UIButton!
    @IBOutlet var viewHolder: UIView!
    @IBOutlet var viewLine: UIView!
    var LargeImgURL:String = ""
    var data :NSDictionary!
    var user:String = ""
    var uid:String = ""
    var urlIdentify:Int = 0
    var circleID:String = "0"
    var ownerID: String = "0"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.avatarView.layer.cornerRadius = 20
        self.avatarView.layer.masksToBounds = true
        self.viewHolder.setWidth(globalWidth)
        self.btnFollow.setX(globalWidth-85)
        self.viewLine.setWidth(globalWidth-85)
        viewLine.setHeight(globalHalf)
    }
    
    func _layoutSubviews() {

        self.uid = self.data.stringAttributeForKey("uid")
        let follow = self.data.stringAttributeForKey("follow")
        user = self.data.stringAttributeForKey("user")
        self.nickLabel!.text = user
        self.avatarView.setHead(uid)
        self.avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LikeCell.onUserClick)))
        
        
        let safeuid = SAUid()
        
        if self.urlIdentify == 1 && self.ownerID == safeuid {
            self.btnFollow.layer.borderWidth = 0
            self.btnFollow.setTitleColor(UIColor.white, for: UIControlState())
            self.btnFollow.backgroundColor = UIColor.HighlightColor()
            self.btnFollow.setTitle("写信", for: UIControlState())
            self.btnFollow.addTarget(self, action: #selector(LikeCell.onLetterClick), for: UIControlEvents.touchUpInside)
            self.btnFollow.isHidden = true
        } else {
            if follow == "0" {
                self.btnFollow.tag = 100
                self.btnFollow.layer.borderColor = UIColor.HighlightColor().cgColor
                self.btnFollow.layer.borderWidth = 1
                self.btnFollow.setTitleColor(UIColor.HighlightColor(), for: UIControlState())
                self.btnFollow.backgroundColor = UIColor.white
                self.btnFollow.setTitle("关注", for: UIControlState())
            }else{
                self.btnFollow.tag = 200
                self.btnFollow.layer.borderWidth = 0
                self.btnFollow.setTitleColor(UIColor.white, for: UIControlState())
                self.btnFollow.backgroundColor = UIColor.HighlightColor()
                self.btnFollow.setTitle("已关注", for: UIControlState())
            }
            self.btnFollow.addTarget(self, action: #selector(LikeCell.onFollowClick(_:)), for: UIControlEvents.touchUpInside)
        }
    }
    
    @objc func onUserClick() {
        let vc = PlayerViewController()
        vc.Id = data.stringAttributeForKey("uid")
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func onLetterClick() {
        if let uid = Int(data.stringAttributeForKey("uid")) {
            let vc = CircleController()
            vc.id = uid
            vc.name = user
            self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func onInviteClick(_ sender:UIButton){
    }
    
    @objc func onFollowClick(_ sender:UIButton){
        let tag = sender.tag
        if tag == 100 {     //没有关注
            self.data.setValue("1", forKey: "follow")
            sender.tag = 200
            sender.layer.borderWidth = 0
            sender.setTitleColor(UIColor.white, for: UIControlState())
            sender.backgroundColor = UIColor.HighlightColor()
            sender.setTitle("已关注", for: UIControlState())
            Api.getFollow(uid) { json in
                
            }
            
        }else if tag == 200 {   //正在关注
            self.data.setValue("0", forKey: "follow")
            sender.tag = 100
            sender.layer.borderColor = UIColor.HighlightColor().cgColor
            sender.layer.borderWidth = 1
            sender.setTitleColor(UIColor.HighlightColor(), for: UIControlState())
            sender.backgroundColor = UIColor.white
            sender.setTitle("关注", for: UIControlState())
            Api.getUnfollow(self.uid) { json in
            }
        }
    }
}
