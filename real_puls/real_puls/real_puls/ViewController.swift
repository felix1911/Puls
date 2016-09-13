//
//  ViewController.swift
//  real_puls
//
//  Created by Philipp Adis on 12.06.16.
//  Copyright © 2016 Philipp Adis. All rights reserved.
//

import UIKit
import Accelerate
import CoreMotion
import Charts
import AVFoundation


class ViewController: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate {
    
    

    //MArk properties
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
 
    @IBOutlet weak var outLabel: UILabel!
    
    @IBOutlet weak var chart_Messwerte: LineChartView!
    @IBOutlet weak var chart_Highpass: LineChartView!
    @IBOutlet weak var chart_Quadrat: LineChartView!
    @IBOutlet weak var chart_Lowpass: LineChartView!
    @IBOutlet weak var window: UIView!
    
    @IBOutlet weak var switch_button: UISegmentedControl!
    @IBOutlet weak var image_view: UIImageView!
    
    
    
    
    var Werte = LineChartDataSet(yVals: nil, label: "Werte")
    
    var Hochpass = LineChartDataSet(yVals: nil, label: "High")
    var Quadrat = LineChartDataSet(yVals: nil, label: "Quadrat")
    var Tiefpass = LineChartDataSet(yVals: nil, label: "Low")
    
    var data_Wert = LineChartData()
    var data_Quadrat = LineChartData()
    var data_Hochpass = LineChartData()
    var data_Tiefpass = LineChartData()
    
    
    let motionmanager = CMMotionManager()
    var state = false
    var Messwerte  = [Double]()
    var Pulswerte = [Double]()
    var good_pulse_found = false
    var good_pulse = 0.0
    
    var global_High = [Double]()
    var global_Low = [Double]()
    var global_Quadrat = [Double]()
    var chart = 0
    
    //-----------------------------------------
    
