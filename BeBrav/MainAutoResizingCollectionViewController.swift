//
//  MainAutoResizingCollectionViewController.swift
//  BeBrav
//
//  Created by bumslap on 25/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.

import UIKit

private let reuseIdentifier = "Cell"

class MainAutoResizingCollectionViewController: UICollectionViewController {
    
    let insets: CGFloat = 5
    let padding: CGFloat = 2
    let columns: CGFloat = 3
    let imageAssets = [#imageLiteral(resourceName: "rail-3678287_1920"),#imageLiteral(resourceName: "evolution-3801547_1920"),#imageLiteral(resourceName: "cat1"),#imageLiteral(resourceName: "harley-davidson-3794909_1920"),#imageLiteral(resourceName: "hamburg"),#imageLiteral(resourceName: "photographer"),#imageLiteral(resourceName: "meteora-3717220_1920"),#imageLiteral(resourceName: "landscape-3779159_1920"),#imageLiteral(resourceName: "open-fire-3879031_1920"),#imageLiteral(resourceName: "rays"),#imageLiteral(resourceName: "rays"),#imageLiteral(resourceName: "helicopter-2966569_1920"),#imageLiteral(resourceName: "IMG_4B21E85D1553-1"),#imageLiteral(resourceName: "north"),#imageLiteral(resourceName: "cat2"),#imageLiteral(resourceName: "christmas-motif-3834860_1920"),#imageLiteral(resourceName: "lion-3372720_1920"),#imageLiteral(resourceName: "fallow-deer-3729821_1920")]
    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionView()
    }
    
    func setCollectionView() {
        self.collectionView!.register(MainAutoResizingCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
            collectionView.delegate = self
        collectionView.dataSource = self
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            //TODO: Layout 변경해야함
        }
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //TODO: 몇개의 데이터를 가져올지 결정하는 로직 구성
        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top
        let insetsNumber = columns * 2 - (columns - 1)
        let width = (collectionView.frame.width - insetsNumber * 0 - insetsNumber * insets) / columns
        var height = (collectionView.frame.height - CGFloat(topPadding ?? 0)) / width
        height.round(FloatingPointRoundingRule.toNearestOrEven)
        return Int(height*columns)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? MainAutoResizingCollectionViewCell else {
            return .init()
        }
        cell.artworkImageView.image = imageAssets[indexPath.row]
        // Configure the cell
        
        return cell
    }
    // MARK: UICollectionViewDelegate
}

extension MainAutoResizingCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if var flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.minimumLineSpacing = insets
        }
        let insetsNumber = columns * 2 - (columns - 1)
        let width = (collectionView.frame.width - insetsNumber * 0 - insetsNumber * insets) / columns
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: insets, left: insets, bottom: insets, right: insets)
    }
}

