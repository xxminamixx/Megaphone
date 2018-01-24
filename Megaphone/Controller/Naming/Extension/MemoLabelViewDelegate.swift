//
//  MemoLabelViewDelegate.swift
//  Megaphone
//
//  Created by 南　京兵 on 2018/01/24.
//  Copyright © 2018年 南　京兵. All rights reserved.
//

import UIKit

extension NamingViewController: MemoLabelViewDelegate {
    func memoMarkerTapped(memoLabelView: MemoLabelView) {
        
        // メモモードじゃなかったら何もしない
        guard isMemo else {
            return
        }
        
        // タップされたマーカーのポインタが変わる前に前のポインタに文字を保存
        if let memoView = self.memoView {
            // テキストビューに文字が入力されていたら削除するまえにマーカーのプロパティに保持
            if let text = memoView.textView.text {
                self.memoMarker?.memoText = text
            }
            memoView.removeFromSuperview()
            // 一度ここにはいったら都度はいらないように
            self.memoView = nil
        }
        
        // タップされたマーカーを保持
        self.memoMarker = memoLabelView
        
        if let memoView = UINib(nibName: memoViewButtomTextField.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? memoViewButtomTextField {
            // メモビューを削除するためにタグ付けを行う
            memoView.tag = memoViewTag
            // デリゲートの設定
            memoView.delegate = self
            // 自身のプロパティに保持
            
            self.memoView = memoView
            // テキストフィールドに前回の文字を反映
            self.memoView?.textView.text = memoLabelView.memoText
            
            
            // 画面したにぴったりくっつくように表示
            self.memoView?.frame = CGRect.init(x: 0, y: self.view.frame.height - 200, width: self.view.frame.width, height: self.view.frame.height)
            imageView?.addSubview(self.memoView!)
        }
    }
    
}
