//
//  RiderViewController.swift
//  ParseStarterProject
//
//  Created by Rob Percival on 07/07/2015.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit

class RiderViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    //declaration of IBOutlet which allow to change the content of UI element with code
    @IBOutlet var callNasberButton: UIButton!
    @IBOutlet var map: MKMapView!
    
    var riderRequestActive = false
    var driverOnTheWay = false
    
    var locationManager:CLLocationManager!
    
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    
    //declaration of IBAction which allow code to run when a button is tapped
    //riderRequest for ride and store the username & location on parse
    @IBAction func callUber(sender: AnyObject) {
        
        if riderRequestActive == false {
        
        var riderRequest = PFObject(className:"riderRequest")
        riderRequest["username"] = PFUser.currentUser()?.username
        riderRequest["location"] = PFGeoPoint(latitude:latitude, longitude:longitude)
        
        
        riderRequest.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                
                self.callNasberButton.setTitle("Cancel Nasber", forState: UIControlState.Normal)
                
                
                
            } else {
               
                var alert = UIAlertController(title: "Could not call Nasber", message: "Please try again!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
                
            }
        }
            
            riderRequestActive = true
            
        
        } else {
            
            self.callNasberButton.setTitle("Call an Nasber", forState: UIControlState.Normal)
            
            riderRequestActive = false
            
            //find whether the current username are in the request list or not
            var query = PFQuery(className:"riderRequest")
            query.whereKey("username", equalTo:PFUser.currentUser()!.username!)
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    
                    print("Successfully retrieved \(objects!.count) scores.")
                    
                    
                    if let objects = objects as? [PFObject] {
                        
                        for object in objects {
                            
                            
                            object.deleteInBackground()

                        }
                    }
                } else {
                    
                    print(error)
                }
            }

            
        }
    }
    

    @IBAction func newBookingRequest(sender: AnyObject) {
        let backItem = UIBarButtonItem()
        backItem.title = "Nasber"
        navigationItem.backBarButtonItem = backItem

    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization() //prompt user to give authorization to access location tracking
        locationManager.startUpdatingLocation()
        

    }
    
    
    //Display location on Mapkit and update the location always
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        var location:CLLocationCoordinate2D = manager.location!.coordinate
        
        //auto update on latitude and longitude
        self.latitude = location.latitude
        self.longitude = location.longitude
        
        //use to display location by searching driver location
        var query = PFQuery(className:"riderRequest")
        
        if PFUser.currentUser()?.username != nil {
        query.whereKey("username", equalTo:PFUser.currentUser()!.username!)
        
        query.findObjectsInBackgroundWithBlock {
            
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                
                if let objects = objects as? [PFObject] {
                    
                    
                    for object in objects {
                        
                        //use to display location of rider and driver if the request is responded
                        if let driverUsername = object["driverResponded"] {
                            
                            var query = PFQuery(className:"driverLocation")
                            query.whereKey("username", equalTo:driverUsername)
                            
                            query.findObjectsInBackgroundWithBlock {
                                
                                (objects: [AnyObject]?, error: NSError?) -> Void in
                                
                                if error == nil {
                                    
                                    
                                    if let objects = objects as? [PFObject] {
                                        
                                        
                                        for object in objects {
                                            
                                            if let driverLocation = object["driverLocation"] as? PFGeoPoint {
                                                
                                                //Convert to CLLocation
                                                let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                                                let userCLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                                                
                                                let distanceMeters = userCLLocation.distanceFromLocation(driverCLLocation)
                                                let distanceKM = distanceMeters / 1000
                                                let roundedTwoDigitDistance = Double(round(distanceKM * 10) / 10)
                                                
                                                self.callNasberButton.setTitle("Driver is \(roundedTwoDigitDistance)km away!", forState: UIControlState.Normal)
                                                
                                                self.driverOnTheWay = true
                                                
                                                let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                                                
                                                //absolute value in order to make two pin fixed inside the map
                                                let latDelta = abs(driverLocation.latitude - location.latitude) * 2 + 0.005
                                                let lonDelta = abs(driverLocation.longitude - location.longitude) * 2 + 0.005
                                                
                                                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
                                                
                                                self.map.setRegion(region, animated: true)
                                                
                                                
                                                self.map.removeAnnotations(self.map.annotations)
                                                
                                                //Display rider pin on the map
                                                var pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                                                var objectAnnotation = MKPointAnnotation()
                                                objectAnnotation.coordinate = pinLocation
                                                objectAnnotation.title = "Your location"
                                                self.map.addAnnotation(objectAnnotation)
                                                
                                                //Display driver pin on the map
                                                pinLocation = CLLocationCoordinate2DMake(driverLocation.latitude, driverLocation.longitude)
                                                objectAnnotation = MKPointAnnotation()
                                                objectAnnotation.coordinate = pinLocation
                                                objectAnnotation.title = "Driver location"
                                                self.map.addAnnotation(objectAnnotation)
                                                
                                                
                                                
                                            }
                                        }
                                    }
                                }
                            }
                            
                            
                            
                            
                            
                            
                            
                            
                        }
                        
                    }
                }
            }
        }
        }
        
        
        
        
        
        if (driverOnTheWay == false) {
            
            let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            self.map.setRegion(region, animated: true)
            
            //Display pin on the map
            self.map.removeAnnotations(map.annotations)
            
            //Display pin on the map
            var pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.latitude, location.longitude)
            var objectAnnotation = MKPointAnnotation()
            objectAnnotation.coordinate = pinLocation
            objectAnnotation.title = "Your location"
            self.map.addAnnotation(objectAnnotation)
            
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //logout segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "logoutRider" {
            
            navigationController?.setNavigationBarHidden(navigationController?.navigationBarHidden == false, animated: false)
            PFUser.logOut()
            
        }
    }
}
