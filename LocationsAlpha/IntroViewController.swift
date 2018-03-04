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
        performSegue(withIdentifier: "DestinationEntered", sender: self)
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
