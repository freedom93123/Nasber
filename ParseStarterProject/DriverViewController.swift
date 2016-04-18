//
//  DriverViewController.swift
//  ParseStarterProject
//
//  Created by FOEIT on 2/16/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit

class DriverViewController: UITableViewController, SlideMenuDelegate, CLLocationManagerDelegate{

    var usernames = [String]()
    var locations = [CLLocationCoordinate2D]()
    var driverLOC = CLLocation()
    var distances = [CLLocationDistance]()
    var travellingTimeArray = [NSTimeInterval]()
    var ETAarray = [NSDate]()
    var TimeOfRequestCreated = [NSDate]()
    var driverName = [String]()
    
    var requestMapItem = MKMapItem()
    var driverMapItem = MKMapItem()
    var time = NSTimeInterval()
    let currentDate = NSDate()
    
    var locationManager:CLLocationManager!
    
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    
    override func viewDidAppear(animated: Bool) {
        self.addSlideMenuButton()
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization() //prompt user to give authorization to access location tracking
        locationManager.startUpdatingLocation()

    }

    func addSlideMenuButton(){
        let btnShowMenu = UIButton(type: UIButtonType.System)
        let image = UIImage(named: "menu.png")
        btnShowMenu.setImage(image,  forState: UIControlState.Normal)
        btnShowMenu.frame = CGRectMake(0, 0, 30, 30)
        btnShowMenu.addTarget(self, action: "onSlideMenuButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        let customBarItem = UIBarButtonItem(customView: btnShowMenu)
        self.navigationItem.leftBarButtonItem = customBarItem;
    }
    
    func slideMenuItemSelectedAtIndex(index: Int32) {
        let topViewController : UIViewController = self.navigationController!.topViewController!
        print("View Controller is : \(topViewController) \n", terminator: "")
        switch(index){
        case 0:
            print("Home\n", terminator: "")
            let DriverViewController = self.storyboard!.instantiateViewControllerWithIdentifier("DriverViewController") as UIViewController
            self.navigationController!.pushViewController(DriverViewController, animated: true)
            //tableView.contentInset = UIEdgeInsetsMake(64,0,0,0)
            break
        case 1:
            print("My Profile\n", terminator: "")
            let MyProfileViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MyProfileViewController") as UIViewController
            self.navigationController!.pushViewController(MyProfileViewController, animated: true)
            tableView.contentInset = UIEdgeInsetsMake(64,0,0,0)
            break
        case 2:
            print("Booking Requests\n", terminator: "")
            let BookingRequestsTableViewController = self.storyboard!.instantiateViewControllerWithIdentifier("DriverBookingTableViewController") as UIViewController
            self.navigationController!.pushViewController(BookingRequestsTableViewController, animated: true)
            tableView.contentInset = UIEdgeInsetsMake(64,0,0,0)
            break
        default:
            print("default\n", terminator: "")
        }
    }
    
    func onSlideMenuButtonPressed(sender : UIButton){
        tableView.contentInset = UIEdgeInsetsZero
        if (sender.tag == 10)
        {
            tableView.contentInset = UIEdgeInsetsMake(64,0,0,0)
            // To Hide Menu If it already there
            self.slideMenuItemSelectedAtIndex(-1);
            //tableView.contentInset =
            
            sender.tag = 0;
            
            let viewMenuBack : UIView = view.subviews.last!
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                var frameMenu : CGRect = viewMenuBack.frame
                frameMenu.origin.x = -1 * UIScreen.mainScreen().bounds.size.width
                viewMenuBack.frame = frameMenu
                viewMenuBack.layoutIfNeeded()
                viewMenuBack.backgroundColor = UIColor.clearColor()
                }, completion: { (finished) -> Void in
                    viewMenuBack.removeFromSuperview()
            })
            
            return
        }
        
        sender.enabled = false
        sender.tag = 10
        
