//
//  SWWallpaperTableViewCell.swift
//  SWRaffle
//
//  Created by Jason on 2020/4/18.
//  Copyright © 2020 UTAS. All rights reserved.
//

import UIKit

class SWWallpaperTableViewCell: UITableViewCell {

    var needsBottomMargin = false
    let numberLabel: SWPaddingableLabel! = SWPaddingableLabel.init()
    let nameLabel: SWPaddingableLabel! = SWPaddingableLabel.init()
    let descriptionLabel: SWPaddingableLabel! = SWPaddingableLabel.init()
    let priceLabel: SWPaddingableLabel! = SWPaddingableLabel.init()
    let stockLabel: SWPaddingableLabel! = SWPaddingableLabel.init()
    let wallpaperView: SWDashableIamgeView! = SWDashableIamgeView.init()

    // only for Home page
    let editButton: UIButton! = SWClickableAreaButton.init(type: .custom)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
                 
        selectionStyle = .none
                
        wallpaperView.backgroundColor = UIColor.lightGray
        wallpaperView.contentMode = .scaleAspectFill
        wallpaperView.clipsToBounds = true
        wallpaperView.layer.cornerRadius = 10
        
        descriptionLabel.numberOfLines = 1
        
        editButton.backgroundColor = UIColor.orange
        editButton.setTitleColor(UIColor.white, for: .normal)
        editButton.layer.cornerRadius = 5
        
        wallpaperView.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = true
        stockLabel.translatesAutoresizingMaskIntoConstraints = false
        editButton.translatesAutoresizingMaskIntoConstraints = false
        
        numberLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        priceLabel.font = UIFont.boldSystemFont(ofSize: 16)
        stockLabel.font = UIFont.systemFont(ofSize: 14)
        editButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        
        numberLabel.textAlignment = .center
        nameLabel.textAlignment = .center
        descriptionLabel.textAlignment = .center
        priceLabel.textAlignment = .center
        stockLabel.textAlignment = .right

        contentView.addSubview(wallpaperView)
        contentView.addSubview(numberLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(stockLabel)
        contentView.addSubview(editButton)

        // layout Views
        let layoutViews:[String: UIView] = ["contentView": contentView, "wallpaperView": wallpaperView, "numberLabel": numberLabel, "nameLabel": nameLabel, "descriptionLabel": descriptionLabel, "priceLabel": priceLabel, "stockLabel": stockLabel, "editButton": editButton]

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"H:|-12-[wallpaperView]-12-|", options:[], metrics:nil, views:layoutViews))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"H:[contentView]-(<=0)-[nameLabel]", options:[.alignAllCenterY], metrics:nil, views:layoutViews))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"H:[stockLabel]-24-|", options:[], metrics:nil, views:layoutViews))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"H:[editButton(==50)]-24-|", options:[], metrics:nil, views:layoutViews))

        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:|-0-[wallpaperView]-0-|", options:[], metrics:nil, views:layoutViews))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:|-12-[numberLabel]", options:[], metrics:nil, views:layoutViews))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:[contentView]-(<=0)-[numberLabel]", options:[.alignAllCenterX], metrics:nil, views:layoutViews))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:[contentView]-(<=0)-[nameLabel]", options:[.alignAllCenterX], metrics:nil, views:layoutViews))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:[nameLabel]-6-[descriptionLabel]", options:[.alignAllCenterX], metrics:nil, views:layoutViews))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:[stockLabel]-12-|", options:[], metrics:nil, views:layoutViews))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:|-12-[editButton]", options:[], metrics:nil, views:layoutViews))

    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override var frame: CGRect {
        didSet {
            var newFrame = frame
            if needsBottomMargin {
                newFrame.size.height -= 12
            }
            super.frame = newFrame
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
                
        // Layout priceLabel
        let maximumWidth = (bounds.width - 12 * 2) / 5
        if priceLabel.intrinsicContentSize.width > maximumWidth {
            priceLabel.frame.size = CGSize.init(width: maximumWidth, height: priceLabel.intrinsicContentSize.height)
        } else {
            priceLabel.frame.size = priceLabel.intrinsicContentSize
        }
        
        priceLabel.center.x = ((bounds.width - 12 * 2) / 5 / 2) + 12
        priceLabel.center.y = bounds.height / 2

    }
}
