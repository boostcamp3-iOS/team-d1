//
//  ArtAddCollectionViewController.swift
//  BeBrav
//
//  Created by 공지원 on 12/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

protocol ArtAddCollectionViewControllerDelegate: class {
    func uploadArtwork(_ controller: ArtAddCollectionViewController, image: UIImage)
}

class ArtAddCollectionViewController: UICollectionViewController {
    
    //MARK : - Properties
    private let cellIdentifier = "ArtAddCell"
    
    private var artAddCell: ArtAddCell? //ArtAddCell 인스턴스를 참조하기 위한 변수
    
    weak var delegate: ArtAddCollectionViewControllerDelegate?
    
    private let imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        return picker
    }()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK : - View Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        setUpCollectionView()
        setKeyboardObserver()
        
        //test
        //determines whether bouncing always occurs when vertical scrolling reaches the end of the content.
        collectionView.alwaysBounceVertical = true
        collectionView.contentInsetAdjustmentBehavior = .never
    }
    
    //MARK : - Helper Method
    
    //TODO : - 개선하기
    private func setUpCollectionView() {
        collectionView.register(ArtAddCell.self, forCellWithReuseIdentifier: cellIdentifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //FixMe : - 화면이 위로 튕김 현상
    @objc func keyboardWillShow(_ sender: Notification) {
        self.view.frame.origin.y = -150  //move view upward
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        self.view.frame.origin.y = 0 //move view to original position
    }
    
    @objc func keyboardDidShow(_ sender: Notification) {
        print()
    }
}

//MARK : - Collection View Data Source
extension ArtAddCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? ArtAddCell else { return UICollectionViewCell() }
        
        artAddCell = cell //큐에서 가져온 현재 셀을 artAddCell이 참조
        
        cell.delegate = self //ArtAddCell의 delegate를 현재 뷰 컨트롤러로 위임
        return cell
    }
}

//MARK : - Scroll View Delegate
extension ArtAddCollectionViewController {
    
    //TODO: - 뷰를 위로 드래그하면 작품이 업로드 된다
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let image = artAddCell?.imageView.image else { return }
        
        if scrollView.contentOffset.y > 100 && velocity.y > 2 {
            if artAddCell?.imageView.image != nil && artAddCell?.titleTextField.text?.isEmpty == false && artAddCell?.descriptionTextField.text?.isEmpty == false {
                print("작품업로드")
                dismiss(animated: true) {
                    self.delegate?.uploadArtwork(self, image: image)
                }
            }
            else {
                print("작품정보를 다 입력해주세요!")
            }
        }
    }
}

//MARK : - ArtAddCell Delegate Method

//현재 뷰 컨트롤러가 ArtAddCell의 기능을 위임받아 구현하는 부분
extension ArtAddCollectionViewController: ArtAddCellDelegate {
    
    //ArtAddCell의 imageView가 tap 되었을때 불리는 메서드
    //이미지 피커를 present한다
    func presentImagePicker(_ cell: ArtAddCell) {
        artAddCell?.cancelButton.isHidden = true
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
        cell.orientationLabel.isHidden = true
        cell.colorLabel.isHidden = true
        cell.temperatureLabel.isHidden = true
    }
    
    func dismissArtAddView(_ cell: ArtAddCell) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - Image Picker Delegate
extension ArtAddCollectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func showImageSortResultLabel() {
        artAddCell?.orientationLabel.isHidden = false
        artAddCell?.colorLabel.isHidden = false
        artAddCell?.temperatureLabel.isHidden = false
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let editedImage = info[.editedImage] as? UIImage
        
        artAddCell?.imageView.image = editedImage
        artAddCell?.plusButton.isHidden = true
        artAddCell?.cancelButton.isHidden = false
        
        dismiss(animated: true) {
            DispatchQueue.global().async {
                var imageSort = ImageSort(input: editedImage)
                
                guard let r1 = imageSort.orientationSort(), let r2 = imageSort.colorSort(), let r3 = imageSort.temperatureSort() else { return }
                
                DispatchQueue.main.async {
                    self.showImageSortResultLabel()
                    
                    self.artAddCell?.orientationLabel.text = "#\(r1)"
                    self.artAddCell?.colorLabel.text = "#\(r2)"
                    self.artAddCell?.temperatureLabel.text = "#\(r3)"
                    
                    if self.artAddCell?.titleTextField.text?.isEmpty == false && self.artAddCell?.descriptionTextField.text?.isEmpty == false {
                        self.artAddCell?.upArrowImageView.image = #imageLiteral(resourceName: "blueArrow")
                        self.artAddCell?.uploadLabel.isHidden = false
                        self.collectionView.isScrollEnabled = true
                    }
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        showImageSortResultLabel()
        artAddCell?.cancelButton.isHidden = false
        dismiss(animated: true, completion: nil)
    }
}

extension ArtAddCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
}
