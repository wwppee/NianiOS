//
//  LSYAlbumPicker.swift
//  AlbumPicker
//
//  Created by okwei on 15/8/5.
//  Copyright (c) 2015年 okwei. All rights reserved.
//

import Foundation
import UIKit
import AssetsLibrary

protocol LSYAlbumPickerDelegate : class{
    func AlbumPickerDidFinishPick(_ assets:NSArray)
}
class LSYAlbumPicker: SAViewController {
    let albumPickerCellIdentifer: String = "albumPickerCellIdentifer"
    var group: ALAssetsGroup!
    var maxminumNumber: Int = 0
    weak var delegate:LSYAlbumPickerDelegate!
    let padding: CGFloat = 8
    var selectedArray: [Int] = []
    var albumAssets: NSMutableArray!

    var albumView:UICollectionView! {
        didSet{
            albumView.allowsMultipleSelection = true
            albumView.delegate = self
            albumView.dataSource = self
            albumView.register(UINib(nibName: "LSYAlbumPickerCell", bundle: nil), forCellWithReuseIdentifier: "albumPickerCellIdentifer")
            self.view.addSubview(albumView)
        }
    }
    fileprivate func setup(){
        if let _title = self.group.value(forProperty: ALAssetsGroupPropertyName) as? String {
            _setTitle(_title)
        }
        setBarButtonImage("newOK", actionGesture: #selector(LSYAlbumPicker.onOK))
        self.view.backgroundColor = UIColor.black
        
        let widthImage = (globalWidth - padding * 2) / 3
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = padding
        flowLayout.itemSize = CGSize(width: widthImage, height: widthImage)
        flowLayout.sectionInset = UIEdgeInsets(top: padding, left: 0, bottom: padding, right: 0)
        
        self.albumView = UICollectionView(frame: CGRect(x: 0, y: 64, width: globalWidth, height: globalHeight - 64), collectionViewLayout: flowLayout)
        LSYAlbum.sharedAlbum().setupAlbumAssets(group: self.group, albumAssets: { (assets) -> () in
            self.albumAssets = assets
            self.albumView.reloadData()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    func onOK() {
        var arr: [ALAsset] = []
        if selectedArray.count > 0 {
            for i in 0...(selectedArray.count - 1) {
                let num = selectedArray[i]
                let obj = albumAssets[num] as! LSYAlbumModel
                let asset = obj.asset
                arr.append(asset!)
            }
        }
        delegate.AlbumPickerDidFinishPick(arr as NSArray)
    }
}
