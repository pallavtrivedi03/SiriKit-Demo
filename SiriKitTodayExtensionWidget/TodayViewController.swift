//
//  TodayViewController.swift
//  SiriKitTodayExtensionWidget
//
//  Created by Pallav Trivedi on 05/04/18.
//  Copyright © 2018 Pallav Trivedi. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreLocation

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var sendDataButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var labelContainerView: UIView!
    
    let EXPANDED_HEIGHT: CGFloat = 240
    let SHRINKED_HEIGHT: CGFloat = 100
    
    var locationManager:CLLocationManager?
    var coordinates = ""
    var date = ""
    var isLoadedFirstTime = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isLoadedFirstTime = true
        locationManager = CLLocationManager.init()
        self.locationManager?.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.startUpdatingLocation()
        }
        
        if #available(iOSApplicationExtension 10.0, *) {
            extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        completionHandler(NCUpdateResult.newData)
    }
    
    @IBAction func didClickOnSendDataButton(_ sender: UIButton)
    {
        
        let params = ["timeStamp":self.date, "location":self.coordinates]
        let url = URL.init(string: "https://obscure-reef-46541.herokuapp.com/saveData")
        var request = URLRequest.init(url: url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
        } catch {
            print("Exception---------")
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil
            {
                print("error=\(String(describing: error))")
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.sendDataButton.setTitle("Your data has been logged at Raw Servers", for: .normal)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.sendDataButton.setTitle("Tap to log your data at Raw Servers", for: .normal)
            }
        }
        task.resume()
    }
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        
        if isLoadedFirstTime
        {
             self.preferredContentSize =  CGSize(width: self.view.frame.size.width, height: SHRINKED_HEIGHT)
            self.labelContainerView.isHidden = true
            isLoadedFirstTime = false
            return
        }
        else
        {
        self.preferredContentSize = (activeDisplayMode == .expanded) ? CGSize(width: self.view.frame.size.width, height: EXPANDED_HEIGHT) : CGSize(width: self.view.frame.size.width, height: SHRINKED_HEIGHT)
        
        if activeDisplayMode == .expanded
        {
            locationLabel.text = self.coordinates
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.date = dateFormatter.string(from: Date())
            timeStampLabel.text = self.date
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(150)) {
            self.labelContainerView.isHidden = (activeDisplayMode == .expanded) ? false : true
        }
        }
    }
    
    
}
extension TodayViewController: CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Failed-------->\(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        self.coordinates = "\(locValue.latitude),\(locValue.longitude)"
    }
}
