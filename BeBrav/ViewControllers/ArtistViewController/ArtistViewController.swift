//
//  ArtistViewController.swift
//  BeBrav
//
//  Created by Seonghun Kim on 24/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class ArtistViewController: UIViewController {
    
    // MARK:- Outlet
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect(),
                                              collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private let signOutButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem()
        barButtonItem.title = "signOut".localized
        barButtonItem.style = .plain
        return barButtonItem
    }()
    
    private let loadingIndicator: LoadingIndicatorView = {
        let indicator = LoadingIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.noticeLabel.text = "loadingImages".localized
        return indicator
    }()
    
    // MARK:- Properties
    private let layout: (spacing: CGFloat, inset: CGFloat) = (5.0, 0.0)
    private let prefetchSize = 6
    private let artworkListIdentifier = "ArtworkListCollectionViewCell"
    private let artworkListHeaderIdentifier = "ArtworkListHeaderCollectionReusableView"
    private let artistDetailHeaderView = "ArtistDetailHeaderView"
    private let tempIdentifier = "temp"
    private let imageLoader: ImageLoaderProtocol
    private let serverDatabase: ServerDatabase
    private let databaseHandler: DatabaseHandler
    
    private var artworkList: [Artwork] = []
    private var artistData: UserDataDecodeType?
    private var artworkImage: [String: UIImage] = [:]
    private var isEditmode = false {
        didSet {
            navigationItem.title = isEditmode ? "modification".localized : "artist".localized
            signOutButton.title = isEditmode ? "done".localized : "edit".localized
            signOutButton.style = isEditmode ? .plain : .done
        }
    }
    public var userUid: String?
    public var isUser = false {
        didSet {
            navigationItem.rightBarButtonItem = signOutButton
            userUid = UserDefaults.standard.string(forKey: "uid")
        }
    }
    
    // MARK:- Initialize
    init(imageLoader: ImageLoaderProtocol,
         serverDatabase: ServerDatabase,
         databaseHandler: DatabaseHandler)
    {
        self.imageLoader = imageLoader
        self.serverDatabase = serverDatabase
        self.databaseHandler = databaseHandler
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "artist".localized
        
        setCollectionView()
        
        fetchArtistData()
        
        signOutButton.target = self
        signOutButton.action = #selector(signOutButtonDidTap(_:))
        loadingIndicator.activateIndicatorView()
        
        if UIApplication.shared.keyWindow?.traitCollection.forceTouchCapability == .available
        {
            registerForPreviewing(with: self, sourceView: collectionView)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setLayout()
    }
    
    // MARK:- Fetch artist data from Server
    private func fetchArtistData() {
        guard let uid = userUid else { return }
        
        let queries = [URLQueryItem(name: "orderBy", value: "\"uid\""),
                       URLQueryItem(name: "equalTo", value: "\"\(uid)\"")
        ]
        
        serverDatabase.read(path: "root/users",
                            type:[String: UserDataDecodeType].self,
                            headers: [:], queries: queries) { result, responds  in
            switch result {
            case .failure:
                self.fetchDataFromDatabase(id: uid)
            case .success(let data):
                guard let data = data[uid] else { return }
                self.artistData = data
                self.saveDataToDatabase(data: data)
                
                DispatchQueue.main.async {
                    self.setImageList()
                    self.collectionView.reloadData()
                    self.loadingIndicator.deactivateIndicatorView()
                }
            }
        }
    }
    
    // MARK:- Fetch data from database
    private func fetchDataFromDatabase(id: String) {
        databaseHandler.readData(type: .artistData, id: id) { data, error in
            guard let data = data as? ArtistModel else {
                self.showErrorAlert()
                return
            }
            
            self.databaseHandler.readArtworkArray(artist: data) { artworks, error in
                guard let artworks = artworks else {
                    self.showErrorAlert()
                    return
                }
                
                let list = artworks.sorted{ $0.timestamp > $1.timestamp }
                var artworksDictionary: [String: Artwork] = [:]
                
                list.forEach{ artworksDictionary[$0.id] = Artwork(artworkModel: $0) }
                
                let artistData = UserDataDecodeType(uid: data.id,
                                                    nickName: data.name,
                                                    description: data.description,
                                                    artworks: artworksDictionary)
                self.artistData = artistData
                
                DispatchQueue.main.async {
                    self.setImageList()
                    self.collectionView.reloadData()
                    self.loadingIndicator.deactivateIndicatorView()
                }
            }
        }
    }
    
    // MARK:- Save data to database
    private func saveDataToDatabase(data: UserDataDecodeType) {
        let author = ArtistModel(id: data.uid, name: data.nickName, description: data.description)
        
        databaseHandler.saveData(data: author)
        
        data.artworks.forEach{
            let artwork = ArtworkDecodeType(artwork: $0.value, userName: data.nickName, userUid: data.uid)
            
            databaseHandler.saveData(data: ArtworkModel(artwork: artwork))
        }
    }
    
    // MARK:- Set Artist's image list
    private func setImageList() {
        guard let artistData = artistData else { return }
        artworkList = artistData.artworks.map{ $0.value }.sorted{ $0.timestamp > $1.timestamp }
        artworkList.indices.forEach{
            self.fetchImage(index: $0, prefetch: true)
        }
    }
    
    // MARK:- Fetch image
    private func fetchImage(index: Int, prefetch: Bool) {
        let artwork = artworkList[index]
        let indexPath = IndexPath(item: index, section: 1)
        
        if artworkImage[artwork.artworkUid] == nil {
            guard let url = URL(string: artwork.artworkUrl) else { return }
            
            imageLoader.fetchImage(url: url, size: .small) { image, error in
                guard let image = image else { return }
                self.artworkImage[artwork.artworkUid] = image
                
                if !prefetch  {
                    DispatchQueue.main.async {
                        self.collectionView.reloadItems(at: [indexPath])
                    }
                }
            }
        }
    }
    
    // MARK:- Show error alert
    private func showErrorAlert() {
        let alert = UIAlertController(title: "networkError".localized,
                                      message: "artistNetworkErrorMessage".localized,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: "done".localized, style: .default) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        
        present(alert, animated: false, completion: nil)
    }
    
    // MARK:- Set CollectionView
    private func setCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = false
        collectionView.register(ArtworkListCollectionViewCell.self,
                                forCellWithReuseIdentifier: artworkListIdentifier)
        collectionView.register(ArtworkListHeaderCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: artworkListHeaderIdentifier)
        collectionView.register(ArtistDetailHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: artistDetailHeaderView)
        collectionView.register(TempCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: tempIdentifier)
    }
    
    // MARK:- Set layout
    private func setLayout() {
        view.addSubview(collectionView)
        view.addSubview(loadingIndicator)
        view.backgroundColor = #colorLiteral(red: 0.1780431867, green: 0.1711916029, blue: 0.2278442085, alpha: 1)
        collectionView.backgroundColor = #colorLiteral(red: 0.1780431867, green: 0.1711916029, blue: 0.2278442085, alpha: 1)
        
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingIndicator.heightAnchor.constraint(equalToConstant: 60).isActive = true
        loadingIndicator.widthAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    // MARK:- Edit button did tap
    @objc func signOutButtonDidTap(_ sender: UIBarButtonItem) {
        UserDefaults.standard.removeObject(forKey: "uid")
        
        let server = NetworkDependencyContainer().buildServerAuth()
        let signInViewController = SignInViewController(serverAuth: server)
        
        let newRootViewController = UINavigationController(rootViewController: signInViewController)
        UIApplication.shared.keyWindow?.rootViewController = newRootViewController
    }
    
    // MARK:- Return ArtworkViewController
    private func artworkViewController(index: IndexPath) -> ArtworkViewController {
        let imageLoader = ImageCacheFactory().buildImageLoader()
        let serverDatabase = NetworkDependencyContainer().buildServerDatabase()
        let databaseHandler = DatabaseHandler()
        let viewController = ArtworkViewController(imageLoader: imageLoader,
                                                   serverDatabase: serverDatabase,
                                                   databaseHandler: databaseHandler)
        
        guard let cell = collectionView.cellForItem(at: index) as? ArtworkListCollectionViewCell,
            let artistDate = artistData
            else
        {
            return viewController
        }
        
         let artwork = artworkList[index.item]

        updateViewsCount(id: artwork.artworkUid)
        
        viewController.transitioningDelegate = self
        viewController.isFromArtistView = true
        viewController.artworkImage = cell.imageView.image
        viewController.artwork = ArtworkDecodeType(artwork: artwork,
                                                   userName: artistDate.nickName,
                                                   userUid: artistDate.uid)
        
        return viewController
    }
    
    private func updateViewsCount(id: String) {
        serverDatabase.read(
            path: "root/artworks/\(id)",
            type: ArtworkDecodeType.self,
            headers: ["X-Firebase-ETag": "true"],
            queries: nil
            )
        { (result, response) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
                guard let formedResponse = response as? HTTPURLResponse,
                    let eTag = formedResponse.allHeaderFields["Etag"] as? String
                    else
                {
                    return
                }
                
                let encodeData = ArtworkDecodeType(
                    userUid: data.userUid,
                    authorName: data.authorName,
                    uid: data.artworkUid,
                    url: data.artworkUrl,
                    title: data.title,
                    timestamp: data.timestamp,
                    views: data.views + 1,
                    orientation: data.orientation,
                    color: data.color,
                    temperature: data.temperature
                )
                
                self.serverDatabase.write(
                    path: "root/artworks/\(id)/",
                    data: encodeData,
                    method: .put,
                    headers: ["if-match": eTag],
                    queries: nil)
                {
                    (result, response) in
                    switch result {
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .success:
                        break
                    }
                }
            }
        }
    }
}

