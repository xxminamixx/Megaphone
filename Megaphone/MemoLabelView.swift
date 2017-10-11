//
//  MemoLabelView.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/10/10.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit

protocol MemoLabelViewDelegate {
    // メモマーカーボタン
    func memoMarkerTapped(memoLabelView: MemoLabelView)
}

class MemoLabelView: UIView {

    static let nibName = "MemoLabelView"
    var delegate: MemoLabelViewDelegate?
    // マーカーがタップされたときにメモ文字列をTextViewに復元するために保持
    var memoText: String?
    var beforeFrame: CGPoint!
    
    @IBOutlet weak var memoButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // ドラックした時の処理
        self.onPan { pan in
            let location: CGPoint = pan.translation(in: self)
            let x = location.x + self.beforeFrame.x
            let y = location.y + self.beforeFrame.y
            self.beforeFrame = CGPoint(x: x, y: y)
            pan.setTranslation(CGPoint.zero, in: self)
            self.frame.origin = self.beforeFrame
        }

    }
    
    @IBAction func memoButtonTapped(_ sender: Any) {
        delegate?.memoMarkerTapped(memoLabelView: self)
    }
}
