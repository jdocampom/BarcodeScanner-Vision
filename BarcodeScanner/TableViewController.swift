////
////  TableViewController.swift
////  BarcodeScanner
////
////  Created by Juan Diego Ocampo on 19/04/22.
////
//
//import UIKit
//
//final class TableViewController: UITableViewController {
//
//    var data = [String: String]()
//    var copy = [String: String]()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.copy = data
//        self.tableView.register(UINib(nibName: "TableViewControllerCell", bundle: nil), forCellReuseIdentifier: "customCell")
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return data.count
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! TableViewControllerCell
//        cell.keyLabel.text = Array(copy.keys)[indexPath.row]
//        cell.valueLabel.text = Array(copy.values)[indexPath.row]
//        return cell
//    }
//
//}
