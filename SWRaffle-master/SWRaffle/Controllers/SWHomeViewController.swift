//
//  SWHomeViewController.swift
//  SWRaffle
//
//  Created by Jason on 2020/4/16.
//  Copyright © 2020 UTAS. All rights reserved.
//

import UIKit

extension UIViewController {
    public func showAlert(_ message: String?) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension Int32 {
    public func ticketNumberString() -> String {
        return self > 0 ? "No. " + String(self) : ""
    }
    public func stockString() -> String {
        return "Stock: " + String(self)
    }
}

extension Double {
    public func priceString() -> String {
        return self > 0 ? "$" + self.cleanZeroString() : "Free"
    }
    public func cleanZeroString() -> String {
        let cleanZeroString = self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) :String(self)
        return cleanZeroString
    }
}

class SWHomeViewController: UITableViewController, SWAddEditTableViewControllerDelegate, SWShareTableViewControllerDelegate, SWWinnerTableViewControllerDelegate, SWWecomeViewControllerDelegate, UITextFieldDelegate {
    
    var raffles = [SWRaffle]()
    var currentRow = -1

    var isReadyToInsert = false
    var isReadyToDelete = false
    var isReadyToReload = false
    
    var margin: Int = 0
    var alertAction: UIAlertAction?
    
    let database : SQLiteDatabase = SQLiteDatabase(databaseName: "MyDatabase")

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        title = "Home"
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Add", style: .done, target: self, action: #selector(addButtonPressed))
        
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
        
        raffles = database.selectAllRaffles()
        
        if raffles.count == 0 {
            presentWecomeViewController()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isReadyToInsert {
            tableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
            isReadyToInsert = false
        }
        if isReadyToDelete {
            tableView.deleteRows(at: [IndexPath.init(row: currentRow, section: 0)], with: .automatic)
            isReadyToDelete = false
        }
        if isReadyToReload {
            tableView.reloadRows(at: [IndexPath.init(row: currentRow, section: 0)], with: .automatic)
            isReadyToReload = false
        }
    }
            
    // MARK: - Private Methods
    
    @objc private func addButtonPressed() {
        let AddViewController: SWAddEditTableViewController! = SWAddEditTableViewController.init(style: .grouped)
        AddViewController.delegate = self
        navigationController!.pushViewController(AddViewController, animated: true)
    }
    
