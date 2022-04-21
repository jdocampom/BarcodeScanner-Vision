//
//  BarcodeScannerViewController.swift
//  BarcodeScanner
//
//  Created by Juan Diego Ocampo on 21/04/22.
//

import AVFoundation
import UIKit

@objc class BarcodeScannerViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var previewLayer: UIView!
    
    var isPortraitDefaultOrientarion = true
    var extractedStringFromBarcode = ""
    var dictionaryFromBarcodeData = [String: String]()
    var captureSession = AVCaptureSession()
    var videoOutput = AVCaptureVideoDataOutput()
    var scannerContext: ScannerContext = .boardingPass
//    var scannerContext: ScannerContext = .luggageTag
    
    lazy var preview: AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer(session: self.captureSession)
        preview.videoGravity = .resizeAspectFill
        return preview
    }()
    
    @objc override var preferredStatusBarStyle : UIStatusBarStyle {
        return .darkContent
    }
    
    @objc override var prefersStatusBarHidden: Bool {
        return true
    }
        
    @objc override func viewDidLoad() {
        super.viewDidLoad()
        self.addCameraInput()
        self.addPreviewLayer()
        self.addVideoOutput()
        self.preview.frame = self.previewLayer.bounds
        self.captureSession.startRunning()
    }
    
    @objc override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.preview.frame = self.previewLayer.bounds
    }
    
    @objc override func viewWillAppear(_ animated: Bool) {
        print("ENTERING BarcodeScannerViewController")
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.preview.frame = self.previewLayer.bounds
        self.captureSession.startRunning()
    }
    
    @objc override func viewWillDisappear(_ animated: Bool) {
        print("LEAVING BarcodeScannerViewController")
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        self.captureSession.stopRunning()
    }
    
    @objc private func addCameraInput() {
        let device = AVCaptureDevice.default(for: .video)!
        let cameraInput = try! AVCaptureDeviceInput(device: device)
        self.captureSession.addInput(cameraInput)
    }
    
    @objc private func addPreviewLayer() {
        self.previewLayer.layer.addSublayer(self.preview)
    }
    
    @objc private func addVideoOutput() {
        self.videoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "barcode.scanning.queue"))
        self.captureSession.addOutput(self.videoOutput)
    }
    
    @objc func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let session = BarcodeReader()
        let example2DString = "M1OCAMPOMALDONADO/JUANEABCDEF INKBEGIN 0541 111Y005E0001 35D>5180OO    BIN              2A             0 IN                        N 21000316514         "
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("❌ ERROR: UNABLE TO GET IMAGE FROM SAMPLE BUFFER ❌")
            return
        }
        if let barcode = session.extractDataFromBarcode(fromFrame: frame, for: scannerContext) {
            DispatchQueue.main.async { [self] in
                self.dictionaryFromBarcodeData = session.process2DBarcodeStringDataInFormatM(from: barcode)
                self.captureSession.stopRunning()
                print("🔍 EXTRACTED DICTIONARY 🔍 \n\(self.dictionaryFromBarcodeData)")
                print("🔍 EXTRACTED BARCODE STRING (WHATS IN BETWEEN ><) 🔍 \n>\(barcode)<")
                example2DString == barcode ? print("✅ STRINGS MATCH ✅") : print("❌ STRINGS DON'T MATCH ❌")
                let alert = UIAlertController(title: "Detected Barcode", message: barcode, preferredStyle: .alert)
                let action = UIAlertAction(title: "Dismiss", style: .default)
                alert.addAction(action)
                self.present(alert, animated: true)
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        print("DISMISS BUTTON TAPPED")
        self.navigationController?.popViewController(animated: true)
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
