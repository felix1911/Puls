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
        var modified_eingabe = [Double]()
        let eingabe_anfang = eingabe[0]
        let eingabe_ende = eingabe[eingabe.count - 1]
        
        var output_1 = [Double](count:eingabe.count+2*nfact, repeatedValue: 0.0 )
        var output_2 = [Double](count:eingabe.count+2*nfact, repeatedValue: 0.0 )
        var output_3 = [Double](count:eingabe.count+2*nfact, repeatedValue: 0.0 )
        var output_4 = [Double](count:eingabe.count+2*nfact, repeatedValue: 0.0 )
        
        var counter = nfact + 1
       
        //padding an beiden Seiten
        while counter >= 2
        {
            modified_eingabe.append(2*eingabe_anfang - eingabe[counter-1])
           
            counter = counter - 1
        }
        modified_eingabe = modified_eingabe + eingabe
        
        counter = eingabe.count - 2                 //vorletztes element
        while counter >= eingabe.count - 1 - nfact
        {
            modified_eingabe.append(2*eingabe_ende - eingabe[counter])
            counter = counter - 1
        }
       
        var i = 0
        
        while i<324
        {
            print(modified_eingabe[i])
            i = i+1
        }
        //////////////////////////////////////////
        var n = 0
        
        while n<(300 + 2 * nfact-1)
        {
            var i = 0
            
            while i < size_numerator
            {
                if(n - i >= 0 )
                {
                    output_1[n] = output_1[n] + numerator[i] * modified_eingabe[n-i]
                }
                i = i + 1
            }
            
            i = 0
            while i < size_denominator
            {
                if (n-i) >= 0
                {
                     output_1[n] = output_1[n] - denominator[i] * output_1[n-i]
                }
                else
                {
                    output_1[n] = output_1[n] - zi[-1*(n-i)] * modified_eingabe[0]
                }
                i = i+1
            }
        n = n+1
        }
    
     output_2 = output_1.reverse()
        
         n = 0
        
        while n<(300 + 2*nfact)
        {
            var i = 0
            
            while i < size_numerator
            {
                if(n - i >= 0 )
                {
                    output_3[n] = output_3[n] + numerator[i] * output_2[n-i]
                }
                i = i + 1
            }
            
            i = 0
            while i < size_denominator
            {
                if (n-i) >= 0
                {
                    output_3[n] = output_3[n] - denominator[i] * output_2[n-i]
                }
                else
                {
                    output_3[n] = output_3[n] - zi[-1*(n-i)] * output_2[0]
                }
                i = i+1
            }
            n = n+1
        }
        
    output_4 = output_3.reverse()
    output_4.removeRange(0...(nfact-1))
    output_4.removeRange((output_4.count-1-nfact)...(output_4.count-1-nfact))
        
       
        
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
                        let denom_high = [-3.8851, 5.6618, 3.6681, 0.8914]
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
