//
//  ViewController.swift
//  LocationsAlpha
//
//  Created by Sandland, Weston on 2/22/18.
//  Copyright © 2018 Sandland, Weston. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    let TowerLatitude : Double = 30.2862
    let TowerLongitude : Double = 97.7394
    let locationManager = CLLocationManager()
    @IBOutlet weak var Tower: UILabel!
    
    func enableLocationServices() {
        locationManager.delegate = self as? CLLocationManagerDelegate
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationManager.requestWhenInUseAuthorization()
            break
            
        case .restricted, .denied:
            // Disable location features
            Tower.text = "location services are disabled"
            break
            
        case .authorizedWhenInUse, .authorizedAlways:
            // Enable basic location features
            setRelativePosition()
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            Tower.text = "location services are disabled"
            break
            
        case .authorizedWhenInUse:
            setRelativePosition()
            break
            
        case .notDetermined, .authorizedAlways:
            break
        }
    }
    
    func setRelativePosition()
    {
        Tower.text = String(describing: locationManager.location?.coordinate.latitude)
        Tower.text?.append(String(describing: locationManager.location?.coordinate.longitude))
        Tower.frame.origin = CGPoint(x: 0.0, y: 0.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //locationManager.requestAlwaysAuthorization()
        enableLocationServices()
        print(Tower.frame.origin.x)
        print(Tower.frame.origin.y)
        // Tower.frame.origin = CGPoint(x: <#T##Int#>, y: <#T##Int#>)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

