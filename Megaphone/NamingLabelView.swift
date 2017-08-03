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
    // このViewの１フレーム前のスケール
    var befroScale: CGFloat = 1.0
    // ラベルのフォントサイズ
    var fontSize: CGFloat = 18.0
    
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
        }
        
        // ピンチした時の処理
        self.onPinch { pinch in
            // TODO: ピンチしたときにフォントサイズを変更する
            
            // 倍率
            let changeAmountScele = pinch.scale / self.befroScale
            
            // ピンチしたときViewの大きさを変えてフォントサイズが変更されてもテキストが見切れないようにする
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width * (changeAmountScele) + 30, height: self.frame.height * (changeAmountScele))
            // Viewに追随してラベルも大きくする
            self.namingLabel.frame = CGRect.init(x: self.namingLabel.frame.origin.x, y: self.namingLabel.frame.origin.y, width: self.namingLabel.frame.width * (changeAmountScele) + 30, height: self.namingLabel.frame.height * (changeAmountScele))
            
            // フォントサイズ変更
            self.fontSize = self.fontSize * changeAmountScele
            print("fontSize: \(self.fontSize)")
            self.namingLabel.font = UIFont(name: "HelveticaNeue-Bold", size: self.fontSize)
            // スケール保持
            self.befroScale = pinch.scale
            
            self.setNeedsLayout()
            self.layoutIfNeeded()
            // ラベルの大きさを文字に合わせる
            self.namingLabel.sizeToFit()
            // ラベルの横幅に合わせてViewの横幅を調整
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.namingLabel.frame.width, height: self.namingLabel.frame.height + self.closeButton.frame.height)

            if pinch.state == .ended {
                self.namingLabel.sizeToFit()
            }
        }
        
        super.awakeFromNib()
    }
    
    // 閉じるボタンが押された時呼ばれる
    @IBAction func close(_ sender: Any) {
        removeFromSuperview()
    }
    
}
