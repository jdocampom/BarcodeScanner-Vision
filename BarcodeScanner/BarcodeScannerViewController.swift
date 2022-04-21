//
//  BarcodeScannerViewController.swift
//  BarcodeScanner
//
//  Created by Juan Diego Ocampo on 21/04/22.
//

import AVFoundation
import UIKit
import Vision

@objc class BarcodeScannerViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var previewLayer: UIView!
    
    var isPortraitDefaultOrientarion = true
    var extractedStringFromBarcode = ""
    var dictionaryFromBarcodeData = [String: String]()
    
    var captureSession = AVCaptureSession()
    var sequenceHandler = VNSequenceRequestHandler()
    var videoOutput = AVCaptureVideoDataOutput()
    
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
//        self.navigationItem.setHidesBackButton(true, animated: false)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
