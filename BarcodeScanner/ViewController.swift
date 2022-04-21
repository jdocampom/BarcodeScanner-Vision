////
////  ViewController.swift
////  BarcodeScanner
////
////  Created by Juan Diego Ocampo on 18/04/22.
////
//
//import AVFoundation
//import UIKit
//import Vision
//
//class ViewController: UINavigationController {
//    
//    enum ScannerContext {
//        case boardingPass, luggageTag, clientInventory
//    }
//    
//    private let captureSession = AVCaptureSession()
//    private let sequenceHandler = VNSequenceRequestHandler()
//    private let videoOutput = AVCaptureVideoDataOutput()
//    
//    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
//        let preview = AVCaptureVideoPreviewLayer(session: self.captureSession)
//        preview.videoGravity = .resizeAspectFill
//        return preview
//    }()
//    
//    var extractedBarcode: String = ""
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.addCameraInput()
//        self.addPreviewLayer()
//        self.addVideoOutput()
//        self.captureSession.startRunning()
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
////        self.previewLayer.frame = self.view.safeAreaLayoutGuide.layoutFrame
////        self.previewLayer.frame = self.view.bounds
//        let startX = self.view.bounds.minX
//        let startY = self.view.safeAreaInsets.top
//        let height = self.view.bounds.height - startY
//        let width = self.view.bounds.width
//        self.previewLayer.frame = CGRect(x: startX, y: startY, width: width, height: height)
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//    }
//
//}
//
//extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
//    
//    private func addCameraInput() {
//        let device = AVCaptureDevice.default(for: .video)!
//        let cameraInput = try! AVCaptureDeviceInput(device: device)
//        self.captureSession.addInput(cameraInput)
//    }
//    
//    private func addPreviewLayer() {
//        self.view.layer.addSublayer(self.previewLayer)
//    }
//    
//    private func addVideoOutput() {
//        self.videoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
//        self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "my.image.handling.queue"))
//        self.captureSession.addOutput(self.videoOutput)
//    }
//    
//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
//            debugPrint("❌ ERROR: UNABLE TO GET IMAGE FROM SAMPLE BUFFER ❌")
//            return
//        }
//        if let barcode = self.extractDataFromBarcode(fromFrame: frame) {
//            DispatchQueue.main.async { [self] in
//                let alert = UIAlertController(title: "Detected Barcode", message: barcode, preferredStyle: .alert)
//                let action = UIAlertAction(title: "Dismiss", style: .default)
//                alert.addAction(action)
//                self.present(alert, animated: true)
//                print("🔍 EXTRACTED BARCODE 🔍 \n\(barcode)")
//                self.extractedBarcode = barcode
////                self.performSegue(withIdentifier: "barcodeScanned", sender: nil)
//            }
//            
//        }
//         // process data here
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let vc: TableViewController = segue.destination as! TableViewController
//        vc.data = self.process2DBarcodeStringDataInFormatM(from: extractedBarcode)
//    }
//    
//}
//
//extension ViewController {
//    
//    private func extractDataFromBarcode(fromFrame frame: CVImageBuffer) -> String? {
//        let barcodeRequest = VNDetectBarcodesRequest()
//        barcodeRequest.symbologies = [.pdf417, .aztec, .qr, .code128]
//        try? self.sequenceHandler.perform([barcodeRequest], on: frame)
//        guard let results = barcodeRequest.results, let firstBarcode = results.first?.payloadStringValue else {
//            return nil
//        }
//        return firstBarcode
//    }
//    
//    private func process2DBarcodeStringDataInFormatM(from string: String) -> [String: String]  {
//        let formattedString = string.trimmingCharacters(in: .whitespaces).uppercased()
//        var dictionary = [String: String]()
//        var range = (startIndex: 0, endIndex: 0)
//        let keys = ["format", "passenger_name", "e_ticket_indicator", "pnr_address", "origin_station_iata", "destination_station_iata", "carrier_code", "flight_number", "julian_date", "fare_code", "seat_number", "security_number", "passenger_status"]
//        let values = [2, 20, 1, 7, 3, 3, 3, 5, 3, 1, 4, 5, 1]
//        for i in 0..<keys.count {
//            range.endIndex += values[i]
//            dictionary[keys[i]] = formattedString.subString(from: range.startIndex, to: range.endIndex).replacingOccurrences(of: " ", with: "")
//            range.startIndex = range.endIndex
//        }
//        print(String(format:"%02X", formattedString))
//        return dictionary
//    }
//    
//}