        let menuVC : MenuViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MenuViewController") as! MenuViewController
        menuVC.btnMenu = sender
        menuVC.delegate = self
        self.view.addSubview(menuVC.view)
        self.addChildViewController(menuVC)
        menuVC.view.layoutIfNeeded()
        menuVC.view.frame=CGRectMake(0 - UIScreen.mainScreen().bounds.size.width, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height);
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            menuVC.view.frame=CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height);
            menuVC.view.backgroundColor = UIColor.clearColor()
            sender.enabled = true
            }, completion:nil)
    }

    //create custom annotation to override the old pin image annotation
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if !(annotation is CustomPointAnnotation) {
            return nil
        }
        
        let reuseId = "driverAnnotation"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = true
        }
        else {
            anView!.annotation = annotation
        }
        
        //Set annotation-specific properties **AFTER**
        //the view is dequeued or created...
        
        let cpa = annotation as! CustomPointAnnotation
        anView!.image = UIImage(named:cpa.imageName)
        
        return anView
    }

    //Display location on Mapkit and update the location always
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        var location:CLLocationCoordinate2D = manager.location!.coordinate
        
        //auto update on latitude and longitude
        self.latitude = location.latitude
        self.longitude = location.longitude
        
        //print("locations = \(location.latitude) \(location.longitude)")
        
        var query = PFQuery(className:"driverLocation")
        
        //find all of the request that driver responded
        //driver username
        var currentUser = PFUser.currentUser()
        if currentUser != nil {
            if PFUser.currentUser()?.username != nil {
        query.whereKey("username", equalTo:PFUser.currentUser()!.username!)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                //if there is driver location on the parse
                if let objects = objects as? [PFObject] {
                    
                    if objects.count > 0 {
                    
                    for object in objects {
                        
                        //when updating a object, the objectId is required
                        var query = PFQuery(className:"driverLocation")
                        query.getObjectInBackgroundWithId(object.objectId!) {
                            (object: PFObject?, error: NSError?) -> Void in
                            if error != nil {
                                print(error)
                            } else if let object = object {
                                
                                //update the driver location to parse
                                self.driverLOC = CLLocation(latitude: location.latitude, longitude: location.longitude)
                                object["driverLocation"] = PFGeoPoint(latitude:location.latitude, longitude:location.longitude)
                                
                                object.saveInBackground()
                            }
                            }
                            }
                    } else {
                    
                    //if there is no driver location on the parse, create the class of driverLocation
                    var driverLocation = PFObject(className:"driverLocation")
                    driverLocation["username"] = PFUser.currentUser()?.username
                    driverLocation["driverLocation"] = PFGeoPoint(latitude:location.latitude, longitude:location.longitude)
                    
                    
                    driverLocation.saveInBackground()
                    
                            }
        } else {
                
                print(error)
            }
                }//if PFUser=nil
            }
        var query = PFQuery(className:"riderRequest")

        //use to find closest object to the driver
        query.whereKey("location", nearGeoPoint:PFGeoPoint(latitude:location.latitude, longitude:location.longitude))
        query.limit = 10
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {

                if let objects = objects as? [PFObject] {
                    
                    self.usernames.removeAll()
                    self.locations.removeAll()
                    self.distances.removeAll()
                    self.travellingTimeArray.removeAll()
                    self.ETAarray.removeAll()
                    self.TimeOfRequestCreated.removeAll()
                    self.driverName.removeAll()
                    
                    for object in objects {
                        
                        //so that the request which driver has already responded will not be displayed
                        if object["driverResponded"] == nil {
                        
                        if let username = object["username"] as? String{
                            self.driverName.append(" - ")
                            self.usernames.append(username)
                            
                            
                        } /*else {
                            self.driverName.append(object["driverResponded"] as! String)
                            
                            //delete object if driver responded to the rider quick request
                             object.deleteInBackground()
                                print("objectDeleted")
 
                            }*/
                        
                        if let returnedlocation = object["location"] as? PFGeoPoint{
                            
                            let requestLocation = CLLocationCoordinate2DMake(returnedlocation.latitude, returnedlocation.longitude)
                            self.locations.append(requestLocation)
                            
                            //Convert CLLocation2D to CLLocation
                            let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
                            
                            let driverCLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                            
                            /*Error occur due to exceeding request rate
                            //Create a placemark from requestlocation
                            CLGeocoder().reverseGeocodeLocation(requestCLLocation, completionHandler: {(placemarks:[CLPlacemark]?, error:NSError?) -> Void in
                                
                                if error != nil {
                                    print(error!)
                                    
                                } else {
                                    if let placemarks = placemarks {
                                        let placemark = placemarks[0]
                                        
                                        //Map request and use the placemark to navigate to rider location
                                        self.requestMapItem = MKMapItem(placemark: MKPlacemark(coordinate: placemark.location!.coordinate, addressDictionary:placemark.addressDictionary as! [String:AnyObject]?))
                                    } else {
                                        print("Problem with the data received from geocoder")
                                    }
                                    
                                }
                                
                            })
                            
                            //Create a placemark from driverlocation
                            CLGeocoder().reverseGeocodeLocation(driverCLLocation, completionHandler: {(placemarks:[CLPlacemark]?, error:NSError?) -> Void in
                                
                                if error != nil {
                                    print(error!)
                                    
                                } else {
                                    if let placemarks = placemarks {
                                        let placemark = placemarks[0]
                                        
                                        //Map request and use the placemark to navigate to rider location
                                        self.driverMapItem = MKMapItem(placemark: MKPlacemark(coordinate: placemark.location!.coordinate, addressDictionary:placemark.addressDictionary as! [String:AnyObject]?))
                                    } else {
                                        print("Problem with the data received from geocoder")
                                    }
                                    
                                }
                                
                            })*/


                            // Create an MKDirectionsRequest by setting the MKMapItem  as the origin and setting the MKMapItem as the destination.
                            let request: MKDirectionsRequest = MKDirectionsRequest()
                            request.source = self.driverMapItem
                            request.destination = self.requestMapItem
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
                                   self.time += quickestRouteForSegment.expectedTravelTime
                                }
                            })
                            
                            self.travellingTimeArray.append(self.time)
                            self.ETAarray.append(self.currentDate.dateByAddingTimeInterval(self.time))
                            //save the time of request made
                            self.TimeOfRequestCreated.append(object.createdAt!)
                                    
                            let distance = driverCLLocation.distanceFromLocation(requestCLLocation)
                            
                            self.distances.append(distance/1000)
                        }
                        
                        self.tableView.reloadData()
                        
                    }
                    }
                }
            } else {
                
                print(error)
            }
        }
        }//query declaration
    }//if current user is nil do ^^^^
    }




    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }

    //Table Loading Code
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! MyBookingTableViewCell

        // Configure the cell...
        // Convert to one decimal places
        var distanceDouble = Double(distances[indexPath.row])
        var roundedDistance = Double(round(distanceDouble * 10) / 10)
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        
        cell.QRusername.text = usernames[indexPath.row]
        cell.RequestTime.text = "Request Time: " + formatter.stringFromDate(TimeOfRequestCreated[indexPath.row])
        cell.distance.text = " is " + String(roundedDistance) + " km away"
        cell.driverResponded.text = "Driver Responded: " + driverName[indexPath.row]
        //cell.travellingTime.text = "Travelling Time: \(stringFromTimeInterval(self.travellingTimeArray[indexPath.row]))"
        //cell.ETA.text = formatter.stringFromDate(ETAarray[indexPath.row])
        
        return cell
    }
    
    //Return NSTimeInterval as String
    func stringFromTimeInterval(interval:NSTimeInterval) -> NSString {
        
        var ti = NSInteger(interval)
        var seconds = ti % 60
        var minutes = (ti / 60) % 60
        var hours = (ti / 3600)
        
        return NSString(format: "%02d:%02d:%02d",hours,minutes,seconds)
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //logout segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "logoutDriver" {
            
            //Hide navigation bar
            navigationController?.setNavigationBarHidden(navigationController?.navigationBarHidden == false, animated: false)
            
            PFUser.logOut()
            
        } else if segue.identifier == "showViewRequests" {
            
                let backItem = UIBarButtonItem()
                backItem.title = "Back"
                navigationItem.backBarButtonItem = backItem
            
            //Casting as RequestViewController allow the passing var of location and usernames to the segue
            if let destination = segue.destinationViewController as? RequestViewController {
                locationManager.stopUpdatingLocation()
                destination.driverCLLocation = driverLOC
                destination.requestLocation = locations[(tableView.indexPathForSelectedRow?.row)!]
                destination.requestUsername = usernames[(tableView.indexPathForSelectedRow?.row)!]
            }
            
        }
    }
}
