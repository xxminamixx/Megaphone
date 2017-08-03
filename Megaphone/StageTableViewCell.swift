//
//  StageTableViewCell.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/07/18.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit

class StageTableViewCell: UITableViewCell {
    
    static let nibName = "StageTableViewCell"

    @IBOutlet weak var stageName: UILabel!
    
    override func awakeFromNib() {
        backgroundColor = UIColor.darkGray
        stageName.textColor = UIColor.white
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
