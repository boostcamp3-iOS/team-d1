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
    
    private var footerView: ArtworkAddFooterReusableView?
    private var isLoading = false
    private var artworkBucket: [ArtworkTest] = []
    private lazy var serverDB = container.buildServerDatabase()
    private var recentTimestamp: Double!
    private var currentKey: String!
    
    private let container = NetworkDependencyContainer()
    private let identifierFooter = "footer"
    private let spacing: CGFloat = 0
    private let insets: CGFloat = 2
    private let padding: CGFloat = 2
    private let columns: CGFloat = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionView()
        fetchPage()
    }
    
    func setCollectionView() {
        guard let collectionView = self.collectionView else { return }
        collectionView.alwaysBounceVertical = true
        collectionView.register(PaginatingCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ArtworkAddFooterReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: identifierFooter)
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 0
            layout.sectionFootersPinToVisibleBounds = true
            layout.minimumLineSpacing = padding
            
        }
        
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        //TODO: 몇개의 데이터를 가져올지 결정하는 로직 구성

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
}

extension PaginatingCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
         let insetsNumber = columns + 1
         let width = (collectionView.frame.width - (insetsNumber * spacing) - (insetsNumber * insets)) / columns
         return CGSize(width: width, height: width)
     }
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
     return UIEdgeInsets(top: insets, left: insets, bottom: insets, right: insets)
     }
}


extension PaginatingCollectionViewController {
    func fetchPage() {
        isLoading = true
        if currentKey == nil {
            let queries = [URLQueryItem(name: "orderBy", value: "\"timestamp\""),
                           URLQueryItem(name: "limitToLast", value: "15")
            ]
            
            serverDB.read(path: "root/artworks", type: [String: ArtworkTest].self, queries: queries) {
                (result, response) in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let data):
                    let result = data.values.sorted(by: { (first,second) in
                        first.timestamp > second.timestamp
                    })
                    if result.count > 1 {
                        for artwork in result {
                            self.artworkBucket.insert(artwork, at: 0)
                        }
                        self.currentKey = result.last?.artworkUid
                        self.recentTimestamp = result.last?.timestamp
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                        self.isLoading = false
                    }
                }
            }
        } else {
           //xcode버그 있어서 그래로 넣으면 가끔 빌드가 안됩니다.
            let string = "\"timestamp\""
                let queries = [URLQueryItem(name: "orderBy", value: string),
                               URLQueryItem(name: "endAt", value: "\(Int(recentTimestamp))"),
                               URLQueryItem(name: "limitToLast", value: "15")
                ]
            serverDB.read(path: "root/artworks", type: [String: ArtworkTest].self, queries: queries) {
                (result, response) in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let data):
                    let result = data.values.sorted(by: { (first,second) in
                        first.timestamp > second.timestamp
                    })
                    print(result)
                    if result.count > 1 {
                        for artwork in result {
                            self.artworkBucket.insert(artwork, at: 0)
                        }
                        self.currentKey = result.last?.artworkUid
                        self.recentTimestamp = result.last?.timestamp
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                        self.isLoading = false
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
            return .init(width: view.frame.width, height: 60)
    }
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
                guard let footerView =
                    collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                    withReuseIdentifier: identifierFooter,
                                                                    for: indexPath) as? ArtworkAddFooterReusableView else {
                    return UICollectionReusableView.init()
                }
                self.footerView = footerView
                return footerView
        default:
        return UICollectionReusableView.init()
        }
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maxOffset - currentOffset <= 40{
            if !isLoading {
                collectionView.collectionViewLayout.invalidateLayout()
                fetchPage()
            }
            
        }
    }
    
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let totalScroll: CGFloat  = scrollView.contentSize.height - scrollView.bounds.size.height;
        let offset: CGFloat = scrollView.contentOffset.y;
        let ratio: CGFloat = offset / totalScroll;
        guard let footer = footerView else { return }
            footer.addArtworkButton.alpha = (1 - ratio * 5);
        footer.layoutIfNeeded()
        }
}

// 테스트용 모델
struct ArtworkTest: Decodable {
    let artworkUid: String
    let artworkUrl: String
    let timestamp: Double
    let title: String
    let views: Int
}

struct Artworks: Decodable {
    let artworks: [String: ArtworkTest]
}
