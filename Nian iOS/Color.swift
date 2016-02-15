//
//  Color.swift
//  Nian iOS
//
//  Created by Sa on 16/1/29.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

/* 主题编号 */
var theme = 2

extension UIColor {
    
    /* 导航栏颜色 */
    class func NavColor() -> UIColor {
        if theme == 1 {
            return UIColor(red: 0x25/255.0, green: 0x27/255.0, blue: 0x2a/255.0, alpha: 1)
        }
        return UIColor(red: 0x1e/255.0, green: 0x20/255.0, blue: 0x25/255.0, alpha: 1)
    }
    
    /* 底部栏颜色 */
    class func TabbarColor() -> UIColor {
        if theme == 1 {
            return UIColor(red: 0x25/255.0, green: 0x27/255.0, blue: 0x2a/255.0, alpha: 1)
        }
        return UIColor(red: 0x1e/255.0, green: 0x20/255.0, blue: 0x25/255.0, alpha: 1)
    }
    
    /* 高亮颜色 */
    class func HightlightColor() -> UIColor {
        if theme == 1 {
            return UIColor(red: 0x6c/255.0, green: 0xc5/255.0, blue: 0xee/255.0, alpha: 1)
            
        }
        return UIColor(red: 0x6c/255.0, green: 0xc5/255.0, blue: 0xee/255.0, alpha: 1)
    }
    
    /* 背景颜色*/
    class func BackgroundColor() -> UIColor {
        if theme == 1 {
            return UIColor.whiteColor()
        }
        return UIColor(red: 0x1e/255.0, green: 0x20/255.0, blue: 0x25/255.0, alpha: 1)
    }
    
    /* 浅灰 */
    class func GreyColor1() -> UIColor {
        if theme == 1 {
            return UIColor(red: 0xe6/255.0, green: 0xe6/255.0, blue: 0xe6/255.0, alpha: 1)
        }
        return UIColor(red: 0xe6/255.0, green: 0xe6/255.0, blue: 0xe6/255.0, alpha: 1)
    }
    
    /* 深灰，#333 */
    class func GreyColor2() -> UIColor {
        return UIColor(red: 0x33/255.0, green: 0x33/255.0, blue: 0x33/255.0, alpha: 1)
    }
    
    /* 中灰，#666 */
    class func GreyColor3() -> UIColor {
        if theme == 1 {
            return UIColor(red: 0xb3/255.0, green: 0xb3/255.0, blue: 0xb3/255.0, alpha: 1)
        }
        return UIColor(red: 0x66/255.0, green: 0x66/255.0, blue: 0x66/255.0, alpha: 1)
    }
    
    /* 主文本颜色 */
    class func ContentColor() -> UIColor {
        return UIColor(red: 0xb3/255.0, green: 0xb3/255.0, blue: 0xb3/255.0, alpha: 1)
    }
    
    /* 分割线颜色 */
    class func LineColor() -> UIColor {
        if theme == 1 {
            return UIColor(red: 0xe6/255.0, green: 0xe6/255.0, blue: 0xe6/255.0, alpha: 1)
        }
        return UIColor(red: 0x33/255.0, green: 0x33/255.0, blue: 0x33/255.0, alpha: 1)
    }
}