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
        vc.destinationEntry = destText
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
        var urlString: String = enteredText
        urlString = urlString.replacingOccurrences(of: " ", with: "+")
        let url = URL(string: "https://www.google.com/search?q=address+of+\(urlString)")
        if url != nil {
            let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
                if error == nil {
                    let urlContent = NSString(data: data!, encoding: String.Encoding.ascii.rawValue) as NSString!
                    if (urlContent?.range(of:";ll=") != nil && urlContent!.components(separatedBy: ";ll=").count > 1 &&
                        urlContent?.range(of:"\"_eGc\">") != nil && urlContent!.components(separatedBy: "\"_eGc\">").count > 1) {
                        let rawData = urlContent?.components(separatedBy: ";ll=")
                        let rawName = urlContent?.components(separatedBy: "\"_eGc\">")
                        if (rawData?[1].range(of: "&amp;") != nil &&
                            rawName?[1].range(of: ",") != nil) {
                            let lessRaw = (rawData?[1].components(separatedBy: "&amp;")[0])
                            let lessName = (rawName?[1].components(separatedBy: ",")[0])
                            if(lessRaw != nil && lessName != nil)
                            {
                                if(lessRaw!.components(separatedBy: ",").count > 1){
                                    let leastRaw = lessRaw?.components(separatedBy: ",")
                                    if Double(leastRaw![0]) != nil {
                                        if Double(leastRaw![1]) != nil {
                                            let thisLat = Double(leastRaw![0])!
                                            let thisLong = Double(leastRaw![1])!
                                            let leastName = lessName?.trimmingCharacters(in: .whitespacesAndNewlines)
                                            self.saveWebData(LLTuple: (thisLat, thisLong), name: leastName!)
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
    
    func saveWebData(LLTuple: (latitude: Double, longitude: Double), name: String)
    {
        destLat = LLTuple.latitude
        destLong = LLTuple.longitude
        destText = name
    }
    
    func enableErrorText()
    {
        ErrorLabel.textColor = #colorLiteral(red: 0.80303514, green: 0.2736586928, blue: 0.2775121331, alpha: 1)
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
