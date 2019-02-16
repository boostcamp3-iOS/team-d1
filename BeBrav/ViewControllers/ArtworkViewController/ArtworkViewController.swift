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
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let closeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        // TODO: Merge 한 후에  UIColor 확장에 색상을 담은 후 반환하도록 변경
        view.backgroundColor = UIColor(displayP3Red: 0.2549019754,
                                       green: 0.2745098174,
                                       blue:0.3019607961,
                                       alpha: 0.5)
        view.clipsToBounds = true
        view.layer.cornerRadius = 15
        return view
    }()
    private let closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("닫기", for: .normal) // TODO: 제품 등록화면 닫기 버튼과 UI 일치하도록 변경
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    private let titleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        // TODO: Merge 한 후에  UIColor 확장에 색상을 담은 후 반환하도록 변경
        view.backgroundColor = UIColor(displayP3Red: 0.2549019754,
                                       green: 0.2745098174,
                                       blue:0.3019607961,
                                       alpha: 0.5)
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
        return view
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
    private let artistView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        // TODO: Merge 한 후에  UIColor 확장에 색상을 담은 후 반환하도록 변경
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
        label.text = ""
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    
    // MARK:- Properties
    public var mainNavigationController: UINavigationController?
    public var artwork: ArtworkDecodeType?
    public var artist = "작가 이름" //TODO: 작가 정보를 담은 객체를 추가
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
            closeView.isHidden = isPeeked
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
            assertionFailure("No artwork information") // TODO: 오류처리 추가 후 변경
            return
        }
        
        titleLabel.text = artwork.title
        viewsLabel.text = artwork.views.decimalString + " Views"
        artistLabel.text = artist
        
        loader.fetchImage(url: url, size: .big) { [weak self] (image, error) in
            guard let self = self else { return }
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
            self.artworkImage = image
        }
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
            closeView.alpha = 0
            titleView.alpha = 0
            artistView.alpha = 0
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                self.closeView.alpha = 1
                self.titleView.alpha = 1
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
        let scale = scrollView.zoomScale
        
        UIView.animate(withDuration: 0.2, animations: {
            self.scrollView.zoomScale = (scale == 1) ? 2 : 1
        })
    }
    
    // MARK:- Set layout
    private func setLayout() {
        view.addSubview(scrollView)
        view.addSubview(artistView)
        view.addSubview(titleView)
        view.addSubview(closeView)
        titleView.addSubview(titleLabel)
        titleView.addSubview(viewsLabel)
        artistView.addSubview(artistLabel)
        closeView.addSubview(closeButton)
        scrollView.addSubview(imageView)
        scrollView.alwaysBounceVertical = true
        scrollView.delegate = self
        
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        
        artistView.bottomAnchor.constraint(equalTo: titleView.topAnchor, constant: -3).isActive = true
        artistView.trailingAnchor.constraint(equalTo: titleView.trailingAnchor).isActive = true
        
        artistLabel.leadingAnchor.constraint(equalTo: artistView.leadingAnchor, constant: 5).isActive = true
        artistLabel.trailingAnchor.constraint(equalTo: artistView.trailingAnchor, constant: -5).isActive = true
        artistLabel.topAnchor.constraint(equalTo: artistView.topAnchor, constant: 5).isActive = true
        artistLabel.bottomAnchor.constraint(equalTo: artistView.bottomAnchor, constant: -5).isActive = true
        
        titleView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15).isActive = true
        titleView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15).isActive = true
        
        titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 5).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -5).isActive = true
        titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor, constant: 1).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: viewsLabel.topAnchor, constant: 1).isActive = true
        
        viewsLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 5).isActive = true
        viewsLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -5).isActive = true
        viewsLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -5).isActive = true
        
        closeView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        closeView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        
        closeButton.topAnchor.constraint(equalTo: closeView.topAnchor, constant: 10).isActive = true
        closeButton.bottomAnchor.constraint(equalTo: closeView.bottomAnchor, constant: -10).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: closeView.leadingAnchor, constant: 10).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: closeView.trailingAnchor, constant: -10).isActive = true
        closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor).isActive = true
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
