//
//  SWDashableIamgeView.swift
//  SWRaffle
//
//  Created by Jason on 2020/4/20.
//  Copyright © 2020 UTAS. All rights reserved.
//

import UIKit

class SWDashableIamgeView: UIImageView {

    var didDrawDashdeline = false

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if bounds.width > 0 && didDrawDashdeline == false {
            addDashdeBorderLayer(self, UIColor.white, 1)
            didDrawDashdeline = true
        }
    }
    
    func addDashdeBorderLayer(_ view:UIView, _ color:UIColor, _ width:CGFloat) {
        let shapeLayer = CAShapeLayer()
        let size = view.frame.size
        
        let shapeRect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = width
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [3, 4]
    
        let path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 10)
        path.move(to: CGPoint(x: size.width / 5, y: 0))
        path.addLine(to: CGPoint(x: size.width / 5, y: UIScreen.main.bounds.size.width / 2.5))

        shapeLayer.path = path.cgPath
        
        view.layer.addSublayer(shapeLayer)
    }
    
}
