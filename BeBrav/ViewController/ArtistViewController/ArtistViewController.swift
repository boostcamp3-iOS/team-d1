//
//  ArtistViewController.swift
//  BeBrav
//
//  Created by Seonghun Kim on 24/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class ArtistViewController: UIViewController {
    
    private let layout: (spacing: CGFloat, inset: CGFloat) = (5.0, 0.0)
    
    // MARK:- Outlet
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private let editButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem()
        barButtonItem.title = "편집"
        barButtonItem.style = .plain
        return barButtonItem
    }()
    
    // MARK:- Properties
    private let photoListIdentifier = "PhotoListCollectionViewCell"
    private let photoListHeaderIdentifier = "PhotoListHeaderCollectionReusableView"
    private let artistDetailHeaderView = "ArtistDetailHeaderView"
    private var isEditmode = false {
        didSet {
            navigationItem.title = isEditmode ? "수정" : "아티스트"
            editButton.title = isEditmode ? "확인" : "편집"
            editButton.style = isEditmode ? .plain : .done
            collectionView.allowsMultipleSelection = isEditmode
            collectionView.allowsSelection = isEditmode
            collectionView.reloadData()
        }
    }
    
    // MARK:- Initialize
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "아티스트"
        navigationItem.rightBarButtonItem = editButton
        
        setCollectionView()
        
        editButton.target = self
        editButton.action = #selector(editButtonDidTap(_:))
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setLayout()
    }
    
    // MARK:- Set CollectionView
    private func setCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsSelection = false
        collectionView.register(PhotoListCollectionViewCell.self,
                                forCellWithReuseIdentifier: photoListIdentifier)
        collectionView.register(PhotoListHeaderCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: photoListHeaderIdentifier)
        collectionView.register(ArtistDetailHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: artistDetailHeaderView)
    }
    
    // MARK:- Set Layout
    private func setLayout() {
        view.addSubview(collectionView)
        
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
    
    // MARK:- Edit Button Did Tap
    @objc func editButtonDidTap(_ sender: UIBarButtonItem) {
        isEditmode = !isEditmode
        
        // TODO: 편집모드에서 탭시 삭제 네트워킹 진행하도록 코드 추가
    }
    
    // MARK:- Delete Photo Button Did Tap
    @objc func deletePhotoButtonDidTap(_ sender: UIButton) {
        // TODO: 이미지 삭제 네트워킹 추가 후 코드 변경
    }
}

// MARK:- UICollectionView DataSource
extension ArtistViewController: UICollectionViewDataSource {
    // MARK:- UICollectionView Header View
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return .init() }
        
        switch indexPath.section {
        case 0:
            return artistDetailHeaderView(collectionView: collectionView, kind: kind, indexPath: indexPath)
        case 1:
            return photoListHeaderView(collectionView: collectionView, kind: kind, indexPath: indexPath)
        default:
            return .init()
        }
    }
    
    func artistDetailHeaderView(collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: artistDetailHeaderView, for: indexPath) as? ArtistDetailHeaderView else { return .init() }
        
        // TODO: 네트워킹 기능 추가 후 적합한 정보가 변경되도록 변경
        headerView.artistNameTextField.text = "작가제목"
        headerView.artistIntroTextView.text = "작가 간략 설명"
        headerView.isEditMode = isEditmode
        
        return headerView
    }
    
    func photoListHeaderView(collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: photoListHeaderIdentifier, for: indexPath) as? PhotoListHeaderCollectionReusableView else { return .init() }
        
        headerView.deleteButton.addTarget(self, action: #selector(deletePhotoButtonDidTap(_:)), for: .touchUpInside)
        headerView.deleteButton.isHidden = !isEditmode
        
        return headerView
    }
    
    // MARK:- UICollectionView Number of Sectino
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    // MARK:- UICollectionView Number of Cell
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 1:
            return 10
        default:
            return 0
        }
    }
    
    // MARK:- UICollectionView Cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 1:
            return photoListCollectionViewCell(collectionView: collectionView, indexPath: indexPath)
        default:
            return .init()
        }
    }
    
    func photoListCollectionViewCell(collectionView: UICollectionView, indexPath: IndexPath) -> PhotoListCollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoListIdentifier, for: indexPath) as? PhotoListCollectionViewCell else {
            return .init()
        }
        
        // TODO: 네트워킹을 추가 후 네트워킹의 이미지 값을 추가하도록 변경
        cell.imageView.image = UIImage(named: "north")
        
        return cell
    }
}

// MARK:- UICollectionView Delegate
extension ArtistViewController: UICollectionViewDelegate {
    
}

// MARK:- UICollectinoView Delegate FlowLayout
extension ArtistViewController: UICollectionViewDelegateFlowLayout {
    // MARK:- UICollectionView Header View Height
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        switch section {
        case 0:
            return CGSize(width: view.frame.width, height: view.frame.height * 0.5)
        case 1:
            return CGSize(width: view.frame.width, height: 50)
        default:
            return CGSize()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let cellWitdh = ((collectionView.frame.width - (layout.spacing * 2)) / 3)
        let cellHeight = cellWitdh
        return CGSize(width: cellWitdh, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return layout.spacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return layout.spacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: layout.inset, left: layout.inset, bottom: layout.inset, right: layout.inset)
    }
}
