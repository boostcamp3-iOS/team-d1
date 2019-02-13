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
    private let bottomBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = #colorLiteral(red: 0.922162652, green: 0.922162652, blue: 0.922162652, alpha: 1)
        view.layer.borderWidth = 0.5
        view.layer.borderColor = #colorLiteral(red: 0.6995778084, green: 0.6954212189, blue: 0.7027743459, alpha: 1)
        return view
    }()
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 10)
        return label
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    public let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.style = .whiteLarge
        return indicator
    }()
    
    // MARK:- Properties
    public var artwork: ArtworkDecodeType?
    public var artist = "" //TODO: 작가 정보를 담은 객체를 추가
    private let loader = ImageCacheFactory().buildImageLoader()
    
    // MARK:- Initialize
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.alpha = 1.0
        
        titleLabel.isHidden = true
        artistLabel.isHidden = true
        
        if let artwork = artwork, let url = URL(string: artwork.artworkUrl) {
            loader.fetchImage(url: url, size: .big) { (image, error) in
                if error != nil {
                    assertionFailure("failed to make cell")
                    return
                }
                guard let image = image else {
                    return
                }
                DispatchQueue.main.async {
                    let width = self.view.frame.width * 0.85
                    let height = width * (image.size.height / image.size.width) + 50
                    self.preferredContentSize = CGSize(width: width, height: height)
                    self.indicator.stopAnimating()
                    self.imageView.image = image
                    self.artistLabel.text = artwork.artworkUid
                    self.titleLabel.text = artwork.title
                    self.titleLabel.isHidden = false
                    self.artistLabel.isHidden = false
                }
            }
        }
        
        setLayout()
        setGestureRecognizer()
    }
    
    // MARK:- Set Gesture Recognizer
    private func setGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(artistLabelDidTap(_:)))
        artistLabel.isUserInteractionEnabled = true
        artistLabel.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK:- Artist Label Did Tap
    @objc func artistLabelDidTap(_ sender: UITapGestureRecognizer) {
        let artistViewController = ArtistViewController()
        
        // TODO: 작가 정보 추가 후 작가 정보 함께 넘겨줄 수 있도록 변경
        
        navigationController?.pushViewController(artistViewController, animated: true)
    }
    
    // MARK:- Set Layout
    private func setLayout() {
        view.addSubview(scrollView)
        view.addSubview(bottomBar)
        view.addSubview(indicator)
        bottomBar.addSubview(artistLabel)
        bottomBar.addSubview(titleLabel)
        scrollView.addSubview(imageView)
        scrollView.delegate = self
        
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        bottomBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        bottomBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        
        indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 7).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 12).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: 12).isActive = true
        
        artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5).isActive = true
        artistLabel.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 12).isActive = true
        artistLabel.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: 12).isActive = true
    }
}

// MARK:- UIScrollView Delegate
extension ArtworkViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
