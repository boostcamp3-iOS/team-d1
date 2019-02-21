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
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "cancel"), for: .normal)
        button.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        button.layer.shadowRadius = 3.0
        button.layer.shadowOpacity = 1
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = ""
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textAlignment = .right
        return label
    }()
    
    private let viewsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .right
        return label
    }()
    
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = ""
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .right
        return label
    }()
    
    // MARK:- Properties
    private let imageLoader: ImageLoaderProtocol
    private let databaseHandler: DatabaseHandler
    private let serverDatabase: ServerDatabase

    public var mainNavigationController: UINavigationController?
    public var artwork: ArtworkDecodeType?
    public var artistName: String?
    public var artworkImage: UIImage? {
        didSet {
            imageView.image = artworkImage
        }
    }
    public var isAnimating = false {
        didSet {
            presentAnimation(isAnimating: isAnimating)
        }
    }
    public var isPeeked = false {
        didSet {
            view.backgroundColor = isPeeked ? .clear : #colorLiteral(red: 0.1780431867, green: 0.1711916029, blue: 0.2278442085, alpha: 1)
            closeButton.isHidden = isPeeked
        }
    }
    public var isFromArtistView = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
        
        fetchArtworkImage()
        
        setLayout()
        setLabels()
        setPreferredContentSize()
        setGestureRecognizer()
        
        closeButton.addTarget(self, action: #selector(touchUpCloseButton(_:)), for: .touchUpInside)
    } 
    
    // MARK:- Fetch artwork image
    private func fetchArtworkImage() {
        guard let artwork = artwork, let url = URL(string: artwork.artworkUrl) else {
            self.showErrorAlert()
            return
        }
        
        titleLabel.text = artwork.title
        viewsLabel.text = artwork.views.decimalString + " " + "views".localized

        imageLoader.fetchImage(url: url, size: .big) { (image, error) in
            self.finishFetchImage(image: image, error: error)
        }
    }
    
    // MARK:- Show error alert
    private func showErrorAlert() {
        let alert = UIAlertController(title: "networkError".localized,
                                      message: "imageNetworkErrorMessage".localized,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: "done".localized, style: .default) { _ in
            if self.imageView.image == nil {
                self.dismiss(animated: true, completion: nil)
            }
        }
        alert.addAction(action)

        present(alert, animated: false, completion: nil)
    }
    
    // MARK:- Finish fetch image
    private func finishFetchImage(image: UIImage?, error: Error?) {
        guard error == nil else { return }
        guard let image = image else { return }
        
        DispatchQueue.main.async {
            self.artworkImage = image
        }
    }
    
    // MARK:- Set Labels
    private func setLabels() {
        setLabelShadow(label: titleLabel)
        setLabelShadow(label: artistLabel)
        setLabelShadow(label: viewsLabel)
        
        artistLabel.text = "임시 이름"//artwork?.authorName
    }
    
    private func setLabelShadow(label: UILabel) {
        label.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        label.shadowOffset = CGSize(width: 0.5, height: 0.5)
        label.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        label.layer.shadowOffset = CGSize(width: 0, height: 0)
        label.layer.shadowRadius = 3.0
        label.layer.shadowOpacity = 1
    }
    
    // MARK:- Set preferred content size to view
    private func setPreferredContentSize() {
        guard let image = imageView.image else { return }
        
        let width = view.frame.width * 0.85
        let height = width * (image.size.height / image.size.width)
        preferredContentSize = CGSize(width: width, height: height)
    }
    
    // MARK:- Set gesture recognizer
    private func setGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,action: #selector(artistLabelDidTap(_:)))
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
            closeButton.alpha = 0
            titleLabel.alpha = 0
            artistLabel.alpha = 0
            viewsLabel.alpha = 0
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                self.closeButton.alpha = 1
                self.titleLabel.alpha = 1
                self.artistLabel.alpha = 1
                self.viewsLabel.alpha = 1
            })
        }
        
        view.backgroundColor = isAnimating ? .clear : #colorLiteral(red: 0.1780431867, green: 0.1711916029, blue: 0.2278442085, alpha: 1)
    }
    
    // MARK:- Touch up close button
    @objc private func touchUpCloseButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK:- Artist label did tap
    @objc private func artistLabelDidTap(_ sender: UITapGestureRecognizer) {
        guard !isFromArtistView else { return }
        
        guard let navigationController = mainNavigationController,
        let id = artwork?.userUid
            else
        {
            return
        }
        let imageLoader = ImageCacheFactory().buildImageLoader()
        let serverDatabase = NetworkDependencyContainer().buildServerDatabase()
        let databaseHandler = DatabaseHandler()
        let viewController = ArtistViewController(imageLoader: imageLoader,
                                                  serverDatabase: serverDatabase,
                                                  databaseHandler: databaseHandler)
        
        viewController.userUid = id

        navigationController.pushViewController(viewController, animated: false)
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK:- Image view did double tap
    @objc private func imageViewDidDoubleTap(_ sender: UITapGestureRecognizer) {
        let scale = scrollView.zoomScale
        
        UIView.animate(withDuration: 0.2, animations: {
            self.scrollView.zoomScale = (scale == 1) ? 2 : 1
        })
    }
    
    // MARK:- Set layout
    private func setLayout() {
        view.addSubview(scrollView)
        view.addSubview(closeButton)
        view.addSubview(artistLabel)
        view.addSubview(titleLabel)
        view.addSubview(viewsLabel)
        scrollView.addSubview(imageView)
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self
        
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true

        artistLabel.trailingAnchor.constraint(equalTo: viewsLabel.trailingAnchor).isActive = true
        artistLabel.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -5).isActive = true
        
        titleLabel.trailingAnchor.constraint(equalTo: viewsLabel.trailingAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: viewsLabel.topAnchor, constant: 1).isActive = true
        
        viewsLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15).isActive = true
        viewsLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15).isActive = true
        
        closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
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
