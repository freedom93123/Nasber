//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController, UITextFieldDelegate {
    
    //A general alert message which is reuseable
    func displayAlert(title: String, message: String) {
        
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    

    @IBOutlet var contactno: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var username: UITextField!
    var signUpState = true
    
    //declaration of IBOutlet which allow to change the content of UI element with code

    @IBOutlet var riderLabel: UILabel!
    @IBOutlet var driverLabel: UILabel!
    @IBOutlet var `switch`: UISwitch!
    
    //Checking and navigate to loginRider interface once the button is tapped
    @IBAction func signUp(sender: AnyObject) {
        
        /*if username.text == "" || password.text == "" || contactno.text == "" {
            
            displayAlert("Missing Field(s)", message: "Username, password and contact number are required")
            
        } else { */
            
        //if the user haven't sign up
        
            if signUpState == false {
                
                if username.text == "" || password.text == "" || contactno.text == "" {
                    
                    displayAlert("Missing Field(s)", message: "Username, password and contact number are required")
                    
                } else if contactno.text != "" {
                    
                    let checkPhone = isValidPhone(contactno.text!)
                    if checkPhone == false {
                        displayAlert("Invalid Phone number", message: "Please enter a valid number")
                    }
                
                } else {
                
                var user = PFUser()
                user.username = username.text
                user.password = password.text
                user["contactNo"] = Int(contactno.text!)

            
                user["isDriver"] = `switch`.on
            
                user.signUpInBackgroundWithBlock {
                    (succeeded: Bool, error: NSError?) -> Void in
                    if let error = error {
                        if let errorString = error.userInfo["error"] as? String {
                    
                            self.displayAlert("Sign Up Failed", message: errorString)
                    
                        }
                    
                    
                    } else {
                        
                        if self.`switch`.on == true {
                            
                            self.performSegueWithIdentifier("loginDriver", sender: self)
                        } else {
                    
                        self.performSegueWithIdentifier("loginRider", sender: self)  // Call up another Interface
                            
                        }
                    
                    }
                    }
                    
                }
                
            } else {
                
                if username.text == "" || password.text == "" {
                    
                    displayAlert("Missing Field(s)", message: "Username and password are required")
                    
                } else {
                
                //if the user already signup and go for login, checking on query will be done
                PFUser.logInWithUsernameInBackground(username.text!, password:password.text!) {
                    (user: PFUser?, error: NSError?) -> Void in
                    if let user = user {
                        
                        if user["isDriver"]! as! Bool == true {
                            
                            self.performSegueWithIdentifier("loginDriver", sender: self)
                            
                        } else {
                            
                            self.performSegueWithIdentifier("loginRider", sender: self)  // Call up another Interface
                            
                        }
                        
                        
                    } else {
                        
                        if let errorString = error?.userInfo["error"] as? String {
                            
                            self.displayAlert("Login Failed", message: errorString)
                            
                        }
                        
                    }
                }
                
            }
            
        }
        
        
    }
    
    @IBOutlet var signUpButton: UIButton!
    
    //Toggle signup button text once it is tapped
    @IBAction func toggleSignup(sender: AnyObject) {
        
        if signUpState == true {
            
            signUpButton.setTitle("Sign Up", forState: UIControlState.Normal)
            
            toggleSignupButton.setTitle("BACK to Login", forState: UIControlState.Normal)
            
            signUpState = false
            
            contactno.alpha = 1
            riderLabel.alpha = 1
            driverLabel.alpha = 1
            `switch`.alpha = 1
            
            //make the labels invisible
            
        } else {
            
            signUpButton.setTitle("Login", forState: UIControlState.Normal)
            
            toggleSignupButton.setTitle("GO to Sign Up", forState: UIControlState.Normal)
            
            signUpState = true
            
            contactno.alpha = 0
            riderLabel.alpha = 0
            driverLabel.alpha = 0
            `switch`.alpha = 0
            
            //make the labels visible
            
        }
        
        
    }
    
    //Validate phone number
    func isValidPhone(value: String) -> Bool {
        
        let PHONE_REGEX = "^\\+\\d{3}-\\d{2}-\\d{7}$"
        
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        
        let result =  phoneTest.evaluateWithObject(value)
        
        return result
        
    }
    
    @IBOutlet var toggleSignupButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        //dismiss the keyboard when tap on the screen
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.username.delegate = self;
        self.password.delegate = self;
        self.contactno.delegate = self;
        contactno.alpha = 0
        riderLabel.alpha = 0
        driverLabel.alpha = 0
        `switch`.alpha = 0
        
    }
    
    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidAppear(animated: Bool) {              //perform checking before viewDidLoad to ensure correct segue without prompting the user to enter the username and password again
        
        if PFUser.currentUser()?.username != nil {

            if PFUser.currentUser()?["isDriver"]! as! Bool == true {
                
                self.performSegueWithIdentifier("loginDriver", sender: self)
                
            } else {
                
                self.performSegueWithIdentifier("loginRider", sender: self)  // Call up another Interface
                
            }

            
        }
        
    }
    
    
}

