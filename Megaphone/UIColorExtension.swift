//
//  UIColorExtension.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/08/07.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit


extension UIColor{
    // 16進数の色文字列をUIColorにして返却する
    static func hexColor(str: String) -> UIColor
    {
        if str.substring(to: str.index(after: str.startIndex)) == "#"
        {
            let colStr = str.substring(from: str.index(after: str.startIndex))
            if colStr.utf16.count == 6
            {
                let rStr = (colStr as NSString).substring(with: NSRange(location: 0, length: 2))
                let gStr = (colStr as NSString).substring(with: NSRange(location: 2, length: 2))
                let bStr = (colStr as NSString).substring(with: NSRange(location: 4, length: 2))
                let rHex = CGFloat(Int(rStr, radix: 16) ?? 0)
                let gHex = CGFloat(Int(gStr, radix: 16) ?? 0)
                let bHex = CGFloat(Int(bStr, radix: 16) ?? 0)
                return UIColor(red: rHex/255.0, green: gHex/255.0, blue: bHex/255.0, alpha: 1.0)
            }
        }
        return UIColor.white
    }
}
