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
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.text = "작가 이름"
        return label
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 19)
        label.text = "작품 제목"
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
    
    // MARK:- Initialize
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.alpha = 1.0
        
        titleLabel.isHidden = true
        artistLabel.isHidden = true
        
        if let artwork = artwork, let url = URL(string: artwork.artworkUrl) {
            NetworkManager.shared.getImageWithCaching(url: url) { (image, error) in
                if error != nil {
                    assertionFailure("failed to make cell")
                    return
                }
                guard let image = image else {
                    return
                }
                DispatchQueue.main.async {
                    let width = self.view.frame.width * 0.85
                    let height = width * (image.size.height / image.size.width)
                    self.preferredContentSize = CGSize(width: width, height: height)
                    self.indicator.stopAnimating()
                    self.imageView.image = image
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
    #warning("Add ViewController and Push for Artist Detail")
    @objc func artistLabelDidTap(_ sender: UITapGestureRecognizer) {
        let artistViewController = ArtistViewController()
        
        navigationController?.pushViewController(artistViewController, animated: true)
    }

    // MARK:- Set Layout
    private func setLayout() {
        view.addSubview(scrollView)
        view.addSubview(indicator)
        scrollView.addSubview(imageView)
        scrollView.addSubview(artistLabel)
        scrollView.addSubview(titleLabel)
        scrollView.delegate = self
        
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor).isActive = true
        
        let width = imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        width.priority = .init(750)
        width.isActive = true
        let height = imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        height.priority = .init(750)
        height.isActive = true
        
        titleLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        
        artistLabel.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -10).isActive = true
        artistLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor).isActive = true
        
        indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

// MARK:- UIScrollView Delegate
extension ArtworkViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
