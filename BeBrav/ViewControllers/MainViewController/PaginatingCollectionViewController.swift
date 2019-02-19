//
//  paginatingCollectionView.swift
//  BeBrav
//
//  Created by bumslap on 05/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class PaginatingCollectionViewController: UICollectionViewController {
    
    
    private let imageLoader: ImageLoaderProtocol
    private let serverDatabase: FirebaseDatabaseService
    
    init(serverDatabase: FirebaseDatabaseService, imageLoader: ImageLoaderProtocol) {
        self.serverDatabase = serverDatabase
        self.imageLoader = imageLoader
        super.init(collectionViewLayout: MostViewedArtworkFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    ///checkIfValidPosition() 메서드가 적용된 이후 리턴되는 튜플을 구분하기 쉽게 적용한 type입니다.
    typealias CalculatedInformation = (sortedArray: [ArtworkDecodeType], index: Int)
    
    
    
    weak var pagingDelegate: PagingControlDelegate!
    

    ///연산이 완료된 currentBatchArtworkBucket를 저장하는 전체 데이터 저장소 프로퍼티입니다.
    private var artworkBucket: [ArtworkDecodeType] = []
    
    ///현재 batchSize만큼 얻어온 데이터 중 checkIfValidPosition() 메서드를 통해 연산한 후 얻어낸
    ///정렬과 레이아웃을 위해 적절히 조정된 데이터셋입니다. +
    ///레이아웃이 새로운 데이터를 요청시 뷰의 bounds를 변경하게되고 이는 MostViewedCollectionViewLayout의
    ///prepare() 메서드를 호출하게 됩니다. 한 array에 데이터를 계속 쌓게 되면 페이지당 가장 뷰수가 많은
    ///데이터를 계산하는것에 문제가 생기기 떄문에 일시적으로 batchSize만큼 받아온 데이터를 저장하고 연산할 공간이
    ///currentBatchArtworkBucket입니다.
    private var currentBatchArtworkBucket: [ArtworkDecodeType] = []
    
    
    
    /// 데이터의 갯수가 batchSize보다 작아지면 다음번 요청은 제한하도록 해주는 프로퍼티입니다.
    private var isEndOfData = false
    
    ///batchSize만큼 데이터를 요청하게 되며 이 사이즈는 calculateNumberOfArtworksPerPage()
    ///메서드를 통해서 기기별 화면 크기에 맞는 한 페이지 분량의 데이터를 계산한 후 3을 뺸 크기입니다
    ///3을 빼주는 이유는 2x2크기의 레이아웃이 있기 때문이고 이 블록이 다른 블록의 4배의 공간을 차지하기
    ///때문입니다.
    private var batchSize = 0
    
    private let pageSize = 2
    
    private var itemsPerScreen = 0
    
    ///isLoading은 스크롤을 끝까지하여 데이터를 요청했을때 데이터가 전부 도착해야만 다음 스크롤때 해당
    ///메서드를 동작시킬수 있도록 제한하는 역할을 합니다
    private var isLoading = false
    
    /// recentTimestamp는 한번 정렬하여 얻어온 데이터를 이용해서 다음번 요청시 이 프로퍼티를 기준으로
    /// 다음 batchSize 만큼의 데이터를 다시 요청하기 위해 만든 프로퍼티입니다.
    private var recentTimestamp: Double!
    
    /// currentKey는 fetch한 데이터가 처음 요청하는 것인지 확인하기 위해서 구현한 프로퍼티입니다.
    private var currentKey: String!
    
    ///FooterView로 추가한 버튼을 관리하는 ReusableView 입니다.
    private var footerView: ArtworkAddFooterReusableView?
    ///
    private var latestContentsOffset: CGFloat = 0
    
    
    ///네트워킹을 전체적으로 관리하는 인스탠스를 생성하기 위한 컨테이너 입니다.
    private let container = NetworkDependencyContainer()
    
    ///컨테이너로 만든 ServerDatabase 인스탠스입니다.
    private lazy var serverDB = container.buildServerDatabase()
    
    private lazy var serverST = container.buildServerStorage()
    private lazy var serverAu = container.buildServerAuth()
    private lazy var manager = ServerManager(authManager: serverAu,
                                             databaseManager: serverDB,
                                             storageManager: serverST,
                                             uid: "123")
    
    private let databaseHandler = DatabaseFactory().buildDatabaseHandler()
    
    private var thumbImage: [String: UIImage] = [:]
    
    //mainCollectionView 설정 관련 프로퍼티
    private let identifierFooter = "footer"
    private let spacing: CGFloat = 0
    private let insets: CGFloat = 2
    private let padding: CGFloat = 2
    private let columns: CGFloat = 3
    
    private let loadingIndicator: LoadingIndicatorView = {
        let indicator = LoadingIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.noticeLabel.text = "loading images"
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let layout = collectionView.collectionViewLayout as? MostViewedArtworkFlowLayout {
            itemsPerScreen = calculateNumberOfArtworksPerPage(numberOfColumns: CGFloat(columns), viewWidth: UIScreen.main.bounds.width, viewHeight: self.view.frame.height, spacing: padding, insets: padding)
                batchSize = itemsPerScreen * pageSize
            layout.numberOfItems = itemsPerScreen
            pagingDelegate = layout
        }
        setCollectionView()
        setLoadingView()
        fetchPages()
        
        if UIApplication.shared.keyWindow?.traitCollection.forceTouchCapability == .available
        {
            registerForPreviewing(with: self, sourceView: collectionView)
            
        }
    }
    
    func setCollectionView() {
        guard let collectionView = self.collectionView else { return }
        collectionView.alwaysBounceVertical = true
        collectionView.register(PaginatingCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        //collectionView.prefetchDataSource = self //TODO: 이미지로더 구현이후 적용
        collectionView.register(ArtworkAddFooterReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: identifierFooter)
        
        //TODO: filtering에 맞는 이미지로 수정
        let barItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(filterButtonDidTap))
        barItem.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        navigationItem.rightBarButtonItem = barItem
        
        if let layout = collectionView.collectionViewLayout as? MostViewedArtworkFlowLayout {
            layout.minimumInteritemSpacing = 0
            layout.sectionFootersPinToVisibleBounds = true
            layout.minimumLineSpacing = padding
            layout.fetchPage = pageSize
        }
    }
    
    func setLoadingView() {
        collectionView.addSubview(loadingIndicator)
        loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingIndicator.heightAnchor.constraint(equalToConstant: 60).isActive = true
        loadingIndicator.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        loadingIndicator.deactivateIndicatorView()
    }
    
    // MARK:- Return ArtworkViewController
    private func artworkViewController(index: IndexPath) -> ArtworkViewController {
        let imageLoader = ImageCacheFactory().buildImageLoader()
        let serverDatabase = NetworkDependencyContainer().buildServerDatabase()
        let viewController = ArtworkViewController(imageLoader: imageLoader,
                                                   serverDatabase: serverDatabase)
        
        guard let cell = collectionView.cellForItem(at: index) as? PaginatingCell else {
            return viewController
        }
        
        viewController.transitioningDelegate = self
        viewController.mainNavigationController = navigationController
        
        let uid = artworkBucket[index.row].artworkUid
        serverDatabase.read(path: "root/artworks/\(uid)", type: ArtworkDecodeType.self, headers: ["X-Firebase-ETag": "true"], queries: nil) { (result, response) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
                guard let formedResponse = response as? HTTPURLResponse, let eTag = formedResponse.allHeaderFields["Etag"] as? String else {
                    return
                }
                
                let updateValue = data.views + 1
                
                let encodeData = ArtworkDecodeType(userUid: "", uid: data.artworkUid, url: data.artworkUrl, title: data.title, timestamp: data.timestamp, views: updateValue, orientation: data.orientation, color: data.color, temperature: data.temperature)
                
                self.serverDatabase.write(path: "root/artworks/\(uid)/", data: encodeData, method: .put, headers: ["if-match": eTag], completion: { (result, response) in
                    switch result {
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .success:
                       print("success")
                    }
                })
            }
        }
        
        viewController.artwork = self.artworkBucket[index.item]
        viewController.artworkImage = cell.artworkImageView.image
        return viewController
    }
    
    @objc func filterButtonDidTap() {
        print(collectionView.indexPathsForVisibleItems)
        //TODO: filtering 기능 추가
        refreshLayout()
        
    }
    
    @objc func addArtworkButtonDidTap() {
        let flowLayout = UICollectionViewFlowLayout()
        let artAddCollectionViewController = ArtAddCollectionViewController(collectionViewLayout: flowLayout)
        artAddCollectionViewController.delegate = self
        present(artAddCollectionViewController, animated: true, completion: nil)
    }
    
    func refreshLayout() {
        guard let layout = collectionView.collectionViewLayout as? MostViewedArtworkFlowLayout else {
            return
        }
        layout.layoutRefresh()
        
        layout.fetchPage = pageSize
        isEndOfData = false
        isLoading = false
        recentTimestamp = nil
        currentKey = nil
        artworkBucket.removeAll()
        thumbImage.removeAll()
        
        
        fetchPages()
        
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artworkBucket.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PaginatingCell else {
            assertionFailure("failed to make cell")
            return .init()
        }

        let artwork = artworkBucket[indexPath.row]
        
        if let image = thumbImage[artwork.artworkUid]?.scale(with: 0.4) {
            cell.artworkImageView.image = image
            thumbImage.removeValue(forKey: artwork.artworkUid)
        } else {
            fetchImage(artwork: artwork, indexPath: indexPath)
        }
        return cell
    }
    
    private func fetchImage(artwork: ArtworkDecodeType, indexPath: IndexPath) {
        guard let url = URL(string: artwork.artworkUrl) else { return }
        
        imageLoader.fetchImage(url: url, size: .small) { (image, error) in
            if error != nil {
                assertionFailure("failed to make cell")
                return
            }
            
            guard let image = image else { return }
            self.thumbImage[artwork.artworkUid] = image
            
            DispatchQueue.main.async {
                self.collectionView.reloadItems(at: [indexPath])
            }
        }
    }
}

