//
//  StampSelectView.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/08/14.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit

protocol StampSelectViewDelegate {
    func stampSelectCloseTapped()
    func stampSelectImageTapped(imageName: String)
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
            self.delegate.stampSelectCloseTapped()
        }
    }
    
}

extension StampSelectView: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt: IndexPath) {
    
        // TODO: タップしたスタンプをnamingViewControllerに引き渡す処理
        // デリゲートメソッドを使って画像を渡す
        let imageName = JsonManager.shared.stamps?[didSelectItemAt.row].name
        
        if let name = imageName {
            delegate.stampSelectImageTapped(imageName: name)
        }

    }
}

extension StampSelectView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return JsonManager.shared.stampCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StampCollectionViewCell.nibName , for: indexPath) as! StampCollectionViewCell
        
        let imageName = JsonManager.shared.stamps?[indexPath.row].name
        
        if let name = imageName {
            if let image = UIImage(named: name) {
                cell.setting(image: image)
            }
        }
        
        return cell
    }
}
