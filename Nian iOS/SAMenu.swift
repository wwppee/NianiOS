//
//  SAMenu.swift
//  Nian iOS
//
//  Created by Sa on 15/5/27.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation

class SAMenu: UIView {
    @IBOutlet var viewLeft: UILabel!
    @IBOutlet var viewMiddle: UILabel!
    @IBOutlet var viewRight: UILabel!
    @IBOutlet var viewLine: UIView!
    @IBOutlet var viewLineBottom: UIView!
    var arr = ["", ""]
    
    override func awakeFromNib() {
        self.setX(globalWidth/2 - 160)
        viewLeft.tag = 0
        viewMiddle.tag = 1
        viewRight.tag = 2
        viewLeft.textColor = UIColor.HighlightColor()
        viewLineBottom.frame = CGRect(x: 160 - globalWidth/2, y: 39.5, width: globalWidth, height: 0.5)
    }
    
    func setup() {
        if arr.count == 2 {
            viewRight.isHidden = true
            viewLeft.setX(320/2 - 86)
            viewMiddle.setX(320/2)
            viewLeft.text = arr[0]
            viewMiddle.text = arr[1]
        } else if arr.count == 3 {
            viewRight.isHidden = false
            viewLeft.text = arr[0]
            viewMiddle.text = arr[1]
            viewRight.text = arr[2]
        }
    }
    
    func switchTab(_ tab: Int) {
        let arrView = [viewLeft, viewMiddle, viewRight]
        viewLeft.textColor = greyColor
        viewMiddle.textColor = greyColor
        viewRight.textColor = greyColor
        arrView[tab]?.textColor = UIColor.HighlightColor()
        let x = arrView[tab]?.x()
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.viewLine.setX(x! + 15)
        })
    }
}
