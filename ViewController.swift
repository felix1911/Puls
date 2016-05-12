//
//  ViewController.swift
//  test_2
//
//  Created by Anna Scheeder on 23.04.16.
//  Copyright © 2016 Felix Berief. All rights reserved.
//


import UIKit
import CoreMotion
import Charts
import Accelerate

func floats(n: Int)->[Float] {
    return [Float](count:n, repeatedValue:0)
}

class ViewController: UIViewController,ChartViewDelegate {

    
    @IBOutlet weak var fourier_chart: LineChartView!
    @IBOutlet weak var chart: LineChartView!
    var state = false
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var Puls: UILabel!
    
    var called = false

 
    
    let motionmanager = CMMotionManager()
    
    
    
    let linedata2 = LineChartData()
    let linedata = LineChartData()
    let fourierTest = LineChartData()
    
    
    let Werte = LineChartDataSet(yVals: nil, label: "Werte")
    let MovingAverage = LineChartDataSet(yVals: nil, label: "Moving Average")
    let Abweichung = LineChartDataSet(yVals: nil, label: "Abweichung")
    let Rechteck = LineChartDataSet(yVals: nil, label: "Puls")
    let FourierVor = LineChartDataSet(yVals: nil, label: "Fourier_Vorher")
    let FourierNach = LineChartDataSet(yVals: nil, label: "Fourier_Nach")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.chart.delegate = self
       
        
        
        self.fourier_chart.hidden = true       //Zweiter Chart hidden
        
        self.fourier_chart.gridBackgroundColor = UIColor.darkGrayColor()
        
        self.fourier_chart.noDataText = "Hallo Felix_2"
        
        self.chart.gridBackgroundColor = UIColor.darkGrayColor()
    
