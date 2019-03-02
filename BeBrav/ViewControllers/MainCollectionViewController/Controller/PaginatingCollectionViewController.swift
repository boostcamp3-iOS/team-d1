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

    private var filterType: FilterType = .none
    private var isOn = true
    private var isOptionOn = false
    
    private let imageLoader: ImageLoaderProtocol
    private let serverDatabase: FirebaseDatabaseService
    private let databaseHandler: DatabaseHandler
    init(serverDatabase: FirebaseDatabaseService, imageLoader: ImageLoaderProtocol, databaseHandler: DatabaseHandler) {
        self.databaseHandler = databaseHandler
        self.serverDatabase = serverDatabase
        self.imageLoader = imageLoader
        super.init(collectionViewLayout: MostViewedArtworkFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    ///
    weak var pagingDelegate: PagingControlDelegate!
    
    ///메인뷰의 데이터를 전부 저장합니다
    private var artworkBucket: [ArtworkDecodeType] = []
    
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
    
    private let prefetchSize = 6
    
    
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
    
    private var thumbImage: [String: UIImage] = [:]
    private var artworkImage: [String: UIImage] = [:]
    private var artworkDataFromDatabase: [ArtworkModel] = []
    
    //mainCollectionView 설정 관련 프로퍼티
    private let identifierFooter = "footer"
    private let spacing: CGFloat = 0
    private let insets: CGFloat = 2
    private let padding: CGFloat = 2
    private let columns: CGFloat = 3
    
    private let loadingIndicator: LoadingIndicatorView = {
        let indicator = LoadingIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.noticeLabel.text = "loadingImages".localized
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "BeBrav"
        
        if let layout = collectionView.collectionViewLayout as? MostViewedArtworkFlowLayout {
            itemsPerScreen = calculateNumberOfArtworksPerPage(numberOfColumns: CGFloat(columns), viewWidth: UIScreen.main.bounds.width, viewHeight: self.view.frame.height, spacing: padding, insets: padding)
                batchSize = itemsPerScreen * pageSize
            layout.numberOfItems = itemsPerScreen
            pagingDelegate = layout
        }
        
        setCollectionView()
        setLoadingView()
        refreshFilteredLayout(filterType: .none, isOn: true)
        
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
        collectionView.backgroundColor = #colorLiteral(red: 0.1780431867, green: 0.1711916029, blue: 0.2278442085, alpha: 1)
        collectionView.register(ArtworkAddFooterReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: identifierFooter)
        
        //set filter right bar button
        let filterButton = UIButton(type: UIButton.ButtonType.custom)
        filterButton.setImage(#imageLiteral(resourceName: "filter (1)"), for: .normal)
        filterButton.addTarget(self, action: #selector(filterButtonDidTap), for: .touchUpInside)
        
        let userButton = UIButton(type: UIButton.ButtonType.custom)
        userButton.setImage(#imageLiteral(resourceName: "userImage"), for: .normal)
        userButton.addTarget(self, action: #selector(userSettingButtonDidTap), for: .touchUpInside)
        
        let userBarButton = UIBarButtonItem(customView: userButton)
        userBarButton.customView?.translatesAutoresizingMaskIntoConstraints = false
        userBarButton.customView?.widthAnchor.constraint(equalToConstant: 20).isActive = true
        userBarButton.customView?.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        let filterBarButton = UIBarButtonItem(customView: filterButton)
        filterBarButton.customView?.translatesAutoresizingMaskIntoConstraints = false
        filterBarButton.customView?.widthAnchor.constraint(equalToConstant: 20).isActive = true
        filterBarButton.customView?.heightAnchor.constraint(equalToConstant: 20).isActive = true
        navigationItem.rightBarButtonItem = filterBarButton
        navigationItem.leftBarButtonItem = userBarButton
        
        if let layout = collectionView.collectionViewLayout as? MostViewedArtworkFlowLayout {
            layout.minimumInteritemSpacing = 0
            layout.sectionFootersPinToVisibleBounds = true
            layout.minimumLineSpacing = padding
            
        }
    }
    
    func setLoadingView() {
        collectionView.addSubview(loadingIndicator)
        loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingIndicator.heightAnchor.constraint(equalToConstant: 60).isActive = true
        loadingIndicator.widthAnchor.constraint(equalToConstant: 200).isActive = true

        loadingIndicator.activateIndicatorView()
    }
    
    // MARK:- Return ArtworkViewController
    private func artworkViewController(index: IndexPath) -> ArtworkViewController {
        let imageLoader = ImageCacheFactory().buildImageLoader()
        let serverDatabase = NetworkDependencyContainer().buildServerDatabase()
        let databaseHandler = DatabaseHandler()
        let viewController = ArtworkViewController(imageLoader: imageLoader,
                                                   serverDatabase: serverDatabase,
                                                   databaseHandler: databaseHandler)
        
        guard let cell = collectionView.cellForItem(at: index) as? PaginatingCell else {
            return viewController
        }
        
        let artwork = artworkBucket[index.row]
        
        updateViewsCount(id: artwork.artworkUid)
        
        viewController.transitioningDelegate = self
        viewController.artwork = artwork
        viewController.artworkImage = cell.artworkImageView.image
        viewController.mainNavigationController = navigationController
        
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
                print(error.localizedDescription)
            case .success(let data):
                guard let formedResponse = response as? HTTPURLResponse,
                    let eTag = formedResponse.allHeaderFields["Etag"] as? String else { return }
                
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
                    { (result, response) in
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
   
    private func getQuery(filterType: FilterType, isOn: Bool) -> [URLQueryItem] {
        let orderBy: String?
        let queries: [URLQueryItem]
        
        switch filterType {
        case .orientation:
            orderBy = "\"orientation\""
        case .color:
            orderBy = "\"color\""
        case .temperature:
            orderBy = "\"temperature\""
        case .none:
            orderBy = "\"timestamp\""
        }
        
        if filterType == .none {
            queries = [URLQueryItem(name: "orderBy", value: "\"timestamp\""),
                       URLQueryItem(name: "limitToLast", value: "\(self.batchSize)")
            ]
        }
        else {
            queries = [URLQueryItem(name: "orderBy", value: orderBy),
                      // URLQueryItem(name: "orderBy", value: "\"timestamp\""),
                       URLQueryItem(name: "equalTo", value: "\(isOn)")
                       //URLQueryItem(name: "limitToLast", value: "\(batchSize)")
            ]
        }
        
        return queries
    }
    
    private func refreshFilteredLayout(filterType: FilterType, isOn: Bool) {
        
        let queries = getQuery(filterType: filterType, isOn: isOn)
        
        refreshLayout(queries: queries, type: filterType, isOn: isOn)
    }
    
    func makeAlert(title: String?) {
        var message: String?
        var trueActionTitle: String?
        var falseActionTitle: String?
        
        if title == "orientation".localized {
            message = "orientationQuestion".localized
            trueActionTitle = "horizontal".localized
            falseActionTitle = "vertical".localized
            filterType = .orientation
        }
        else if title == "color".localized {
            message = "colorQuestion".localized
            trueActionTitle = "colorScale".localized
            falseActionTitle = "grayScale".localized
            filterType = .color
        }
        else if title == "temperature".localized {
            message = "orientationQuestion".localized
            trueActionTitle = "coldArtwork".localized
            falseActionTitle = "warmArtwork".localized
            filterType = .temperature
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let trueAction = UIAlertAction(title: trueActionTitle, style: .default, handler: { (action) in
            self.isOn = true
            self.refreshFilteredLayout(filterType: self.filterType, isOn: true)
        })
        
        let falseAction = UIAlertAction(title: falseActionTitle, style: .default, handler: { (action) in
            self.isOn = false
            self.refreshFilteredLayout(filterType: self.filterType, isOn: false)
        })
        
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil)
        
        alertController.addAction(trueAction)
        alertController.addAction(falseAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func filterButtonDidTap() {
        let alertController = UIAlertController(title: "filtering".localized, message: "chooseFilterDescription".localized, preferredStyle: .actionSheet)
        
        let orientationAction = UIAlertAction(title: "orientation".localized, style: .default) { (action) in
            self.isOptionOn = true
            self.makeAlert(title: action.title)
        }
        
        let colorAction = UIAlertAction(title: "color".localized, style: .default) { (action) in
            self.makeAlert(title: action.title)
            self.isOptionOn = true
        }
        
        let temperatureAction = UIAlertAction(title: "temperature".localized, style: .default) { (action) in
            self.isOptionOn = true
            self.makeAlert(title: action.title)
        }
        
        let originAction = UIAlertAction(title: "allArtworks".localized, style: .default) { (action) in
            self.isOn = true
            self.isOptionOn = false
            self.refreshFilteredLayout(filterType: .none, isOn: true)
        }
        
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil)
        
        alertController.addAction(orientationAction)
        alertController.addAction(colorAction)
        alertController.addAction(temperatureAction)
        alertController.addAction(originAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
   
    @objc func userSettingButtonDidTap() {
        let imageLoader = ImageCacheFactory().buildImageLoader()
        let serverDatabase = NetworkDependencyContainer().buildServerDatabase()
        let databaseHandler = DatabaseHandler()
        let userInformationViewController = ArtistViewController(imageLoader: imageLoader, serverDatabase: serverDatabase, databaseHandler: databaseHandler)
        userInformationViewController.isUser = true
        navigationController?.pushViewController(userInformationViewController, animated: true)
    }
    
    @objc func addArtworkButtonDidTap() {
        let artAddViewController = ArtAddViewController()
        artAddViewController.delegate = self
        present(artAddViewController, animated: true, completion: nil)
    }

    private func refreshLayout(queries: [URLQueryItem], type: FilterType, isOn: Bool) {
        guard let layout = collectionView.collectionViewLayout as? MostViewedArtworkFlowLayout else {
            return
        }
        layout.layoutRefresh()
        isEndOfData = false
        isLoading = false
        recentTimestamp = nil
        currentKey = nil
        artworkBucket.removeAll()
        thumbImage.removeAll()
        loadingIndicator.activateIndicatorView()
        fetchPages(queries: queries, type: type, isOn: isOn)
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artworkBucket.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PaginatingCell else {
            return .init()
        }

        let artwork = artworkBucket[indexPath.row]
        
        if let image = artworkImage[artwork.artworkUid] {
            cell.artworkImageView.image = image
            artworkImage.removeValue(forKey: artwork.artworkUid)
        } else {
            fetchImage(artwork: artwork, indexPath: indexPath)
        }
        return cell
    }
    
    private func fetchImage(artwork: ArtworkDecodeType, indexPath: IndexPath?) {
        if artworkImage[artwork.artworkUid] == nil {
            guard let url = URL(string: artwork.artworkUrl) else { return }
            
            imageLoader.fetchImage(url: url, size: .small) { image, error in
                guard let image = image else { return }
                self.artworkImage[artwork.artworkUid] = image
                
                if let indexPath = indexPath {
                    DispatchQueue.main.async {
                        self.reloadCellImage(indexPath: indexPath)
                    }
                }
            }
        }
    }

    
    private func reloadCellImage(indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PaginatingCell else { return }
        guard collectionView.visibleCells.contains(cell) else { return }
        guard let image = artworkImage[artworkBucket[indexPath.item].artworkUid] else { return }
        
        cell.artworkImageView.image = image
        artworkImage.removeValue(forKey: artworkBucket[indexPath.item].artworkUid)
    }
}

extension PaginatingCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath)
        -> CGSize
    {
         let insetsNumber = columns + 1
         let width = (collectionView.frame.width - (insetsNumber * spacing) - (insetsNumber * insets)) / columns
         return CGSize(width: width, height: width)
     }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int)
        -> UIEdgeInsets
    {
        return UIEdgeInsets(top: insets, left: insets, bottom: insets, right: insets)
    }
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath)
    {
        let viewController = artworkViewController(index: indexPath)
        viewController.isAnimating = true
        
        present(viewController, animated: true) {
            viewController.isAnimating = false
        }
    }
}

extension PaginatingCollectionViewController {
    private func fetchPages(queries: [URLQueryItem], type: FilterType, isOn: Bool) {
//        loadingIndicator.activateIndicatorView()
        if !isEndOfData {
            isLoading = true
            
            guard let layout = self.collectionViewLayout as? MostViewedArtworkFlowLayout else {
                return
            }
            if currentKey == nil {
                let queries = queries
                
                serverDB.read(path: "root/artworks",
                              type: [String: ArtworkDecodeType].self, headers: [:],
                              queries: queries) {
                                (result, response) in
                    switch result {
                    case .failure(let error):
                        self.fetchDataFromDatabase(filter: type,
                                                   isOn: isOn,
                                                   doNeedMore: false,
                                                   targetLayout: layout)
                    case .success(let data):
                        self.processData(data: data,
                                         doNeedMore: false,
                                         targetLayout: layout)
                    }
                }
            } else {
                //xcode버그 있어서 그대로 넣으면 가끔 빌드가 안됩니다.
                let timestamp = "\"timestamp\""
                var queries = [URLQueryItem(name: "orderBy", value: timestamp),
                               URLQueryItem(name: "endAt", value: "\(Int(recentTimestamp - 1))"),
                               URLQueryItem(name: "limitToLast", value: "\(batchSize)")
                ]
                
                serverDB.read(path: "root/artworks",
                              type: [String: ArtworkDecodeType].self,
                              headers: [:],
                              queries: queries) {
                                (result, response) in
                    switch result {
                    case .failure(let error):
                        self.fetchDataFromDatabase(filter: type,
                                                   isOn: isOn,
                                                   doNeedMore: true,
                                                   targetLayout: layout)
                        defer {
                            DispatchQueue.main.async {
                                self.loadingIndicator.deactivateIndicatorView()
                                self.isLoading = false
                            }
                        }
                    case .success(let data):
                        self.processData(data: data,
                                         doNeedMore: true,
                                         targetLayout: layout)
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
    
    
    private func fetchDataFromDatabase(filter: FilterType,
                                       isOn: Bool,
                                       doNeedMore: Bool,
                                       targetLayout: MostViewedArtworkFlowLayout)
    {
        if artworkDataFromDatabase.isEmpty {
            databaseHandler.readArtworkArray{ data, error in
                if error != nil { return }
                
                guard let data = data else { return }
                
                self.artworkDataFromDatabase = data.sorted{ $0.timestamp > $1.timestamp }
                
                self.processDataFromDatabase(filter: filter,
                                             isOn: isOn,
                                             doNeedMore: doNeedMore,
                                             targetLayout: targetLayout)
            }
        } else {
            processDataFromDatabase(filter: filter,
                                    isOn: isOn,
                                    doNeedMore: doNeedMore,
                                    targetLayout: targetLayout)
        }
    }
    
    private func processDataFromDatabase(filter: FilterType,
                                         isOn: Bool,
                                         doNeedMore: Bool,
                                         targetLayout: MostViewedArtworkFlowLayout)
    {
        var pageArtwork = artworkDataFromDatabase
        
        if let recentTimestamp = recentTimestamp {
            pageArtwork = artworkDataFromDatabase.filter{ $0.timestamp < recentTimestamp }
        }
        
        if filter != .none {
            switch filter {
            case .orientation:
                pageArtwork = pageArtwork.filter{ $0.orientation == isOn }
            case .color:
                pageArtwork = pageArtwork.filter{ $0.color == isOn }
            case .temperature:
                pageArtwork = pageArtwork.filter{ $0.temperature == isOn }
            case .none:
                break
            }
        }
        
        var artworksData: [String: ArtworkDecodeType] = [:]
        
        pageArtwork[0..<min(self.batchSize, pageArtwork.count)].forEach {
            artworksData[$0.id] = ArtworkDecodeType(artworkModel: $0)
        }
        
        self.processData(data: artworksData, doNeedMore: doNeedMore, targetLayout: targetLayout)
    }
    
    private func processData(data: [String: ArtworkDecodeType],
                             doNeedMore: Bool,
                             targetLayout: MostViewedArtworkFlowLayout) {
        
        let result = data.values.sorted()
        result.forEach {
            self.databaseHandler.saveData(data: ArtworkModel(artwork: $0))
            self.fetchImage(artwork: $0, indexPath: nil)
        }
        
        if doNeedMore {
            var indexList: [Int] = []
            
            self.currentKey = result.first?.artworkUid
            self.recentTimestamp = result.first?.timestamp
            
            if result.count < self.batchSize {
                self.isEndOfData = true
                
            }
            let infoBucket =  calculateCellInfo(fetchedData: result,
                                                batchSize: self.itemsPerScreen,
                                                columns:self.columns)
            
            infoBucket.forEach {
                self.artworkBucket.append(contentsOf: $0.sortedArray)
                indexList.append($0.index)
            }
            
            DispatchQueue.main.async {
                self.loadingIndicator.deactivateIndicatorView()
                self.pagingDelegate.constructNextLayout(indexList: indexList, pageSize: result.count)
                let indexPaths = self.calculateIndexPathsForReloading(from: result)
                self.collectionView.insertItems(at: indexPaths)
            }
            
        } else {
            self.currentKey = result.first?.artworkUid
            self.recentTimestamp = result.first?.timestamp
            
            if result.count < self.batchSize {
                self.isEndOfData = true
            }
            targetLayout.fetchPage = result.count
            let infoBucket =
                calculateCellInfo(fetchedData: result,
                                  batchSize: self.itemsPerScreen,
                                  columns: self.columns)
            infoBucket.forEach {
                self.artworkBucket.append(contentsOf: $0.sortedArray)
                targetLayout.prepareIndex.append($0.index)
            }
            
            DispatchQueue.main.async {
                self.loadingIndicator.deactivateIndicatorView()
                self.isLoading = false
                self.collectionView.reloadData()
            }
        }
    }
    
    private func calculateIndexPathsForReloading(from newArtworks: [ArtworkDecodeType]) -> [IndexPath] {
        let startIndex = artworkBucket.count - newArtworks.count
        let endIndex = startIndex + newArtworks.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
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
                return .init()
            }
            footerView.addArtworkButton.addTarget(self,
                                                  action: #selector(addArtworkButtonDidTap),
                                                  for: .touchUpInside)
            self.footerView = footerView
            return footerView
        default:
            return .init()
        }
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                           willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height
     
        if maxOffset - currentOffset <= 40{
            if !isEndOfData, !isLoading, !isOptionOn {
                self.loadingIndicator.activateIndicatorView()
            }
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        latestContentsOffset = scrollView.contentOffset.y;
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 {
            if self.latestContentsOffset > scrollView.contentOffset.y {
                self.footerView?.addArtworkButton.alpha = 1
            }
            else if (self.latestContentsOffset < scrollView.contentOffset.y) {
                    self.footerView?.addArtworkButton.alpha = 0
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

// MARK:- PaginatingCollectionViewController Transitioning Delegate
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
}

extension PaginatingCollectionViewController: ArtAddViewControllerDelegate {
    func reloadMainView(controller: ArtAddViewController) {
        self.refreshFilteredLayout(filterType: .none, isOn: true)
    }
}

extension PaginatingCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        prefetchArtworkImage(indexPath: indexPath)
    }
    // MARK:- Prefetch artwork image
    private func prefetchArtworkImage(indexPath: IndexPath) {
        let visubleCellsIndex = collectionView.visibleCells.map{collectionView.indexPath(for: $0)?.item ?? 0}
        let max = visubleCellsIndex.max{ $0 < $1 }
        
        guard let maxIndex = max, maxIndex != 0 else { return }
        var prefetchIndex = 0
        if maxIndex < indexPath.item {
            prefetchIndex = min(indexPath.item + prefetchSize, artworkBucket.count - 1)
            removePrefetchedArtwork(prefetchIndex: prefetchIndex, front: true)
        } else {
            prefetchIndex = min(indexPath.item - prefetchSize, artworkBucket.count - 1)
            removePrefetchedArtwork(prefetchIndex: prefetchIndex, front: false)
        }
        
        guard  artworkBucket.count > prefetchIndex, prefetchIndex >= 0 else { return }
        
        let artwork = artworkBucket[prefetchIndex]
        if artworkImage[artwork.artworkUid] == nil {
            self.fetchImage(artwork: artwork, indexPath: nil)
        }
    }
    
    // MARK:- Remove prefetched artwork from ViewController
    private func removePrefetchedArtwork(prefetchIndex: Int, front: Bool) {
        if front {
            let targetIndex = prefetchIndex - prefetchSize
            
            guard targetIndex >= 0 else { return }
            
            for i in 0..<targetIndex {
                let artwork = artworkBucket[i]
                
                if artworkImage[artwork.artworkUid] != nil {
                    artworkImage.removeValue(forKey: artwork.artworkUid)
                }
            }
            
        } else {
            let targetIndex = prefetchIndex + prefetchSize
            
            guard targetIndex < artworkBucket.count else { return }
            
            for i in targetIndex..<artworkBucket.count {
                let artwork = artworkBucket[i]
                
                if artworkImage[artwork.artworkUid] != nil {
                    artworkImage.removeValue(forKey: artwork.artworkUid)
                }
            }

        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard artworkBucket.count - batchSize < indexPath.item else { return }
        
        if !isEndOfData, !isLoading, !isOptionOn {
            isLoading = true
            let queries = getQuery(filterType: filterType, isOn: isOn)
            fetchPages(queries:queries, type: filterType, isOn: isOn)
        }
    }
}

enum FilterType {
    case orientation
    case color
    case temperature
    case none
}
