//
//  PhotoViewController.swift
//  BeBrav
//
//  Created by Seonghun Kim on 22/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class ArtworkViewController: UIViewController {
    
    // MARK:- Outlet
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.maximumZoomScale = 2.0
        scrollView.minimumZoomScale = 1.0
        scrollView.zoomScale = 1
        scrollView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        return scrollView
    }()
    private let topBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        return view
    }()
    private let artistView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(displayP3Red: 0.2549019754,
                                       green: 0.2745098174,
                                       blue:0.3019607961,
                                       alpha: 0.5)
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
        return view
    }()
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 22)
        return label
    }()
    private let closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("닫기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        
        return button
    }()
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK:- Properties
    public var mainNavigationController: UINavigationController?
    public var artwork: ArtworkDecodeType?
    public var artist = "작가 이름" //TODO: 작가 정보를 담은 객체를 추가
    public var thumbImage: UIImage? {
        didSet {
            imageView.image = thumbImage
        }
    }
    public var isAnimating = false {
        didSet {
            presentAnimation(isAnimating: isAnimating)
        }
    }
    public var isPeeked = false {
        didSet {
            closeButton.isHidden = isPeeked
        }
    }
    
    private let loader = ImageCacheFactory().buildImageLoader()
    
    // MARK:- Initialize
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchArtworkImage()
        
        setLayout()
        setPreferredContentSize()
        setGestureRecognizer()
        
        closeButton.addTarget(self, action: #selector(touchUpCloseButton(_:)), for: .touchUpInside)
    }
    
    // MARK:- Fetch artwork image
    private func fetchArtworkImage() {
        guard let artwork = artwork, let url = URL(string: artwork.artworkUrl) else {
            assertionFailure("No artwork information")
            return
        }
        
        titleLabel.text = artwork.title
        artistLabel.text = artist
        
        loader.fetchImage(url: url, size: .big) { (image, error) in
            self.finishFetchImage(image: image, error: error)
        }
    }
    
    // MARK:- Finish fetch image
    private func finishFetchImage(image: UIImage?, error: Error?) {
        if let error = error {
            assertionFailure(error.localizedDescription) // TODO: 오류처리 추가 후 삭제
            return
        }
        guard let image = image else {
            assertionFailure("failed to fetch image Data") // TODO: 오류처리 추가 후 삭제
            return
        }
        DispatchQueue.main.async {
            self.imageView.image = image
        }
    }
    // MARK:- Set preferred content size to view
    private func setPreferredContentSize() {
        guard let image = imageView.image else { return }
        
        let width = view.frame.width * 0.85
        let height = width * (image.size.height / image.size.width) + 50
        preferredContentSize = CGSize(width: width, height: height)
    }
    
    // MARK:- Set gesture recognizer
    private func setGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(artistLabelDidTap(_:)))
        artistLabel.isUserInteractionEnabled = true
        artistLabel.addGestureRecognizer(tapGestureRecognizer)
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewDidDoubleTap(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    // MARK:- Present animation
    private func presentAnimation(isAnimating: Bool) {
        if isAnimating {
            topBar.alpha = 0
            artistView.alpha = 0
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                self.topBar.alpha = 1
                self.artistView.alpha = 1
            })
        }
        
        scrollView.backgroundColor = isAnimating ? .clear : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    // MARK:- Touch up close button
    @objc private func touchUpCloseButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK:- Artist label did tap
    @objc private func artistLabelDidTap(_ sender: UITapGestureRecognizer) {
        guard let navigationController = mainNavigationController else {
            return
        }
        
        let artistViewController = ArtistViewController()
        // TODO: 작가 정보 추가 후 함께 넘겨 줄 수 있도록 변경
        navigationController.pushViewController(artistViewController, animated: false)
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK:- Image view did double tap
    @objc private func imageViewDidDoubleTap(_ sender: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1 {
            UIView.animate(withDuration: 0.2, animations: {
                self.scrollView.zoomScale = 2
            })
            return
        }
        
        if scrollView.zoomScale == 2 {
            UIView.animate(withDuration: 0.2, animations: {
                self.scrollView.zoomScale = 1
            })
            return
        }
    }
    
    // MARK:- Set layout
    private func setLayout() {
        view.addSubview(scrollView)
        view.addSubview(topBar)
        view.addSubview(artistView)
        topBar.addSubview(titleLabel)
        topBar.addSubview(closeButton)
        artistView.addSubview(artistLabel)
        scrollView.addSubview(imageView)
        scrollView.alwaysBounceVertical = true
        scrollView.delegate = self
        
        scrollView.topAnchor.constraint(equalTo: topBar.bottomAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        
        topBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 7).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: topBar.bottomAnchor, constant: -7).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: 12).isActive = true
        
        closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        closeButton.bottomAnchor.constraint(equalTo: topBar.bottomAnchor).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12).isActive = true
        closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor).isActive = true
        closeButton.setContentCompressionResistancePriority(.init(999), for: .horizontal)
        
        artistView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        artistView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        artistView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        
        artistLabel.leadingAnchor.constraint(equalTo: artistView.leadingAnchor, constant: 12).isActive = true
        artistLabel.trailingAnchor.constraint(equalTo: artistView.trailingAnchor, constant: -12).isActive = true
        artistLabel.centerXAnchor.constraint(equalTo: artistView.centerXAnchor).isActive = true
        artistLabel.centerYAnchor.constraint(equalTo: artistView.centerYAnchor).isActive = true
    }
}

// MARK:- UIScrollView Delegate
extension ArtworkViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView.zoomScale == 1 else { return }
        guard (view.frame.origin.y - scrollView.contentOffset.y) > 80 else { return }
        
        dismiss(animated: true, completion: nil)
    }
}


/*
 // 다음 코드들을 메인화면 ViewController에 추가해야함
 
override func viewDidLoad() {
    super.viewDidLoad()
    if UIApplication.shared.keyWindow?.traitCollection.forceTouchCapability == .available
    {
        registerForPreviewing(with: self, sourceView: collectionView)
        
    }
}

// MARK:- Return ArtworkViewController
private func artworkViewController(index: IndexPath) -> ArtworkViewController {
    guard let cell = collectionView.cellForItem(at: index) as? PaginatingCell else {
        return .init()
    }
    
    let viewController = ArtworkViewController()
    herbDetails.transitioningDelegate = self
    viewController.mainNavigationController = navigationController
    viewController.artwork = artworkBucket[index.item]
    viewController.imageView.image = cell.artworkImageView.image
    
    return viewController
}

override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let viewController = artworkViewController(index: indexPath)
    
    present(viewController, animated: true, completion: nil)
}
extension PaginatingCollectionViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                           viewControllerForLocation location: CGPoint)
        -> UIViewController?
    {
        guard let index = collectionView.indexPathForItem(at: location) else {
            return .init()
        }
        let viewController = artworkViewController(index: index)
        viewController.closeButton.isHidden = true
        
        return viewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                           commit viewControllerToCommit: UIViewController)
    {
        guard let viewController = viewControllerToCommit as? ArtworkViewController else {
            return
        }
        viewController.closeButton.isHidden = false
 
        present(viewController, animated: false, completion: nil)
    }
}
 
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
        transition.originFrame = collectionView.convert(cell.frame, to: nil)
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning?
    {
        return nil
    }
}
*/
