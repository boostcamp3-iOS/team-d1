//
//  ArtAddInstaViewController.swift
//  BeBrav
//
//  Created by 공지원 on 20/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit
import Photos

protocol ArtAddViewControllerDelegate: class {
    func reloadMainView(controller: ArtAddViewController)
}

class ArtAddViewController: UIViewController {
    
    private let cellIdentifier = "ArtAddCollectionViewCell"
    private let spacing: CGFloat = 12
    private let numOfItemsPerRow: CGFloat = 4
    private let minimumLineSpacingForSectionAt: CGFloat = 3
    private let minimumInteritemSpacingForSectionAt: CGFloat = 3
    private let targetSizeWidth = 280
    private let targetSizeHeight = 280
    
    private lazy var imageManager = PHCachingImageManager()
    private var firstItemImage: UIImage?
    
    private var fetchResult: PHFetchResult<PHAsset>?
    private var cameraRoll: PHAssetCollection?
    
    weak var delegate: ArtAddViewControllerDelegate?
    
    private let uid = UserDefaults.standard.string(forKey: "uid")
    
    private let container = NetworkDependencyContainer()
    
    private lazy var serverDB = container.buildServerDatabase()
    private lazy var serverST = container.buildServerStorage()
    private lazy var serverAu = container.buildServerAuth()
    private lazy var manager = ServerManager(authManager: serverAu,
                                             databaseManager: serverDB,
                                             storageManager: serverST,
                                             uid: self.uid ?? "")
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("cancel".localized, for: .normal)
        button.titleLabel?.tintColor = .white
        return button
    }()
    
    let uploadButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("share".localized, for: .normal)
        button.titleLabel?.tintColor = .white
        return button
    }()
    
    let titleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        textField.borderStyle = .roundedRect
        textField.font = UIFont.boldSystemFont(ofSize: 20)
        textField.placeholder = "artworkTitle".localized
        textField.attributedPlaceholder = NSAttributedString(string: "artworkTitle".localized, attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
        textField.textAlignment = .center
        textField.backgroundColor = #colorLiteral(red: 0.2247451784, green: 0.2193362291, blue: 0.2924295654, alpha: 1)
        return textField
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
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
    
    let temperatureLabel: UILabel = {
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
    
    private let loadingIndicator: LoadingIndicatorView = {
        let indicator = LoadingIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.deactivateIndicatorView()
        indicator.noticeLabel.text = "uploading artwork".localized
        return indicator
    }()
    
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = #colorLiteral(red: 0.1780431867, green: 0.1711916029, blue: 0.2278442085, alpha: 1)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestAlbumAuth()
        
        setUpViews()
        setCollectionView()
        setLoadingView()
        titleTextField.delegate = self
        
        cancelButton.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
        uploadButton.addTarget(self, action: #selector(uploadButtonDidTap), for: .touchUpInside)
    }
    
    func setLoadingView() {
        view.addSubview(loadingIndicator)
        loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingIndicator.heightAnchor.constraint(equalToConstant: 60).isActive = true
        loadingIndicator.widthAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    //사용자로부터 사진첩 접근 허용 받기
    func requestAlbumAuth() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("authorized")
            self.getFetchResult()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.commonInit()
            }
        case .denied:
            print("denied")
            showDeniedAlert()
            
        case .notDetermined:
            print("notDetermined")
            PHPhotoLibrary.requestAuthorization({ (status) in
                switch status {
                case .authorized:
                    print("authorized")
                    self.getFetchResult()
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        self.commonInit()
                    }
                case .denied:
                    print("denied")
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                default: break
                }
            })
        case .restricted:
            print("restricted")
        }
    }
    
    func showDeniedAlert() {
        let alertController = UIAlertController(title: "photoAccessDenied".localized, message: "photoAccessDeniedMessage".localized, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "done".localized, style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func getFetchResult() {
        //카메라롤에 접근
        guard let cameraRoll = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil).firstObject else { return }
        
        let fetchOption = PHFetchOptions()
        fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        fetchResult = PHAsset.fetchAssets(in: cameraRoll, options: fetchOption)
    }
    
    func commonInit() {
        guard let fetchResult = fetchResult else { return }
        guard let asset = fetchResult.firstObject else { return }
        imageManager.requestImage(for: asset, targetSize: CGSize(width: targetSizeWidth, height: targetSizeHeight), contentMode: .aspectFill, options: nil) { (image, _) in
            
            guard let image = image else { return }
            self.imageView.image = image
            
            self.imageSorting(image: image)
        }
        
        collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .top)
    }
    
    @objc func cancelButtonDidTap() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func uploadButtonDidTap() {
        loadingIndicator.activateIndicatorView()
        guard let titleText = titleTextField.text else { return }
        var title = titleText
        
        //title을 따로 지정해주지 않았다면, 작품명을 "무제"로 업로드함
        if title.isEmpty {
            title = "noTitle".localized
        }
        
        guard let uploadImage = imageView.image else { return }
        
        uploadButton.isEnabled = false
            self.manager.uploadArtwork(image: uploadImage, scale: 0.1, path: "artworks", fileName: title, completion: { (result) in
                switch result {
                case .failure(let error):
                    print(error)
                case .success:
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: {
                            self.uploadButton.isEnabled = true
                            self.loadingIndicator.deactivateIndicatorView()
                            self.delegate?.reloadMainView(controller: self)
                        })
                    }
                }
            })
    }
    
    func showImageSortResultLabel() {
        orientationLabel.isHidden = false
        colorLabel.isHidden = false
        temperatureLabel.isHidden = false
    }
    
    func setUpViews() {
        view.backgroundColor = #colorLiteral(red: 0.1780431867, green: 0.1711916029, blue: 0.2278442085, alpha: 1)
        
        view.addSubview(cancelButton)
        view.addSubview(uploadButton)
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
        
        imageView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 10).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.5).isActive = true
        
        titleTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleTextField.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor).isActive = true
        titleTextField.widthAnchor.constraint(equalToConstant: view.frame.width * 0.6).isActive = true
        titleTextField.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        orientationLabel.trailingAnchor.constraint(equalTo: colorLabel.leadingAnchor, constant: -5).isActive = true
        orientationLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -5).isActive = true
        
        colorLabel.trailingAnchor.constraint(equalTo: temperatureLabel.leadingAnchor, constant: -5).isActive = true
        colorLabel.bottomAnchor.constraint(equalTo: orientationLabel.bottomAnchor).isActive = true
        
        temperatureLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -5).isActive = true
        temperatureLabel.bottomAnchor.constraint(equalTo: colorLabel.bottomAnchor).isActive = true
        
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
    
    func clearImageViewLabels() {
        orientationLabel.isHidden = true
        colorLabel.isHidden = true
        temperatureLabel.isHidden = true
        
        imageView.image = nil
        titleTextField.text = nil
    }
    
    func imageSorting(image: UIImage?) {
        DispatchQueue.global(qos: .userInitiated).async {
            var imageSort = ImageSort(input: image)
            
            guard let r1 = imageSort.orientationSort(), let r2 = imageSort.colorSort(), let r3 = imageSort.temperatureSort() else { return }
            
            let orientation = r1 ? "#horizontal".localized : "#vertical".localized
            let color = r2 ? "#color".localized : "#gray".localized
            let temperature = r3 ? "#cold".localized : "#warm".localized
            
            DispatchQueue.main.async {
                self.showImageSortResultLabel()
                
                self.orientationLabel.text = orientation
                self.colorLabel.text = color
                self.temperatureLabel.text = temperature
            }
        }
    }
}

//Collection View Delegate
extension ArtAddViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        titleTextField.placeholder = "artworkTitle".localized
        
        clearImageViewLabels()
        
        guard let selectedItem = collectionView.cellForItem(at: indexPath) as? ArtAddCollectionViewCell else { return }
        let selectedItemImage = selectedItem.imageView.image
        imageView.image = selectedItemImage
        
        //분류 알고리즘 적용
        imageSorting(image: selectedItemImage)
    }
}

//Collection View Data Source
extension ArtAddViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? ArtAddCollectionViewCell else { return ArtAddCollectionViewCell() }
        
        guard let asset = fetchResult?.object(at: indexPath.row) else { return ArtAddCollectionViewCell() }
        
        imageManager.requestImage(for: asset, targetSize: CGSize(width: targetSizeWidth, height: targetSizeHeight), contentMode: .aspectFill, options: nil) { (image, _) in
            guard let image = image else { return }
            cell.imageView.image = image
        }
        
        return cell
    }
}

extension ArtAddViewController: UICollectionViewDelegateFlowLayout {
    
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

extension ArtAddViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
