//
//  Camera.swift
//  ObjectIdentfier
//
//  Created by MacBook Pro on 7/17/18.
//  Copyright © 2018 Bassyouni. All rights reserved.
//

import Foundation
import AVFoundation

enum FlashState
{
    case on
    case off
}

class Camera
{
    //MARK:- varibales
    private var _captureSession: AVCaptureSession!
    private var _cameraOutput: AVCapturePhotoOutput!
    private var _previewLayer: AVCaptureVideoPreviewLayer!
    
    //MARK:- init's
    init(previewLayerFrame: CGRect)
    {
        _previewLayer.frame = previewLayerFrame
        initalizer()
    }
    
    init() {
        initalizer()
    }
    
    //MARK:- public methods
    public func startRunning()
    {
        _captureSession.startRunning()
    }
    
    public func stopRunning()
    {
        _captureSession.stopRunning()
    }
    
    
    public func captureImage(flashControlState: FlashState, delegate: AVCapturePhotoCaptureDelegate)
    {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType, kCVPixelBufferWidthKey as String: 160, kCVPixelBufferHeightKey as String: 160]
        
        settings.previewPhotoFormat = previewFormat
        
        if flashControlState == .off
        {
            settings.flashMode = .off
        }
        else
        {
            settings.flashMode = .on
        }
        
        _cameraOutput.capturePhoto(with: settings, delegate: delegate)
    }
    
    //MARK:- private methods
    private func initalizer()
    {
        _captureSession = AVCaptureSession()
        _captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        
        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            
            let input = try AVCaptureDeviceInput(device: backCamera!)
            
            if _captureSession.canAddInput(input) == true
            {
                _captureSession.addInput(input)
            }
            
            _cameraOutput = AVCapturePhotoOutput()
            
            if _captureSession.canAddOutput(_cameraOutput) == true
            {
                _captureSession.addOutput(_cameraOutput!)
            }
            
            _previewLayer = AVCaptureVideoPreviewLayer(session: _captureSession!)
            _previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
            _previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        }
        catch
        {
            debugPrint(error)
        }
    }
    
    //MARK:- Setters & Getters
    var previewLayer:AVCaptureVideoPreviewLayer
    {
        get { return _previewLayer }
    }
    
    
}
