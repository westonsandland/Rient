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
    @IBOutlet weak var DestinationField: UITextField!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ViewController
        vc.destinationEntry = DestinationField.text!
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        DestinationField.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        var validLocation : BooleanLiteralType = true
        var urlString: String = textField.text!
        urlString = urlString.replacingOccurrences(of: " ", with: "+")
        let url = URL(string: "https://www.google.com/search?q=address+of+\(urlString)")
        if url != nil {
            let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
                print(data!)
                if error == nil {
                    let urlContent = NSString(data: data!, encoding: String.Encoding.ascii.rawValue) as NSString!
                    let rawData = urlContent?.components(separatedBy: ";ll=")
                    if(rawData != nil)
                    {
                        let lessRaw = rawData![1].components(separatedBy: "&amp;")[0]
                        if(lessRaw != nil)
                        {
                            print(lessRaw)
                        } else
                        {
                            validLocation = false
                        }
                    } else
                    {
                        validLocation = false
                    }
                }
            })
            task.resume()
        } else
        {
            validLocation = false
        }
        if(validLocation)
        {
            performSegue(withIdentifier: "DestinationEntered", sender: self)
        }
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
