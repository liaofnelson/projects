//
//  SWWinnerTableViewController.swift
//  SWRaffle
//
//  Created by Jason on 2020/4/22.
//  Copyright © 2020 UTAS. All rights reserved.
//

import UIKit

protocol SWWinnerTableViewControllerDelegate: NSObjectProtocol {
    func didDeleteRaffle(_ raffle: SWRaffle)
}

class SWWinnerTableViewController: UITableViewController {

    weak var delegate: SWWinnerTableViewControllerDelegate?

    var ticket: SWTicket!
    var raffle: SWRaffle!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Winner"

        tableView.separatorStyle = .none
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UIScreen.main.bounds.size.width / 2.5
        } else {
            return 60
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let identifier = "SWWallpaperTableViewCell"
            var cell: SWWallpaperTableViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? SWWallpaperTableViewCell
            if cell == nil {
                cell = SWWallpaperTableViewCell(style:UITableViewCell.CellStyle.subtitle, reuseIdentifier: identifier)
                cell!.editButton.isHidden = true
            }
            
            cell!.wallpaperView.image = UIImage.init(data: raffle.wallpaperData)
            cell!.numberLabel.text = ticket.ticketNumber.ticketNumberString()
            cell!.nameLabel.text = raffle.name
            cell!.descriptionLabel.text = raffle.description
            cell!.priceLabel.text = raffle.price.priceString()
            cell!.stockLabel.text = ticket.isSold == 0 ?  "xxxx" : ticket.customerName
            
            return cell!
        } else {
            let identifier = "SWButtonTableViewCell"
            var cell: SWButtonTableViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? SWButtonTableViewCell
            if cell == nil {
                cell = SWButtonTableViewCell(style:UITableViewCell.CellStyle.subtitle, reuseIdentifier: identifier)
                cell!.label.text = "Delete Raffle"
                cell!.label.textColor = UIColor.red
            }
            
            return cell!
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            let alert = UIAlertController(title: nil, message: "Are you sure you want to delete \"" + raffle!.name + "\"?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in

                self.navigationController?.popViewController(animated: true)
                self.delegate?.didDeleteRaffle(self.raffle!)

            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        }
    }

        
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView.init()
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if section == 0 {
            view.backgroundColor = UIColor.white
        } else {
            view.backgroundColor = UIColor.clear
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 43.5
        } else {
            return 12
        }
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let footer = SWTitleView.init(bottom: 12)
            footer.titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
            footer.titleLabel.textColor = UIColor.red
            let amountStr = ticket?.isSold == 0 ? "This raffle has no winner" : "The winner is : " + ticket.customerName
            footer.titleLabel.text = amountStr
            return footer
        } else {
            return UIView.init()
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if section == 0 {
            view.backgroundColor = UIColor.white
        } else {
            view.backgroundColor = UIColor.clear
        }
    }

}
