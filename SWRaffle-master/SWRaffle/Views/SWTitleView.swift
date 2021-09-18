//
//  SWTitleView.swift
//  SWRaffle
//
//  Created by Jason on 2020/4/18.
//  Copyright © 2020 UTAS. All rights reserved.
//

import UIKit

class SWTitleView: UIView {
    
    var bottom: CGFloat = 0
    let titleLabel: UILabel! = UILabel.init()
    
    init(bottom: CGFloat) {
        super.init(frame: CGRect.zero)
        
        self.bottom = bottom
        
        backgroundColor = UIColor.white
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 1
        titleLabel.font = UIFont.boldSystemFont(ofSize: 12)
        titleLabel.textColor = UIColor.gray
        addSubview(titleLabel)

        // layout Views
        let layoutViews:[String: UILabel] = ["titleLabel": titleLabel]
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"H:|-15-[titleLabel]-15-|", options:[], metrics:nil, views:layoutViews))
        
        let metrics: [String: CGFloat] = ["bottom": bottom]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:[titleLabel]-bottom-|", options:[], metrics:metrics, views:layoutViews))

    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
