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
    // このラベルの拡大率を保持
    var scaleX: CGFloat = 1.0
    var scaleY: CGFloat = 1.0
    
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
            // オートレイアウトの制約を超えてLabelが大きくなる問題を修正
            self.setNeedsLayout()
            self.layoutIfNeeded()
            self.namingLabel.sizeToFit()
            
            // 画面外に出た時に画面内に戻す処理
            if self.frame.origin.x < 0 {
                self.frame.origin.x = 0
            } else if self.frame.origin.y < 0 {
                self.frame.origin.y = 0
            } else if self.frame.origin.x + self.frame.size.width > UIScreen.main.bounds.width {
                self.frame.origin.x = UIScreen.main.bounds.width - self.frame.width
            } else if self.frame.origin.y + self.frame.size.height > UIScreen.main.bounds.height {
                self.frame.origin.y =  UIScreen.main.bounds.height - self.frame.height
            }
        }
        
        // ピンチした時の処理
        self.onPinch { pinch in
            
            // ラベルが画面外に出ないような制御
            if self.frame.origin.x  > 0 && self.frame.origin.y > 0 &&
                self.frame.origin.x + self.frame.size.width < UIScreen.main.bounds.width &&
                self.frame.origin.y + self.frame.size.height < UIScreen.main.bounds.height {
                
                self.transform = self.transform.scaledBy(x: pinch.scale, y: pinch.scale)
                
                // 保持している倍率に今ピンチした倍率をかけて元の大きさからの倍率を保持
                self.scaleX = self.scaleX * pinch.scale
                self.scaleY = self.scaleY * pinch.scale
                
                pinch.scale = 1
            }


        }
        
        super.awakeFromNib()
    }
    
    // ビューのマージンが変更された時に呼ばれる
    override func layoutMarginsDidChange() {
        self.namingLabel.sizeToFit()
    }
    
    // 閉じるボタンが押された時呼ばれる
    @IBAction func close(_ sender: Any) {
        removeFromSuperview()
    }
    
}
