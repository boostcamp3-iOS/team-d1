//
//  MainAutoResizingCollectionViewController.swift
//  BeBrav
//
//  Created by bumslap on 28/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class MainAutoResizingCollectionViewController: UICollectionViewController {
    
    private let spacing: CGFloat = 0
    private let insets: CGFloat = 5
    private let padding: CGFloat = 2
    private let columns: CGFloat = 3
    private let imageAssets = [ #imageLiteral(resourceName: "fallow-deer-3729821_1920"),#imageLiteral(resourceName: "helicopter-2966569_1920"),#imageLiteral(resourceName: "lion-3372720_1920"),#imageLiteral(resourceName: "open-fire-3879031_1920"),#imageLiteral(resourceName: "photographer"),#imageLiteral(resourceName: "meteora-3717220_1920"),#imageLiteral(resourceName: "cat1"),#imageLiteral(resourceName: "evolution-3801547_1920"),#imageLiteral(resourceName: "rays"),#imageLiteral(resourceName: "harley-davidson-3794909_1920"),#imageLiteral(resourceName: "christmas-motif-3834860_1920"),#imageLiteral(resourceName: "hamburg"),#imageLiteral(resourceName: "rail-3678287_1920"),#imageLiteral(resourceName: "north"),#imageLiteral(resourceName: "IMG_4B21E85D1553-1"), #imageLiteral(resourceName: "fallow-deer-3729821_1920"),#imageLiteral(resourceName: "helicopter-2966569_1920"),#imageLiteral(resourceName: "lion-3372720_1920"),#imageLiteral(resourceName: "open-fire-3879031_1920"),#imageLiteral(resourceName: "photographer"),#imageLiteral(resourceName: "meteora-3717220_1920"),#imageLiteral(resourceName: "cat1"),#imageLiteral(resourceName: "evolution-3801547_1920"),#imageLiteral(resourceName: "rays"),#imageLiteral(resourceName: "harley-davidson-3794909_1920"),#imageLiteral(resourceName: "christmas-motif-3834860_1920"),#imageLiteral(resourceName: "hamburg"),#imageLiteral(resourceName: "rail-3678287_1920"),#imageLiteral(resourceName: "north"),#imageLiteral(resourceName: "IMG_4B21E85D1553-1"), #imageLiteral(resourceName: "fallow-deer-3729821_1920"),#imageLiteral(resourceName: "helicopter-2966569_1920"),#imageLiteral(resourceName: "lion-3372720_1920"),#imageLiteral(resourceName: "open-fire-3879031_1920"),#imageLiteral(resourceName: "photographer"),#imageLiteral(resourceName: "meteora-3717220_1920"),#imageLiteral(resourceName: "cat1"),#imageLiteral(resourceName: "evolution-3801547_1920"),#imageLiteral(resourceName: "rays"),#imageLiteral(resourceName: "harley-davidson-3794909_1920"),#imageLiteral(resourceName: "christmas-motif-3834860_1920"),#imageLiteral(resourceName: "hamburg"),#imageLiteral(resourceName: "rail-3678287_1920"),#imageLiteral(resourceName: "north"),#imageLiteral(resourceName: "IMG_4B21E85D1553-1") ]
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionView()
    }
    
    func setCollectionView() {
        guard let collectionView = self.collectionView else { return }
        collectionView.register(MainAutoResizingCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        if var layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
         //   layout.minimumInteritemSpacing = 0
           // layout.minimumLineSpacing = insets
            
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
        return calculateNumberOfArtworksPerPage(numberOfColums: columns, viewWidth: collectionView.frame.width, viewHeight: collectionView.frame.height, spacing: 0, insets: 2)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? MainAutoResizingCollectionViewCell else {
            assertionFailure("failed to make cell")
            return .init()
        }
        cell.artworkImageView.image = imageAssets[indexPath.row]
        return cell
    }
}

extension MainAutoResizingCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let insetsNumber = columns + 1
        let width = (collectionView.frame.width - (insetsNumber * spacing) - (insetsNumber * insets)) / columns
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: insets, left: insets, bottom: insets, right: insets)
    }
}

extension MainAutoResizingCollectionViewController: MostViewedArtworkDelegate {
    
    func collectionView(_ collectionView:UICollectionView, mostViewedArtworkIndexPath indexPath:IndexPath) -> Bool {
        return true
    }
}

