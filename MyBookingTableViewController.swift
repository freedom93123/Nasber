//
//  MyBookingTableViewController.swift
//  NasberINTIIU
//
//  Created by FOEIT on 11/04/2016.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class MyBookingTableViewController: UITableViewController {

    var imgarray:[AnyObject] = [AnyObject]()
    var drivernamearray = [String]()
    var DriverArrivalTime:[NSDate] = [NSDate]()
    var meetingStartTimearray:[NSDate] = [NSDate]()
    var pickUpLocarray  = [String]()
    var objectID = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.reloadData()
        
        if PFUser.currentUser()?.username != nil {
            var query = PFQuery(className:"bookingRequest")
            query.whereKey("username", equalTo:(PFUser.currentUser()?.username)!)
            query.findObjectsInBackgroundWithBlock {
                
                (objects: [AnyObject]?, error: NSError?) -> Void in
                
                if let objects = objects as? [PFObject] {
                    
                    var objectCount = 0
                    self.imgarray.removeAll()
                    self.drivernamearray.removeAll()
                    self.DriverArrivalTime.removeAll()
                    self.meetingStartTimearray.removeAll()
                    self.pickUpLocarray.removeAll()
                    
                    for object in objects {
                        self.drivernamearray.append(object["driverResponsible"] as! String)
                        self.DriverArrivalTime.append(object["driverArrivalTime"] as! NSDate)
                        self.meetingStartTimearray.append(object["meetingST"] as! NSDate)
                        self.pickUpLocarray.append(object["origin"] as! String)
                        self.objectID.append(object.objectId! as String)
                        //Bug: Cannot save the image file in the imgarray
                        /*
                        var query:PFQuery = PFUser.query()!
                        if PFUser.currentUser()?.username != nil {
                            query.whereKey("username", equalTo:self.drivernamearray[objectCount])
                            query.findObjectsInBackgroundWithBlock {
                                
                                (objects: [AnyObject]?, error: NSError?) -> Void in
                                
                                if error == nil {
                                    
                                    if let objects = objects as? [PFObject] {
                                        
                                        for object in objects {
                                            
                                            //Display profile picture which store in parse Database
                                            if object["imageFile"] != nil {
                                                var profilePic = object["imageFile"]
                                                self.imgarray.append(profilePic!)
                                            }
                                            //print(self.imgarray.count)
                                        }
                                    }
                                } else {
                                    print(error)
                                }
                            }
                        }*/
                        objectCount = objectCount+1;
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        return self.drivernamearray.count
    }
    
    //Bug: This func is not called previously due to the imgarray is empty, code can run but the table cannot be displayed.
    //Debugging tableView
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)as! MyBookingTableViewCell
        //print(self.imgarray.count)
        
       /* self.imgarray[indexPath.row].getDataInBackgroundWithBlock {(imageData:NSData?,error:NSError?) -> Void in
            if error == nil {
                cell.profilePic.image = UIImage(data: imageData!)
                
            }
        }*/
        
        let formatter = NSDateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("ddMMMhmma")
        //formatter.dateStyle = .ShortStyle
        //formatter.timeStyle = .ShortStyle
        
        cell.drivername.text = self.drivernamearray[indexPath.row]
        cell.driverArrivalTime.text = "will arrive at " + formatter.stringFromDate(self.DriverArrivalTime[indexPath.row])
        cell.meetingStartTime.text = "Meeting Time: "+formatter.stringFromDate(self.meetingStartTimearray[indexPath.row])
        var itemname = self.pickUpLocarray[indexPath.row].componentsSeparatedByString("|")
        cell.pickUpLocation.text = "Pick Up Location: " + itemname[0]
        
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
        if segue.identifier == "showBookingDetails" {
            
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            
            //Casting as RequestViewController allow the passing var of location and usernames to the segue
            if let destination = segue.destinationViewController as? BookingDetailsViewController {
                print(objectID)
                destination.OID = objectID[(tableView.indexPathForSelectedRow?.row)!]
            }
            
        }
    }
    

}
