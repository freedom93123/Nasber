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


class RequestViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
   
    var requestLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(0,0)
    var requestUsername:String = ""
    var driverCLLocation = CLLocation()
    var requestCLLocation = CLLocation()
    var MapItem:[(integer: Int!, mapItem: MKMapItem?)]!

    var currentDate = NSDate()
    var TTime = NSTimeInterval()

    var locationManager:CLLocationManager!
    
    @IBOutlet var map: MKMapView!
    @IBOutlet var travellingT: UILabel!
    @IBOutlet var etaLabel: UILabel!
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //Create a placemark from driverlocation
        CLGeocoder().reverseGeocodeLocation(locations.last!, completionHandler: {(placemarks:[CLPlacemark]?, error:NSError?) -> Void in
            
            if error != nil {
                print(error!)
                
            } else {
                if let placemarks = placemarks {
                    let placemark = placemarks[0]
                    
                    //Map request and use the placemark to navigate to rider location
                    //self.driverMapItem =
                    self.MapItem[0].mapItem = (MKMapItem(placemark: MKPlacemark(coordinate: placemark.location!.coordinate, addressDictionary:placemark.addressDictionary as! [String:AnyObject]?)))
                    //print(self.driverMapItem.name)
                } else {
                    print("Problem with the data received from geocoder")
                }
                
            }
            
        })
        
        //Create a placemark from requestlocation
        requestCLLocation = CLLocation(latitude: self.requestLocation.latitude, longitude: self.requestLocation.longitude)
        CLGeocoder().reverseGeocodeLocation(requestCLLocation, completionHandler: {(placemarks:[CLPlacemark]?, error:NSError?) -> Void in
            
            if error != nil {
                print(error!)
                
            } else {
                if let placemarks = placemarks {
                    let placemark = placemarks[0]
                    
                    //Map request and use the placemark to navigate to rider location
                    //self.requestMapItem =
                    self.MapItem[1].mapItem = (MKMapItem(placemark: MKPlacemark(coordinate: placemark.location!.coordinate, addressDictionary:placemark.addressDictionary as! [String:AnyObject]?)))
                } else {
                    print("Problem with the data received from geocoder")
                }
                
            }
            
        })
    }
    
    @IBAction func calculate(sender: AnyObject) {
        
        locationManager.stopUpdatingLocation()
        let request: MKDirectionsRequest = MKDirectionsRequest()
        request.source = MapItem[0].mapItem
        request.destination = MapItem[1].mapItem
        // Set requestsAlternateRoutes to true to fetch all the reasonable routes from the origin to destination.
        request.requestsAlternateRoutes = true
        // Set the transportation type to .Automobile for this particular scenario. eg .Walking and .Any
        request.transportType = .Automobile
        // Initialize an MKDirections object with the MKDirectionsRequest, then call calculateDirectionsWithCompletionHandler(_:) to get an MKDirectionsResponse containing an array of MKRoutes.
        var time:NSTimeInterval = 0
        var routes = [MKRoute]()
        let directions = MKDirections(request: request)
        directions.calculateDirectionsWithCompletionHandler ({
            (response: MKDirectionsResponse?, error: NSError?) in
            if let routeResponse = response?.routes {
                //sort the routes from least to greatest expected travel time, then pull out the first index, i.e., the index with the shortest expected travel time.
                let quickestRouteForSegment: MKRoute =
                    routeResponse.sort({$0.expectedTravelTime <
                        $1.expectedTravelTime})[0]
                routes.append(quickestRouteForSegment)
                // Add this new route’s expected travel time to the time parameter.
                time += quickestRouteForSegment.expectedTravelTime
                self.TTime = time
            }
        })
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        travellingT.text = "Travelling Time: \(stringFromTimeInterval(self.TTime))"
        etaLabel.text = "ETA: " + formatter.stringFromDate(currentDate.dateByAddingTimeInterval(self.TTime))
        
        

    }
    
    @IBAction func pickUpRider(sender: AnyObject) {
    
    //find the particular request
    var query = PFQuery(className:"riderRequest")
    query.whereKey("username", equalTo:requestUsername)
    query.findObjectsInBackgroundWithBlock {
        (objects: [AnyObject]?, error: NSError?) -> Void in
    
        if error == nil {

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
                        //Set the access control list to readable and writable
                        object["driverResponded"] = PFUser.currentUser()!.username!
                        
                        object.saveInBackgroundWithBlock {
                            (success: Bool, error: NSError?) -> Void in
                            if (success) {
                                // The object has been saved.
                                print("objectUpdated")
                            } else {
                                // There was a problem, check error.description
                               print("objectFailedToUpdate")
                            }
                        }
                        
                        //navigate to the rider location on driver app
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
                        
                    }
                }
                
            }
            }
    } else {
            print(error)
        }
    }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(requestUsername)
        print(requestLocation)
        print(driverCLLocation)
        
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.setRegion(region, animated: true)
        
        //remove annotations from map
        self.map.removeAnnotations(map.annotations)
        
        //Display pin on the map

        var objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = requestLocation
        objectAnnotation.title = requestUsername
        self.map.addAnnotation(objectAnnotation)
        
        MapItem = [(0,nil),(1,nil)]
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization() //prompt user to give authorization to access location tracking
        locationManager.startUpdatingLocation()
        // Do any additional setup after loading the view.
    }
    
        /*
    func calculateTime(var time:NSTimeInterval){
        let request: MKDirectionsRequest = MKDirectionsRequest()
        request.source = MapItem[0].mapItem
        request.destination = MapItem[1].mapItem
        // Set requestsAlternateRoutes to true to fetch all the reasonable routes from the origin to destination.
        request.requestsAlternateRoutes = true
        // Set the transportation type to .Automobile for this particular scenario. eg .Walking and .Any
        request.transportType = .Automobile
        // Initialize an MKDirections object with the MKDirectionsRequest, then call calculateDirectionsWithCompletionHandler(_:) to get an MKDirectionsResponse containing an array of MKRoutes.
        
        let directions = MKDirections(request: request)
        directions.calculateDirectionsWithCompletionHandler ({
            (response: MKDirectionsResponse?, error: NSError?) in
            if let routeResponse = response?.routes {
                //sort the routes from least to greatest expected travel time, then pull out the first index, i.e., the index with the shortest expected travel time.
                let quickestRouteForSegment: MKRoute =
                    routeResponse.sort({$0.expectedTravelTime <
                        $1.expectedTravelTime})[0]
                
                // Add this new route’s expected travel time to the time parameter.
                time += quickestRouteForSegment.expectedTravelTime
                print(time)
            }
        })
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        travellingT.text = "Travelling Time: \(self.stringFromTimeInterval(time))"
        etaLabel.text = "ETA: " + formatter.stringFromDate(self.currentDate.dateByAddingTimeInterval(self.time))
        

    }*/
    
    //Return NSTimeInterval as String
    func stringFromTimeInterval(interval:NSTimeInterval) -> NSString {
        
        var ti = NSInteger(interval)
        var seconds = ti % 60
        var minutes = (ti / 60) % 60
        var hours = (ti / 3600)
        
        return NSString(format: "%02d:%02d:%02d",hours,minutes,seconds)
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
