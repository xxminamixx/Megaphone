//
//  StampSelectView.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/08/14.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit

protocol StampSelectViewDelegate {
    func stampCloseTapped()
}

class StampSelectView: UIView {

    static let nibName = "StampSelectView"

    @IBOutlet weak var close: UIImageView!
    @IBOutlet weak var stampView: UICollectionView!
    
    var delegate: StampSelectViewDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.darkGray
        // コレクションビューの色を設定
        stampView.backgroundColor = UIColor.darkGray
        
        // コレクションビューの初期設定
        stampView?.delegate = self
        stampView?.dataSource = self
        stampView?.isUserInteractionEnabled = true
        let nib = UINib(nibName: StampCollectionViewCell.nibName, bundle: nil)
        stampView.register(nib, forCellWithReuseIdentifier: StampCollectionViewCell.nibName)
        
        close.onTap { _ in
            self.delegate.stampCloseTapped()
        }
    }
    
}

extension StampSelectView: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt: IndexPath) {}
}

extension StampSelectView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StampCollectionViewCell.nibName , for: indexPath) as! StampCollectionViewCell
        
        cell.setting(image: UIImage(named: "stamp.png")!)
        
        return cell
    }
}