extension PaginatingCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
         let insetsNumber = columns + 1
         let width = (collectionView.frame.width - (insetsNumber * spacing) - (insetsNumber * insets)) / columns
         return CGSize(width: width, height: width)
     }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: insets, left: insets, bottom: insets, right: insets)
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        
        let viewController = artworkViewController(index: indexPath)
        viewController.isAnimating = true
        
        present(viewController, animated: true) {
            viewController.isAnimating = false
        }
    }
}

extension PaginatingCollectionViewController {
    
    /// 컬렉션 뷰의 데이터를 페이지 단위로 받아오기 위한 메서드입니다.
    /// 이전에 데이터를 받아온 적이 있는지 currentKey를 통해서 확인합니다. 이후 쿼리를 생성하여 timestamp로
    /// 정렬된 데이터를 batchSize만큼 요청합니다. checkIfValidPosition()메서드를 이용하여 리턴된 값을
    /// 데이터 소스에 추가하고 nextLayoutYPosition을 Layout인스탠스의 pageNumber 프로퍼티에 전달해줍니다.
    func fetchPages() {
        
        if !isEndOfData {
            currentBatchArtworkBucket.removeAll()
            isLoading = true
            loadingIndicator.activateIndicatorView()
            
            guard let layout = self.collectionViewLayout as? MostViewedArtworkFlowLayout else {
                return
            }
            if currentKey == nil {
                let queries = [URLQueryItem(name: "orderBy", value: "\"timestamp\""),
                               URLQueryItem(name: "limitToLast", value: "\(batchSize)")
                ]
                
                serverDB.read(path: "root/artworks",
                              type: [String: ArtworkDecodeType].self, headers: [:],
                              queries: queries) {
                                (result, response) in
                                switch result {
                                case .failure(let error):
                                    //TODO: 유저에게 보여줄 에러메세지 생성
                                    print(error)
                                case .success(let data):
                                    let result = data.values.sorted()
                                    if result.count < self.batchSize {
                                        self.isEndOfData = true
                                    }
                                    for artwork in result {
                                        self.currentBatchArtworkBucket.append(artwork)
                                    }
                                    let infoBucket =
                                        self.calculateCellInfo(fetchedData: self.currentBatchArtworkBucket,
                                                               batchSize: self.itemsPerScreen)
                                    var indexList: [Int] = []
                                    infoBucket.forEach {
                                        self.artworkBucket.append(contentsOf: $0.sortedArray)
                                        layout.prepareIndex.append($0.index)
                                    }
                                    self.currentKey = result.first?.artworkUid
                                    self.recentTimestamp = result.first?.timestamp
                                    
                                    DispatchQueue.main.async {
                                        self.collectionView.reloadData()
                                    }
                                    defer {
                                        DispatchQueue.main.async {
                                            self.isLoading = false
                                            self.loadingIndicator.deactivateIndicatorView()
                                        }
                                    }
                                }
                }
            } else {
                //xcode버그 있어서 그대로 넣으면 가끔 빌드가 안됩니다.
                let timestamp = "\"timestamp\""
                let queries = [URLQueryItem(name: "orderBy", value: timestamp),
                               URLQueryItem(name: "endAt", value: "\(Int(recentTimestamp))"),
                               URLQueryItem(name: "limitToLast", value: "\(batchSize)")
                ]
                serverDB.read(path: "root/artworks",
                              type: [String: ArtworkDecodeType].self, headers: [:],
                              queries: queries) {
                                (result, response) in
                                switch result {
                                case .failure(let error):
                                    //TODO: 유저에게 보여줄 에러메세지 생성
                                    print(error)
                                case .success(let data):
                                    let result = data.values.sorted()
                                    if result.count < self.batchSize {
                                        self.isEndOfData = true
                                    }
                                    for artwork in result {
                                        self.currentBatchArtworkBucket.append(artwork)
                                    }
                                    let infoBucket =
                                        self.calculateCellInfo(fetchedData: self.currentBatchArtworkBucket,
                                                               batchSize: self.itemsPerScreen)
                                    var indexList: [Int] = []
                                    self.currentKey = result.first?.artworkUid
                                    self.recentTimestamp = result.first?.timestamp
                                    infoBucket.forEach {
                                        self.artworkBucket.append(contentsOf: $0.sortedArray)
                                        indexList.append($0.index)
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.pagingDelegate.constructNextLayout(indexList: indexList, pageSize: result.count)
                                        let indexPaths = self.calculateIndexPathsForReloading(from: self.currentBatchArtworkBucket)
                                        self.collectionView.insertItems(at: indexPaths)
                                        
                                    }
                                    defer {
                                        DispatchQueue.main.async {
                                            self.loadingIndicator.deactivateIndicatorView()
                                            self.isLoading = false
                                        }
                                    }
                                }
                }
            }
        }
    }
    
