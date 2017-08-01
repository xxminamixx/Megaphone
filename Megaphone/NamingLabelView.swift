//
//  NamingLabelView.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/07/28.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit

protocol NamingLabelViewDelegate {
    func namingViewClose(view: UIView)
    func namingLabelTapped(label: UILabel)
    func namingViewDraged(locate: CGPoint, view: UIView)
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
        
        // NamingLabelViewにタップ判定付加
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(labelTapped))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(drag))
        
        namingLabel.addGestureRecognizer(tapGesture)
        addGestureRecognizer(panGesture)
        
        super.awakeFromNib()
    }
    
    // 閉じるボタンが押された時呼ばれる
    @IBAction func close(_ sender: Any) {
        delegate.namingViewClose(view: self)
    }
    
    // ラベルをタップした時に呼ばれる
    func labelTapped() {
        delegate.namingLabelTapped(label: namingLabel)
    }
    
    // ドラッグした時に呼ばれる
    func drag(sender: UIPanGestureRecognizer) {
        let location: CGPoint = sender.translation(in: self)
        let x = location.x + beforFrame.x
        let y = location.y + beforFrame.y
        beforFrame = CGPoint(x: x, y: y)
        sender.setTranslation(CGPoint.zero, in: self)
        delegate.namingViewDraged(locate: beforFrame, view: self)
    }
    
}