        self.chart.noDataText = "No data provided"
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    
    @IBAction func Start(sender: UIButton){
        
        
        Werte.axisDependency = .Left
        Werte.setColor(UIColor.blueColor().colorWithAlphaComponent(0.5))
        Werte.setCircleColor(UIColor.blueColor())
        Werte.lineWidth = 1.0
        Werte.circleRadius = 1.0
        Werte.fillAlpha = 65 / 255.0
        Werte.fillColor = UIColor.blueColor()
        Werte.highlightColor = UIColor.blueColor()
        Werte.drawValuesEnabled = false
        
        MovingAverage.axisDependency = .Left
        MovingAverage.setColor(UIColor.redColor().colorWithAlphaComponent(0.5))
        MovingAverage.setCircleColor(UIColor.redColor())
        MovingAverage.lineWidth = 1.0
        MovingAverage.circleRadius = 1.0
        MovingAverage.fillAlpha = 65 / 255.0
        MovingAverage.fillColor = UIColor.redColor()
        MovingAverage.highlightColor = UIColor.redColor()
        MovingAverage.drawValuesEnabled = false
        
       
        Abweichung.axisDependency = .Left
        Abweichung.setColor(UIColor.blueColor().colorWithAlphaComponent(0.5))
        Abweichung.setCircleColor(UIColor.blueColor())
        Abweichung.lineWidth = 1.0
        Abweichung.circleRadius = 1.0
        Abweichung.fillAlpha = 65 / 255.0
        Abweichung.fillColor = UIColor.blueColor()
        Abweichung.highlightColor = UIColor.blueColor()
        Abweichung.drawValuesEnabled = false
        
        
        Rechteck.axisDependency = .Left
        Rechteck.setColor(UIColor.redColor().colorWithAlphaComponent(0.5))
        Rechteck.setCircleColor(UIColor.redColor())
        Rechteck.lineWidth = 1.0
        Rechteck.circleRadius = 1.0
        Rechteck.fillAlpha = 65 / 255.0
        Rechteck.fillColor = UIColor.redColor()
        Rechteck.highlightColor = UIColor.redColor()
        Rechteck.drawValuesEnabled = false
        
        
    
        FourierVor.axisDependency = .Left
        FourierVor.setColor(UIColor.redColor().colorWithAlphaComponent(0.5))
        FourierVor.setCircleColor(UIColor.redColor())
        FourierVor.lineWidth = 1.0
        FourierVor.circleRadius = 1.0
        FourierVor.fillAlpha = 65 / 255.0
        FourierVor.fillColor = UIColor.redColor()
        FourierVor.highlightColor = UIColor.redColor()
        FourierVor.drawValuesEnabled = false
        
        
        FourierNach.axisDependency = .Left
        FourierNach.setColor(UIColor.blueColor().colorWithAlphaComponent(0.5))
        FourierNach.setCircleColor(UIColor.blueColor())
        FourierNach.lineWidth = 1.0
        FourierNach.circleRadius = 1.0
        FourierNach.fillAlpha = 65 / 255.0
        FourierNach.fillColor = UIColor.blueColor()
        FourierNach.highlightColor = UIColor.blueColor()
        FourierNach.drawValuesEnabled = false
        
        
       
            
        
        
        
        motionmanager.accelerometerUpdateInterval = 0.01  //100 Hertz Abtastrate
        
        if state == false // Falls Start noch nicht gedrückt wurde
        {
            state = true
            startButton.setTitle("Stop", forState: UIControlState.Normal)
            self.fourier_chart.hidden = true
            self.chart.hidden = false
            
            if motionmanager.accelerometerAvailable
            {
            
            
                var time:Double = 0
                var i = 0
                var kumuliert = 0.00
                var kumuliert2 = 0.00
                var kumuliert_help = 0.00
                var max_peak = 0.00
                var last_high = 0
                var high = false
                var intervall = 0
           
                //Hinzufügen der Sets
                
                //linedata: unsichtbar
                linedata.addDataSet(Werte)
                linedata.addDataSet(MovingAverage)
                
                //linedata2:sichtbar
                linedata2.addDataSet(Rechteck)
                linedata2.addDataSet(Abweichung)
                
                
                fourierTest.addDataSet(FourierNach)
                fourierTest.addDataSet(FourierVor)
                
                
                
                
                chart.data = linedata2
            
            
                //Start der Updates
                motionmanager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!)
                {
                    
                [weak self] (dataacc: CMAccelerometerData?, error: NSError?) in
                
                
                //X-Wert(Zeit) hinzufügen
                self!.linedata.addXValue(String(format:"%.1f" ,time))
                self!.linedata2.addXValue(String(format:"%.1f" ,time))
                    
                //Quadrierte Messwerte hinzufügen
                self!.linedata.addEntry(ChartDataEntry(value: dataacc!.acceleration.z*10*dataacc!.acceleration.z,xIndex :i), dataSetIndex: 0)
                    
                
                //Nach 30 Messwerten
                if (i>30)
                {
                    kumuliert = 0
                    for n in 0...29
                    {
                        kumuliert = kumuliert+(self!.linedata.getDataSetByIndex(0).entryForXIndex(i-n)?.value)!
                    }
                    
                    //Mittelwert der letzten 30 Eintraege
                    self!.linedata.addEntry(ChartDataEntry(value:  kumuliert/30,xIndex: i), dataSetIndex: 1)
                    
                    kumuliert2 = 0
                    
                    
                    //Mittelwert des Betrages der Abweichung (des Mittwelwerts vom Messwert) der letzten 6 Einträge
                    for n in 0...5
                    {
                        kumuliert_help = abs((self!.linedata.getDataSetByIndex(0).entryForXIndex(i-n)?.value)!-(self!.linedata.getDataSetByIndex(1).entryForXIndex(i-n)?.value)! )
                        kumuliert2 = kumuliert2 + kumuliert_help
                        
                    }
                    
                    self!.linedata2.addEntry(ChartDataEntry(value: kumuliert2/6,xIndex: i), dataSetIndex: 1)
                   
                    
                   
                    
                }
                
                    
                //Alle 120 Werte wird der Maximalwert herausgesucht und als Referenz für einen Puls gesetzt
                if (i%120 == 0 && i>0)
                {
                    max_peak = 0
                    for n in 0...119
                    {
                        if((self!.linedata2.getDataSetByIndex(1).entryForXIndex(i-n)?.value)! >= max_peak)
                        {
                            max_peak = (self!.linedata2.getDataSetByIndex(1).entryForXIndex(i-n)?.value)!
                          
                        }
                        
                    }
                }
                
                
                // Falls ein Wert innerhalb eines Toleranzbereiches um den max_peak liegt und nicht innerhalb der letzten 0.4s ein Peak gefunden wurde --> Peak gefunden
                if (i>=120)
                {
                    if ((self!.linedata2.getDataSetByIndex(1).entryForXIndex(i)?.value)! >= 0.8*max_peak && (self!.linedata2.getDataSetByIndex(1).entryForXIndex(i)?.value)! <= 1.5*max_peak)
                    {
                        
                        if (high == false)
                        {
                            high = true
                            
                            if (i-last_high > 40)
                            {
                                intervall = i - last_high
                                
                                    self?.Puls.text = String(format: "%.2f /min ", 60/(Double(intervall)*0.01))
                                max_peak = (self!.linedata2.getDataSetByIndex(1).entryForXIndex(i)?.value)!
                                self!.linedata2.addEntry(ChartDataEntry(value: 0.1,xIndex: i), dataSetIndex: 0)
                                  
                            }
                            
                            last_high = i
                        }
                        
                        
                    }
                    else
                    {
                       self!.linedata2.addEntry(ChartDataEntry(value: 0,xIndex: i), dataSetIndex: 0)
                        high = false
                    }
                    
                }
                
                //Anzeige der Werte
                if (i%10 == 0)
                {
                    self!.chart.notifyDataSetChanged()
                    self!.chart.setVisibleXRangeMaximum(400)
                    self!.chart.moveViewToX(CGFloat(self!.linedata2.xValCount-401))
                }
                
                //Begrenzung der Größe der Tabellen auf 512
                if (i>=512 )
                {
                    
                    self!.linedata2.removeEntryByXIndex(i-512, dataSetIndex: 1)
                    self!.linedata2.removeEntryByXIndex(i-512, dataSetIndex: 0)
                    self!.linedata.removeEntryByXIndex(i-512, dataSetIndex: 1)
                    self!.linedata.removeEntryByXIndex(i-512, dataSetIndex: 0)
                    self!.chart.leftAxis.axisMinValue = self!.linedata2.yMin - 0.25
                    self!.chart.leftAxis.axisMaxValue = self!.linedata2.yMax + 0.25
                    self!.chart.leftAxis.labelCount = Int(self!.chart.leftAxis.axisMaxValue - self!.chart.leftAxis.axisMinValue)
                    self!.chart.leftAxis.startAtZeroEnabled = false
                   
                }
               
          
                
                
                
                
                time = time +  0.01
                i  = i + 1
               
            }
        }
       

    }
        else
        {
            //FOURIER
            motionmanager.stopAccelerometerUpdates()
            startButton.setTitle("Start", forState: UIControlState.Normal)
            
            state = false
           
            
            let size = 1024
            let sizeHalf = 1024/2
            let log2n:UInt = 10
            
            //FFT-SETUP
            let fft = vDSP_create_fftsetup(log2n, FFTRadix(FFT_RADIX2))
            
            var originalReal = [Float]() //1. Speicherort unserer Messwerte
            
            var real = floats(sizeHalf ) //2 Float Arrays zum Speichern von Real und Imag
            var imaginary = floats(sizeHalf)
            
            var magnitude = floats(sizeHalf)
            
            var splitComplex = DSPSplitComplex(realp: &real, imagp: &imaginary) // DSP-Typ zum Speichern von komplexen Zahlen
            
           
            //Abwechselnd einen Messwert (Realteil) und 0(Imaginärteil) speichern
            for i in 0...(size/2-1)
            {
                
                originalReal.append(Float((self.linedata2.getDataSetByIndex(1).entryForXIndex(self.linedata2.xValCount-512+i)?.value)!))
                print((self.linedata.getDataSetByIndex(0).entryForXIndex(self.linedata2.xValCount-512+i)?.value)!)
                originalReal.append(Float(0))
            }
            
            
            vDSP_ctoz(UnsafePointer<COMPLEX>(originalReal), 2, &splitComplex, 1,UInt(size/2)) //Umwandeln des Float Arrays in eine komplexe Zahl (originalReal -> splitComplex)
            

            vDSP_fft_zrip(fft, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))  //Fourier-Transformation von splitComplex
            
