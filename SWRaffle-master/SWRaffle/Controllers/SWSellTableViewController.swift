//
//  SWSellTableViewController.swift
//  SWRaffle
//
//  Created by Jason on 2020/4/20.
//  Copyright © 2020 UTAS. All rights reserved.
//

import UIKit

class SWSellTableViewController: UITableViewController, UITextFieldDelegate {

    var raffle: SWRaffle!
    var customerName: String! = ""
    var amount: String! = ""
    let customers = SQLiteDatabase(databaseName: "MyDatabase").selectFrequentCustomers()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Sell"

        tableView.separatorStyle = .none
        
        let tap = UITapGestureRecognizer(target:self, action:#selector(handleTap(sender:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - Pricate Methods

    @objc private func handleTap(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    private func randomTicketGenerator(_ tickets: Array<SWTicket>) ->() ->SWTicket? {

        var nums = [SWTicket]();
        for ticket in tickets {
            nums.append(ticket)
        }

        func randomTicket() -> SWTicket! {
            let index = Int(arc4random_uniform(UInt32(nums.count)))
            return nums.remove(at: index)
        }

        return randomTicket
    }
    
    private func check() -> Bool {

        if customerName.count == 0 {
            showAlert("Please enter a customer's name.")
            return false
        } else if amount.count == 0 {
            showAlert("Please enter an amount.")
            return false
        } else if Int32(amount)! > raffle.stock {
            showAlert("Insufficient stock\n remaining: " + String(raffle.stock))
            return false
        }


        return true
    }
    
    @objc private func textButtonPressed(_ sender: UIButton) {
        let cell: SWTextFieldTableViewCell = tableView.cellForRow(at: IndexPath.init(row: 0, section: 2)) as! SWTextFieldTableViewCell
        cell.textField.text = sender.titleLabel?.text
        customerName = sender.titleLabel?.text
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 12
        } else if section == 1 {
            if customers.count > 0 {
                return 25
            } else {
                return 0
            }
        } else if section == 4 {
            return 0
        } else if section == 2 {
            if customers.count > 0 {
                return 15
            } else {
                return 25
            }
        } else {
            return 15
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 || section == 4 {
            let header = UIView.init()
            header.backgroundColor = UIColor.white
            return header
        } else {
            let header = SWTitleView.init(bottom: 0)
            switch section {
            case 1:
                header.titleLabel.text = "History Customers"
            case 2:
                header.titleLabel.text = "Customer Name"
            default:
                header.titleLabel.text = "Amount"
            }
            return header
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UIScreen.main.bounds.size.width / 2.5
        } else if indexPath.section == 4 {
            return 60
        } else if indexPath.section == 1 {
            return SWButtonsTableViewCell.contentHeight(customers)
        } else {
            return 44
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let identifier = "SWWallpaperTableViewCell"
            var cell: SWWallpaperTableViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? SWWallpaperTableViewCell
            if cell == nil {
                cell = SWWallpaperTableViewCell(style:UITableViewCell.CellStyle.subtitle, reuseIdentifier: identifier)
                cell?.editButton.isHidden = true
            }
            
            cell!.wallpaperView.image = UIImage.init(data: raffle.wallpaperData)
            cell!.numberLabel.text = raffle.isMarginRaffle == 0 ? ((raffle.maximumNumber - raffle.stock + 1).ticketNumberString()) : "No. ???"
            cell!.nameLabel.text = raffle.name
            cell!.descriptionLabel.text = raffle.description
            cell!.priceLabel.text = raffle.price.priceString()
            cell!.stockLabel.text = raffle.stock.stockString()

            return cell!
        } else if indexPath.section == 1 {
            
            // History Customers
            let identifier = "SWButtonsTableViewCell"
            var cell: SWButtonsTableViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? SWButtonsTableViewCell
            if cell == nil {
                cell = SWButtonsTableViewCell()
            }
            
            cell!.customers = customers
            for textButton in cell!.textButtons {
                textButton.addTarget(self, action: #selector(textButtonPressed(_:)), for: .touchUpInside)
            }
            
            return cell!
            
        } else if indexPath.section <= 3 {
            
            // Customer Name & Amount
            let identifier = "SWTextFieldTableViewCell"
            var cell: SWTextFieldTableViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? SWTextFieldTableViewCell
            if cell == nil {
                cell = SWTextFieldTableViewCell(style:UITableViewCell.CellStyle.subtitle, reuseIdentifier: identifier)
                cell!.textField.delegate = self
                cell!.selectionStyle = .none
            }

            switch indexPath.section {
            case 2:
                cell!.textField.placeholder = "Enter your customer's name"
                cell!.textField.returnKeyType = UIReturnKeyType.next
            default:
                cell!.textField.placeholder = "Enter an amount of tickets"
                cell!.textField.keyboardType = .numberPad
                cell!.textField.returnKeyType = UIReturnKeyType.done
            }
            
            return cell!
        } else {
            let identifier = "SWButtonTableViewCell"
            var cell: SWButtonTableViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? SWButtonTableViewCell
            if cell == nil {
                cell = SWButtonTableViewCell(style:UITableViewCell.CellStyle.subtitle, reuseIdentifier: identifier)
                cell!.label.textColor = UIColor.orange
                cell!.label.text = "Confirm"
            }
            
            return cell!
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 4 {
            if check() {
                let database : SQLiteDatabase = SQLiteDatabase(databaseName: "MyDatabase")
                let unsoldTickets = database.selectAllTicketsBy(raffleID: raffle.ID, isSold: 0)
                var soldTickets = Array<SWTicket>.init()
                
                let now = Date().addingTimeInterval(TimeInterval(NSTimeZone.system.secondsFromGMT()))
                let format = DateFormatter()
                format.dateFormat = "yyyy-MM-dd aaa hh:mm:ss"

                let randomTicket = randomTicketGenerator(unsoldTickets)
                for index in 0 ..< Int32(amount)! {
                    var soldTicket: SWTicket!
                    if raffle.isMarginRaffle == 0 {
                        soldTicket = unsoldTickets[Int(index)]
                    } else {
                        soldTicket = randomTicket()
                    }

                    soldTicket.customerName = customerName
                    soldTicket.isSold = 1
                    soldTicket.purchaseTime = format.string(from: now)
                    soldTickets.append(soldTicket)
                }

                let soldViewController = SWShareTableViewController.init(style: .grouped)
                soldViewController.tickets = soldTickets
                soldViewController.raffle = raffle
                navigationController?.pushViewController(soldViewController, animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section >= 3 {
            return 20
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init()
    }
    
    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var cell = textField.superview!.superview as! SWTextFieldTableViewCell
        let section = tableView.indexPath(for: cell)?.section
        
        if section == 2 {
            cell = (tableView.cellForRow(at: IndexPath.init(row: 0, section: 3)) as! SWTextFieldTableViewCell)
            cell.textField.becomeFirstResponder()
        } else {
            cell.textField.resignFirstResponder()
        }

        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let textFieldCell = textField.superview!.superview as! SWTextFieldTableViewCell
        let section = tableView.indexPath(for: textFieldCell)?.section
                
        if section == 2 {
            customerName = textField.text
        } else {
            amount = textField.text
        }
    }
}
