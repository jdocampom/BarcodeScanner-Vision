//
//  BarcodeReader.swift
//  BarcodeScanner
//
//  Created by Juan Diego Ocampo on 21/04/22.
//

import AVFoundation
import UIKit
import Vision

/// Context of how the scanner will be used on a given situation. For example, if it will be used to scan boarding passes or lugagge tags.
enum ScannerContext {
    case boardingPass, luggageTag, clientInventory
}

/// An object that performs barcode scanning and data validation for PDF417, Aztec, QR, Code-128 and Code-39 formats.
@objc class BarcodeReader: NSObject {
    
    /// An object that processes image analysis requests for each frame in a sequence.
    let sequenceHandler = VNSequenceRequestHandler()
        
    /// Method that extracts the string representation for a given barcode thats being scanned with the device's Wide Angle camera.
    /// - Parameters:
    ///   - frame: Still frame from a giVen AVCaptureSession.
    ///   - context: Context of how the scanner will be used on a given situation. For example, if it will be used to scan boarding passes
    ///   or lugagge tags.
    /// - Returns: String representation of a ba
    func extractDataFromBarcode(fromFrame frame: CVImageBuffer, for context: ScannerContext = .boardingPass) -> String? {
        let barcodeRequest = VNDetectBarcodesRequest()
        var contextSymbologies = [VNBarcodeSymbology]()
        switch context {
        case .boardingPass:
            contextSymbologies = [.aztec, .pdf417, .qr]
        case .luggageTag:
            contextSymbologies = [.code128, .code39]
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
    
    /// Method that parses a given String from a 2D barcode into a dictionary with human-readable information from the barcode.
    /// - Parameter string: String contents of a 2D barcode. Only Aztec, PDF417 or QR are currently supported.
    /// - Returns: String: String dictionary with a human-readable representation of the string contents of a 2D barcode. This dictionary
    /// will be used to populate the main TableView.
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
    
    /// Checks if the last 5 elements of a given array are identical given that this array has more than 10 elements.
    /// - Parameter array: Array that contains the string representation of the barcodes scanned.
    /// - Returns: Boolean flag that allows either to carry on with the application or retry scanning automatically.
    func validateBarcodeReading(with array: [String]) -> Bool {
        print("⚠️ STARTING VALIDATION ⚠️")
        print("VALIDATION ARRAY LENGTH: \(array.count)")
        var didPassValidation = false
        if array.count > 10 {
            let testBatch = array.suffix(5)
            didPassValidation = testBatch.dropFirst().allSatisfy({ $0 == array.first })
            print("✅ PASSED VALIDATION ✅")
            return didPassValidation
        } else {
            print("❌ FAILED VALIDATION ❌")
            return didPassValidation
        }
    }
    
}
