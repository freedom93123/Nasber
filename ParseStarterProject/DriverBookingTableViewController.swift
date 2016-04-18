//
//  DriverBookingTableViewController.swift
//  NasberINTIIU
//
//  Created by FOEIT on 11/04/2016.
//  Copyright © 2016 Parse. All rights reserved.
//

import Parse
import UIKit

class DriverBookingTableViewController: UITableViewController {
    
    var usernamearray = [String]()
    var departTimeArray = [NSDate]()
    var DVpickUpLocArray = [String]()
    var destinationArray = [String]()
    var objectID = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.reloadData()
        
        if PFUser.currentUser()?.username != nil {
            var query = PFQuery(className:"bookingRequest")
            query.whereKey("driverResponsible", equalTo:(PFUser.currentUser()?.username)!)
            query.findObjectsInBackgroundWithBlock {
                
                (objects: [AnyObject]?, error: NSError?) -> Void in
                
                if let objects = objects as? [PFObject] {
                    
                    var objectCount = 0
                    //self.imgarray.removeAll()
                    self.usernamearray.removeAll()
                    self.departTimeArray.removeAll()
                    self.DVpickUpLocArray.removeAll()
                    self.destinationArray.removeAll()
                    
                    for object in objects {
                        self.usernamearray.append(object["username"] as! String)
                        self.departTimeArray.append(object["driverDepartTime"] as! NSDate)
                        self.DVpickUpLocArray.append(object["origin"] as! String)
                        self.destinationArray.append(object["destination"] as! String)
                        self.objectID.append(object.objectId! as String)
                        
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
        return usernamearray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("driverCell", forIndexPath: indexPath) as! MyBookingTableViewCell

        let formatter = NSDateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("ddMMMhmma")
        
        cell.username.text = self.usernamearray[indexPath.row]
        cell.departTime.text = "Depart Time:  " + formatter.stringFromDate(self.departTimeArray[indexPath.row])
        var itemname = self.DVpickUpLocArray[indexPath.row].componentsSeparatedByString("|")
        cell.DVPickUpLoc.text = "Pick Up Location: " + itemname[0]
        itemname = self.destinationArray[indexPath.row].componentsSeparatedByString("|")
        cell.Destination.text = "Destination: " + itemname[0]

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
        if segue.identifier == "BookingDetailsFromDriver" {
            
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
