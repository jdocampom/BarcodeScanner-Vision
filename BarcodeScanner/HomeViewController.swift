//
//  HomeViewController.swift
//  BarcodeScanner
//
//  Created by Juan Diego Ocampo on 21/04/22.
//

import UIKit

@objc class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scanButton: UIButton!
    
    public var parsedData: [String: String] = ["format": "M1"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    @IBAction func scannerButtonTapped(_ sender: UIButton) {
        print("SCAN BUTTON TAPPED")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension HomeViewController {
    
    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parsedData.count
//        return 1
    }
    
//    @objc func numberOfSections(in tableView: UITableView) -> Int {
//        return parsedData.count
//    }
    
    @objc func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "parsedDataCell", for: indexPath) as! ParsedDataCell
        cell.keyLabel.text = Array(parsedData.keys)[indexPath.row].capitalized
        cell.valueTextField.text = Array(parsedData.values)[indexPath.row].uppercased()
//        cell.keyLabel.text = "format".capitalized
//        cell.valueTextField.text = "DOE/MRJOHN".uppercased()
//        cell.layer.masksToBounds = true
//        cell.layer.cornerRadius = 5
//        cell.layer.borderWidth = 1
//        cell.layer.shadowOffset = CGSize(width: -1, height: 1)
//        cell.layer.borderColor = CGColor(red: 199/255, green: 199/255, blue: 204/255, alpha: 1)
        return cell
    }
    
}


