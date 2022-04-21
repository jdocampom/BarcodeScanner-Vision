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
    
    public var parsedData: [String: String] = ["format": "", "passenger_name": "", "e_ticket_indicator": "", "pnr_address": "", "origin_station_iata": "", "destination_station_iata": "", "carrier_code": "", "flight_number": "", "julian_date": "", "fare_code": "", "seat_number": "", "security_number": "", "passenger_status": ""]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.keyboardDismissMode = .interactive
        self.tableView.reloadData()
    }
    
    @objc override func viewWillAppear(_ animated: Bool) {
        print("ENTERING BarcodeScannerViewController")
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        setNeedsStatusBarAppearanceUpdate()
        self.tableView.reloadData()
    }
    
    @objc override func viewWillDisappear(_ animated: Bool) {
        print("LEAVING BarcodeScannerViewController")
        super.viewWillDisappear(animated)
    }
    
    @IBAction func scannerButtonTapped(_ sender: UIButton) {
        print("SCAN BUTTON TAPPED")
    }

    // MARK: - Navigation

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "scannerButtonTapped" {
             let destination = segue.destination as! BarcodeScannerViewController
             destination.dictionaryFromBarcodeData = self.parsedData
             destination.parentVC = self
         }
     }

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
        cell.keyLabel.text = Array(parsedData.keys)[indexPath.row].capitalized.replacingOccurrences(of: "_", with: " ").replacingOccurrences(of: "Iata", with: "IATA").replacingOccurrences(of: "Pnr", with: "PNR")
        cell.valueTextField.text = Array(parsedData.values)[indexPath.row].uppercased()
        cell.selectionStyle = .none
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
