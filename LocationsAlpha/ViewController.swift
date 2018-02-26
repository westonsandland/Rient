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
    @IBOutlet weak var LatitudeFrom: UILabel!
    @IBOutlet weak var LongitudeFrom: UILabel!
    @IBOutlet weak var Pointer: UIImageView!
    
    var currentAngle: Double = 0
    var correction: Double = 0
    
    func enableLocationServices() {
        locationObj.delegate = self

        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationObj.requestWhenInUseAuthorization()
            break
            
        case .restricted, .denied:
            // Disable location features
            //Tower.text = "location services are disabled"
            break
            
        case .authorizedWhenInUse, .authorizedAlways:
            // Enable basic location features
            locationObj.startUpdatingLocation()
            locationObj.startUpdatingHeading()
            setRelativePosition()
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            //Tower.text = "location services are disabled"
            break
            
        case .authorizedWhenInUse:
            setRelativePosition()
            break
            
        case .notDetermined, .authorizedAlways:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let fromTowerTuple = getLatitudeAndLongitudeFromTower()
        LatitudeFrom.text = String(describing: fromTowerTuple.latitude)
        LongitudeFrom.text = String(describing: fromTowerTuple.longitude)
        rotatePointer(xyTuple: fromTowerTuple)
        print("current angle is " + String(currentAngle))
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let uncorrected = correction
        correction = newHeading.magneticHeading * (Double.pi / 180.0)
        Pointer.transform = Pointer.transform.rotated(by: CGFloat(correction - uncorrected))
    }
    
    func getLatitudeAndLongitudeFromTower() -> (latitude: Double, longitude: Double)
    {
        let currentLatitude : Double = (locationObj.location?.coordinate.latitude)!
        let currentLongitude : Double = (locationObj.location?.coordinate.longitude)!
        print("method ran")
        print("current latitude is "+String(currentLatitude))
        print("current longitude is "+String(currentLongitude))
        print("UT latitude is "+String(LocationConstants.Coordinates.towerLatitude))
        print("UT longitude is "+String(LocationConstants.Coordinates.towerLongitude))
        return (LocationConstants.Coordinates.towerLatitude - currentLatitude,
                LocationConstants.Coordinates.towerLongitude - currentLongitude)
    }
    
    func rotatePointer(xyTuple: (latitude: Double, longitude: Double))
    {
        let x = xyTuple.longitude
        let y = xyTuple.latitude
        let hypo = sqrt(pow(x, 2.0) + pow(y, 2.0))
        var radianRotation : Double
        if x < 0 && y < 0 {
            radianRotation = acos(-x / hypo) + Double.pi
        } else if x < 0
        {
            radianRotation = acos(x / hypo)
        } else
        {
            radianRotation = asin(y / hypo)
        }
        if radianRotation < 0.0
        {
            radianRotation = Double.pi * 2.0 + radianRotation
        }
        radianRotation = radianRotation - correction
        let toRotateBy = radianRotation - currentAngle
        Pointer.transform = Pointer.transform.rotated(by: CGFloat(toRotateBy))
        currentAngle = radianRotation
    }
    
    func setRelativePosition()
    {
        //Tower.text = String(describing: locationObj.location?.coordinate.latitude)
        //Tower.text?.append(String(describing: locationObj.location?.coordinate.longitude))
        //Tower.frame.origin = CGPoint(x: 0.0, y: 0.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //locationManager.requestAlwaysAuthorization()
        LatitudeFrom.adjustsFontSizeToFitWidth = true
        LongitudeFrom.adjustsFontSizeToFitWidth = true
        enableLocationServices()
        //print(Tower.frame.origin.x)
        //print(Tower.frame.origin.y)
        // Tower.frame.origin = CGPoint(x: <#T##Int#>, y: <#T##Int#>)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

