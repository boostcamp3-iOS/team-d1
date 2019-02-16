//
//  LoadingIndicator.swift
//  BeBrav
//
//  Created by bumslap on 09/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class LoadingIndicatorView: UIVisualEffectView {
    
   private let indicatorStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.distribution = .fillProportionally
        view.spacing = 10
        return view
    }()
    
   private let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.style = .gray
        return indicator
    }()
    
    let noticeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        return label
    }()
    
    init() {
        super.init(effect: UIBlurEffect(style: .light))
        self.backgroundColor = .clear
        setLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setLayout() {
        
        contentView.addSubview(indicatorStackView)
        indicatorStackView.addArrangedSubview(indicator)
        indicatorStackView.addArrangedSubview(noticeLabel)
        
        indicatorStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        indicatorStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 15
    }
    
    func activateIndicatorView() {
        self.isHidden = false
        indicator.startAnimating()
    }
    
    func deactivateIndicatorView() {
        self.isHidden = true
        indicator.stopAnimating()
    }
}
