//
//  ArtistDetailCollectionViewController.swift
//  BeBrav
//
//  Created by 공지원 on 22/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ArtistDetailCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let headerId = "headerId"
    
    let headerView: UIView = {
        let view = UIView()
        return view
    }()
    
    let artistImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "user")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        //headerView.addSubview(artistImageView)
        
        //setUpHeaderViewLayout()
    }
    
    //headerView 제약조건
    func setUpHeaderViewLayout() {
        artistImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        artistImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 100).isActive = true
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    //add headerView to collectionView header
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath)
        header.backgroundColor = .blue 
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 300)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }
    
    /*
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController = ArtAddViewController()
        self.navigationController?.pushViewController(viewController, animated: false)
    }
     */
}


