//
//  NamingLabelView.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/07/28.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit
import GestureRecognizerClosures

protocol NamingLabelViewDelegate {
    func namingLabelTapped(view: NamingLabelView)
}

class NamingLabelView: UIView {
    
    static let nibName = "NamingLabelView"
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var namingLabel: UILabel!
    
    var delegate: NamingLabelViewDelegate!
    
    // このViewの１フレーム前の移動量
    var beforFrame: CGPoint!
    
    override func awakeFromNib() {
        
        backgroundColor = UIColor.clear        
        namingLabel.textColor = UIColor.white
        
        // Viewをタップしたときの処理
        self.onTap {_ in
            self.delegate.namingLabelTapped(view: self)
        }
        
        // ドラックした時の処理
        self.onPan { pan in
            let location: CGPoint = pan.translation(in: self)
            let x = location.x + self.beforFrame.x
            let y = location.y + self.beforFrame.y
            self.beforFrame = CGPoint(x: x, y: y)
            pan.setTranslation(CGPoint.zero, in: self)
            self.frame.origin = self.beforFrame
        }
        
        // ピンチした時の処理
        self.onPinch { pinch in
            self.transform = self.transform.scaledBy(x: pinch.scale, y: pinch.scale)
            pinch.scale = 1
        }
        
        super.awakeFromNib()
    }
    
    // 閉じるボタンが押された時呼ばれる
    @IBAction func close(_ sender: Any) {
        removeFromSuperview()
    }
    
}
