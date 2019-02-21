//
//  ArtAddInstaViewController.swift
//  BeBrav
//
//  Created by 공지원 on 20/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit
import Photos

protocol ArtAddInstaViewControllerDelegate: class {
    func uploadArtwork(_ controller: ArtAddInstaViewController, image: UIImage, title: String)
}

class ArtAddInstaViewController: UIViewController {
    
    var fetchResult: PHFetchResult<PHAsset>?
    var cameraRoll: PHAssetCollection?
    var imageList: [UIImage] = []
    
    let imageManager = PHCachingImageManager()
    
    let cellIdentifier = "ArtAddCollectionViewCell"
    let spacing: CGFloat = 12
    let numOfItemsPerRow: CGFloat = 4
    let minimumLineSpacingForSectionAt: CGFloat = 3
    let minimumInteritemSpacingForSectionAt: CGFloat = 3
    
    weak var delegate: ArtAddInstaViewControllerDelegate?
    
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
    
    let titleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.attributedPlaceholder = NSAttributedString(string: "작품 제목", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)])
        textField.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        textField.borderStyle = .none
        textField.font = UIFont.boldSystemFont(ofSize: 30)
        return textField
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .white
        return imageView
    }()
    
    let orientationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.isHidden = true
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 3.0
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize(width: 4, height: 4)
        label.layer.masksToBounds = false
        return label
    }()
    
    let colorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.isHidden = true
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 3.0
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize(width: 4, height: 4)
        label.layer.masksToBounds = false
        return label
    }()
    
    let temperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.isHidden = true
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 3.0
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize(width: 4, height: 4)
        label.layer.masksToBounds = false
        return label
    }()
    
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .black
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //FiXME: - 앱 제일 처음 시작할때 접근 허용 받도록 하기
        requestAlbumAuth()
        
        setUpViews()
        setCollectionView()
        
        titleTextField.delegate = self
        
        cancelButton.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
        uploadButton.addTarget(self, action: #selector(uploadButtonDidTap), for: .touchUpInside)
        
        fetchImages()
        
    }
    
    //Helper Method
    func fetchImages() {
        guard let cameraRoll = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil).firstObject else { return }
        
        let fetchOption = PHFetchOptions()
        fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        fetchResult = PHAsset.fetchAssets(in: cameraRoll, options: fetchOption)
        
        for i in 0..<fetchResult!.count {
        let asset = fetchResult?.object(at: i)
        
        let width = view.frame.width
        let height = view.frame.height * 0.5
        
            imageManager.requestImage(for: asset!, targetSize: CGSize(width: width, height: height), contentMode: .aspectFill, options: nil) { (image, _) in
            self.imageList.append(image!)
            
            if i==0 {
                self.imageView.image = image
            }
        }
            
            DispatchQueue.global().async {
                var imageSort = ImageSort(input: self.imageList[0])
                
                guard let r1 = imageSort.orientationSort(), let r2 = imageSort.colorSort(), let r3 = imageSort.temperatureSort() else { return }
                
                let orientation = r1 ? "#가로" : "#세로"
                let color = r2 ? "#컬러" : "#흑백"
                let temperature = r3 ? "#차가움" : "#따뜻함"
                
                DispatchQueue.main.async {
                    self.showImageSortResultLabel()
                    
                    self.orientationLabel.text = orientation
                    self.colorLabel.text = color
                    self.temperatureLabel.text = temperature
                }
            }
        }
    }
    
    @objc func cancelButtonDidTap() {
        //dismiss(animated: true, completion: nil)
    }
    
    @objc func uploadButtonDidTap() {
        //업로드
        var title = titleTextField.text
        
        //title을 따로 지정해주지 않았다면, 작품명을 "무제"로 업로드함
        if titleTextField.text?.isEmpty == true {
            title = "무제"
        }
        
        //delegate?.uploadArtwork(self, image: imageView.image, title: titleTextField.text)
    }
    
    //사용자로부터 사진첩 접근 허용 받기
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
        //FIXME: - 색 변경 예정
        view.backgroundColor = .black
        
        view.addSubview(cancelButton)
        view.addSubview(uploadButton)
        //view.addSubview(titleTextField)
        view.addSubview(imageView)
        view.addSubview(titleTextField)
        view.addSubview(orientationLabel)
        view.addSubview(colorLabel)
        view.addSubview(temperatureLabel)
        view.addSubview(collectionView)
        
        //set constraint
        cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        
        uploadButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        uploadButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
        
//        titleTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        titleTextField.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor).isActive = true
//
        imageView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 10).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.5).isActive = true
        
        titleTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: view.frame.width * 0.5).isActive = true 
        titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.frame.height * 0.48).isActive = true
        
        temperatureLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -10).isActive = true
        temperatureLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -5).isActive = true
        
        colorLabel.bottomAnchor.constraint(equalTo: temperatureLabel.bottomAnchor).isActive = true
        colorLabel.trailingAnchor.constraint(equalTo: temperatureLabel.leadingAnchor, constant: -10).isActive = true
        
        orientationLabel.bottomAnchor.constraint(equalTo: colorLabel.bottomAnchor).isActive = true
        orientationLabel.trailingAnchor.constraint(equalTo: colorLabel.leadingAnchor, constant: -10).isActive = true

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
    
    func showImageSortResultLabel() {
        orientationLabel.isHidden = false
        colorLabel.isHidden = false
        temperatureLabel.isHidden = false
    }
}

//Collection View Delegate
extension ArtAddInstaViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        imageView.image = nil
        titleTextField.text = nil
        titleTextField.placeholder = "작품 제목"
        
        //FIXME: - imageView의 image 화질이 이상함
        print(indexPath) //FIXME: - 제거
        let selectedImage = imageList[indexPath.row]
        imageView.image = selectedImage
        
        DispatchQueue.global().async {
            var imageSort = ImageSort(input: selectedImage)
            
            guard let r1 = imageSort.orientationSort(), let r2 = imageSort.colorSort(), let r3 = imageSort.temperatureSort() else { return }
            
            let orientation = r1 ? "#가로" : "#세로"
            let color = r2 ? "#컬러" : "#흑백"
            let temperature = r3 ? "#차가움" : "#따뜻함"
            
            DispatchQueue.main.async {
                //self.showImageSortResultLabel()
                
                self.orientationLabel.text = orientation
                self.colorLabel.text = color
                self.temperatureLabel.text = temperature
            }
        }
    }
}

//Collection View Data Source
extension ArtAddInstaViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? ArtAddCollectionViewCell else { return ArtAddCollectionViewCell() }
        
        cell.imageView.image = imageList[indexPath.row]

        return cell
    }
}


extension ArtAddInstaViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width - spacing) / numOfItemsPerRow
        let cellHeight = cellWidth
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacingForSectionAt
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumInteritemSpacingForSectionAt
    }
}

extension ArtAddInstaViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing")
    }
}