            print("-------------------------------------------------")
            
            
            //Ausgabe der transformierten Werte
            for i in 0...(sizeHalf-1)
            {
                //print(String(format: "%d %.1f + %.1f i",i,splitComplex.realp[i],splitComplex.imagp[i]))
            }
           
            //Gleichanteil = 0

            
            
            splitComplex.realp[0] = 0
            splitComplex.imagp[0] = 0
            
            
            
            
//            for i in 20...511
//            {
//                splitComplex.realp[i] = 0
//                splitComplex.imagp[i] = 0
//            }
      
            
            print("-------------------------------------------------")
            

            
            for i in 0...(sizeHalf-1)
            {
                  //print(String(format: "%d . %.2f + %.1f i",i,splitComplex.realp[i],(splitComplex.imagp[i])))
            }
         var scale = Float( 1.0 / (2 * 1024));
             vDSP_zvmags(&splitComplex, 1, &magnitude, 1, UInt(sizeHalf))
            
            vDSP_vsmul(&magnitude, 1, &scale,&magnitude, 1, UInt(size/2));

            vDSP_fft_zrip(fft, &splitComplex, 1, log2n, FFTDirection(FFT_INVERSE))
            
            
            vDSP_vsmul(splitComplex.realp, 1, &scale,splitComplex.realp, 1, UInt(size/2));
            vDSP_vsmul(splitComplex.imagp, 1, &scale, splitComplex.imagp, 1, UInt(size/2));
            
            
           
            
            
            
           
         
            
            
            
            for i in 0...(size/2-1)
            {
               self.fourierTest.addEntry(ChartDataEntry(value: self.linedata2.getDataSetByIndex(1).entryForIndex(i)!.value,xIndex:i), dataSetIndex: 1)
              
                
                self.fourierTest.addEntry(ChartDataEntry(value: Double(magnitude[i/2]) ,xIndex: i), dataSetIndex: 0) //ersetze               splitComplex.realp[i] durch magnitude[i] für Frequenzspektrum      splitComplex.realp[i]
                
                self.fourierTest.addXValue(String(format: "%.1f", Double(self.linedata2.xValCount-511+i)*0.01 ))
                
                //print(String(format: "%d . %.5f + %.1f i",i,splitComplex.realp[i],(splitComplex.imagp[i])))
                //print(String(format: "%.8f",magnitude[i]))
              
               
            }
         
            self.chart.hidden = true
            self.fourier_chart.hidden = false
           
             self.fourier_chart.data = self.fourierTest
            
            
            
            
            
           
            
        }
    }
    

}

