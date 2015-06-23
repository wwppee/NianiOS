//
//  CircleCollectionCell.swift
//  Nian iOS
//
//  Created by WebosterBob on 6/9/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit

class CircleCollectionCell: UICollectionViewCell {
    @IBOutlet weak var imageHeadView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var viewLine: UIView!
    @IBOutlet var btnStep: UIButton!
    @IBOutlet var btnBBS: UIButton!
    @IBOutlet var btnChat: UIButton!
    @IBOutlet var labelBBS: UILabel!
    
    var largeImageURL: String = ""
    var data: NSDictionary?
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 4.0
        self.layer.masksToBounds = true
        
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor(red: 0xe6/255.0, green: 0xe6/255.0, blue: 0xe6/255.0, alpha: 1).CGColor
        
        self.imageHeadView.layer.cornerRadius = 4.0
        self.imageHeadView.layer.masksToBounds = true
        self.viewLine.frame.size = CGSizeMake(globalWidth/2 - 24, 0.5)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.viewLine.frame.size = CGSizeMake(globalWidth/2 - 24, 0.5)
        if self.data != nil {
            var id = self.data!.stringAttributeForKey("id")
            var title = self.data!.stringAttributeForKey("title")
            
            if id == "0" {
                btnStep.hidden = true
                btnBBS.hidden = true
                btnChat.hidden = true
                labelBBS.hidden = false
                println(labelBBS.frame.origin)
                self.imageHeadView.setImage("http://img.nian.so/dream/1_1420533664.png!dream", placeHolder: IconColor)
                self.titleLabel.text = "广场"
            } else {
                btnStep.hidden = false
                btnBBS.hidden = false
                btnChat.hidden = false
                labelBBS.hidden = true
                var img = self.data!.stringAttributeForKey("img")
                if title == "梦境" {
                    Api.getCircleTitle(id) { json in
                        if json != nil {
                            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                            var safeuid = Sa.objectForKey("uid") as! String
                            var img = json!["img"] as! String
                            var titleNew = json!["title"] as! String
                            
                            self.titleLabel.text = titleNew
                            self.imageHeadView.setImage("http://img.nian.so/dream/\(img)!dream", placeHolder: IconColor)
                            SD.executeChange("insert into circlelist(id, circleid, title, image, postdate, owner) values (null, ?, ?, ?, '0', ?)", withArgs: [id, titleNew, img, safeuid])
                        }
                    }
                } else {
                    self.titleLabel.text = title
                    self.imageHeadView.setImage("http://img.nian.so/dream/\(img)!dream", placeHolder: IconColor)
                }
                self.setupBtn()
            }
        }
    }
    
    func setupBtn() {
        if 1==1 {
            var a = self.getNum(0)
            var b = self.getNum(1)
            var c = self.getNum(2)
            if a > 0 {
                self.btnStep.setTitle("\(a)", forState: .allZeros)
                self.btnStep.setImage(nil, forState: UIControlState.allZeros)
            } else {
                self.btnStep.setTitle("", forState: .allZeros)
                self.btnStep.setImage(UIImage(named: "text"), forState: UIControlState.allZeros)
            }
            if b > 0 {
                self.btnBBS.setTitle("\(b)", forState: .allZeros)
                self.btnBBS.setImage(nil, forState: UIControlState.allZeros)
            } else {
                self.btnBBS.setTitle("", forState: .allZeros)
                self.btnBBS.setImage(UIImage(named: "topic"), forState: UIControlState.allZeros)
            }
            if c > 0 {
                self.btnChat.setTitle("\(c)", forState: .allZeros)
                self.btnChat.setImage(nil, forState: UIControlState.allZeros)
            } else {
                self.btnChat.setTitle("", forState: .allZeros)
                self.btnChat.setImage(UIImage(named: "chat"), forState: UIControlState.allZeros)
            }
        }
    }
    
    func getNum(type: Int) -> Int {
        var safeuid = SAUid()
        var id = self.data!.stringAttributeForKey("id")
        var word = ""
        if type == 0 {
            word = "and type = 3"
        } else if type == 1 {
            word = "and type = 4"
        } else {
            word = "and type != 4 and type != 3"
        }
        let (resultSet, err) = SD.executeQuery("select id from circle where circle='\(id)' and isread = 0 \(word) and owner = '\(safeuid)'")
        if err == nil {
            return min(resultSet.count, 99)
        }
        return 0
    }
    
    func toNewCircle(current: Int) {
        if let id = self.data?.stringAttributeForKey("id") {
            var vc = NewCircleController()
            vc.id = id
            vc.current = current
            vc.textTitle = self.data!.stringAttributeForKey("title")
            self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}


