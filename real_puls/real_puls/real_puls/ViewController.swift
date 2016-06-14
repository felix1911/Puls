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

class ViewController: UIViewController {

    //MArk properties
    @IBOutlet weak var outputLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    
    
    let motionmanager = CMMotionManager()
    var state = false
     var Messwerte  = [Double]()
   
    
    func filter ( eingabe: [Double], numerator: [Double], denominator:[Double], zi:[Double]) -> [Double]
    {
        
        let size_numerator = numerator.count
        let size_denominator = denominator.count
        let size_zi = zi.count
        var nfilt = max(size_numerator, size_denominator)
        var nfact = max(1, 3*(nfilt-1))
        var modified_eingabe = [Double](count:12, repeatedValue: 0.0 )
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
        
        /////////////////////////////////////////
        print("Modified_eingabe")
        var i = 0
        while i<323
        {
            print(modified_eingabe[i],",")
            i = i+1
        }
        print("Modified_eingabe ende!")
        ////////////////////////////////////////// Filtern vorwärts
        
        var dbuffer = [Double](count:5, repeatedValue: 0.0 )
        
        for k in 0...3
        {
            dbuffer[k + 1] = zi[k];
        }
        
        for j in 0...323
        {
            for k in 0...3
            {
                dbuffer[k] = dbuffer[k + 1];
            }
            
            dbuffer[4] = 0.0;
            for k in 0...4
            {
                dbuffer[k] += modified_eingabe[j] * numerator[k];
            }
            for k in 0...3
            {
                dbuffer[k + 1] -= dbuffer[0] * denominator[k + 1];
            }
            output_1[j] = dbuffer[0];
        }
        //////////////////////////////////////////Ausgabe output_1
        
        i = 0
        while i<324
        {
            print(output_1[i])
            i = i+1
        }
        ////////////////////////////////////////// Filtern rückwärts
       output_2 = output_1.reverse()

        for k in 0...3
        {
            dbuffer[k + 1] = zi[k];
        }
        
        for j in 0...323
        {
            for k in 0...3
            {
                dbuffer[k] = dbuffer[k + 1];
            }
            
            dbuffer[4] = 0.0;
            for k in 0...4
            {
                dbuffer[k] += output_2[j] * numerator[k];
            }
            for k in 0...3
            {
                dbuffer[k + 1] -= dbuffer[0] * denominator[k + 1];
            }
            output_3[j] = dbuffer[0];
        }
        
    output_4 = output_3.reverse()
    output_4.removeRange(0...(nfact-1))
    output_4.removeRange((output_4.count-1-nfact)...(output_4.count-1-nfact))
        
        print("-------------------------------------")
        i = 0
        while i<299
        {
            print(output_4[i])
            i = i+1
        }
        print("-------------------------------------")
    return output_4
        
    }
   // func puls (messwerte: [Double] ) -> Double
    //{
        
   // }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Mark actions

    @IBAction func reset(sender: UIButton)
    {
        outputLabel.text = "Press START!"
    }
        
    @IBAction func start(sender: UIButton)
    {
        
        motionmanager.accelerometerUpdateInterval = 0.01  //100 Hertz Abtastrate
        
        if state == false // Falls Start noch nicht gedrückt wurde
        {
            state = true
            startButton.setTitle("Stop", forState: UIControlState.Normal)
            if motionmanager.accelerometerAvailable
            {
                var counter_filter = 0
                var counter = 0
               
                //Start der Updates
                motionmanager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!)
                {
                    [weak self] (dataacc: CMAccelerometerData?, error: NSError?) in
                    
                    
                    self!.Messwerte.append( dataacc!.acceleration.z)
                    print(dataacc!.acceleration.z)
                   
                    
                    
                    if counter_filter == 299
                    {
                        print("-------------------------------------")
                        //FILTERFUNKTION
                        counter_filter = 0
                        let zi_high = [-0.9441,2.8324,-2.8324,0.9441]
                        let num_high = [0.9441,-3.7766,5.6649,-3.7766,0.9441]
                        let denom_high = [1,-3.8851, 5.6618, -3.6681, 0.8914]
                        var out = self!.filter(self!.Messwerte, numerator: num_high, denominator: denom_high, zi: zi_high)
                        
                        
                        
                        print("-----------------------------------")
                        
                    }
                    if counter >= 299
                    {
                        self!.Messwerte.removeAtIndex(0)
                        counter = counter - 1
                    }
                    //Messwerte hinzufügen
                    
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
        }
    }
}
