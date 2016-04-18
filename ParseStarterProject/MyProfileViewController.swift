//
//  MyProfileViewController.swift
//  ParseStarterProject
//
//  Created by FOEIT on 3/28/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Parse
import UIKit

class MyProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var profilePic: UIImageView!
    
    @IBOutlet var username: UITextField!
    
    @IBOutlet var contactNo: UITextField!
    
    @IBOutlet var emailAddress: UITextField!
    
    @IBOutlet var notificationToggle: UISwitch!
    
    //A general alert message which is reuseable
    func displayAlert(title: String, message: String) {
        
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

    
    @IBAction func saveButton(sender: AnyObject) {
        var query:PFQuery = PFUser.query()!
        if PFUser.currentUser()?.username != nil {
            query.whereKey("username", equalTo:PFUser.currentUser()!.username!)
            query.findObjectsInBackgroundWithBlock {
                
                (objects: [AnyObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    
                    if let objects = objects as? [PFObject] {
                        
                        for object in objects {
                            
                            //when updating a object, the objectId is required
                            var query:PFQuery = PFUser.query()!
                            query.getObjectInBackgroundWithId(object.objectId!) {
                                (object: PFObject?, error: NSError?) -> Void in
                                if error != nil {
                                    print(error)
                                } else if let object = object {
                            
                            //validate new contact number
                            let checkPhone = self.isValidPhone(self.contactNo.text!)
                            if checkPhone == false {
                                self.displayAlert("Invalid Phone number", message: "Please enter a valid number")
                            } else {
                                object["contactNo"] = Int(self.contactNo.text!)
                            }
                            
                            //validate new email address
                            let checkEmail = self.isValidEmail(self.emailAddress.text!)
                            if checkEmail == true || self.emailAddress.text == "" {
                                object["email"] = self.emailAddress.text
                            } else {
                                self.displayAlert("Invalid Email Address", message: "Please enter a valid email address")
                                    }
                            //Update profile pic on parse
                            if self.profilePic.image == nil {
                                print("Image is not uploaded")
                            } else {
                                var imageData = UIImageJPEGRepresentation(self.profilePic.image!,0.5)
                                var parseImageFile = PFFile(name:"profileIMG.jpeg", data:  imageData!)
                                object["imageFile"] = parseImageFile
                            }
                                    
                                    object.saveInBackgroundWithBlock {
                                        (success: Bool, error: NSError?) -> Void in
                                        if (success) {
                                            // The object has been saved.
                                            self.displayAlert("Saved sucessfully", message: "The data has been updated")
                                        } else {
                                            // There was a problem, check error.description
                                            self.displayAlert("Fail to save the data", message: (error?.description)!)
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    print(error)
                }
            }
        }
        
    }
    
    @IBAction func resetPassword(sender: AnyObject) {
    }
    
    func imageTapped(gesture:UIGestureRecognizer){
        if let profilePic = gesture.view as? UIImageView {
            var myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(myPickerController, animated:true, completion: nil)
        }
    }
    
    //Set image to profile image
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        profilePic.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    //Validate email address
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    //Validate phone number
    func isValidPhone(value: String) -> Bool {
        
        let PHONE_REGEX = "^6?01\\d{8}$"
        
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        
        let result =  phoneTest.evaluateWithObject(value)
        
        return result
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("imageTapped:"))
        
        profilePic.layer.borderWidth = 1.0
        profilePic.layer.masksToBounds = false
        profilePic.layer.borderColor = UIColor.whiteColor().CGColor
        profilePic.layer.cornerRadius = profilePic.frame.size.width/2
        profilePic.clipsToBounds = true
        profilePic.userInteractionEnabled = true
        profilePic.addGestureRecognizer(tapGestureRecognizer)
        
        
        //dismiss the keyboard when tap on the screen
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        
        var query:PFQuery = PFUser.query()!
        if PFUser.currentUser()?.username != nil {
            query.whereKey("username", equalTo:PFUser.currentUser()!.username!)
            query.findObjectsInBackgroundWithBlock {
                
                (objects: [AnyObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    
                    if let objects = objects as? [PFObject] {
                        
                        for object in objects {
      
                            self.username.text = object["username"] as! String
                            self.username.enabled = false
                            self.contactNo.text = "\(object["contactNo"]!)"
                            if object["email"] != nil {
                                self.emailAddress.text = object["email"] as! String
                            }
                            
                            //Display profile picture which store in parse Database
                            if object["imageFile"] != nil {
                                var userProfilePic = object["imageFile"]
                                userProfilePic!.getDataInBackgroundWithBlock {(imageData:NSData?,error:NSError?) -> Void in
                                    if error == nil {
                                        self.profilePic.image = UIImage(data: imageData!)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    print(error)
                }
            }
        }
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
    
    override func viewWillAppear(animated: Bool) {
            }
    
}

