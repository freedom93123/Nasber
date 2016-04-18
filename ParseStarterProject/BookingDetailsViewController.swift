//
//  BookingDetailsViewController.swift
//  NasberINTIIU
//
//  Created by FOEIT on 12/04/2016.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class BookingDetailsViewController: UIViewController , UITextViewDelegate{

    var OID:String = ""
    
    @IBOutlet var origin: UITextField!
    @IBOutlet var destination: UITextField!
    @IBOutlet var meetingST: UITextField!
    @IBOutlet var meetingET: UITextField!
    @IBOutlet var username: UITextField!
    @IBOutlet var drivername: UITextField!
    @IBOutlet var driverDT: UITextField!
    @IBOutlet var driverAT: UITextField!
    @IBOutlet var tripET: UITextField!
    @IBOutlet var bookingApprovedT: UITextField!
    
    @IBOutlet var textview: UITextView!
    
    @IBAction func CancelBooking(sender: AnyObject) {
        if textview.text.isEmpty || textview.text == "Leave comment when You decide to CANCEL Booking"{
            displayAlert("Could not Cancel Booking", message: "You must leave comment if you want to cancel booking")
        } else {
            var query = PFQuery(className:"bookingRequest")
            query.getObjectInBackgroundWithId(OID) {
                (object: PFObject?, error: NSError?) -> Void in
                if error == nil && object != nil {
                    
                    object!.deleteInBackground()
                    self.displayAlert("Booking has been successfully cancelled", message: "Reason: " + self.textview.text)
                    
                } else {
                    print(error)
                }
            }
        }
    }
    
    //A general alert message which is reuseable
    func displayAlert(title: String, message: String) {
        
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        if title == "Booking has been successfully cancelled" {
            self.dismissViewControllerAnimated(false, completion: nil)
        } else {
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textview.text = "Leave comment when You decide to CANCEL Booking"
        textview.textColor = UIColor.lightGrayColor()
        textview.delegate = self
       
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        var query = PFQuery(className:"bookingRequest")
        query.getObjectInBackgroundWithId(OID) {
            (object: PFObject?, error: NSError?) -> Void in
                if error == nil && object != nil {
                    
                    let formatter = NSDateFormatter()
                    formatter.dateStyle = .ShortStyle
                    formatter.timeStyle = .ShortStyle
                    
                    self.origin.text = "Origin: \(object!["origin"] as! String)"
                    self.origin.enabled = false
                    self.destination.text = "Destination: \(object!["destination"] as! String)"
                    self.destination.enabled = false
                    self.meetingST.text = "Meeting Start: " + formatter.stringFromDate(object!["meetingST"] as! NSDate)
                    self.meetingST.enabled = false
                    self.meetingET.text = "Meeting End: " + formatter.stringFromDate(object!["meetingET"] as! NSDate)
                    self.meetingET.enabled = false
                    self.username.text = "Ridername: \(object!["username"] as! String)"
                    self.username.enabled = false
                    self.drivername.text = "Drivername: \(object!["driverResponsible"] as! String)"
                    self.drivername.enabled = false
                    self.driverDT.text = "Driver will depart at: " + formatter.stringFromDate(object!["driverDepartTime"] as! NSDate)
                    self.driverDT.enabled = false
                    self.driverAT.text = "Driver will arrive at: " + formatter.stringFromDate(object!["driverArrivalTime"] as! NSDate)
                    self.driverAT.enabled = false
                    self.tripET.text = "Round trip end at: " + formatter.stringFromDate(object!["tripEndTime"] as! NSDate)
                    self.tripET.enabled = false
                    self.bookingApprovedT.text = "Request made at: " + formatter.stringFromDate((object!.createdAt)!)
                    self.bookingApprovedT.enabled = false

                } else {
                    print(error)
                }
        }
        // Do any additional setup after loading the view.
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textview.textColor == UIColor.lightGrayColor() {
            textview.text = nil
            textview.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textview.text.isEmpty {
            textview.text = "Leave comment when You decide to CANCEL Booking"
            textview.textColor = UIColor.lightGrayColor()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
/*
    @IBAction func navigationBtn(sender: AnyObject) {
        //navigate to the origin location on driver app
        //create CLLocation
        self.requestCLLocation = CLLocation(latitude: self.requestLocation.latitude, longitude: self.requestLocation.longitude)
        //Create a placemark from location
        CLGeocoder().reverseGeocodeLocation(self.requestCLLocation, completionHandler: { (placemarks, error) -> Void in
            
            if error != nil {
                print(error!)
                
            } else {
                
                if placemarks!.count > 0 {
                    
                    let pm = placemarks![0] as! CLPlacemark
                    
                    let mkPm = MKPlacemark(placemark: pm)
                    
                    //Map request and use the placemark to navigate to rider location
                    var mapItem = MKMapItem(placemark: mkPm)
                    
                    mapItem.name = self.requestUsername
                    
                    var launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                    
                    mapItem.openInMapsWithLaunchOptions(launchOptions)
                    
                    
                } else {
                    print("Problem with the data received from geocoder")
                }
                
            }
            
        })
        
    }*/
    
    @IBAction func callBtn(sender: AnyObject) {
        
        var query:PFQuery = PFUser.query()!
        if PFUser.currentUser()?.username != nil {
            query.whereKey("username", equalTo:PFUser.currentUser()!.username!)
            query.findObjectsInBackgroundWithBlock {
                
                (objects: [AnyObject]?, error: NSError?) -> Void in
                
                if error == nil {
                   
                    if let objects = objects as? [PFObject] {
                        
                        for object in objects {
                            
                            if object["isDriver"] as! Bool == true {
                                
                                var query:PFQuery = PFUser.query()!
                                if PFUser.currentUser()?.username != nil {
                                    query.whereKey("username", equalTo:self.username.text!)
                                    query.findObjectsInBackgroundWithBlock {
                                        
                                        (objects: [AnyObject]?, error: NSError?) -> Void in
                                        
                                        if error == nil {
                                            
                                            if let objects = objects as? [PFObject] {
                                                
                                                for object in objects {
                                                    let contactNo = object["contactNo"] as! String
                                                    var url:NSURL = NSURL(string:"tel://"+contactNo)!
                                                    UIApplication.sharedApplication().openURL(url)
                                                }
                                            }
                                        }
                                    }
                                }
                            //if object["isDriver"] == true
                            } else {
                                var query:PFQuery = PFUser.query()!
                                if PFUser.currentUser()?.username != nil {
                                    query.whereKey("username", equalTo:self.drivername.text!)
                                    query.findObjectsInBackgroundWithBlock {
                                        
                                        (objects: [AnyObject]?, error: NSError?) -> Void in
                                        
                                        if error == nil {
                                            
                                            if let objects = objects as? [PFObject] {
                                                
                                                for object in objects {
                                                    let contactNo = object["contactNo"] as! String
                                                    var url:NSURL = NSURL(string:"tel://"+contactNo)!
                                                    UIApplication.sharedApplication().openURL(url)
                                                }
                                            }
                                        }
                                    }
                                }

                            }//if object["isDriver"] == false
                            
                        }
                    }
                }
            }
        }
    }
    
    func dismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    func textFieldShouldReturn(textView: UITextView) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y -= keyboardSize.height
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
