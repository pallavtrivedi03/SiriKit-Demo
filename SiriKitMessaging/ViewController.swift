//
//  ViewController.swift
//  SiriKitMessaging
//
//  Created by Pallav Trivedi on 29/03/18.
//  Copyright © 2018 Pallav Trivedi. All rights reserved.
//

import UIKit
import Intents

class ViewController: UIViewController {

    var locationManager: CLLocationManager?
    override func viewDidLoad() {
        super.viewDidLoad()
        INPreferences.requestSiriAuthorization { (status) in
            //Handle error
        }
        
        locationManager = CLLocationManager.init()
        self.locationManager?.requestWhenInUseAuthorization()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

