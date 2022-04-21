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
    
    ///Validation
    var validationTarget: Int32 = 5
    ///Validation
    var minimunLengthOfValidationArray: Int32 = 10
    /// Camera orientation. By default its portrait since auto-rotate is not supported in the app.
    var isPortraitDefaultOrientarion = true
    /// Context of how the scanner will be used on a given situation. For example, if it will be used to scan boarding passes or lugagge tags.
    var scannerContext: ScannerContext = .boardingPass
    /// String: String dictionary that contains the parsed data from the barcode's String representation.
    var dictionaryFromBarcodeData = [String: String]()
    /// Array used for barcode validation. Starts as an empty String array and gets an element appended after each succesful scan.
    var validationArray = [String]()
    /// String representation extracted from each barcode scan. Used for debugging purposes only.
    var extractedStringFromBarcode = ""
    /// An object that processes image analysis requests for each frame in a sequence.
    let sequenceHandler = VNSequenceRequestHandler()
    /// An object that manages capture activity and coordinates the flow of data from input devices to capture outputs.
    var captureSession = AVCaptureSession()
    /// A capture output that records video and provides access to video frames for processing.
    var videoOutput = AVCaptureVideoDataOutput()
    /// Parent View Controller. In this case, it is HomeViewController.
    lazy var parentVC = BarcodeScannerViewController()
    /// A Core Animation layer that displays the video as it’s captured by the device's Wide Angle camera.
    /// Neither Telephoto or Ultra Wide Angle cameras are currently supported due to compatibility reasons.
    lazy var preview: AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer(session: self.captureSession)
        preview.videoGravity = .resizeAspectFill
        return preview
    }()
    

// MARK: - Camera Methods
    
    /// Setup Barcode Reader AVCaptureSession,
    @objc func configureSession() {
        self.addCameraInput()
        self.addVideoOutput()
        self.captureSession.startRunning()
    }
    
    /// Adds a given input defined by `cameraInput` to `captureSession`.
    @objc func addCameraInput() {
        DispatchQueue.main.async {
            let device = AVCaptureDevice.default(for: .video)!
            let cameraInput = try! AVCaptureDeviceInput(device: device)
            self.captureSession.addInput(cameraInput)
        }
    }
    
    /// Adds a given input defined by `videoOutput` to `captureSession`.
    @objc func addVideoOutput() {
        DispatchQueue.main.async {
            self.videoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
            self.videoOutput.setSampleBufferDelegate(self.parentVC, queue: DispatchQueue(label: "barcode.scanning.queue"))
            self.captureSession.addOutput(self.videoOutput)
        }
    }
    
    /// Called whenever an AVCaptureVideoDataOutput instance outputs a new video frame.
    /// - Parameters:
    ///   - output: The abstract superclass for objects that output the media recorded in a capture session.
    ///   - sampleBuffer: An object that models a buffer of media data.
    ///   - connection: A connection between a specific pair of capture input and capture output objects in a capture session.
    @objc func rootClassCaptureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection, onSuccess: @escaping ([String: String])-> Void ) {
        let session = BarcodeReader()
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("❌ ERROR: UNABLE TO GET IMAGE FROM SAMPLE BUFFER ❌")
            return
        }
        if let barcode = self.extractDataFromBarcode(fromFrame: frame, for: scannerContext) {
            DispatchQueue.main.async { [self] in
                self.dictionaryFromBarcodeData = session.process2DBarcodeStringDataInFormatM(from: barcode)
                print("🔍 EXTRACTED DICTIONARY 🔍 \n\(self.dictionaryFromBarcodeData)")
                print("🔍 EXTRACTED BARCODE STRING (WHATS IN BETWEEN ><) 🔍 \n>\(barcode)<")
                self.validationArray.append(barcode)
                if self.validateBarcodeReading(with: self.validationArray) {
                    self.captureSession.stopRunning()
                    // send results as a parameter
                    onSuccess(self.dictionaryFromBarcodeData)
                }
            }
        }
    }
    
// MARK: - Validation Methods
    
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
        if array.count > Int(self.minimunLengthOfValidationArray) {
            let testBatch = array.suffix(Int(self.validationTarget))
            didPassValidation = testBatch.dropFirst().allSatisfy({ $0 == array.first })
            print("✅ PASSED VALIDATION ✅")
            return didPassValidation
        } else {
            print("❌ FAILED VALIDATION ❌")
            return didPassValidation
        }
    }
    
}
