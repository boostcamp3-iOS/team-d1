//
//  PhotoViewController.swift
//  BeBrav
//
//  Created by Seonghun Kim on 22/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
    
    // MARK:- Outlet
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.maximumZoomScale = 1.5
        scrollView.minimumZoomScale = 0.7
        return scrollView
    }()
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.text = "작가 이름"
        return label
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 19)
        label.text = "작품 제목"
        return label
    }()
    
    // MARK:- Initialize
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        setGestureRecognizer()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let centerOffsetX = (scrollView.contentSize.width - scrollView.frame.size.width) / 2
        let centerOffsetY = (scrollView.contentSize.height - scrollView.frame.size.height) / 2
        let centerPoint = CGPoint(x: centerOffsetX, y: centerOffsetY)
        scrollView.setContentOffset(centerPoint, animated: false)
    }
    
    // MARK:- Set Gesture Recognizer
    private func setGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(artistLabelDidTap(_:)))
        artistLabel.isUserInteractionEnabled = true
        artistLabel.addGestureRecognizer(tapGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(imageViewDidPinched(_:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    // MARK:- Artist Label Did Tap
    #warning("Add ViewController and Push for Artist Detail")
    @objc func artistLabelDidTap(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true) {
            //TODO: 화면 닫은 후에 메인화면의 navigationController에서 작가상세화면으로 push 하도록 코드 추가
        }
    }
    
    // MARK:- ImageView Did Pinched
    @objc func imageViewDidPinched(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .ended {
            if sender.scale < 0.8 {
                dismiss(animated: true, completion: nil)
            } else {
                scrollView.zoomScale = 1.0
            }
        } else {
            scrollView.zoomScale = sender.scale
        }
    }
    
    // MARK:- Set Layout
    private func setLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(artistLabel)
        scrollView.addSubview(titleLabel)
        scrollView.delegate = self
        
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        imageView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        let left = imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor)
        left.priority = .init(1)
        left.isActive = true
        let right = imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
        right.priority = .init(1)
        right.isActive = true
        
        titleLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        
        artistLabel.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -10).isActive = true
        artistLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor).isActive = true
    }
}

// MARK:- UIScrollView Delegate
extension PhotoViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
