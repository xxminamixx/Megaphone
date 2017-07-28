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
    func nimingLabelTapped()
}

class NamingLabelView: UIView {
    
    static let nibName = "NamingLabelView"
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var namingLabel: UILabel!
    
    var delegate: NamingLabelViewDelegate!
    
    override func awakeFromNib() {
        
        // NamingLabelViewにタップ判定付加
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(labelTapped))
        namingLabel.addGestureRecognizer(tapGesture)
        
        super.awakeFromNib()
    }
    
    // 閉じるボタンが押された時呼ばれる
    @IBAction func close(_ sender: Any) {
        delegate.namingViewClose(view: self)
    }
    
    // ラベルをタップした時に呼ばれる
    func labelTapped() {
        delegate.nimingLabelTapped()
//        let view = Bundle.main.loadNibNamed("TextViewController", owner: self, options: nil) as? TextViewController
//        let navigation = UINavigationController.init(rootViewController: view!)
//        present(navigation, animated: true, completion: nil)
    }
    
}
