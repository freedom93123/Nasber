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

class DriverViewController: UITableViewController, CLLocationManagerDelegate{

    var usernames = [String]()
    var locations = [CLLocationCoordinate2D]()
    var distances = [CLLocationDistance]()
    
    var locationManager:CLLocationManager!
    
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization() //prompt user to give authorization to access location tracking
        locationManager.startUpdatingLocation()

    }
        

    

    //Display location on Mapkit and update the location always
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        var location:CLLocationCoordinate2D = manager.location!.coordinate
        
        //auto update on latitude and longitude
        self.latitude = location.latitude
        self.longitude = location.longitude
        
        print("locations = \(location.latitude) \(location.longitude)")
        
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
                
                print("Successfully retrieved \(objects!.count) scores.")
                
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
                    
                    for object in objects {
                        
                        //so that the request which driver has already responded will not be displayed
                        if object["driverResponded"] == nil {
                        
                        if let username = object["username"] as? String{
                            
                            self.usernames.append(username)
                        }
                        
                        if let returnedlocation = object["location"] as? PFGeoPoint{
                            
                            let requestLocation = CLLocationCoordinate2DMake(returnedlocation.latitude, returnedlocation.longitude)
                            self.locations.append(requestLocation)
                            
                            //Convert CLLocation2D to CLLocation
                            let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
                            
                            let driverCLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                            
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
        }
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
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        // Configure the cell...
        // Convert to one decimal places
        var distanceDouble = Double(distances[indexPath.row])
        var roundedDistance = Double(round(distanceDouble * 10) / 10)
        cell.textLabel?.text = usernames[indexPath.row] + " - " + String(roundedDistance) + " km away"

        return cell
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
                
                destination.requestLocation = locations[(tableView.indexPathForSelectedRow?.row)!]
                destination.requestUsername = usernames[(tableView.indexPathForSelectedRow?.row)!]
            }
            
        }
    }
}
