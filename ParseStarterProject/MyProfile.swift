//
//  MyProfile.swift
//  ParseStarterProject
//
//  Created by FOEIT on 3/27/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class MyProfile: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var profilePic: UIImageView!
    
    @IBOutlet var username: UITextField!
    
    @IBOutlet var contactNo: UITextField!
    
    @IBOutlet var emailAddress: UITextField!
    
    @IBOutlet var notificationToggle: UISwitch!
    
    @IBAction func saveButton(sender: AnyObject) {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //dismiss the keyboard when tap on the screen
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
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
    
    override func viewDidAppear(animated: Bool) {
        //var query
    }
}
