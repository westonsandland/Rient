//
//  ViewController.swift
//  LocationsAlpha
//
//  Created by Sandland, Weston on 2/22/18.
//  Copyright © 2018 Sandland, Weston. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit


//extension ViewController: enableLocation {
//}

class ViewController: UIViewController, CLLocationManagerDelegate, URLSessionDelegate {

    let locationObj = CLLocationManager()
    @IBOutlet weak var LatitudeFrom: UILabel!
    @IBOutlet weak var LongitudeFrom: UILabel!
    @IBOutlet weak var Pointer: UIImageView!
    @IBOutlet weak var DistanceFrom: UILabel!
    @IBOutlet weak var DestinationLabel: UILabel!
    @IBOutlet weak var blackout: UIImageView!
    @IBOutlet weak var arrived: UILabel!
    
    var destinationEntry: String = "none"
    var destinationLatitude: Double = 0.0
    var destinationLongitude: Double = 0.0
    var currentAngle: Double = 0
    var correction: Double = 0
    var fullAddress: [String] = [""]
    var webData: Data?
    var exactDistanceFrom: Double = 0.0
    var isHere: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func enableLocationServices() -> Int8 {
        var returner: Int8 = -1
        locationObj.delegate = self
        while(returner == -1){
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                // Request when-in-use authorization initially
                locationObj.requestWhenInUseAuthorization()
                break
                
            case .restricted, .denied:
                // Disable location features
                //Tower.text = "location services are disabled"
                returner = 0
                break
                
            case .authorizedWhenInUse, .authorizedAlways:
                // Enable basic location features
                locationObj.startUpdatingLocation()
                locationObj.startUpdatingHeading()
                setRelativePosition()
                returner = 1
                break
            }
        }
        return returner
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
        LatitudeFrom.text = String(describing: round(fromTowerTuple.latitude*10000000)/10000000)
        LongitudeFrom.text = String(describing: round(fromTowerTuple.longitude*10000000)/10000000)
        let targetLocation = CLLocation(latitude: destinationLatitude, longitude: destinationLongitude)
        let myLocation = CLLocation(latitude: (locationObj.location?.coordinate.latitude)!, longitude: (locationObj.location?.coordinate.longitude)!)
        //print("TARGET LAT AND LONG IS:")
        //print(targetLocation.coordinate.latitude)
        //print(targetLocation.coordinate.longitude)
        //print("MY LAT AND LONG IS:")
        //print(myLocation.coordinate.latitude)
        //print(myLocation.coordinate.longitude)
        exactDistanceFrom = targetLocation.distance(from: myLocation) * 0.000621371
        DistanceFrom.text = String(round(exactDistanceFrom * 100)/100) + " miles away"
        rotatePointer(xyTuple: fromTowerTuple)
        //print("current angle is " + String(currentAngle))
        hereCheck()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let uncorrected = correction
        correction = newHeading.magneticHeading * (Double.pi / 180.0)
        currentAngle = currentAngle - (correction - uncorrected)
        Pointer.transform = Pointer.transform.rotated(by: CGFloat((correction - uncorrected) * -1.0))
    }
    
    func getLatitudeAndLongitudeFromTower() -> (latitude: Double, longitude: Double)
    {
        let currentLatitude : Double = (locationObj.location?.coordinate.latitude)!
        let currentLongitude : Double = (locationObj.location?.coordinate.longitude)!
        //print("current latitude is "+String(currentLatitude))
        //print("current longitude is "+String(currentLongitude))
        //print("\(destinationEntry) latitude is "+String(destinationLatitude))
        //print("\(destinationEntry) longitude is "+String(destinationLongitude))
        return (destinationLatitude - currentLatitude,
                destinationLongitude - currentLongitude)
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
        //Pointer.transform = Pointer.transform.rotated(by: CGFloat(Double.pi/2.0))
        Pointer.transform = Pointer.transform.rotated(by: CGFloat(toRotateBy * -1.0))
        currentAngle = radianRotation
        //print("webdata is "+(webData?.base64EncodedString())!)
    }
    
    func setRelativePosition()
    {
        //Tower.text = String(describing: locationObj.location?.coordinate.latitude)
        //Tower.text?.append(String(describing: locationObj.location?.coordinate.longitude))
        //Tower.frame.origin = CGPoint(x: 0.0, y: 0.0)
    }
    
    func hereCheck()
    {
        if(exactDistanceFrom < 0.005 && !isHere)
        {
            animateHere()
            isHere = true
        } else if(exactDistanceFrom >= 0.005 && isHere)
        {
            removeHere()
            isHere = false
        }
    }
    
    func animateHere()
    {
        UIView.animate(withDuration: 1.0, animations:
        {
            self.blackout.alpha = 1.0
            self.arrived.alpha = 1.0
            self.view.backgroundColor = #colorLiteral(red: 0.80303514, green: 0.2736586928, blue: 0.2775121331, alpha: 1)
        }, completion: nil)
    }
    
    func removeHere()
    {
        UIView.animate(withDuration: 1.0, animations:
            {
                self.blackout.alpha = 0.0
                self.arrived.alpha = 0.0
                self.view.backgroundColor = #colorLiteral(red: 0.1960576177, green: 0.1960916817, blue: 0.1960501969, alpha: 1)
        }, completion: nil)
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blackout.alpha = 0.0
        arrived.alpha = 0.0
        //locationManager.requestAlwaysAuthorization()
        LatitudeFrom.adjustsFontSizeToFitWidth = true
        LongitudeFrom.adjustsFontSizeToFitWidth = true
        DestinationLabel.text = "Directions to \(destinationEntry)"
        enableLocationServices()
        //print(destinationEntry)
        //constraints start here
        //Pointer.translatesAutoresizingMaskIntoConstraints = false
        //view.addSubview(Pointer)
        //let bounds = UILayoutGuide()
        //let widthMinusPointer = margins.rightAnchor - #imageLiteral(resourceName: "Pointer").size.width
        //let distanceFromLeft = widthMinusPointer / (1.7)
        //let distanceFromRight = widthMinusPointer - distanceFromLeft
        //let leftConstraint = NSLayoutConstraint(item: Pointer, attribute: .leading, relatedBy: .equal, toItem: bounds, attribute: .trailingMargin, multiplier: 1/1.7, constant: #imageLiteral(resourceName: "Pointer").size.width/(-1.7))
        //let rightConstraint = NSLayoutConstraint(item: Pointer, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailingMargin, multiplier: 2.4/1.7, constant: ((-0.7)/1.7)*#imageLiteral(resourceName: "Pointer").size.width)
        
        //NSLayoutConstraint.activate([leftConstraint, rightConstraint])
        // Do any additional setup after loading the view, typically from a nib.
//        blackout.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(blackout)
//        let margins = view.layoutMarginsGuide
//        NSLayoutConstraint.activate([
//            blackout.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
//            blackout.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
//            ])
        //blackout.image = resizeImage(image: blackout.image!, targetSize: self.view.frame.size)
        //print("constraints updated")
    }
    
    // delegate methods
    /*
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        guard let response = response as? HTTPURLResponse,
            (200...299).contains(response.statusCode),
            let mimeType = response.mimeType,
            mimeType == "text/html" else {
                completionHandler(.cancel)
                return
        }
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.webData?.append(data)
    }
    
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        return URLSession(configuration: configuration,
                          delegate: self, delegateQueue: nil)
    }()
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                print("bug happened")
            } else if let receivedData = self.webData,
                let string = String(data: receivedData, encoding: .utf8) {
                print("string is "+string)
            }
        }
    }
    */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

