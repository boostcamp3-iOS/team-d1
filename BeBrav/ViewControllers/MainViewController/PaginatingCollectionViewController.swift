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
    
    ///checkIfValidPosition() 메서드가 적용된 이후 리턴되는 튜플을 구분하기 쉽게 적용한 type입니다.
    typealias CalculatedInformation = (sortedArray: [ArtworkDecodeType], index: Int)
    
    
    lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(artworkCellDidTap))
        recognizer.minimumPressDuration = 1
        recognizer.delaysTouchesBegan = true
        return recognizer
    }()
    
    let loadingIndicator: LoadingIndicatorView = {
        let indicator = LoadingIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.noticeLabel.text = "loading images"
        return indicator
    }()
    ///MostViewedCollectionViewLayout의 prepare() 메서드가 호출되면 계산해야할 레이아웃은
    ///이전에 계산한 yOffset 아래에 위치해야 하기때문에 한번 데이터를 fetch하면 레이아웃을 이 프로퍼티
    ///를 통해서 업데이트 해주어야합니다.
    private var nextLayoutYPosition = 1
    
    ///연산이 완료된 currentBatchArtworkBucket를 저장하는 전체 데이터 저장소 프로퍼티입니다.
    private var artworkBucket: [ArtworkDecodeType] = []
    
    ///현재 batchSize만큼 얻어온 데이터 중 checkIfValidPosition() 메서드를 통해 연산한 후 얻어낸
    ///가장 뷰수가 많은 데이터의 index입니다.
    private var currentMostViewdArtworkIndex = 0
    
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
    
    //mainCollectionView 설정 관련 프로퍼티
    private let identifierFooter = "footer"
    private let spacing: CGFloat = 0
    private let insets: CGFloat = 2
    private let padding: CGFloat = 2
    private let columns: CGFloat = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //frame이 제대로 안잡힐 것으로 예상했지만 view의 frame은 정상적으로 잡히고 있습니다.
        if let layout = collectionView.collectionViewLayout as? MostViewedArtworkFlowLayout {
            batchSize = calculateNumberOfArtworksPerPage(numberOfColumns: CGFloat(columns), viewWidth: self.view.frame.width, viewHeight: self.view.frame.height, spacing: padding, insets: padding)
            layout.numberOfItems = batchSize
        }
        setCollectionView()
        setLoadingView()
        fetchPage()
        
        if UIApplication.shared.keyWindow?.traitCollection.forceTouchCapability == UIForceTouchCapability.available
        {
            registerForPreviewing(with: self, sourceView: view)
            
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
    func setCollectionView() {
        guard let collectionView = self.collectionView else { return }
        collectionView.alwaysBounceVertical = true
        collectionView.register(PaginatingCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ArtworkAddFooterReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: identifierFooter)
        collectionView.addGestureRecognizer(longPressGestureRecognizer)
        //TODO: filtering에 맞는 이미지로 수정
        let barItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(filterButtonDidTap))
        barItem.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        navigationItem.rightBarButtonItem = barItem
        
        if let layout = collectionView.collectionViewLayout as? MostViewedArtworkFlowLayout {
            layout.minimumInteritemSpacing = 0
            layout.sectionFootersPinToVisibleBounds = true
            layout.minimumLineSpacing = padding
            layout.delegate = self
        }
        
    }
    
    @objc func filterButtonDidTap() {
        //TODO: filtering 기능 추가
        let alertController: UIAlertController = UIAlertController(title: "필터 방식 선택",message: "어떤 필터링을 적용할까요? ",preferredStyle: .actionSheet)
        let reservationRateAction: UIAlertAction = UIAlertAction(title: "흑백 / 컬러", style: .default, handler: {(action: UIAlertAction) in
        })
        
        let qurationAction: UIAlertAction = UIAlertAction(title: "가로 / 세로", style: .default, handler: {(action: UIAlertAction) in
        })
        
        let outDateAction: UIAlertAction = UIAlertAction(title: "색 온도", style: .default, handler: {(action: UIAlertAction) in
        })
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(reservationRateAction)
        alertController.addAction(qurationAction)
        alertController.addAction(outDateAction)
        alertController.addAction(cancelAction)
        
        if UI_USER_INTERFACE_IDIOM() == .pad { //아이패드일 경우 액션시트를 대체해서 사용된다.
            alertController.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
            alertController.popoverPresentationController?.permittedArrowDirections = .up
            alertController.popoverPresentationController?.sourceView = self.view
            alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            self.present(alertController, animated: true, completion: nil)
        } else {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func addArtworkButtonDidTap() {
        //TODO: addArtwork 기능 추가
        let artAddViewController = ArtAddViewController()
        navigationController?.pushViewController(artAddViewController, animated: false)
    }
    
    @objc func artworkCellDidTap() {
        
        if longPressGestureRecognizer.state != .ended {
            return
        }
        let location = longPressGestureRecognizer.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: location) else {
            return
            
        }
        let pressedCell = collectionView.cellForItem(at: indexPath)
        pressedCell?.isSelected = true
    }
    
    // MARK:- Return viewController
    private func artworkViewController(location: CGPoint) -> ArtworkViewController {
        guard let index = collectionView.indexPathForItem(at: location)?.item else {
                return .init()
        }
        
        let photoViewController = ArtworkViewController()
        photoViewController.artwork = artworkBucket[index]
        // TODO: 이미지 사이즈에 따라 테스트후 preferredContentSize 값 설정
        photoViewController.preferredContentSize = CGSize(width: 0.0, height: 300)
        return photoViewController
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
        guard let url = URL(string: artworkBucket[indexPath.row].artworkUrl) else {
            assertionFailure("failed to make cell")
            return .init()
        }
        //TODO: 팀원과 협의하여 캐시정책 적용
        NetworkManager.shared.getImageWithCaching(url: url) { (image, error) in
            if error != nil {
                assertionFailure("failed to make cell")
                return
            }
            DispatchQueue.main.async {
                 cell.artworkImageView.image = image
            }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PaginatingCell else {
            fatalError()
        }
        let photoViewController = ArtworkViewController()
        photoViewController.imageView.image = cell.artworkImageView.image
        navigationController?.pushViewController(photoViewController, animated: false)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        return
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
}

extension PaginatingCollectionViewController {
    
    /// 컬렉션 뷰의 데이터를 페이지 단위로 받아오기 위한 메서드입니다.
    /// 이전에 데이터를 받아온 적이 있는지 currentKey를 통해서 확인합니다. 이후 쿼리를 생성하여 timestamp로
    /// 정렬된 데이터를 batchSize만큼 요청합니다. checkIfValidPosition()메서드를 이용하여 리턴된 값을
    /// 데이터 소스에 추가하고 nextLayoutYPosition을 Layout인스탠스의 pageNumber 프로퍼티에 전달해줍니다.
    func fetchPage() {
        currentBatchArtworkBucket.removeAll()
        isLoading = true
        loadingIndicator.activateIndicatorView()
        if !isEndOfData {
            guard let layout = self.collectionViewLayout as? MostViewedArtworkFlowLayout else {
                return
            }
            if currentKey == nil {
                let queries = [URLQueryItem(name: "orderBy", value: "\"timestamp\""),
                               URLQueryItem(name: "limitToLast", value: "\(batchSize)")
                ]
                
                serverDB.read(path: "root/artworks",
                              type: [String: ArtworkDecodeType].self,
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
                        if result.count > 0 {
                            for artwork in result {
                                self.currentBatchArtworkBucket.append(artwork)
                            }
                            let calculatedInfo: CalculatedInformation = checkIfValidPosition(data: self.currentBatchArtworkBucket,
                                                                                             numberOfColumns: Int(self.columns))
                            self.artworkBucket.append(contentsOf: calculatedInfo.sortedArray)
                            self.currentMostViewdArtworkIndex = calculatedInfo.index
                            self.currentKey = result.first?.artworkUid
                            self.recentTimestamp = result.first?.timestamp
                            DispatchQueue.main.async {
                                self.loadingIndicator.deactivateIndicatorView()
                                self.collectionView.reloadData()
                            }
                            self.isLoading = false
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
                              type: [String: ArtworkDecodeType].self,
                              queries: queries) {
                    (result, response) in
                    switch result {
                    case .failure(let error):
                        //TODO: 유저에게 보여줄 에러메세지 생성
                        print(error)
                    case .success(let data):
                        let result = data.values.sorted()
                        print("result is\(result.count)")
                        if result.count < self.batchSize {
                            self.isEndOfData = true
                        }
                        for artwork in result {
                            self.currentBatchArtworkBucket.append(artwork)
                        }
                        self.currentKey = result.first?.artworkUid
                        self.recentTimestamp = result.first?.timestamp
                        
                        let calculatedInfo: CalculatedInformation = checkIfValidPosition(data: self.currentBatchArtworkBucket,
                                                                                         numberOfColumns: Int(self.columns))
                            self.currentMostViewdArtworkIndex = calculatedInfo.index
                            self.artworkBucket.append(contentsOf: calculatedInfo.sortedArray)
                            layout.pageNumber = self.nextLayoutYPosition
                            self.nextLayoutYPosition = self.nextLayoutYPosition + 1
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                        }
                        self.isLoading = false
                        DispatchQueue.main.async {
                            self.loadingIndicator.deactivateIndicatorView()
                            //self.footerView?.indicator.stopAnimating()
                        }
                        
                    }
                }
            }
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
        if !isEndOfData {
            let window = UIApplication.shared.keyWindow
            let topPadding = window?.safeAreaInsets.top
            
            let contentLarger = (scrollView.contentSize.height > scrollView.frame.size.height - topPadding!)
            let viewableHeight = contentLarger ? (scrollView.frame.size.height - topPadding!) : scrollView.contentSize.height
            let atBottom = (scrollView.contentOffset.y >= scrollView.contentSize.height - viewableHeight - 40)
            if atBottom && !isLoading {
                fetchPage()
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
}

extension PaginatingCollectionViewController: MostViewLayoutDelegate {
    func getCurrentMostViewedArtworkIndex() -> Int {
        return currentMostViewdArtworkIndex
    }
}

extension PaginatingCollectionViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                           viewControllerForLocation location: CGPoint)
        -> UIViewController?
    {
         let viewController = artworkViewController(location: location)
        
        return viewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                           commit viewControllerToCommit: UIViewController)
    {
        
        show(viewControllerToCommit, sender: self)
    }
    
    
}