// MARK:- UICollectionView DataSource
extension ArtistViewController: UICollectionViewDataSource {
    // MARK:- UICollectionView Header View
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath)
        -> UICollectionReusableView
    {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return tempCollectionReusableView(collectionView: collectionView,
                                              kind: kind,
                                              indexPath: indexPath)
        }
        
        switch indexPath.section {
        case 0:
            return self.artistDetailHeaderView(collectionView: collectionView,
                                               kind: kind,
                                               indexPath: indexPath)
        case 1:
            return self.artworkListHeaderView(collectionView: collectionView,
                                              kind: kind,
                                              indexPath: indexPath)
        default:
            return tempCollectionReusableView(collectionView: collectionView,
                                              kind: kind,
                                              indexPath: indexPath)
        }
    }
    
    // MARK:- Return artistDetailHeaderView
    private func artistDetailHeaderView(collectionView: UICollectionView,
                                        kind: String,
                                        indexPath: IndexPath)
        -> UICollectionReusableView
    {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: artistDetailHeaderView,
            for: indexPath) as? ArtistDetailHeaderView else
        {
            return tempCollectionReusableView(collectionView: collectionView,
                                              kind: kind,
                                              indexPath: indexPath)
        }
        
        guard let artistData = artistData else {
            return tempCollectionReusableView(collectionView: collectionView,
                                              kind: kind,
                                              indexPath: indexPath)
        }
        
        headerView.artistNameTextField.text = artistData.nickName
        headerView.artistIntroTextField.text = artistData.description
        headerView.isEditMode = isEditmode
        
        return headerView
    }
    
    // MARK:- Return artworkListHeaderView
    private func artworkListHeaderView(collectionView: UICollectionView,
                                       kind: String,
                                       indexPath: IndexPath)
        -> UICollectionReusableView
    {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: artworkListHeaderIdentifier,
            for: indexPath) as? ArtworkListHeaderCollectionReusableView else
        {
            return tempCollectionReusableView(collectionView: collectionView,
                                              kind: kind,
                                              indexPath: indexPath)
        }
        
        if artistData != nil {
            headerView.titleLabel.isHidden = false
        }
        
        return headerView
    }
    
    private func tempCollectionReusableView(collectionView: UICollectionView,
                                            kind: String,
                                            indexPath: IndexPath)
        -> UICollectionReusableView
    {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                               withReuseIdentifier: tempIdentifier,
                                                               for: indexPath)
    }
    
    // MARK:- UICollectionView Number of Sectino
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    // MARK:- UICollectionView Number of Cell
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int)
        -> Int
    {
        switch section {
        case 1:
            return artworkList.count
        default:
            return 0
        }
    }
    
    // MARK:- UICollectionView Cell
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell
    {
        switch indexPath.section {
        case 1:
            return artworkListCollectionViewCell(collectionView: collectionView,
                                                 indexPath: indexPath)
        default:
            return .init()
        }
    }
    
    // MARK:- Return artworkListCollectionViewCell
    private func artworkListCollectionViewCell(collectionView: UICollectionView,
                                               indexPath: IndexPath)
        -> ArtworkListCollectionViewCell
    {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: artworkListIdentifier,
            for: indexPath) as? ArtworkListCollectionViewCell else
        {
            return .init()
        }
        let id = artworkList[indexPath.item].artworkUid
        
        if let image = artworkImage[id] {
            cell.imageView.image = image
            artworkImage.removeValue(forKey: id)
        } else {
            fetchImage(index: indexPath.item, prefetch: false)
        }
        
        return cell
    }
}

