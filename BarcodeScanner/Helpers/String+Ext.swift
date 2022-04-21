//
//  String+Ext.swift
//  BarcodeScanner
//
//  Created by Juan Diego Ocampo on 19/04/22.
//

import UIKit

extension String {
    
    func formatted() -> [String] {
        return self.replacingOccurrences(of: "[\\s\n]+", with: " ", options: .regularExpression, range: nil).components(separatedBy: " ")
    }
    
    func subString(from: Int, to: Int) -> String {
       let startIndex = self.index(self.startIndex, offsetBy: from)
       let endIndex = self.index(self.startIndex, offsetBy: to)
       return String(self[startIndex..<endIndex])
    }
    
}
