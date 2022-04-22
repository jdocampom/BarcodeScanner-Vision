//
//  BarcodeScannerViewController.swift
//  BarcodeScanner
//
//  Created by Juan Diego Ocampo on 21/04/22.
//

import AVFoundation
import UIKit

@objc class BarcodeScannerViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: - Barcode Scanner View Controller IBOutlets and Properties
    
    /// View that displays whats being captured by the camera.
    @IBOutlet weak var previewLayer: UIView!
    /// Horizontal red stripe that simulates a laset tagging gun.
    @IBOutlet weak var redLaserLineView: UIView!
    /// String: String dictionary that contains the parsed data from the barcode's String representation.
    lazy var dictionaryFromBarcodeData = [String: String]()
    /// Barcode Reader object instance.
    lazy var barcodeReader = BarcodeReader()
    /// Parent View Controller. In this case, it is HomeViewController.
    lazy var parentVC = HomeViewController()
    /// A Core Animation layer that displays the video as it’s captured by the device's Wide Angle camera.
    /// Neither Telephoto or Ultra Wide Angle cameras are currently supported due to compatibility reasons.
    lazy var preview = barcodeReader.preview
    
    // MARK: - Barcode Scanner View Controller Lifecycle Methods
    
    /// Called immediately before any BarcodeScannerViewControllerinstance is deallocated from memory.
    @objc deinit {
        self.barcodeReader.extractedStringFromBarcode = ""
        self.barcodeReader.dictionaryFromBarcodeData = [String: String]()
        self.barcodeReader.captureSession.stopRunning()
        print("BarcodeScannerViewController HAS BEEN DEINITIALISED")
    }
    
    /// Controls the attributes of the status bar when this view controller is shown.
    @objc override var preferredStatusBarStyle : UIStatusBarStyle {
        return .darkContent
    }
    
    /// Controls whether status bar is shown or not when this view controller is shown.
    @objc override var prefersStatusBarHidden: Bool {
        return true
    }
    
    /// Moves `redLaserLineView` on top of `previewLayer` so it is shown on screen while scanning a barcode.
    @objc func setupRedLaserLineView() {
        self.redLaserLineView.layer.zPosition = 1
        self.redLaserLineView.clipsToBounds = true
        self.redLaserLineView.layer.cornerRadius = 2
    }
    
    /// Called after the view has been loaded.
    @objc override func viewDidLoad() {
        super.viewDidLoad()
        self.addPreviewLayer()
        self.preview.frame = self.previewLayer.safeAreaLayoutGuide.layoutFrame
        self.setupRedLaserLineView()
        self.barcodeReader.parentVC = self
        self.barcodeReader.configureSession()
    }
    
    /// Called when the view is about to made visible.
    @objc override func viewWillAppear(_ animated: Bool) {
        print("ENTERING BarcodeScannerViewController")
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.preview.frame = self.previewLayer.bounds
        self.barcodeReader.captureSession.startRunning()
    }
    
    /// Called when the view is dismissed, covered or otherwise hidden.
    @objc override func viewWillDisappear(_ animated: Bool) {
        print("LEAVING BarcodeScannerViewController")
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        self.barcodeReader.captureSession.stopRunning()
    }
    
    /// Called just after the view controller's view's layoutSubviews method is invoked.
    @objc override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.preview.frame = self.previewLayer.bounds
    }
    
    /// Puts the Core Animation layer that displays the video on top of `previewLayer` so it's visible to the user.
    @objc func addPreviewLayer() {
        self.previewLayer.layer.addSublayer(self.preview)
    }
    
    /// Called whenever an AVCaptureVideoDataOutput instance outputs a new video frame.
    /// - Parameters:
    ///   - output: The abstract superclass for objects that output the media recorded in a capture session.
    ///   - sampleBuffer: An object that models a buffer of media data.
    ///   - connection: A connection between a specific pair of capture input and capture output objects in a capture session.
    @objc func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        self.barcodeReader.rootClassCaptureOutput(output, didOutput: sampleBuffer, from: connection) {data in
            self.parentVC.parsedData = data
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}

// MARK: - Barcode Scanner View Controller IBActions and Methods

extension BarcodeScannerViewController {
    
    /// Dismisses this view controller and returns to `HomeViewController` when tapped.
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        print("DISMISS BUTTON TAPPED")
        self.navigationController?.popViewController(animated: true)
    }
    
}
