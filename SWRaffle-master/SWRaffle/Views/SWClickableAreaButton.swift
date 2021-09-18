//
//  SWClickableAreaButton.swift
//  SWRaffle
//
//  Created by Jason on 2020/4/20.
//  Copyright © 2020 UTAS. All rights reserved.
//

import UIKit

class SWClickableAreaButton: UIButton {
    
    var clickableMarginX:CGFloat = 12
    var clickableMarginY:CGFloat = 12

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let clickableArea = bounds.insetBy(dx: -clickableMarginX, dy: -clickableMarginY)
        return clickableArea.contains(point)
    }

}
