//
//  StampView.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/08/14.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit

protocol StampViewDelegate {
    func stampCloseTapped(view: UIView)
}

class StampView: UIView {
    
    static let nibName = "StampView"

    @IBOutlet weak var close: UIImageView!
    @IBOutlet weak var stamp: UIImageView!
    
    var beforeFrame: CGPoint!
    var delegate: StampViewDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clear
        stamp.contentMode = .scaleAspectFit
        
        self.onPan { pan in
            let location: CGPoint = pan.translation(in: self)
            let x = location.x + self.beforeFrame.x
            let y = location.y + self.beforeFrame.y
            self.beforeFrame = CGPoint(x: x, y: y)
            pan.setTranslation(CGPoint.zero, in: self)
            self.frame.origin = self.beforeFrame
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
        
        close.onTap {_ in 
            self.delegate.stampCloseTapped(view: self)
        }
    }

}