    private func calculateIndexPathsForReloading(from newArtworks: [ArtworkDecodeType]) -> [IndexPath] {
        let startIndex = artworkBucket.count - newArtworks.count
        let endIndex = startIndex + newArtworks.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
            return .init(width: view.frame.width, height: 60)
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
                guard let footerView =
                    collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                    withReuseIdentifier: identifierFooter,
                                                                    for: indexPath) as? ArtworkAddFooterReusableView else {
                    return UICollectionReusableView.init()
                }
                footerView.addArtworkButton.addTarget(self,
                                                      action: #selector(addArtworkButtonDidTap),
                                                      for: .touchUpInside)
                self.footerView = footerView
                return footerView
        default:
        return UICollectionReusableView.init()
        }
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                           willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maxOffset - currentOffset <= 40{
            if !isLoading {
                collectionView.layoutIfNeeded()
                fetchPages()
            }
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        latestContentsOffset = scrollView.contentOffset.y;
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 {
            if self.latestContentsOffset > scrollView.contentOffset.y {
                UIView.animate(withDuration: 1) {
                self.footerView?.addArtworkButton.alpha = 1
                }
            }
            else if (self.latestContentsOffset < scrollView.contentOffset.y) {
                UIView.animate(withDuration: 1) {
                    self.footerView?.addArtworkButton.alpha = 0
                }
            }
        }
    }
    
    func calculateCellInfo(fetchedData: [ArtworkDecodeType], batchSize: Int) -> [CalculatedInformation] {
        var mutableDataBucket = fetchedData
        var calculatedInfoBucket: [CalculatedInformation] = []
        let numberOfPages = fetchedData.count / batchSize
        for _ in 0..<numberOfPages {
            
            var currentBucket: [ArtworkDecodeType] = []
            for _ in 0..<batchSize {
                currentBucket.append(mutableDataBucket.removeLast())
            }
            let calculatedInfo: CalculatedInformation =
                checkIfValidPosition(data: currentBucket,
                                     numberOfColumns: Int(columns))
            calculatedInfoBucket.append(calculatedInfo)
            currentBucket.removeAll()
        }
        
        if !mutableDataBucket.isEmpty {
            let calculatedInfo: CalculatedInformation =
                checkIfValidPosition(data: mutableDataBucket,
                                     numberOfColumns: Int(columns))
            calculatedInfoBucket.append(calculatedInfo)
        }
        return calculatedInfoBucket
    }
}

