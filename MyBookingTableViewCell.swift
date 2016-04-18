//
//  MyBookingTableViewCell.swift
//  NasberINTIIU
//
//  Created by FOEIT on 11/04/2016.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class MyBookingTableViewCell: UITableViewCell {

    //MyBookingTableView
    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var drivername: UILabel!
    @IBOutlet var driverArrivalTime: UILabel!
    @IBOutlet var meetingStartTime: UILabel!
    @IBOutlet var pickUpLocation: UILabel!
    
    //DriverViewBookingTable
    @IBOutlet var username: UILabel!
    @IBOutlet var departTime: UILabel!
    @IBOutlet var DVPickUpLoc: UILabel!
    @IBOutlet var Destination: UILabel!
    
    //DriverViewQuickRequest
    @IBOutlet var QRusername: UILabel!
    @IBOutlet var RequestTime: UILabel!
    @IBOutlet var distance: UILabel!
    @IBOutlet var travellingTime: UILabel!
    @IBOutlet var ETA: UILabel!
    @IBOutlet var driverResponded: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
