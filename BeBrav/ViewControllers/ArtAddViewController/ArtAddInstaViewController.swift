//
//  ArtAddInstaViewController.swift
//  BeBrav
//
//  Created by 공지원 on 20/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit
import Photos

class ArtAddInstaViewController: UIViewController {
    
    //properties for photos
    var fetchResult: PHFetchResult<PHAsset>?
    let imageManager: PHCachingImageManager = PHCachingImageManager()
    var cameraRoll: PHAssetCollection?
    var imageList: [UIImage] = []
    
    let cellIdentifier = "ArtAddCollectionViewCell"
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    let cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("취소", for: .normal)
        button.titleLabel?.tintColor = .white
        return button
    }()
    
    let uploadButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("등록", for: .normal)
        button.titleLabel?.tintColor = .white
        return button
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .white
        return imageView
    }()
    
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .black
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestAlbumAuth()
        
        setUpViews()
        setCollectionView()
        
        guard let cameraRoll = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil).firstObject else { return }
        
        let fetchOption = PHFetchOptions()
        fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        fetchResult = PHAsset.fetchAssets(in: cameraRoll, options: fetchOption)
        
        let asset = fetchResult?.firstObject
        
        imageManager.requestImage(for: asset!, targetSize: CGSize(width: (collectionView.frame.width-12)/4, height: (collectionView.frame.width-12)/4), contentMode: .aspectFill, options: nil) { (image, _) in
            self.imageView.image = image
        }
        
    }
    
    func requestAlbumAuth() {
        let requestHandler = { (status: PHAuthorizationStatus) in
            switch status {
            case PHAuthorizationStatus.authorized:
                print("사진첩 접근 허용됨")
            case PHAuthorizationStatus.denied:
                print("사진첩 접근 거부됨")
            default:
                break
            }
        }
        
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized: print("사진첩 접근 허용됨")
        case .denied: print("사진첩 접근 거부됨")
        case .restricted: print("사진첩 접근 제한됨")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(requestHandler)
        }
    }
    
    func setUpViews() {
        view.backgroundColor = .black
        
        view.addSubview(cancelButton)
        view.addSubview(uploadButton)
        view.addSubview(imageView)
        view.addSubview(collectionView)
        
        //set constraint
        cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        
        uploadButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        uploadButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
        
        imageView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 10).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.5).isActive = true
        
        collectionView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    func setCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(ArtAddCollectionViewCell.self,
                                forCellWithReuseIdentifier: cellIdentifier)
    }
    
//    func configure(cell: ArtAddCollectionViewCell, collectionView: UICollectionView, indexPath: IndexPath) {
//        //카메라롤 가져오기
//
//        guard let maxIndex = fetchResult?.count else { return }
//
//
//
//        guard let assetList = assetList else { return }
//
//        let asset = assetList[indexPath.row]
//
//        let width = (collectionView.frame.width - 12) / 4
//        let height = width
//        imageManager.requestImage(for: asset, targetSize: CGSize(width: width, height: height), contentMode: .aspectFit, options: nil) { (image, _) in
//            let cellAtIndex: UICollectionViewCell? = collectionView.cellForItem(at: indexPath)
//            guard let cell: ArtAddCollectionViewCell = cellAtIndex as? ArtAddCollectionViewCell else { return }
//
//            cell.imageView.image = image
//        }
//    }
}

extension ArtAddInstaViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //TODO: - 선택된 이미지를 imageView의 image로 지정
        print(indexPath)
        imageView.image = imageList[indexPath.row]
    }
}

extension ArtAddInstaViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? ArtAddCollectionViewCell else { return ArtAddCollectionViewCell() }
        
        let asset = fetchResult?.object(at: indexPath.row)
        let width = (collectionView.frame.width - 12) / 4
        let height = width
        imageManager.requestImage(for: asset!, targetSize: CGSize(width: width, height: height), contentMode: .aspectFit, options: nil) { (image, _) in
            
            if let image = image {
            self.imageList.append(image)
            }
            cell.imageView.image = image
        }
        return cell
    }
}


extension ArtAddInstaViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width - 12) / 4
        let cellHeight = cellWidth
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
}
