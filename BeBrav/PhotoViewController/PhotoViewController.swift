//
//  PhotoViewController.swift
//  BeBrav
//
//  Created by Seonghun Kim on 22/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

@IBDesignable
class PhotoViewController: UIViewController {
    
    // MARK:- Outlet
    var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.maximumZoomScale = 1.5
        scrollView.minimumZoomScale = 0.7
        return scrollView
    }()
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    var artistLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.text = "작가 이름"
        return label
    }()
    var titleLabel: UILabel = {
        let label = UILabel()
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
    
    // MARK:- Tap Artist Label
    #warning("Add ViewController for Artist Detail")
    @objc func artistLabelDidTap(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true) {
            let VC = UIViewController()
            self.navigationController?.pushViewController(VC, animated: true)
        }
    }
    
    // MARK:- Pinch ImageView
    @objc func imageViewDidPinched(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .ended {
            if sender.scale < 0.8 {
                UIView.animate(withDuration: 0.3, animations: {
                    self.dismiss(animated: false, completion: nil)
                })
            } else {
                scrollView.zoomScale = 1.0
            }
        } else {
            scrollView.zoomScale = sender.scale
        }
    }
}

// MARK:- UIScrollView Delegate
extension PhotoViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

// MARK:- Set Layout And Gesture
extension PhotoViewController {
    // MARK:- Set Layout
    private func setLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(artistLabel)
        scrollView.addSubview(titleLabel)
        scrollView.delegate = self
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        let left = imageView.leftAnchor.constraint(equalTo: scrollView.leftAnchor)
        left.priority = .init(1)
        left.isActive = true
        let right = imageView.rightAnchor.constraint(equalTo: scrollView.rightAnchor)
        right.priority = .init(1)
        right.isActive = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let titleBottom = titleLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        titleBottom.constant += -20
        titleBottom.isActive = true
        let titleRight = titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        titleRight.constant += -20
        titleRight.isActive = true
        
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        let artistBottom = artistLabel.bottomAnchor.constraint(equalTo: titleLabel.topAnchor)
        artistBottom.constant += -10
        artistBottom.isActive = true
        artistLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor).isActive = true
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
}
