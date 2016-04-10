//
//  RequestViewController.swift
//  ParseStarterProject
//
//  Created by FOEIT on 2/17/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import MapKit
import Parse


class RequestViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet var map: MKMapView!

    @IBAction func pickUpRider(sender: AnyObject) {
    
    //find the particular request
    var query = PFQuery(className:"riderRequest")
    query.whereKey("username", equalTo:requestUsername)
    query.findObjectsInBackgroundWithBlock {
        (objects: [AnyObject]?, error: NSError?) -> Void in
    
        if error == nil {
    
        print("Successfully retrieved \(objects!.count) scores.")
    
    
        if let objects = objects as? [PFObject] {
    
            for object in objects {
                
                //when updating a object, the objectId is required
                var query = PFQuery(className:"riderRequest")
                query.getObjectInBackgroundWithId(object.objectId!) {
                    (object: PFObject?, error: NSError?) -> Void in
                    if error != nil {
                        print(error)
                    } else if let object = object {
                        
                        //update the object so that it is responded by driver
                        object["driverResponded"] = PFUser.currentUser()!.username!
                        
                        object.saveInBackground()
                        
                        //navigate to the rider location on driver app
                        //create CLLocation
                        let requestCLLocation = CLLocation(latitude: self.requestLocation.latitude, longitude: self.requestLocation.longitude)
                        
                        //Create a placemark from location
                        CLGeocoder().reverseGeocodeLocation(requestCLLocation, completionHandler: { (placemarks, error) -> Void in
                            
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
                        
                    }
                }
                
            }
            }
    } else {
    
            print(error)
        }
    }

    }
    
    
    var requestLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(0,0)
    var requestUsername:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(requestUsername)
        print(requestLocation)
        
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.setRegion(region, animated: true)
        
        //remove annotations from map
        self.map.removeAnnotations(map.annotations)
        
        //Display pin on the map

        var objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = requestLocation
        objectAnnotation.title = requestUsername
        self.map.addAnnotation(objectAnnotation)


        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
