//
//  SWAddEditTableViewController.swift
//  SWRaffle
//
//  Created by Jason on 2020/4/17.
//  Copyright © 2020 UTAS. All rights reserved.
//

import UIKit

protocol SWAddEditTableViewControllerDelegate: NSObjectProtocol {
    func didAddRaffle(_ raffle: SWRaffle)
    func didDeleteRaffle(_ raffle: SWRaffle)
    func didEditRaffle(_ raffle: SWRaffle)
}

class SWAddEditTableViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    weak var delegate: SWAddEditTableViewControllerDelegate?
    
    var raffle: SWRaffle?
    var name: String! = ""
    var price: String! = ""
    var stock: String! = ""
    var purchaseLimit: String! = ""
    var descriptionStr: String! = ""
    var isMarginRaffle: Int32 = 0
    var wallpaperImage: UIImage?
        
    override func viewDidLoad() {
        super.viewDidLoad()

        if raffle == nil {
            title = "Add"
        } else {
            title = "Edit"
            
            name = raffle!.name
            price = raffle!.price.cleanZeroString()
            stock = String(raffle!.stock)
            if raffle!.purchaseLimit != 0 {
                purchaseLimit = String(raffle!.purchaseLimit)
            }
            descriptionStr = raffle!.description
            isMarginRaffle = raffle!.isMarginRaffle
            wallpaperImage = UIImage.init(data: raffle!.wallpaperData)
        }
                
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(doneButtonPressed))

        tableView.separatorStyle = .none
        
        let tap = UITapGestureRecognizer(target:self, action:#selector(handleTap(sender:)))
        tap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tap)
    }

    // MARK: - Pricate Methods

    @objc private func handleTap(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    @objc func doneButtonPressed() {
        if check() {
            navigationController?.popViewController(animated: true)
            if raffle == nil {
                delegate?.didAddRaffle(result())
            } else {
                delegate?.didEditRaffle(result())
            }
        }
    }

    private func check() -> Bool {

        if name.count == 0 {
            showAlert("Please enter a name.")
            return false
        } else if price.count == 0 {
            showAlert("Please enter a price.")
            return false
        } else if stock.count == 0 {
            showAlert("Please enter a stock.")
            return false
        } else if Int(stock) == 0 {
            showAlert("Stock must be larger than 0.")
            return false
        } else if wallpaperImage == nil {
            showAlert("Please set a ticket wallpaper.")
            return false
        }

        return true
    }
        
    private func result() -> SWRaffle {
                
        if raffle == nil { // Add
            raffle = SWRaffle.init(name: name, price: Double(price)!,
                                   stock: Int32(stock)!,
                                   maximumNumber: Int32(stock)!,
                                   purchaseLimit: (purchaseLimit.count == 0) ? 0 : Int32(purchaseLimit)!,
                                   description: descriptionStr,
                                   wallpaperData: wallpaperImage!.jpegData(compressionQuality: 0)!,
                                   isMarginRaffle: isMarginRaffle)
        } else { // Edit
            raffle!.name = name
            raffle!.price = Double(price)!
            raffle!.maximumNumber = Int32(stock)!
            raffle!.stock = Int32(stock)!
            raffle!.purchaseLimit = (purchaseLimit.count == 0) ? 0 : Int32(purchaseLimit)!
            raffle!.description = descriptionStr!
            raffle!.wallpaperData = wallpaperImage!.jpegData(compressionQuality: 0)!
            raffle!.isMarginRaffle = isMarginRaffle
        }
        return raffle!
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if raffle != nil {
            return 8
        } else {
            return 7
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < 6 {
            return 1
        } else if section == 6 {
            return 3
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 6 && indexPath.row == 2 {
            return UIScreen.main.bounds.size.width / 2.5
        } else if indexPath.section == 7 {
            return 60
        } else {
            return 44
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section < 5 {
            let identifier = "SWTextFieldTableViewCell"
            var cell: SWTextFieldTableViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? SWTextFieldTableViewCell
            if cell == nil {
                cell = SWTextFieldTableViewCell(style:UITableViewCell.CellStyle.subtitle, reuseIdentifier: identifier)
                cell!.textField.delegate = self
                cell!.selectionStyle = .none
            }

            switch indexPath.section {
            case 0:
                cell!.textField.placeholder = "Ex. Lucy Door Prize"
                cell!.textField.returnKeyType = UIReturnKeyType.next
                cell!.textField.text = name
            case 1:
                cell!.textField.placeholder = "Will show \"Free\" when Price is set to 0"
                cell!.textField.returnKeyType = UIReturnKeyType.next
                cell!.textField.keyboardType = .decimalPad
                cell!.textField.text = price
            case 2:
                cell!.textField.placeholder = "Will show \"Sold out\" when Stock is 0"
                cell!.textField.returnKeyType = UIReturnKeyType.next
                cell!.textField.keyboardType = .numberPad
                cell!.textField.text = stock
            case 3:
                cell!.textField.placeholder = "Optional"
                cell!.textField.returnKeyType = UIReturnKeyType.next
                cell!.textField.keyboardType = .numberPad
                cell!.textField.text = purchaseLimit
            default:
                cell!.textField.placeholder = "Optional"
                cell!.textField.returnKeyType = UIReturnKeyType.done
                cell!.textField.text = descriptionStr
            }
            return cell!
        } else if indexPath.section == 5 {
            let identifier = "UITableViewCell"
            var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
            if cell == nil {
                cell = UITableViewCell(style:UITableViewCell.CellStyle.subtitle, reuseIdentifier: identifier)
            }
            cell!.accessoryType = isMarginRaffle == 0 ? .none : .checkmark
            cell!.textLabel?.font = UIFont.systemFont(ofSize: 16)
            cell!.textLabel?.textColor = UIColor.orange
            cell!.textLabel?.text = "Set as a margin raffle"

            return cell!
            
        } else if indexPath.section == 6 {
            if indexPath.row < 2 {
                let identifier = "UITableViewCell"
                var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
                if cell == nil {
                    cell = UITableViewCell(style:UITableViewCell.CellStyle.subtitle, reuseIdentifier: identifier)
                }
                cell?.accessoryType = .disclosureIndicator
                cell!.textLabel?.font = UIFont.systemFont(ofSize: 16)
                cell!.textLabel?.textColor = UIColor.orange

                if indexPath.row == 0 {
                    cell!.textLabel?.text = "Take Photo..."
                } else {
                    cell!.textLabel?.text = "Choose from Existing"
                }
                
                return cell!
            } else {
                let identifier = "SWWallpaperTableViewCell"
                var cell: SWWallpaperTableViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? SWWallpaperTableViewCell
                if cell == nil {
                    cell = SWWallpaperTableViewCell(style:UITableViewCell.CellStyle.subtitle, reuseIdentifier: identifier)
                    cell?.editButton.isHidden = true
                }
                if raffle != nil {
                    cell!.wallpaperView.image = UIImage.init(data: raffle!.wallpaperData)
                    cell!.numberLabel.text = raffle!.isMarginRaffle == 0 ? "No. 1" : "No. ???"
                    cell!.nameLabel.text = raffle!.name
                    cell!.priceLabel.text = raffle!.price.priceString()
                    cell!.stockLabel.text = raffle!.stock.stockString()
                    cell!.descriptionLabel.text = raffle!.description
                } else {
                    cell!.numberLabel.text = "No. 1"
                }
                
                return cell!
            }
            
        } else {
            let identifier = "SWButtonTableViewCell"
            var cell: SWButtonTableViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? SWButtonTableViewCell
            if cell == nil {
                cell = SWButtonTableViewCell(style:UITableViewCell.CellStyle.subtitle, reuseIdentifier: identifier)
                cell!.label.text = "Delete Raffle"
            }
            
            return cell!
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 5 {
            let cell = tableView.cellForRow(at: indexPath)
            let wallpaperCell: SWWallpaperTableViewCell = tableView.cellForRow(at: IndexPath.init(row: 2, section: 6)) as! SWWallpaperTableViewCell
            if cell!.accessoryType == .none {
                cell!.accessoryType = .checkmark
                wallpaperCell.numberLabel.text = "No. ???"
                isMarginRaffle = 1
            } else {
                cell!.accessoryType = .none
                wallpaperCell.numberLabel.text = "No. 1"
                isMarginRaffle = 0
            }

        } else if indexPath.section == 6 {
            if indexPath.row == 0 {
                showAlert("Cooming soon.")
            } else if (indexPath.row == 1) {
                let pickerCamera = UIImagePickerController()
                
                pickerCamera.allowsEditing = true
                pickerCamera.sourceType = .photoLibrary
                pickerCamera.delegate = self
                
                present(pickerCamera, animated: true, completion: nil)
            }
        } else if indexPath.section == 7 {
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
        if section == 0 || section == 6 {
            return 25
        } else if section == 5 || section == 7 {
            return 0
        } else {
            return 15
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = SWTitleView.init(bottom: 0)
        
        switch section {
        case 0:
            header.titleLabel.text = "Raffle Name"
        case 1:
            header.titleLabel.text = "Price"
        case 2:
            header.titleLabel.text = "Stock"
        case 3:
            header.titleLabel.text = "Purchase Limit"
        case 4:
            header.titleLabel.text = "Description"
        case 6:
            header.titleLabel.text = "Ticket Wallpaper"
        default:
            header.titleLabel.text = ""
        }
        
        return header
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section < 4 {
            return 0
        } else {
            return 20
        }
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init()
    }
    
    //MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                
        var imagePicker = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        if picker.allowsEditing {
            imagePicker = (info[UIImagePickerController.InfoKey.editedImage] as? UIImage)!
        }

        let cell: SWWallpaperTableViewCell? = tableView.cellForRow(at: IndexPath.init(row: 2, section: 6)) as? SWWallpaperTableViewCell
        cell?.wallpaperView.image = imagePicker
        wallpaperImage = imagePicker
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var cell = textField.superview!.superview as! SWTextFieldTableViewCell
        let section = tableView.indexPath(for: cell)?.section
        
        if section == 0 {
            cell = (tableView.cellForRow(at: IndexPath.init(row: 0, section: 1)) as! SWTextFieldTableViewCell)
            cell.textField.becomeFirstResponder()
        } else {
            cell.textField.resignFirstResponder()
        }

        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let textFieldCell = textField.superview!.superview as! SWTextFieldTableViewCell
        let section = tableView.indexPath(for: textFieldCell)?.section
                
        let wallpaperCell: SWWallpaperTableViewCell = tableView.cellForRow(at: IndexPath.init(row: 2, section: 6)) as! SWWallpaperTableViewCell

        switch section {
        case 0:
            name = textField.text
            wallpaperCell.nameLabel.text = name
        case 1:
            price = textField.text
            if price.count > 0 {
                let doublePrice = Double(price)!
                wallpaperCell.priceLabel.text = doublePrice.priceString()
            } else {
                wallpaperCell.priceLabel.text = ""
            }
            wallpaperCell.setNeedsLayout()
        case 2:
            stock = textField.text
            if stock.count > 0 {
                wallpaperCell.stockLabel.text = Int32(stock)!.stockString()
            } else {
                wallpaperCell.stockLabel.text = ""
            }
        case 3:
            purchaseLimit = textField.text
        default:
            descriptionStr = textField.text
            wallpaperCell.descriptionLabel.text = descriptionStr
        }
    }
        
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 0)
//        self.tableView.scrollIndicatorInsets = self.tableView.contentInset
//    }
//            
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        self.tableView.contentInset = UIEdgeInsets.zero
//        self.tableView.scrollIndicatorInsets = UIEdgeInsets.zero
//    }

}