    @objc private func editButtonPressed(_ sender: UIButton) {
        
        let row = tableView.indexPath(for: sender.superview!.superview! as! UITableViewCell)!.row
        
        currentRow = row
        let raffle = raffles[row]
        
        if raffle.maximumNumber == raffle.stock { // Edit
            let editTableViewController = SWAddEditTableViewController.init(style: .grouped)
            editTableViewController.raffle = raffle
            editTableViewController.delegate = self
            navigationController?.pushViewController(editTableViewController, animated: true)
        } else { // Draw
            if raffle.isMarginRaffle == 0 { // Normal Raffle
                let winnerViewController = SWWinnerTableViewController.init(style: .grouped)
                winnerViewController.delegate = self
                winnerViewController.raffle = raffle
                
                let soldTickets = database.selectAllTicketsBy(raffleID: raffle.ID, isSold: 1)
                winnerViewController.ticket = soldTickets.randomElement()
                
                self.navigationController?.pushViewController(winnerViewController, animated: true)
            } else { // Margin Raffle
                let alert = UIAlertController(title: nil, message: "Plase enter a margin:", preferredStyle: .alert)
                
                alert.addTextField { (textField) in
                    textField.delegate = self
                    textField.keyboardType = .numberPad
                }
                alertAction = UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
                    let winnerViewController = SWWinnerTableViewController.init(style: .grouped)
                    winnerViewController.delegate = self
                    winnerViewController.raffle = raffle
                    
                    let ticket = self.database.selectTicketBy(raffleID: raffle.ID, ticketNumber: Int32(self.margin))
                    winnerViewController.ticket = ticket
                    self.margin = 0
                    
                    self.navigationController?.pushViewController(winnerViewController, animated: true)
                })
                alertAction?.isEnabled = false
                alert.addAction(alertAction!)
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                
                present(alert, animated: true)
            }
        }
    }
    
    private func presentWecomeViewController() {
        let wecomeViewController = SWWecomeViewController.init()
        wecomeViewController.delegate = self
        
        self.present(wecomeViewController, animated: true, completion: nil)
    }
        
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return raffles.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.size.width / 2.5 + 12
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "SWWallpaperTableViewCell"
        var cell: SWWallpaperTableViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? SWWallpaperTableViewCell
        if cell == nil {
            cell = SWWallpaperTableViewCell(style:UITableViewCell.CellStyle.subtitle, reuseIdentifier: identifier)
            cell!.editButton.addTarget(self, action: #selector(editButtonPressed(_:)), for: .touchUpInside)
            cell!.needsBottomMargin = true
        }
        
        let raffle = raffles[indexPath.row]
        cell!.wallpaperView.image = UIImage.init(data: raffle.wallpaperData)
        if raffle.stock > 0 {
            cell!.numberLabel.text = raffle.isMarginRaffle == 0 ? (raffle.maximumNumber - raffle.stock + 1).ticketNumberString() : "No. ???"
        } else {
            cell!.numberLabel.text = "Sold Out"
        }
        cell!.nameLabel.text = raffle.name
        cell!.descriptionLabel.text = raffle.description
        cell!.priceLabel.text = raffle.price.priceString()
        cell!.stockLabel.text = raffle.stock.stockString()
        
        let title = raffle.maximumNumber == raffle.stock ? "Edit" : "Draw"
        cell!.editButton.setTitle(title, for: .normal)

        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let raffle = raffles[indexPath.row]

        if raffle.stock > 0 {
            currentRow = indexPath.row
            
            let sellViewController = SWSellTableViewController.init(style: .grouped)
            sellViewController.raffle = raffle
            navigationController?.pushViewController(sellViewController, animated: true)
        } else {
            showAlert("Sold out, please draw out a winner")
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = SWTitleView.init(bottom: 0)
        header.titleLabel.text = "All Raffles"
        
        return header
    }
            
    // MARK: - SWWecomeViewControllerDelegate
    
    func didAddDefaultRaffle(_ raffle: SWRaffle) {

        didAddRaffle(raffle)
        
        // Update UI manually
        viewDidAppear(false)
    }

    // MARK: - SWAddEditTableViewControllerDelegate & SWWinnerTableViewControllerDelegate
    
    func didAddRaffle(_ raffle: SWRaffle) {
        
        // update RAFFLE table (Must insert first to get a raffleID)
        database.insert(raffle: raffle)
        raffles = database.selectAllRaffles()
        
        // update TICKET table
        for index in 1...raffle.maximumNumber {
            database.insert(ticket: SWTicket.init(raffleID: raffles.first!.ID, ticketNumber: index, ticketPrice: raffle.price, customerName: "", isSold: 0, purchaseTime: ""))
        }
        
        // update UI
        isReadyToInsert = true
    }
    
    func didEditRaffle(_ raffle: SWRaffle) {
        
        // update TICKET table
        let oldRaffle = raffles[currentRow]
        if oldRaffle.maximumNumber < raffle.maximumNumber {
            for index in (oldRaffle.maximumNumber + 1)...raffle.maximumNumber { // adding
                database.insert(ticket: SWTicket.init(raffleID: raffles.first!.ID, ticketNumber: index, ticketPrice: raffle.price, customerName: "", isSold: 0, purchaseTime: ""))
            }
        } else if oldRaffle.maximumNumber > raffle.maximumNumber{
            for index in (raffle.maximumNumber + 1)...oldRaffle.maximumNumber { // removing
                database.delete(raffleID: raffle.ID, ticketNumber: index)
            }
        }
        
        // update RAFFLE table
        database.update(raffle: raffle)
        
        // update UI
        raffles[currentRow] = raffle
        isReadyToReload = true
    }
    
    func didDeleteRaffle(_ raffle: SWRaffle) {
                        
        // update TICKET table
        for index in 1...raffle.maximumNumber {
            database.delete(raffleID: raffle.ID, ticketNumber: index)
        }
        
        // update RAFFLE table
        database.delete(raffle: raffle)
        
        // update UI
        raffles.remove(at: currentRow)
        if raffles.count == 0 {
            tableView.deleteRows(at: [IndexPath.init(row: currentRow, section: 0)], with: .automatic)
            presentWecomeViewController()
        } else {
            isReadyToDelete = true
        }
    }
    
    // MARK: - SWSellTableViewControllerDelegate
    
    func didSellTickets(_ tickets: Array<SWTicket>) {
        
        // update RAFFLE table
        var raffle = raffles[currentRow]
        raffle.stock -= Int32(tickets.count)
        raffles[currentRow] = raffle
        database.update(raffle: raffle)
        
        // update TICKET table
        for ticket in tickets {
            database.update(ticket: ticket)
        }
        
        // update Customer table
        let customerName = tickets.first!.customerName
        let purchaseTimes = tickets.count
        
        let customer = database.selectCustomerBy(name: customerName)
        if customer == nil {
            database.insert(customer: SWCustomer.init(name: customerName, purchaseTimes: Int32(purchaseTimes)))
        } else {
            database.update(customer: SWCustomer.init(name: customerName, purchaseTimes: customer!.purchaseTimes + Int32(purchaseTimes)))
        }

        // update UI
        isReadyToReload = true
    }

    // MARK: - UITextFieldDelegate
        
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text!.count > 0 {
            margin = Int(textField.text!)!
            alertAction?.isEnabled = true
        } else {
            margin = 0
            alertAction?.isEnabled = false
        }
    }
}
