//
//  LogInViewController.swift
//  FoodTracker
//
//  Created by Chris Jones on 2017-02-13.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var infoWarning: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        infoWarning.isHidden = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    
    @IBAction func logIn(_ sender: UIButton) {
        
        guard let password = passwordTextField.text else {
            infoWarning.isHidden = false
            return
        }
        
        guard let username = usernameTextField.text else {
            infoWarning.isHidden = false
            return
        }
        
        guard password.characters.count > 5 else {
            infoWarning.isHidden = false
            return
        }
        
        print("U: \(username) P: \(password)")
        self.dismiss(animated: true, completion: nil)
        
        let postData = ["Username": username, "Password": password]
        
        guard let postJSON = try? JSONSerialization.data(withJSONObject: postData, options: JSONSerialization.WritingOptions.prettyPrinted) else {
            print("could not serialize json")
            return
        }
        
        let url = URL(string: "http://159.203.243.24:8000/signup")!
        
        var request: URLRequest = URLRequest(url:url)
        request.httpBody = postJSON
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error: Error?) in
            
            guard let data = data else {
                print("no data returned from server \(error?.localizedDescription)")
                return
            }
            guard let resp = response as? HTTPURLResponse else {
                print("no response returned from server \(error)")
                return
            }
            guard let rawJSON = try? JSONSerialization.jsonObject(with: data, options: []) as! Dictionary<String,Dictionary<String,String>> else {
                    print("data returned is not json, or not valid")
                    return
            }
            guard resp.statusCode == 200 else {
                // handle error
                print("an error occurred")
                return
            }
            let defaults = UserDefaults.standard
            defaults.set(username, forKey: "Username")
            defaults.set(password, forKey: "Password")
            defaults.set(rawJSON["user"], forKey: "user")
            
            self.dismiss(animated: true, completion: nil)
        }
        
        task.resume()
    }
}