// MARK:- UICollectionView Delegate
extension ArtistViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath)
    {
        let visubleCellsIndex = collectionView.visibleCells.map{ collectionView.indexPath(for: $0)?.item ?? 0 }
        let max = visubleCellsIndex.max{ $0 < $1 }
        
        guard let maxIndex = max, maxIndex != 0 else { return }
        var prefetchIndex = 0
        if maxIndex < indexPath.item {
            prefetchIndex = min(indexPath.item + prefetchSize, artworkList.count - 1)
            removePrefetchedArtwork(prefetchIndex: prefetchIndex, front: true)
        } else {
            prefetchIndex = min(indexPath.item - prefetchSize, artworkList.count - 1)
            removePrefetchedArtwork(prefetchIndex: prefetchIndex, front: false)
        }
        
        guard  artworkList.count > prefetchIndex, prefetchIndex >= 0 else { return }
        
        let artwork = artworkList[prefetchIndex]
        if artworkImage[artwork.artworkUid] == nil {
            self.fetchImage(index: prefetchIndex, prefetch: true)
        }
    }
    
    // MARK:- Remove prefetched artwork from ViewController
    private func removePrefetchedArtwork(prefetchIndex: Int, front: Bool) {
        if front {
            let targetIndex = prefetchIndex - prefetchSize
            
            guard targetIndex >= 0 else { return }
            
            for i in 0..<targetIndex {
                let artwork = artworkList[i]
                
                if artworkImage[artwork.artworkUid] != nil {
                    artworkImage.removeValue(forKey: artwork.artworkUid)
                }
            }
        } else {
            let targetIndex = prefetchIndex + prefetchSize
            
            guard targetIndex < artworkList.count else { return }
            
            for i in targetIndex..<artworkList.count {
                let artwork = artworkList[i]
                
                if artworkImage[artwork.artworkUid] != nil {
                    artworkImage.removeValue(forKey: artwork.artworkUid)
                }
            }
        }
    }
}

