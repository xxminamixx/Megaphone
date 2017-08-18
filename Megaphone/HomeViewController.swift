//
//  HomeViewController.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/07/18.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit
import GoogleMobileAds

class HomeViewController: UIViewController {

    @IBOutlet weak var stageTableView: UITableView!
    @IBOutlet weak var bannerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView.backgroundColor = UIColor.darkGray   
        // 広告の設定
        let banner = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        // AdMobで発行された広告ユニットIDを設定
        banner.adUnitID = "ca-app-pub-9801569699151969/2940484932"
        banner.delegate = self
        banner.rootViewController = self
        let gadRequest:GADRequest = GADRequest()
        
        // テスト用の広告を表示する時のみ使用（申請時に削除）
//        gadRequest.testDevices = [kGADSimulatorID]
        
        banner.load(gadRequest)
        bannerView.addSubview(banner)
        
        // テーブルビューの初期設定
        stageTableView.backgroundColor = UIColor.darkGray
        stageTableView.delegate = self
        stageTableView.dataSource = self
        let nib = UINib(nibName: StageTableViewCell.nibName, bundle: nil)
        stageTableView.register(nib, forCellReuseIdentifier: StageTableViewCell.nibName)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // タイトルを設定
        navigationItem.title = "めがほん"
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
        let viewController = storyboard?.instantiateViewController(withIdentifier: NamingViewController.identifier) as! NamingViewController
        
        let stageEntity = JsonManager.shared.stages?[indexPath.row]
        viewController.navigationItem.title = stageEntity?.stageName

        if let imageName = stageEntity?.imageName {
            // 画像を生成
            if let image = UIImage(named: imageName) {
                // 画面いっぱい
                let fullScreen = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                
                // イメージビュー生成
                let imageView = UIImageView(frame: fullScreen)
                imageView.contentMode = .scaleAspectFit
                imageView.image = image
                imageView.isUserInteractionEnabled = true
                viewController.imageView = imageView
            }
        }
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return JsonManager.shared.stageCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = stageTableView.dequeueReusableCell(withIdentifier: StageTableViewCell.nibName, for: indexPath) as! StageTableViewCell
        
        guard let stageList = JsonManager.shared.stages else {
            // jsonのパースに失敗していた場合ステージ名をセットせずリターン
            return cell
        }
        
        cell.stageName.text = stageList[indexPath.row].stageName
        
        // 選択時のスタイルを無しにする
        cell.selectionStyle = .none
        
        return cell
    }
    
}

// MARK: GADBannerViewDelegate
extension HomeViewController: GADBannerViewDelegate {
    
}
