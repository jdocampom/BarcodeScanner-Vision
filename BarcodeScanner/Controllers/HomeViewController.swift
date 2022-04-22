//
//  HomeViewController.swift
//  BarcodeScanner
//
//  Created by Juan Diego Ocampo on 21/04/22.
//

import UIKit

@objc class HomeViewController: UIViewController, UITableViewDelegate {
    
// MARK: - View Controller IBOutlets and Properties
    
    /// Table view that displays parsed data from barcode scan.
    @IBOutlet weak var tableView: UITableView!
    /// Button that prompts the user with the barcode scanner view.
    @IBOutlet weak var scanButton: UIBarButtonItem!
    /// Toolbar located at the bottom where the Scan Button is located at.
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    /// Dictionary that populates the tableView. By default it contains all the keys and empty strings as the value for each key.
    lazy var parsedData: [String: String] = [
        "format"                    : "",
        "passenger_name"            : "",
        "e_ticket_indicator"        : "",
        "pnr_address"               : "",
        "origin_station_iata"       : "",
        "destination_station_iata"  : "",
        "carrier_code"              : "",
        "flight_number"             : "",
        "julian_date"               : "",
        "fare_code"                 : "",
        "seat_number"               : "",
        "security_number"           : "",
        "passenger_status"          : ""
    ]
    
// MARK: - View Controller Lifecycle Methods

    /// Called after the view has been loaded.
    @objc override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.keyboardDismissMode = .interactive
        self.tableView.reloadData()
    }
    
    /// Called when the view is about to made visible.
    @objc override func viewWillAppear(_ animated: Bool) {
        print("ENTERING BarcodeScannerViewController")
        super.viewWillAppear(animated)
//        self.navigationController?.setToolbarHidden(false, animated: animated)
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        setNeedsStatusBarAppearanceUpdate()
        self.tableView.reloadData()
    }
    
    /// Called when the view is dismissed, covered or otherwise hidden.
    @objc override func viewWillDisappear(_ animated: Bool) {
        print("LEAVING BarcodeScannerViewController")
        super.viewWillDisappear(animated)
//        self.navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    // MARK: - View Controller IBActions and Methods
    
    /// Redirects the user to the BarcodeScannerViewController
    @IBAction func scannerButtonTapped(_ sender: UIButton) {
        print("SCAN BUTTON TAPPED")
    }
    
}

// MARK: - Navigation

extension HomeViewController {
    
    /// Passes parsedData to ScannerViewContrloller for further actions. Triggered during segue unwinding.
    @objc override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "scannerButtonTapped" {
             let destination = segue.destination as! BarcodeScannerViewController
             destination.dictionaryFromBarcodeData = self.parsedData
             destination.parentVC = self
         }
     }

}

// MARK: - Table View Data Source

extension HomeViewController: UITableViewDataSource {
    
    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parsedData.count
    }
    
    @objc func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "parsedDataCell", for: indexPath) as! ParsedDataCell
        cell.keyLabel.text = Array(parsedData.keys)[indexPath.row].capitalized.replacingOccurrences(of: "_", with: " ").replacingOccurrences(of: "Iata", with: "IATA").replacingOccurrences(of: "Pnr", with: "PNR").replacingOccurrences(of: "Id", with: "ID")
        cell.valueTextField.text = Array(parsedData.values)[indexPath.row].uppercased()
        cell.selectionStyle = .none
        return cell
    }
    
}
