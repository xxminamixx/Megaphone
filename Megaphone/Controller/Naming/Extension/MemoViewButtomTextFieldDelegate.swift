//
//  MemoViewButtomTextFieldDelegate.swift
//  Megaphone
//
//  Created by 南　京兵 on 2018/01/24.
//  Copyright © 2018年 南　京兵. All rights reserved.
//

import UIKit

extension NamingViewController: MemoViewButtomTextFieldDelegate {
    func memoViewTapped(keyBoardRect: CGRect) {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .allowAnimatedContent, animations: {
            self.memoView?.frame.origin.y = self.view.frame.size.height - keyBoardRect.size.height - 200
        }, completion: { _ in })
    }
    
    func disableKeyBoard(text: String?) {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .allowAnimatedContent, animations: {
            self.memoView?.frame.origin.y = self.view.frame.size.height - 200
            // メモビューのテキストをメモマーカーのプロパティに格納
            self.memoMarker?.memoText = text
        }, completion: { _ in })
    }
    
    func deleteMemoMerker() {
        // アニメーションでメモビューを画面外に移動
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .allowAnimatedContent, animations: {
            self.memoView?.frame.origin.y = self.view.frame.size.height
        }, completion: { _ in })
        // メモビューを選択しているかはオプショナルバインディングで判定しているのでnilを代入
        memoView = nil
        // メモマーカーを削除
        memoMarker?.removeFromSuperview()
    }
}
