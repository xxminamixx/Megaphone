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
    
    @IBOutlet weak var memoButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // TODO: マーカーボタンの初期色の設定などなど
    }
    
    @IBAction func memoButtonTapped(_ sender: Any) {
        delegate?.memoMarkerTapped(memoLabelView: self)
    }
}

//extension MemoLabelView: memoViewButtomTextFieldDelegate {
//    // メモビューがタップされてキーボードが出現したときにコールする
//    func memoViewTapped(keyBoardRect: CGRect) {
//        
//    }
//    
//    // キーボードが消えた時にコールする
//    func disableKeyBoard(text: String?) {
//        memoText = text
//    }
//}