    var werte_kamera = [Double]()
    var durchlauf = 0
    var filter_durchlauf = 0
    var captureSession = AVCaptureSession()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var videoOutput = AVCaptureVideoDataOutput()
    var sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL)
    var first_kamera = false
    var counter_mittelwert_kamera = 0
    var points_kamera = ""
   
    
    
    //Durchschnitt
    func mean (eingabe: [Double]) -> Double
    {
        var sum = 0.0
        var i = 0
        while i<eingabe.count
            {
                sum = sum + eingabe[i]
                i = i+1;
            }
        
        return (sum / Double(eingabe.count))
    }
    
    
    //Standardabweichung
    func std (eingabe:[Double]) ->Double
    {
        let mean_eingabe = mean(eingabe)
        
        var variance = 0.0
        var i = 0
        while i<eingabe.count
        {
            variance = variance + (eingabe[i]-mean_eingabe) * (eingabe[i]-mean_eingabe)
            i = i+1;
        }
    
        return sqrt(variance/(Double(eingabe.count)-1.0))
    }
    
    //normalisieren
    func normalize(eingabe:[Double])->[Double]
    {
        let out = eingabe.map{$0-mean(eingabe)}
        let out_2 = out.map{$0/std(eingabe)}
        
        return out_2;
    }
    
    
    //autokorrelation
    func xcorr(eingabe:[Double])->[Double]
    {
        let padding = [Double](count:eingabe.count, repeatedValue: 0.0 )
        let eingabe_verschoben = padding +  eingabe
        var output = [Double](count:eingabe.count, repeatedValue: 0.0 )
        
        var n = 0;
        
        while n<eingabe.count
        {
            var i = 0
            while i<eingabe.count
            {
                output[n] = output[n] + eingabe[i]*eingabe_verschoben[i-n+eingabe.count]
                i = i+1
            }
        
        n = n+1
        
        }
    return output
    
    
    }
    
    
    //Berechnet das erste maximum nach der Autokorr. angewendet
    func max_x(eingabe:[Double]) ->Int
    {
        var data_check = [Double]()
        var y_check = 0.0
        var x_check = 0
        var out = eingabe
        out.removeRange(150...(out.count-1))
        out.removeRange(0...32)
        
        let max_peak = out.maxElement()!
        let index_peak = out.indexOf(max_peak)!+33
        var x = index_peak
        
        let max_n = floor(Double(index_peak) / 33.0)
        
        var i = 2
        
        while Double(i)<=max_n
        {
            let check_peak = Double(index_peak) / Double(i)
            data_check = out
            data_check.removeRange(Int(floor(check_peak-33.0+2.0))...data_check.count-1)
            if (Int(ceil(check_peak-33.0-3.0-1.0)) > 0)
            {
                data_check.removeRange(0...max(0,Int(ceil(check_peak-33.0-3.0-1.0))))
            }
            
            
            y_check = data_check.maxElement()!
            x_check = data_check.indexOf(y_check)!+33
            
            
            if (y_check>=0.85*max_peak)
            {
                x = x_check + Int(ceil(check_peak-33-4));
                
            }
            i = i+1
        }
        
        return x
        
    }
    
   
    //filtfilt
    func filter ( eingabe: [Double], numerator: [Double], denominator:[Double], zi_prev:[Double]) -> [Double]
    {
        
        let size_numerator = numerator.count
        let size_denominator = denominator.count
        let size_zi = zi_prev.count
        var zi = [Double]()
       
        let nfilt = max(size_numerator, size_denominator)
        let nfact = max(1, 3*(nfilt-1))
        var modified_eingabe = [Double](count:nfact, repeatedValue: 0.0 )
        let eingabe_anfang = eingabe[0]
        let eingabe_ende = eingabe[eingabe.count - 1]
        
        var output_1 = [Double](count:eingabe.count+2*nfact, repeatedValue: 0.0 )
        var output_2 = [Double](count:eingabe.count+2*nfact, repeatedValue: 0.0 )
        var output_3 = [Double](count:eingabe.count+2*nfact, repeatedValue: 0.0 )
        var output_4 = [Double](count:eingabe.count+2*nfact, repeatedValue: 0.0 )
        
        var counter = nfact + 1
       
        //////////////////////////////////////////padding an beiden Seiten
        
        while counter >= 2
        {
            modified_eingabe[nfact+1-counter] = (2*eingabe_anfang - eingabe[counter-1])
           
            counter = counter - 1
        }
        modified_eingabe = modified_eingabe + eingabe
        
        counter = eingabe.count - 2                 //vorletztes element
        while counter >= eingabe.count - 1 - nfact
        {
            modified_eingabe.append(2*eingabe_ende - eingabe[counter])
            counter = counter - 1
        }
       
        zi = zi_prev.map{$0*modified_eingabe[0]}
        
        ////////////////////////////////////////// Filtern vorwärts
        var dbuffer = [Double](count:5, repeatedValue: 0.0 )
        
        for k in 0...size_zi-1
        {
            dbuffer[k + 1] = zi[k];
        }
        
        for j in 0...modified_eingabe.count-1
        {
            for k in 0...size_zi-1
            {
                dbuffer[k] = dbuffer[k + 1];
            }
            
            dbuffer[size_zi] = 0.0;
            for k in 0...size_zi
            {
                dbuffer[k] += modified_eingabe[j] * numerator[k];
            }
            for k in 0...size_zi-1
            {
                dbuffer[k + 1] -= dbuffer[0] * denominator[k + 1];
            }
            output_1[j] = dbuffer[0];
        }
        
        ////////////////////////////////////////// Filtern rückwärts
       output_2 = output_1.reverse()
        
        zi = zi_prev.map{$0*output_2[0]}

        for k in 0...size_zi-1
        {
            dbuffer[k + 1] = zi[k];
        }
        
        for j in 0...modified_eingabe.count-1
        {
            for k in 0...size_zi-1
            {
                dbuffer[k] = dbuffer[k + 1];
            }
            
            dbuffer[size_zi] = 0.0;
            for k in 0...size_zi
            {
                dbuffer[k] += output_2[j] * numerator[k];
            }
            for k in 0...size_zi-1
            {
                dbuffer[k + 1] -= dbuffer[0] * denominator[k + 1];
            }
            output_3[j] = dbuffer[0];
        }
        
    output_4 = output_3.reverse()
    output_4.removeRange(0...(nfact-1))
    output_4.removeRange((output_4.count-nfact)...(output_4.count-1))
        
       
    return output_4
        
    }
 

    
    //Funktion für das Swipen der gefilterten Messwerte, welche nach dem Messen angezeigt werden. Es wird jeweils der das gewünschte Diagramm gezeigt, die anderen werden unsichtbar gemacht.
    func swiper(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                
                switch chart{
                case 1:
                        chart_Highpass.hidden = true
                        chart_Messwerte.hidden = false
                case 2:
                        chart_Quadrat.hidden = true
                        chart_Highpass.hidden = false
                case 3:
                        chart_Lowpass.hidden = true
                        chart_Quadrat.hidden = false
                default:
                    break
                }
                if (chart>0 )
                {
                    chart = chart-1
                }
            case UISwipeGestureRecognizerDirection.Left:
                switch chart{
                case 0:
                    chart_Messwerte.hidden = true
                    chart_Highpass.hidden = false
                case 1:
                    if (switch_button.selectedSegmentIndex == 1)
                    {
                        chart_Highpass.hidden = true
                        chart_Quadrat.hidden = false
                    }
                case 2:
                    chart_Quadrat.hidden = true
                    chart_Lowpass.hidden = false
                default:
                    break
                }
                if ((chart<3 && switch_button.selectedSegmentIndex == 1) || (chart == 0 && switch_button.selectedSegmentIndex == 0))
                {
                    chart = chart+1
                }
            default:
                break
            }
        }
    }
    
    //Durch "rauszoomen" werden die Messwerte geschlossen und das Startlayout wird wieder angezeigt.
    func pincher(gesture: UIGestureRecognizer) {
        
        if let pinchGesture = gesture as? UIPinchGestureRecognizer {
            
            if (pinchGesture.scale<0.85)
            {
                chart_Messwerte.hidden = true
                chart_Highpass.hidden = true
                chart_Quadrat.hidden = true
                chart_Lowpass.hidden = true
                window.hidden = true
                pinchGesture.scale = 1.0
            }
            
        }
        
        
    }

    //Vergleichbar mit der main-Funktion eines C-Programms
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "swiper:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "swiper:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
        
        let pinch = UIPinchGestureRecognizer(target: self, action: "pincher:")
        self.view.addGestureRecognizer(pinch)
       
       
        
        chart_Messwerte.descriptionText = ""
        chart_Highpass.descriptionText = ""
        chart_Lowpass.descriptionText = ""
        chart_Quadrat.descriptionText = ""
        
        chart_Messwerte.getAxis(ChartYAxis.AxisDependency.Right).drawLabelsEnabled = false
        chart_Highpass.getAxis(ChartYAxis.AxisDependency.Right).drawLabelsEnabled = false
        chart_Lowpass.getAxis(ChartYAxis.AxisDependency.Right).drawLabelsEnabled = false
        chart_Quadrat   .getAxis(ChartYAxis.AxisDependency.Right).drawLabelsEnabled = false
    
      
       
    }

    //Standardfunktion von Swift.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //Reset Funktion
    @IBAction func reset(sender: UIButton)
    {
        outLabel.text = "Press Start"
        Messwerte.removeAll()
        Pulswerte.removeAll()
        
         Werte = LineChartDataSet(yVals: nil, label: "Werte")
         Hochpass = LineChartDataSet(yVals: nil, label: "High")
         Quadrat = LineChartDataSet(yVals: nil, label: "Quadrat")
         Tiefpass = LineChartDataSet(yVals: nil, label: "Low")
        
         data_Wert = LineChartData()
         data_Quadrat = LineChartData()
         data_Hochpass = LineChartData()
         data_Tiefpass = LineChartData()
        
        good_pulse_found = false
         good_pulse = 0.0
        
         werte_kamera = [Double]()
         durchlauf = 0
         filter_durchlauf = 0
         captureSession = AVCaptureSession()
         previewLayer = AVCaptureVideoPreviewLayer()
         videoOutput = AVCaptureVideoDataOutput()
         sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL)
         first_kamera = false
         counter_mittelwert_kamera = 0
         points_kamera = ""
        
         global_High = [Double]()
         global_Low = [Double]()
         global_Quadrat = [Double]()
         chart = 0
        
        self.switch_button.hidden = false
        
    }
    
    
    //Start Funktion
    @IBAction func start(sender: UIButton)
    {
        //Wenn die Messung mit der Kamera erfolgen soll
        if(switch_button.selectedSegmentIndex == 0)
        {
        //Wenn "Start" noch nicht gedrückt wurde, wird die Messung getsartet.
        if(!state)
        {
            captureSession = AVCaptureSession()
            captureSession.sessionPreset = AVCaptureSessionPresetMedium
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
            
            startButton.setTitle("Stop", forState: UIControlState.Normal)
            state = true
            
        }
        //Wenn die Messung schon läuft
        else
        {
            
            startButton.setTitle("Start", forState: UIControlState.Normal)
            state = false
            
            
            
            
            dispatch_async(sessionQueue){() -> Void in
                self.previewLayer.removeFromSuperlayer()
                self.captureSession.stopRunning()
                
                self.captureSession.removeOutput(self.videoOutput)
                
            }
           
            self.Werte.axisDependency = .Left
            self.Werte.setColor(UIColor.blueColor().colorWithAlphaComponent(0.5)) // our line's opacity is 50%
            self.Werte.setCircleColor(UIColor.blueColor()) // our circle will be dark red
            self.Werte.lineWidth = 1.0
            self.Werte.circleRadius = 1.0 // the radius of the node circle
            self.Werte.fillAlpha = 65 / 255.0
            self.Werte.fillColor = UIColor.blueColor()
            self.Werte.highlightColor = UIColor.blueColor()
            self.Werte.drawValuesEnabled = false
            
            self.Hochpass.axisDependency = .Left // Line will correlate with left axis values
            self.Hochpass.setColor(UIColor.redColor().colorWithAlphaComponent(0.5)) // our line's opacity is 50%
            self.Hochpass.setCircleColor(UIColor.redColor()) // our circle will be dark red
            self.Hochpass.lineWidth = 1.0
            self.Hochpass.circleRadius = 1.0 // the radius of the node circle
            self.Hochpass.fillAlpha = 65 / 255.0
            self.Hochpass.fillColor = UIColor.redColor()
            self.Hochpass.highlightColor = UIColor.redColor()
            self.Hochpass.drawValuesEnabled = false
            
            self.data_Wert.addDataSet(self.Werte)
            self.data_Hochpass.addDataSet(self.Hochpass)
            
            for i in 0...89
            {
                self.data_Wert.addXValue(String(format:"%d",i))
                self.data_Hochpass.addXValue(String(format:"%d",i))
                
                
                
                self.data_Wert.addEntry(ChartDataEntry(value: self.werte_kamera[i],xIndex: i), dataSetIndex: 0)
                self.data_Hochpass.addEntry(ChartDataEntry(value: self.global_High[i],xIndex: i), dataSetIndex: 0)
                
                
            }
            self.switch_button.hidden = true
            self.chart_Messwerte.hidden = false
            self.window.layer.zPosition = 1
            self.window.hidden = false
            
            self.chart_Messwerte.data = self.data_Wert
            
            self.chart_Highpass.data = self.data_Hochpass
           
        }

        }
        //Wenn die Messung mit dem Beschleunigungssensor getsartet werden soll
        else{
        motionmanager.accelerometerUpdateInterval = 0.01  //100 Hertz Abtastrate
        
        if state == false // Falls Start noch nicht gedrückt wurde
        {
            state = true
            startButton.setTitle("Stop", forState: UIControlState.Normal)
            if motionmanager.accelerometerAvailable
            {
                var counter_filter = 0      //Zählervar. für die Filterung
                var counter = 0             //Zählervar. für die für die Messwerte
                var counter_mittelwert = 0  //Zählervar. für Mittelwertberechnung
                var first = false
                var points = ""             //Für die Warteanimation
               
                //Start der Updates
                motionmanager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!)
                {
                    [weak self] (dataacc: CMAccelerometerData?, error: NSError?) in
                    
                    //Messwerte in Array speichern
                    self!.Messwerte.append( dataacc!.acceleration.z)
                   
                    
                    //Anfangs wird gewartet, bis 300 Messwerte (3Sekunden in idesem Fall, da 100Hz) aufgenommen wurden, dann wird das erste mal gefiltert und ein Pulswert ermittelt. Dieser wird in einem "Pulswertearray" gespeichert womit später durch Standardabweichung ein genauer Puls ermittelt wird. Nach den ersten 300 Messwerten, wird alle 40 Messwerte(0.4Sekunden) ernuet ein Pulswert ermittel.
                    //First wird nach dem ersten Durchlauf auf true gesetzt -> dies wird weiter unten gebraucht.
                    if ((counter_filter == 299 && first == false) || (counter_filter == 40 && first == true))
                    {
                       
                        //FILTERn
                        
                        counter_filter = 0
                        
                        first = true
                        
                        //Highpass Filterkoeffizienten
                        let zi_high = [-0.94414920614909692, 2.8324476184277416,-2.8324476184093066, 0.94414920613062669 ]
                        let num_high = [0.94414920597899188, -3.7765968239159675,5.6648952358739511, -3.7765968239159675, 0.94414920597899188]
                        let denom_high = [1.0, -3.8850732107733075, 5.6617776923558045,-3.6681186693839489, 0.89141772315080958]
                       
                        //Highpass gefilterte Messwerte
                        let out = self!.filter(self!.Messwerte, numerator: num_high, denominator: denom_high, zi_prev: zi_high)
                        self!.global_High = out
                        
                        //Highpass gefilterte Messwerte quadrieren
                        var out_square = [Double](count:300, repeatedValue: 0.0)
                        for i in 0...299
                        {
                            out_square[i] = out[i]*out[i]
                        }
                        
                        self!.global_Quadrat = out_square
                        
                        //Lowpass des quadrierten high
                        let zi_low = [0.9921797919665043, -0.7581863929097681]
                        let num_low = [ 0.0078202080334971724, 0.015640416066994345, 0.0078202080334971724 ]
                        let denom_low = [1.0, -1.7347257688092754, 0.76600660094326412]
                        let out_low = self!.filter(out_square, numerator: num_low, denominator: denom_low, zi_prev: zi_low )
                        
                        self!.global_Low = out_low
                        
                        //Lowpass gefilterte Werte normalisieren
                        let out_normalized = self!.normalize(out_low)
                        
                        //Autokorrelation
                        let out_final = self!.xcorr(out_normalized)
                        
                        //Ermitteln des ersten Maximum innerhalb der xcorr-Daten
                        let max_T = self!.max_x(out_final)
                        
                        
                        //Falls bereits 10 Pulswerte errechnet wurden, wird nun der erste Pulswert berechnet, welcher auch ausgegeben wird.
                        if (counter_mittelwert == 10)
                        {
                            var Pulswerte_helper = self!.Pulswerte
                            
                            //falls die Standardabw. größer 3.9 ist und mehr als 4 Messwerte vorhanden sind, wird derjenige Wert entfernt, der am meisten abweicht
                            while(self!.std(self!.Pulswerte)>3.9 && self!.Pulswerte.count > 4)
                            {
                               
                                Pulswerte_helper = self!.Pulswerte.map{$0-self!.mean(self!.Pulswerte)}
                                Pulswerte_helper = Pulswerte_helper.map{abs($0)}
                                
                              
                                self!.Pulswerte.removeAtIndex(Pulswerte_helper.indexOf(Pulswerte_helper.maxElement()!)!)
                                
                            }
                            //Wenn die Standardabweichung kleiner als 3.9 ist, wird der aktuelle Puls aus dem Durchschnitt der aktuellen Messwerte ereechnet und ausgegeben.
                            if(self!.std(self!.Pulswerte)<=3.9)
                            {
                                self!.good_pulse = self!.mean(self!.Pulswerte)
                                
                                self!.outLabel.text = String(format:"Puls: %3.2f", self!.good_pulse)
                               
                                self!.good_pulse_found = true
                                
                               
                            }
                            self!.Pulswerte.removeFirst()
                            counter_mittelwert = self!.Pulswerte.count
                            
                        }
                        //Falls noch keine 10 Pulswerte errechnet wurden
                        else
                        {
                            if (self!.good_pulse_found==true)
                            {
                             self!.outLabel.text = String(format:"Puls: %3.2f",self!.good_pulse)
                            }
                            else    //anfangs gibt es noch keine Messwerte ->       Warteanimation wird ausgegeben
                            {
                                points = points + ". "
                                
                                self!.outLabel.text = points
                            }
                            //Hier werden die vorläufigen Pulswerte in den "Pulswertearray" geschreiben
                            self!.Pulswerte.append(60.0*100.0/Double(max_T))
                             counter_mittelwert = counter_mittelwert + 1
                        }
                       
                    }
                    //Wenn das erste mal 300 Messwerte errmittelt wurden, wird jeweils der älteste entfernt und ein neuer hinzugefügt
                    if counter >= 299
                    {
                        self!.Messwerte.removeAtIndex(0)
                        counter = counter - 1
                    }
                    
                    counter = counter + 1
                    counter_filter = counter_filter + 1
                }
            }

        }
        else
        {
            motionmanager.stopAccelerometerUpdates()
            startButton.setTitle("Start", forState: UIControlState.Normal)
            state = false
            
            Werte.axisDependency = .Left // Line will correlate with left axis values
            Werte.setColor(UIColor.blueColor().colorWithAlphaComponent(0.5)) // our line's opacity is 50%
            Werte.setCircleColor(UIColor.blueColor()) // our circle will be dark red
            Werte.lineWidth = 1.0
            Werte.circleRadius = 1.0 // the radius of the node circle
            Werte.fillAlpha = 65 / 255.0
            Werte.fillColor = UIColor.blueColor()
            Werte.highlightColor = UIColor.blueColor()
            Werte.drawValuesEnabled = false
            
            Hochpass.axisDependency = .Left // Line will correlate with left axis values
            Hochpass.setColor(UIColor.redColor().colorWithAlphaComponent(0.5)) // our line's opacity is 50%
            Hochpass.setCircleColor(UIColor.redColor()) // our circle will be dark red
            Hochpass.lineWidth = 1.0
            Hochpass.circleRadius = 1.0 // the radius of the node circle
            Hochpass.fillAlpha = 65 / 255.0
            Hochpass.fillColor = UIColor.redColor()
            Hochpass.highlightColor = UIColor.redColor()
            Hochpass.drawValuesEnabled = false
            
            
            Quadrat.axisDependency = .Left // Line will correlate with left axis values
            Quadrat.setColor(UIColor(red: 0, green: 0.4, blue: 0,alpha:1.0).colorWithAlphaComponent(0.5)) // our line's opacity is 50%
            Quadrat.setCircleColor(UIColor(red: 0, green: 0.4, blue: 0,alpha:1.0)) // our circle will be dark red
            Quadrat.lineWidth = 1.0
            Quadrat.circleRadius = 1.0 // the radius of the node circle
            Quadrat.fillAlpha = 65 / 255.0
            Quadrat.fillColor = UIColor(red: 0, green: 0.4, blue: 0,alpha:1.0)
            Quadrat.highlightColor = UIColor(red: 0, green: 0.4, blue: 0,alpha:1.0)
            Quadrat.drawValuesEnabled = false
            
            
            Tiefpass.axisDependency = .Left // Line will correlate with left axis values
            Tiefpass.setColor(UIColor.blackColor().colorWithAlphaComponent(0.5)) // our line's opacity is 50%
            Tiefpass.setCircleColor(UIColor.blackColor()) // our circle will be dark red
            Tiefpass.lineWidth = 1.0
            Tiefpass.circleRadius = 1.0 // the radius of the node circle
            Tiefpass.fillAlpha = 65 / 255.0
            Tiefpass.fillColor = UIColor.blackColor()
            Tiefpass.highlightColor = UIColor.blackColor()
            Tiefpass.drawValuesEnabled = false
            
        
           
            
            data_Wert.addDataSet(Werte)
            data_Quadrat.addDataSet(Quadrat)
            data_Hochpass.addDataSet(Hochpass)
            data_Tiefpass.addDataSet(Tiefpass)
            
            for i in 0...298
            {
                
                data_Wert.addXValue(String(format:"%d",i))
                data_Quadrat.addXValue(String(format:"%d",i))
                data_Hochpass.addXValue(String(format:"%d",i))
                data_Tiefpass.addXValue(String(format:"%d",i))
                
                
                data_Wert.addEntry(ChartDataEntry(value: Messwerte[i],xIndex: i), dataSetIndex: 0)
                data_Quadrat.addEntry(ChartDataEntry(value: global_Quadrat[i],xIndex: i), dataSetIndex: 0)
                data_Hochpass.addEntry(ChartDataEntry(value: global_High[i],xIndex: i), dataSetIndex: 0)
                data_Tiefpass.addEntry(ChartDataEntry(value: global_Low[i],xIndex: i), dataSetIndex: 0)
            
            }
            
            chart_Messwerte.data = data_Wert
            chart_Lowpass.data = data_Tiefpass
            chart_Highpass.data = data_Hochpass
            chart_Quadrat.data = data_Quadrat
        
            switch_button.hidden = true
            chart_Messwerte.hidden = false
            window.layer.zPosition = 1
            window.hidden = false
            
            }
            
            
            
        }
    }
    
    //Funktion in der die Kameremessung und Auswertung stattfindet
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
       
        //Kamerawerte werden aufgenommen
    dispatch_async(dispatch_get_main_queue()){ () -> Void in
            var brightness = 0.0
            for i in 0.stride(to: length, by: 2)
            {
                brightness = brightness + Double(buf[i])
            }
            
            var a = img.debugDescription
            self.werte_kamera.append(2*brightness/Double(length))
        
            self.durchlauf = self.durchlauf + 1
            self.filter_durchlauf = self.filter_durchlauf+1
        
            if(self.durchlauf>90)
            {
                self.werte_kamera.removeFirst()
                self.durchlauf = self.durchlauf - 1
            }
        
        //Wenn das erste mal gemessen wird und 90 Messwerte(auch hier 3s da 30Hz) oder sonst alle 12 Messwerte, was auch hier 0.4s entspricht
        if ((self.first_kamera == false && self.filter_durchlauf>90) || (self.first_kamera == true && self.filter_durchlauf == 12))
        {
            //Filtern
            self.first_kamera = true
            self.filter_durchlauf = 0
            let numerator = [0.825510291599237, -3.30204116639695, 4.95306174959542, -3.30204116639695, 0.825510291599237]
            let denominator = [1, -3.61706078143905, 4.92280714963786 ,-2.98682949239827 ,0.681467242112611]
            let zi = [-0.825510291597917,2.47653087479426,-2.47653087479467,0.825510291598337]
        
            let out_high = self.filter(self.werte_kamera, numerator: numerator, denominator: denominator, zi_prev: zi)
            self.global_High = out_high
        
            //Lowpass gefilterte Werte normalisieren
            let out_normalized = self.normalize(out_high)
        
            //Autokorrelation
            var out_final = self.xcorr(out_normalized)
            
            
            out_final.removeRange(65...(out_final.count-1))
            out_final.removeRange(0...9)
        
        
            let y_check = out_final.maxElement()!
            let x_check = out_final.indexOf(y_check)!+10
            
            //Wenn bereits 10 Pulswerte ermittelt wurden
            if (self.counter_mittelwert_kamera == 10)
            {
                var Pulswerte_helper = self.Pulswerte
                
                //Falls Standardabweichung größer 5 und mehr als 4 Pulswerte vorhanden, wird so lange das Element, dass am meisten abweicht entfernt, bis die standardabweichung kleiner als 5 ist oder nur noch 4 Pulswerte vorhanden sind
                while(self.std(self.Pulswerte)>5 && self.Pulswerte.count > 4)
                {
                    
                    Pulswerte_helper = self.Pulswerte.map{$0-self.mean(self.Pulswerte)}
                    Pulswerte_helper = Pulswerte_helper.map{abs($0)}
                    
                    
                    self.Pulswerte.removeAtIndex(Pulswerte_helper.indexOf(Pulswerte_helper.maxElement()!)!)
                    
                    
                    
                }
                //Falls die Standardabweichung kleiner als 5 ist, wird der Mittelwert der zuvor errechneten Pulswerte ermittelt und ausgegeben
                if(self.std(self.Pulswerte)<=5)
                {
                    self.good_pulse = self.mean(self.Pulswerte)
                    
                    self.outLabel.text = String(format:"Puls: %3.2f", self.good_pulse)
                    
                    //dies bedeutet, das es bereits einen vernünftigen Pulswert gibt, falls im nächsten Schritt zu viele unterschiedliche Werte gemessen werden und durch die Standardabweichungsbed. zu wenig Pulswerte vorhanden sind.
                    self.good_pulse_found = true
                    
                    
                }
                self.Pulswerte.removeFirst()
                self.counter_mittelwert_kamera = self.Pulswerte.count
                
            }
            else
            {
                //Die ist der Fall, dass zu wenig Werte die Standardabweichungsbed. erfüllen, somit wird der zuletzt ereechnete Puls noch einmal ausgegeben
                if (self.good_pulse_found==true)
                {
                    self.outLabel.text = String(format:"Puls: %3.2f",self.good_pulse)
                }
                    //Die passiert nur am Anfang, wenn noch nicht genug Messwerte vorhanden sind und somit die Warteanimation ausgegeben wird
                else
                {
                    self.points_kamera = self.points_kamera + ". "
                    
                    self.outLabel.text = self.points_kamera
                }
                self.Pulswerte.append(60.0*30.0/Double(x_check))//Hier werden die Pulswerte errechnet und gespeichert im "Pulswertearray"
                self.counter_mittelwert_kamera = self.counter_mittelwert_kamera + 1
            }
            
        
        }
        }
    
        CVPixelBufferUnlockBaseAddress(imageBuffer!, 0)
    }
}