// MARK:- PaginatingCollectionViewController Transitioning Delegate
extension ArtistViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController)
        -> UIViewControllerAnimatedTransitioning?
    {
        guard let index = collectionView.indexPathsForSelectedItems?.first,
            let cell = collectionView.cellForItem(at: index)
            else
        {
            return nil
        }
        
        let transition = CollectionViewControllerPresentAnimator()
        
        transition.viewFrame = view.frame
        transition.originFrame = collectionView.convert(cell.frame, to: nil)
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning?
    {
        return nil
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath)
    {
        let viewController = artworkViewController(index: indexPath)
        viewController.isAnimating = true
        
        present(viewController, animated: true) {
            viewController.isAnimating = false
        }
    }
}

// MARK:- UIViewController Previewing Delegate
extension ArtistViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                           viewControllerForLocation location: CGPoint)
        -> UIViewController?
    {
        guard let index = collectionView.indexPathForItem(at: location),
            let cell = collectionView.cellForItem(at: index) else {
                return nil
        }
        previewingContext.sourceRect = cell.frame
        
        let viewController = artworkViewController(index: index)
        viewController.isPeeked = true
        
        return viewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                           commit viewControllerToCommit: UIViewController)
    {
        guard let viewController = viewControllerToCommit as? ArtworkViewController else {
            return
        }
        viewController.isPeeked = false
        
        present(viewController, animated: false, completion: nil)
    }
}

// MARK:- UICollectinoView Delegate FlowLayout
extension ArtistViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int)
        -> CGSize
    {
        switch section {
        case 0:
            return CGSize(width: view.frame.width, height: 170)
        case 1:
            return CGSize(width: view.frame.width, height: 50)
        default:
            return CGSize()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath)
        -> CGSize
    {
        
        let cellWitdh = ((collectionView.frame.width - (layout.spacing * 2)) / 3)
        let cellHeight = cellWitdh
        return CGSize(width: cellWitdh, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int)
        -> CGFloat
    {
        return layout.spacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int)
        -> CGFloat
    {
        return layout.spacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int)
        -> UIEdgeInsets
    {
        let edgeInsets = UIEdgeInsets(top: layout.inset,
                                      left: layout.inset,
                                      bottom: layout.inset,
                                      right: layout.inset)
        
        return edgeInsets
    }
}
