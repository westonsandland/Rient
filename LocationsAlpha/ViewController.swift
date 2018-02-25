//
//  ViewController.swift
//  LocationsAlpha
//
//  Created by Sandland, Weston on 2/22/18.
//  Copyright © 2018 Sandland, Weston. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    let locationObj = CLLocationManager()
    @IBOutlet weak var Tower: UILabel!
    
    func enableLocationServices() {
        locationObj.delegate = self

        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationObj.requestWhenInUseAuthorization()
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
    
    func getLatitudeAndLongitudeFromTower() -> (latitude: Double, longitude: Double)
    {
        let currentLatitude : Double = (locationObj.location?.coordinate.latitude)!
        let currentLongitude : Double = (locationObj.location?.coordinate.longitude)!
        return (LocationConstants.Coordinates.towerLatitude - currentLatitude,
                LocationConstants.Coordinates.towerLongitude - currentLongitude)
    }
    
    func setRelativePosition()
    {
        Tower.text = String(describing: locationObj.location?.coordinate.latitude)
        Tower.text?.append(String(describing: locationObj.location?.coordinate.longitude))
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

