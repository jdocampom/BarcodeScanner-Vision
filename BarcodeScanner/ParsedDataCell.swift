//
//  ParsedDataCell.swift
//  BarcodeScanner
//
//  Created by Juan Diego Ocampo on 19/04/22.
//

import UIKit

@objc class ParsedDataCell: UITableViewCell {
    
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueTextField: UITextField!

    override class func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

