//
//  SWButtonsTableViewCell.swift
//  SWRaffle
//
//  Created by Jason on 2020/4/23.
//  Copyright © 2020 UTAS. All rights reserved.
//

import UIKit

let MaximumNumber = 10
let FontSize: CGFloat = 14

let LeftPadding: CGFloat = 15
let RightPadding: CGFloat = 15
let TopPadding: CGFloat = 7.5
let BottomPadding: CGFloat = 7.5

let ButtonHeight: CGFloat = 30
let Lengthening: CGFloat = 8
let Spacing: CGFloat = 12

class SWButtonsTableViewCell: UITableViewCell {

    var textButtons = Array<UIButton>()
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        customers = Array<SWCustomer>()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var customers: Array<SWCustomer> {
        didSet {
            for textButton in textButtons {
                textButton.removeFromSuperview()
            }
            textButtons.removeAll()
            
            var count = 0
            for customer in customers {
                let textButton = SWClickableAreaButton.init(type: .custom)
                textButtons.append(textButton)
                textButton.clickableMarginX = 6
                textButton.clickableMarginY = 3.75
                textButton.setTitle(customer.name, for: .normal)
                textButton.setTitleColor(.white, for: .normal)
                textButton.backgroundColor = .orange
                textButton.titleLabel?.font = UIFont.systemFont(ofSize: FontSize)
                textButton.layer.cornerRadius = 5
                contentView.addSubview(textButton)
                
                count += 1
                if count == MaximumNumber {
                    break
                }
            }
        }
    }
    
    class func contentHeight(_ customers: Array<SWCustomer>) -> CGFloat {
        var originX: CGFloat = 0
        var height: CGFloat = 0
        
        let end = customers.count < MaximumNumber ? customers.count : MaximumNumber
        for index in 0 ..< end {
            let customer = customers[index]
            let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize)]
            let option = NSStringDrawingOptions.usesLineFragmentOrigin
            var buttonWidth:CGFloat = customer.name.boundingRect(with: CGSize.zero, options: option, attributes: attributes, context: nil).size.width
            let maximumButtonWidth = UIScreen.main.bounds.size.width - Lengthening - LeftPadding - RightPadding
            if buttonWidth > maximumButtonWidth {
                buttonWidth =  maximumButtonWidth
            }
            
            if index == 0 {
                originX = LeftPadding
                height += TopPadding + ButtonHeight + BottomPadding
            }
            
            // change a line
            if originX + buttonWidth + Lengthening > UIScreen.main.bounds.size.width - RightPadding {
                originX = LeftPadding
                height += ButtonHeight + BottomPadding
            }
            originX += buttonWidth + Lengthening + Spacing
        }

        return height;
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var originX: CGFloat = LeftPadding
        var originY: CGFloat = TopPadding

        let end = customers.count < MaximumNumber ? customers.count : MaximumNumber
        for index in 0 ..< end {
            let textButton = textButtons[index]
            var buttonWidth = textButton.titleLabel!.sizeThatFits(CGSize.zero).width
            let maximumButtonWidth = UIScreen.main.bounds.size.width - Lengthening - LeftPadding - RightPadding
            if buttonWidth > maximumButtonWidth {
                buttonWidth =  maximumButtonWidth
            }

            // change a line
            if originX + buttonWidth + Lengthening > UIScreen.main.bounds.size.width - RightPadding {
                originX = LeftPadding
                originY += ButtonHeight + BottomPadding
            }
            textButton.frame = CGRect.init(x: originX, y: originY, width: buttonWidth + Lengthening, height: ButtonHeight)
            originX += buttonWidth + Lengthening + Spacing
        }
    }

}
