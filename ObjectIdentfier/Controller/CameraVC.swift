//
//  CameraVC.swift
//  CoreML
//
//  Created by MacBook Pro on 7/15/18.
//  Copyright © 2018 Bassyouni. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision


class CameraVC: UIViewController {

    //MARK:- variables
    var camera: Camera!
    
    var photoData: Data?
    
    var flashControlState: FlashState = .off
    
    var speechSynthesier = AVSpeechSynthesizer()
    
    //MARK:- IBOutlets
    @IBOutlet weak var flashBtn: RoundedShadowBtn!
    @IBOutlet weak var identficationLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var capturedImageView: RoundedShadowImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    
    //MARK:- view methods
    override func viewDidLoad() {
        super.viewDidLoad()
        flashBtn.addTarget(self, action: #selector(flashBtnPressed), for: UIControlEvents.touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        camera.previewLayer.frame = cameraView.bounds
        speechSynthesier.delegate = self
        spinner.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCameraView))
        tap.numberOfTapsRequired = 1
        
        camera = Camera()
        cameraView.layer.addSublayer(camera.previewLayer)
        cameraView.addGestureRecognizer(tap)
        camera.startRunning()
        
    }

    //MARK:- UIButtons Actions
    @objc func didTapCameraView()
    {
        self.cameraView.isUserInteractionEnabled = false
        spinner.isHidden = false
        spinner.startAnimating()
        
        camera.captureImage(flashControlState: flashControlState, delegate: self)
        
    }
    
    @objc func flashBtnPressed()
    {
        switch flashControlState {
        case .off:
            flashBtn.setTitle("Flash ON", for: .normal)
            flashControlState = .on
        case .on:
            flashBtn.setTitle("Flash OFF", for: .normal)
            flashControlState = .off
        }
    }
    
    //MARK:- methods
    func resultsMethod(request: VNRequest, error: Error?)
    {
        guard let results = request.results as? [VNClassificationObservation] else { return }
        for classification in results
        {
            if classification.confidence < 0.5
            {
                let unkownObjectMessage = "I'm not sure what this is. Please try again."
                self.identficationLabel.text = unkownObjectMessage
                synthesizeSpeech(formString: unkownObjectMessage)
                self.confidenceLabel.text = ""
                break
            }
            else
            {
                let identfication = classification.identifier
                let confidence = Int(classification.confidence * 100)
                self.identficationLabel.text = identfication
                self.confidenceLabel.text = "CONFIDENCE: \(confidence)%"
                let completeSentence = "This looks like \(identfication) and I'm \(confidence) percent sure."
                synthesizeSpeech(formString: completeSentence)
                break
            }
            
        }
    }
    
    func synthesizeSpeech(formString string: String)
    {
        let speechUtterance = AVSpeechUtterance(string: string)
        speechSynthesier.speak(speechUtterance)
    }
}

//MARK:- AVCapturePhotoCaptureDelegate
extension CameraVC: AVCapturePhotoCaptureDelegate
{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error =  error
        {
            debugPrint(error)
        }
        else
        {
            photoData = photo.fileDataRepresentation()
            
            do
            {
                let model = try VNCoreMLModel(for: SqueezeNet().model )
                let request = VNCoreMLRequest(model: model, completionHandler: resultsMethod)
                let handler = VNImageRequestHandler(data: photoData!)
                try handler.perform([request])
            }
            catch
            {
                debugPrint(error)
            }
            
            let image = UIImage(data: photoData!)
            self.capturedImageView.image = image
        }
    }
}

//MARK:- AVSpeechSynthesizerDelegate
extension CameraVC: AVSpeechSynthesizerDelegate
{
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.cameraView.isUserInteractionEnabled = true
        self.spinner.isHidden = true
        self.spinner.stopAnimating()
    }
}


















