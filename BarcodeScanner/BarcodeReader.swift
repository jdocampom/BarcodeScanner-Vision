//
//  BarcodeReader.swift
//  BarcodeScanner
//
//  Created by Juan Diego Ocampo on 21/04/22.
//

import AVFoundation
import UIKit
import Vision

@objc class BarcodeReader: NSObject {
    
    enum ScannerContext {
        case boardingPass, luggageTag, clientInventory
    }
    
    let sequenceHandler = VNSequenceRequestHandler()
    
    func extractDataFromBarcode(fromFrame frame: CVImageBuffer, for context: ScannerContext = .boardingPass) -> String? {
        let barcodeRequest = VNDetectBarcodesRequest()
        var contextSymbologies = [VNBarcodeSymbology]()
        switch context {
        case .boardingPass:
            contextSymbologies = [.aztec, .pdf417, .qr]
        case .luggageTag:
            contextSymbologies = [.code128]
        case .clientInventory:
            contextSymbologies = [.code128, .code39]
        }
        barcodeRequest.symbologies = contextSymbologies
        try? self.sequenceHandler.perform([barcodeRequest], on: frame)
        guard let results = barcodeRequest.results, let firstBarcode = results.first?.payloadStringValue else {
            return nil
        }
        return firstBarcode
    }
    
    func process2DBarcodeStringDataInFormatM(from string: String) -> [String: String]  {
        let formattedString = string.trimmingCharacters(in: .whitespaces).uppercased()
        var dictionary = [String: String]()
        var range = (startIndex: 0, endIndex: 0)
        let keys = ["format", "passenger_name", "e_ticket_indicator", "pnr_address", "origin_station_iata", "destination_station_iata", "carrier_code", "flight_number", "julian_date", "fare_code", "seat_number", "security_number", "passenger_status"]
        let values = [2, 20, 1, 7, 3, 3, 3, 5, 3, 1, 4, 5, 1]
        for i in 0..<keys.count {
            range.endIndex += values[i]
            dictionary[keys[i]] = formattedString.subString(from: range.startIndex, to: range.endIndex).replacingOccurrences(of: " ", with: "")
            range.startIndex = range.endIndex
        }
        print(String(format:"%02X", formattedString))
        return dictionary
    }
    
}
