//
//  IntroViewController.swift
//  LocationsAlpha
//
//  Created by Sandland, Weston on 2/26/18.
//  Copyright © 2018 Sandland, Weston. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController, UITextFieldDelegate {

    var destText : String = ""
    var destLat : Double = 1000.0
    var destLong : Double = 1000.0
    var toContinue : Bool = false
    @IBOutlet weak var DestinationField: UITextField!
    @IBOutlet weak var ErrorLabel: UILabel!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ViewController
        vc.destinationEntry = DestinationField.text!
        vc.destinationLongitude = destLong
        vc.destinationLatitude = destLat
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        DestinationField.delegate = self
        disableErrorText()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        destLat = 1000.0
        destLong = 1000.0
        disableErrorText()
        toContinue = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        getWebData(enteredText: textField.text!)
        while(!toContinue){}
        toContinue = false
        if(destLat != 1000.0 && destLong != 1000.0){
            disableErrorText()
            self.performSegue(withIdentifier: "DestinationEntered", sender: self)
        }else
        {
            enableErrorText()
        }
    }
    
    func getWebData(enteredText: String)
    {
        print(destLat)
        print(destLong)
        var urlString: String = enteredText
        urlString = urlString.replacingOccurrences(of: " ", with: "+")
        let url = URL(string: "https://www.google.com/search?q=address+of+\(urlString)")
        if url != nil {
            let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
                if error == nil {
                    let urlContent = NSString(data: data!, encoding: String.Encoding.ascii.rawValue) as NSString!
                    if (urlContent?.range(of:";ll=") != nil && urlContent!.components(separatedBy: ";ll=").count > 1) {
                        let rawData = urlContent?.components(separatedBy: ";ll=")
                        if (rawData?[1].range(of: "&amp;") != nil) {
                            let lessRaw = (rawData?[1].components(separatedBy: "&amp;")[0])
                            if(lessRaw != nil)
                            {
                                if(lessRaw!.components(separatedBy: ",").count > 1){
                                    let leastRaw = lessRaw?.components(separatedBy: ",")
                                    if Double(leastRaw![0]) != nil {
                                        if Double(leastRaw![1]) != nil {
                                            let thisLat = Double(leastRaw![0])!
                                            let thisLong = Double(leastRaw![1])!
                                            self.saveWebData(LLTuple: (thisLat, thisLong))
                                            self.processFinished()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    self.processFinished()
                }else
                {
                    print("we got un error")
                    print("error: \(String(describing: error))")
                    self.enableErrorText()
                    self.processFinished()
                }
            })
            task.resume()
        }
    }
    
    func saveWebData(LLTuple: (latitude: Double, longitude: Double))
    {
        destLat = LLTuple.latitude
        destLong = LLTuple.longitude
    }
    
    func enableErrorText()
    {
        ErrorLabel.textColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
    }
    
    func disableErrorText()
    {
        ErrorLabel.textColor = UIColor(white: 1, alpha: 0)
    }
    
    func processFinished()
    {
        toContinue = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
