//
//  SWPaddingableLabel.swift
//  SWRaffle
//
//  Created by Jason on 2020/4/19.
//  Copyright © 2020 UTAS. All rights reserved.
//

import UIKit

class SWPaddingableLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 5
        layer.backgroundColor = UIColor.white.cgColor
        textColor = UIColor.orange

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let padding = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    override var intrinsicContentSize : CGSize {
        let superContentSize = super.intrinsicContentSize
        let width = superContentSize.width + padding.left + padding.right
        let heigth = superContentSize.height + padding.top + padding.bottom
        return CGSize(width: width, height: heigth)
    }
}
