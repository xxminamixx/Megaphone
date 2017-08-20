//
//  StampCollectionViewCell.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/08/14.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit

class StampCollectionViewCell: UICollectionViewCell {
    
    static let nibName = "StampCollectionViewCell"

    @IBOutlet weak var stamp: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setting(image: UIImage) {
        self.stamp.image = image
    }

}
