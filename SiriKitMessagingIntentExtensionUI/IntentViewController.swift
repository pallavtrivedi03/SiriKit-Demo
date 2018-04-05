//
//  IntentViewController.swift
//  SiriKitMessagingIntentExtensionUI
//
//  Created by Pallav Trivedi on 29/03/18.
//  Copyright © 2018 Pallav Trivedi. All rights reserved.
//

import IntentsUI

// As an example, this extension's Info.plist has been configured to handle interactions for INSendMessageIntent.
// You will want to replace this or add other intents as appropriate.
// The intents whose interactions you wish to handle must be declared in the extension's Info.plist.

// You can test this example integration by saying things to Siri like:
// "Send a message using <myApp>"

class IntentViewController: UIViewController, INUIHostedViewControlling {
    
    @IBOutlet weak var textLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - INUIHostedViewControlling
    
    // Prepare your view controller for the interaction to handle.
    func configureView(for parameters: Set<INParameter>, of interaction: INInteraction, interactiveBehavior: INUIInteractiveBehavior, context: INUIHostedViewContext, completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void) {
        let intent = interaction.intent as! INSendMessageIntent
       
        if (parameters.count > 0) {
            let messageIntentDescriptionParameter = INParameter(for: INSendMessageIntent.self, keyPath: #keyPath(INSendMessageIntent.content))
            
            if parameters.contains(messageIntentDescriptionParameter) {
                self.textLabel.text = intent.content
                completion(true, parameters, self.desiredSize)
            }
        }
        
        return completion(false, parameters, CGSize.zero)
    }
    
    var desiredSize: CGSize {
        
        let size = self.extensionContext!.hostedViewMinimumAllowedSize
        return CGSize.init(width: size.width, height: size.height + 100)
    }
    
}
