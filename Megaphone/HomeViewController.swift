//
//  HomeViewController.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/07/18.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var stageTableView: UITableView!
    @IBOutlet weak var bannerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // テーブルビューの初期設定
        stageTableView.delegate = self
        stageTableView.dataSource = self
        let nib = UINib(nibName: StageTableViewCell.nibName, bundle: nil)
        stageTableView.register(nib, forCellReuseIdentifier: StageTableViewCell.nibName)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // ステージの個数分
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = stageTableView.dequeueReusableCell(withIdentifier: StageTableViewCell.nibName, for: indexPath) as! StageTableViewCell
        cell.stageName.text = "テスト"
        return cell
    }
    
}
