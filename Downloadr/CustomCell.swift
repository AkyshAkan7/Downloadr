//
//  MyCell.swift
//  Downloadr
//
//  Created by Akan Akysh on 8/26/19.
//  Copyright © 2019 Akysh Akan. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class CustomCell: UITableViewCell {
    
    static let cellId = "cellId"
    
    let stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.spacing = 5
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let artisLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkGray
        return label
    }()
    
    let progressView: UIProgressView = {
        let pv = UIProgressView()
        pv.transform = pv.transform.scaledBy(x: 1, y: 2)
        pv.clipsToBounds = true
        pv.layer.cornerRadius = 3
        pv.isHidden = true
        return pv
    }()
    
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Скачать", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
        // Adding tableViewCell components
        addSubview(stackView)
        addSubview(actionButton)
        
        // Adding stackView components
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(artisLabel)
        stackView.addArrangedSubview(progressView)

        // Adding constraints
        stackView.snp.makeConstraints { (make) in
            make.top.equalTo(7)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.bottom.equalTo(-5)
            make.height.equalTo(53)
        }
        
        actionButton.snp.makeConstraints { (make) in
            make.topMargin.equalTo(15)
            make.right.equalTo(-20)
        }
    }
    
    func updateDisplay(progress: Float) {
        progressView.progress = progress
    }
    
    func updateButtonState(isDownloading: Bool, isDownloaded: Bool) {
        if isDownloading == false, isDownloaded == false{
            actionButton.setTitle("Скачать", for: .normal)
            actionButton.setTitleColor(.blue, for: .normal)
            actionButton.isEnabled = true
            progressView.isHidden = true
        }
        
        if isDownloading == true, isDownloaded == false{
            actionButton.setTitle("Идет загрузка", for: .normal)
            actionButton.setTitleColor(.blue, for: .normal)
            actionButton.isEnabled = false
            progressView.isHidden = false
        }
        
        if isDownloading == false, isDownloaded == true{
            actionButton.setTitle("Удалить", for: .normal)
            actionButton.setTitleColor(.red, for: .normal)
            actionButton.isEnabled = true
            progressView.isHidden = true
        }
        
    }
    
}