extension PaginatingCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            guard let url = URL(string: artworkBucket[$0.row].artworkUrl) else {
                return
            }//TODO: 이미지로더 구현이후 적용
            imageLoader.fetchImage(url: url, size: .small) { (image, error) in
                if error != nil {
                    assertionFailure("failed to make cell")
                    return
                }
            }
        }
    }
}

// MARK:- UIViewController Previewing Delegate
extension PaginatingCollectionViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                           viewControllerForLocation location: CGPoint)
        -> UIViewController?
    {
        guard let index = collectionView.indexPathForItem(at: location),
            let cell = collectionView.cellForItem(at: index) else {
                return .init()
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

// MARK:- PaginatingCollection ViewController
extension PaginatingCollectionViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController)
        -> UIViewControllerAnimatedTransitioning?
    {
        guard let collectionView = collectionView,
            let index = collectionView.indexPathsForSelectedItems?.first,
            let cell = collectionView.cellForItem(at: index)
            else
        {
            return nil
        }
        
        let transition = PaginatingViewControllerPresentAnimator()
        
        transition.viewFrame = view.frame
        transition.originFrame = collectionView.convert(cell.frame, to: nil)
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning?
    {
        return nil
    }
}

extension PaginatingCollectionViewController: ArtAddCollectionViewControllerDelegate {
    func uploadArtwork(_ controller: ArtAddCollectionViewController, image: UIImage) {
        
        //FIXME: - SignIn 머지되면 수정
        manager.signIn(email: "t1@naver.com", password: "123456") { (result) in
            switch result {
            case .failure(let error):
                print(error)
                return
            case .success(let data):
                print("success")
                self.manager.uploadArtwork(image: image, scale: 0.1, path: "artworks", fileName: "test401", completion: { (result) in
                    switch result {
                    case .failure(let error):
                        print(error)
                        return
                    case .success(let data):
                        print(data)
                    }
                })
            }
        }
        
        DispatchQueue.main.async {
            self.fetchPages()
        }
    }
}
