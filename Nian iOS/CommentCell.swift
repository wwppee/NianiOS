//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics


class CommentCell: UITableViewCell {
    
    @IBOutlet var avatarView:UIImageView!
    @IBOutlet var nickLabel:UILabel!
    @IBOutlet var contentLabel:UILabel!
    @IBOutlet var lastdate:UILabel!
    @IBOutlet var View:UIView!
    @IBOutlet var imageContent:UIImageView!
    var data :NSDictionary!
    var contentLabelWidth:CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.nickLabel!.textColor = SeaColor
        self.avatarView.layer.masksToBounds = true
        self.avatarView.layer.cornerRadius = 16
    }
    
    func _layoutSubviews()
    {
//        super.layoutSubviews()
        let uid = self.data.stringAttributeForKey("uid")
        let user = self.data.stringAttributeForKey("user")
        let lastdate = self.data.stringAttributeForKey("lastdate")
        let content = self.data.stringAttributeForKey("content")
        self.nickLabel!.text = user
        self.lastdate!.text = lastdate
        self.avatarView!.setHead(uid)
        let height = data.objectForKey("heightContent") as! CGFloat
        let wImage = data.objectForKey("widthImage") as! CGFloat
        let hImage = data.objectForKey("heightImage") as! CGFloat
        
        self.avatarView?.tag = Int(uid)!
        self.contentLabel!.setHeight(height)
        self.contentLabel!.text = content
        self.imageContent.setWidth(wImage)
        self.imageContent.setHeight(hImage)
        self.avatarView.setBottom(height + 55)
        self.nickLabel.setBottom(height + 60)
        self.nickLabel.setWidth(user.stringWidthWith(11, height: 21))
        self.lastdate.setWidth(lastdate.stringWidthWith(11, height: 21))
        self.lastdate.setBottom(height + 60)
        
        self.lastdate.setX(user.stringWidthWith(11, height: 21)+83)
        self.contentLabel.setX(80)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.image = nil
        nickLabel.text = nil
    }
    
    class func cellHeightByData(data:NSDictionary) -> NSArray {
        let content = data.stringAttributeForKey("content")
        let height = content.stringHeightWith(15,width:208)
        var wImage: CGFloat = 0
        var hImage: CGFloat = 0
        if height == "".stringHeightWith(15,width:208) {
            let oneLineWidth = content.stringWidthWith(15, height: 24)
            wImage = oneLineWidth + 27
            hImage = 37
        }else{      //如果是多行
            wImage = 235
            hImage = height + 20
        }
        return [height + 60, height, wImage, hImage]
    }
    
}

extension String {
    func toCGFloat() -> CGFloat {
        return CGFloat((self as NSString).floatValue)
    }
}







