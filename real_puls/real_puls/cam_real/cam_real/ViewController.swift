//
//  ViewController.swift
//  cam_real
//
//  Created by Philipp Adis on 07.07.16.
//  Copyright © 2016 Philipp Adis. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate  {
    
    var state=false
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var werte = [Double]()
    var durchlauf = 0
    var captureSession = AVCaptureSession()
    var previewLayer = AVCaptureVideoPreviewLayer()
    let videoOutput = AVCaptureVideoDataOutput()
    var sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL)
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func button_touch(sender: AnyObject) {
        
        
       
        
        
        
        
        
        if(!state)
        {
            captureSession = AVCaptureSession()
            captureSession.sessionPreset = AVCaptureSessionPresetHigh
            let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            do {
                try backCamera.lockForConfiguration()
                backCamera.exposureMode = AVCaptureExposureMode.AutoExpose
                backCamera.torchMode = AVCaptureTorchMode.On
                backCamera.activeVideoMaxFrameDuration = CMTimeMake(1, 30)
                backCamera.activeVideoMinFrameDuration = CMTimeMake(1, 30)
                backCamera.focusMode = AVCaptureFocusMode.Locked
                try backCamera.setTorchModeOnWithLevel(1.0)
            } catch _ {
                
            }
            
            
          
            
            
            do
            {
                let input = try AVCaptureDeviceInput(device: backCamera)
                
                captureSession.addInput(input)
            }
            catch
            {
                print("can't access camera")
                return
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            view.layer.addSublayer(previewLayer)
            
            
            
           
            videoOutput.setSampleBufferDelegate(self,queue: dispatch_queue_create("sample_queue", DISPATCH_QUEUE_SERIAL))
            
             captureSession.addOutput(videoOutput)
            
            dispatch_async(sessionQueue){() -> Void in
             self.captureSession.startRunning()
            }
            
            
            
        
            button.setTitle("Stop", forState: UIControlState.Normal)
            state = true
          
        }
        else
        {
        
            button.setTitle("Start", forState: UIControlState.Normal)
            state = false
            
            

            
            dispatch_async(sessionQueue){() -> Void in
                self.previewLayer.removeFromSuperlayer()
                self.captureSession.stopRunning()
                
                self.captureSession.removeOutput(self.videoOutput)
               
               
               
            }
            
            
            for i in 0...50
            {
                print(self.werte[i])
            }
        }
    }
    
    
    
    
    
    
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!)
    {
        
        
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        
        CVPixelBufferLockBaseAddress(imageBuffer!, 0)
        let yPlanBufferAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer!, 0)
        
        let width = CVPixelBufferGetWidth(imageBuffer!)
        let height = CVPixelBufferGetHeight(imageBuffer!)
        let bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane( imageBuffer!, 0 );
        
        let data = NSData(bytes: yPlanBufferAddress, length: width * height)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let dataProvider = CGDataProviderCreateWithCFData(data)
        let imageRef = CGImageCreate(width, height, 8, 8, bytesPerRow, colorSpace, CGBitmapInfo.ByteOrderDefault, dataProvider, nil, false,.RenderingIntentDefault)
        
        
        let rawData = CGDataProviderCopyData(CGImageGetDataProvider(imageRef));
     
        
        let buf = CFDataGetBytePtr(rawData);
        let length = Int(CFDataGetLength(rawData));
        
        
        
       
        
        
        
        
        let img = UIImage(CGImage: imageRef!)
        
        
        dispatch_async(dispatch_get_main_queue())
        {
            var brightness = 0.0
            for i in 0...length
            {
                brightness = brightness + Double(buf[i])
            }
            
            self.label.text = String(Double(brightness/Double(length)))
            self.imageview.image = img
            
            
            self.werte.append(brightness/Double(length))
            self.durchlauf = self.durchlauf + 1
            if(self.durchlauf>299)
            {
                self.werte.removeFirst()
            }
            
        }
        
        CVPixelBufferUnlockBaseAddress(imageBuffer!, 0)
        
        
        
       
       
        
        
       
        
    }

}

