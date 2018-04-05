//
//  IntentHandler.swift
//  SiriKitMessagingIntentExtension
//
//  Created by Pallav Trivedi on 29/03/18.
//  Copyright © 2018 Pallav Trivedi. All rights reserved.
//
import ApiAI
import Intents
import CoreLocation
// As an example, this class is set up to handle Message intents.
// You will want to replace this or add other intents as appropriate.
// The intents you wish to handle must be declared in the extension's Info.plist.

// You can test your example integration by saying things to Siri like:
// "Send a message using <myApp>"
// "<myApp> John saying hello"
// "Search for messages in <myApp>"

class IntentHandler: INExtension, INSendMessageIntentHandling
{
    
    var locationManager:CLLocationManager?
    var coordinates = ""
    var date = ""
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        let configuration: AIConfiguration = AIDefaultConfiguration()
        configuration.clientAccessToken = "a79f502960824af09b2d996831a5296b"
        let apiai = ApiAI.shared()
        apiai?.configuration = configuration
        
        DispatchQueue.main.async {
            self.locationManager = CLLocationManager.init()
            self.locationManager?.requestWhenInUseAuthorization()
        }
            if CLLocationManager.locationServicesEnabled()
            {
                self.locationManager?.delegate = self
                self.locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager?.startUpdatingLocation()
        }

        
        
        return self
    }
    
    // MARK: - INSendMessageIntentHandling
    
    // Implement resolution methods to provide additional information about your intent (optional).
    func resolveRecipients(for intent: INSendMessageIntent, with completion: @escaping ([INPersonResolutionResult]) -> Void)
    {
        let resolutionResults = [INPersonResolutionResult.success(with: INPerson.init(personHandle: INPersonHandle.init(value: "Raw", type: .unknown), nameComponents: PersonNameComponents.init(), displayName: "Raw", image: INImage.init(), contactIdentifier: "Raw", customIdentifier: "Raw"))]
        
            completion(resolutionResults)
    }
    
    func resolveContent(for intent: INSendMessageIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if let text = intent.content, !text.isEmpty {
            print(">>>>>>>>>>>\(text)")
            
            //call AI service here
            
            let request = ApiAI.shared().textRequest()
            if text != "" {
                request?.query = text
            } else {
                return
            }
            request?.setMappedCompletionBlockSuccess({ (request, response) in
                let response = response as! AIResponse
                if response.result.action == "stats"
                {
                    if let parameters = response.result.parameters as? [String:AIResponseParameter]
                    {
                        if let stats = parameters["stats"]?.stringValue
                        {
                            switch stats
                            {
                            case "stats":
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                self.date = dateFormatter.string(from: Date())
                                
                                if let locValue = self.locationManager?.location?.coordinate
                                {
                                    self.coordinates = "\(locValue.latitude),\(locValue.longitude)"
                                }
                                let dataToSend = "Here are your statistics\nTime Stamp: \(self.date)\nLocation: \(self.coordinates)"
                                
                                completion(INStringResolutionResult.success(with: dataToSend))
                            default:
                                print("Default")
                            }
                        }
                    }
                }
                else
                {
                    completion(INStringResolutionResult.success(with: text))
                }
                
              
            }, failure: { (request, error) in
                print(error)
            })
            ApiAI.shared().enqueue(request)
            
        } else {
            completion(INStringResolutionResult.needsValue())
        }
    }
    
    // Once resolution is completed, perform validation on the intent and provide confirmation (optional).
    
    func confirm(intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
        // Verify user is authenticated and your app is ready to send a message.
        
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSendMessageIntent.self))
        let response = INSendMessageIntentResponse(code: .ready, userActivity: userActivity)
        
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
            
            print("response = \(String(describing: response))")
           
        }
        task.resume()
        completion(response)
    }
    
    // Handle the completed intent (required).
    
    func handle(intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
        // Implement your application logic to send a message here.
        
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSendMessageIntent.self))
        let response = INSendMessageIntentResponse(code: .success, userActivity: userActivity)
        completion(response)
    }

}
extension IntentHandler: CLLocationManagerDelegate
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
