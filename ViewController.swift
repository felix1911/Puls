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
    let set1 = LineChartDataSet(yVals: nil, label: "Werte")
    let set2 = LineChartDataSet(yVals: nil, label: "Moving Average")
    let set3 = LineChartDataSet(yVals: nil, label: "Abweichung")
    let set4 = LineChartDataSet(yVals: nil, label: "Puls")
    let set5 = LineChartDataSet(yVals: nil, label: "Fourier_Vorher")
    let set6 = LineChartDataSet(yVals: nil, label: "Fourier_Vergleich")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 1
        self.chart.delegate = self
        // 2
       
        self.fourier_chart.hidden = true
        
        self.fourier_chart.gridBackgroundColor = UIColor.darkGrayColor()
        
        self.fourier_chart.noDataText = "Hallo Philipp"
        
        self.chart.gridBackgroundColor = UIColor.darkGrayColor()
    
        self.chart.noDataText = "No data provided"
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func Start(sender: UIButton){
        
        
        set1.axisDependency = .Left // Line will correlate with left axis values
        set1.setColor(UIColor.blueColor().colorWithAlphaComponent(0.5)) // our line's opacity is 50%
        set1.setCircleColor(UIColor.blueColor()) // our circle will be dark red
        set1.lineWidth = 1.0
        set1.circleRadius = 1.0 // the radius of the node circle
        set1.fillAlpha = 65 / 255.0
        set1.fillColor = UIColor.blueColor()
        set1.highlightColor = UIColor.blueColor()
        set1.drawValuesEnabled = false
        
        set2.axisDependency = .Left // Line will correlate with left axis values
        set2.setColor(UIColor.redColor().colorWithAlphaComponent(0.5)) // our line's opacity is 50%
        set2.setCircleColor(UIColor.redColor()) // our circle will be dark red
        set2.lineWidth = 1.0
        set2.circleRadius = 1.0 // the radius of the node circle
        set2.fillAlpha = 65 / 255.0
        set2.fillColor = UIColor.redColor()
        set2.highlightColor = UIColor.redColor()
        set2.drawValuesEnabled = false
        
       
        set3.axisDependency = .Left // Line will correlate with left axis values
        set3.setColor(UIColor.blueColor().colorWithAlphaComponent(0.5)) // our line's opacity is 50%
        set3.setCircleColor(UIColor.blueColor()) // our circle will be dark red
        set3.lineWidth = 1.0
        set3.circleRadius = 1.0 // the radius of the node circle
        set3.fillAlpha = 65 / 255.0
        set3.fillColor = UIColor.blueColor()
        set3.highlightColor = UIColor.blueColor()
        set3.drawValuesEnabled = false
        
        
        set4.axisDependency = .Left // Line will correlate with left axis values
        set4.setColor(UIColor.redColor().colorWithAlphaComponent(0.5)) // our line's opacity is 50%
        set4.setCircleColor(UIColor.redColor()) // our circle will be dark red
        set4.lineWidth = 1.0
        set4.circleRadius = 1.0 // the radius of the node circle
        set4.fillAlpha = 65 / 255.0
        set4.fillColor = UIColor.redColor()
        set4.highlightColor = UIColor.redColor()
        set4.drawValuesEnabled = false
        
        
    
        set5.axisDependency = .Left // Line will correlate with left axis values
        set5.setColor(UIColor.redColor().colorWithAlphaComponent(0.5)) // our line's opacity is 50%
        set5.setCircleColor(UIColor.redColor()) // our circle will be dark red
        set5.lineWidth = 1.0
        set5.circleRadius = 1.0 // the radius of the node circle
        set5.fillAlpha = 65 / 255.0
        set5.fillColor = UIColor.redColor()
        set5.highlightColor = UIColor.redColor()
        set5.drawValuesEnabled = false
        
        
        set6.axisDependency = .Left // Line will correlate with left axis values
        set6.setColor(UIColor.blueColor().colorWithAlphaComponent(0.5)) // our line's opacity is 50%
        set6.setCircleColor(UIColor.blueColor()) // our circle will be dark red
        set6.lineWidth = 1.0
        set6.circleRadius = 1.0 // the radius of the node circle
        set6.fillAlpha = 65 / 255.0
        set6.fillColor = UIColor.blueColor()
        set6.highlightColor = UIColor.blueColor()
        set6.drawValuesEnabled = false
        
        
       
            
        
        
        
        motionmanager.accelerometerUpdateInterval = 0.01
        
        if state == false
        {
            state = true
            startButton.setTitle("Stop", forState: UIControlState.Normal)
            
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
           
                
                
                linedata.addDataSet(set1)
                linedata.addDataSet(set2)
                
                
                
                linedata2.addDataSet(set4)
                linedata2.addDataSet(set3)
                
                
                fourierTest.addDataSet(set6)
                fourierTest.addDataSet(set5)
                
               chart.data = linedata2
            
            
            motionmanager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!){
                [weak self] (dataacc: CMAccelerometerData?, error: NSError?) in
                
                
                
                
                self!.linedata.addXValue(String(format:"%.1f" ,time))
                 self!.linedata2.addXValue(String(format:"%.1f" ,time))
                self!.linedata.addEntry(ChartDataEntry(value: 10*dataacc!.acceleration.z*10*dataacc!.acceleration.z,xIndex :i), dataSetIndex: 0)
                if (i>20)
                {
                    kumuliert = 0
                    for n in 0...29
                    {
                        kumuliert = kumuliert+(self!.linedata.getDataSetByIndex(0).entryForXIndex(i-n)?.value)!
                    }
                    
                    self!.linedata.addEntry(ChartDataEntry(value:   kumuliert/30,xIndex: i), dataSetIndex: 1)
                    
                    kumuliert2 = 0
                    
                    for n in 0...5
                    {
                        kumuliert_help = abs((self!.linedata.getDataSetByIndex(0).entryForXIndex(i-n)?.value)!-(self!.linedata.getDataSetByIndex(1).entryForXIndex(i-n)?.value)! )
                        kumuliert2 = kumuliert2 + kumuliert_help
                        
                    }
                    
                    self!.linedata2.addEntry(ChartDataEntry(value: kumuliert2/6,xIndex: i), dataSetIndex: 1)
                   
                    
                   
                    
                }
                
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
                
                if (i>=120)
                {
                    if ((self!.linedata2.getDataSetByIndex(1).entryForXIndex(i)?.value)! >= 0.8*max_peak && (self!.linedata2.getDataSetByIndex(1).entryForXIndex(i)?.value)! <= 1.5*max_peak)
                    {
                         self!.linedata2.addEntry(ChartDataEntry(value: 0.5,xIndex: i), dataSetIndex: 0)
                        if (high == false)
                        {
                            high = true
                            
                            if (i-last_high > 35)
                            {
                                intervall = i - last_high
                                
                                    self?.Puls.text = String(format: "%.2f /min ", 60/(Double(intervall)*0.01))
                                  
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
                
                if (i%10 == 0)
                {
                    self!.chart.notifyDataSetChanged()
                    self!.chart.setVisibleXRangeMaximum(400)
                    self!.chart.moveViewToX(CGFloat(self!.linedata2.xValCount-401))
                }
                
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
            startButton.setTitle("Start", forState: UIControlState.Normal)
            
            state = false
            motionmanager.stopAccelerometerUpdates()
            
            let size = 1024
            
            
            let fft = vDSP_create_fftsetup(10, FFTRadix(FFT_RADIX2))
            
            var originalReal = [Float]()
            
            var real = floats((size/2) * sizeof(Float))
            var imaginary = floats((size/2) * sizeof(Float))
            var splitComplex = DSPSplitComplex(realp: &real, imagp: &imaginary)
            
            print("--------------------------------------------")
            
            for i in 0...(size/2-1)
            {
                //print((self.linedata2.getDataSetByIndex(1).entryForXIndex(self.linedata2.xValCount-511+i)?.value)!)
                originalReal.append(Float((self.linedata2.getDataSetByIndex(1).entryForXIndex(self.linedata2.xValCount-512+i)?.value)!))
                originalReal.append(Float(0))
            }
            vDSP_ctoz(UnsafePointer<COMPLEX>(originalReal), 2, &splitComplex, 1,UInt(size/2))
            
//              print("----------------------------------------------")
//            for i in 0...(size/2-1)
//            {
//                print(String(format: "%.1f + %.1f i",splitComplex.realp.advancedBy(i).memory,(splitComplex.imagp.advancedBy(i).memory)))
//            }
            vDSP_fft_zrip(fft, &splitComplex, 1, 10, FFTDirection(FFT_FORWARD))
            
            print("-------------------------------------------------")
            for i in 0...(size/2-1)
            {
                print(String(format: "%.1f + %.1f i",splitComplex.realp.advancedBy(i).memory,(splitComplex.imagp.advancedBy(i).memory)))
            }
           
            print("---------------------------------------------------")
            splitComplex.realp.advancedBy(0).memory = 0
            splitComplex.imagp.advancedBy(0).memory = 0
            
            
            for i in 1...510
            {
                splitComplex.realp.advancedBy(i).memory = 0
                splitComplex.imagp.advancedBy(i).memory = 0
            }
            
            vDSP_fft_zrip(fft, &splitComplex, 1, 10, FFTDirection(FFT_INVERSE))
            var scale = Float( 1.0 / (2 * 1024));
            
            vDSP_vsmul(splitComplex.realp, 1, &scale,splitComplex.realp, 1, UInt(size/2));
            vDSP_vsmul(splitComplex.imagp, 1, &scale, splitComplex.imagp, 1, UInt(size/2));
            
            
            
            
           
         
            
            
            
            for i in 0...(size/2-1)
            {
               self.fourierTest.addEntry(ChartDataEntry(value: self.linedata2.getDataSetByIndex(1).entryForIndex(i)!.value,xIndex:i), dataSetIndex: 0)
                
                self.fourierTest.addEntry(ChartDataEntry(value: Double(splitComplex.realp.advancedBy(i).memory) ,xIndex: i), dataSetIndex: 1)
                
                self.fourierTest.addXValue(String(format: "%.1f", Double(self.linedata2.xValCount-511+i)*0.01 ))
                
                print(String(format: "%d . %.2f + %.1f i",i,splitComplex.realp.advancedBy(i).memory,(splitComplex.imagp.advancedBy(i).memory)))
                print(self.fourierTest.xValCount)
                print(self.linedata2.xValCount-510+i)
               
            }
         
            self.chart.hidden = true
            self.fourier_chart.hidden = false
           
             self.fourier_chart.data = self.fourierTest
            
            
            
            
            
           
            
        }
    }
    

}

