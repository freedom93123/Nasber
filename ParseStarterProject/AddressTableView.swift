//
//  AddressTableView.swift
//  ParseStarterProject
//
//  Created by FOEIT on 3/7/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import MapKit

class AddressTableView: UITableView {
    
    var mainViewController: BookingViewController!
    var addresses: [String]!
    var placemarkArray: [CLPlacemark]!
    var currentTextField: UITextField!
    var sender: UIButton!
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.registerClass(UITableViewCell.self, forCellReuseIdentifier: "AddressCell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension AddressTableView: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica Neue Light", size: 15)
        label.textAlignment = .Center
        label.text = "Best Matches"
        label.backgroundColor = UIColor(red: 240.0/255.0, green: 229.0/255.0, blue: 141.0/225.0, alpha: 1)
        
        return label
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //Since the last row in the table is “None of the above,” you only update the text field and its associated map item when the row is less than the length of the addresses array.
        if addresses.count > indexPath.row {
            
            //Update the current text field to contain the selected address.
            currentTextField.text = addresses[indexPath.row]
            
            //Create a MKMapItem with the placemark corresponding to the selected row and associate the MKMapItem with the current text field in mainViewController's locationTuples array.
            let mapItem = MKMapItem(placemark:
                MKPlacemark(coordinate: placemarkArray[indexPath.row].location!.coordinate,
                    addressDictionary: placemarkArray[indexPath.row].addressDictionary
                        as! [String:AnyObject]?))
            mainViewController.locationTuples[currentTextField.tag-1].mapItem = mapItem
            
            sender.selected = true
            
            //Create annotation for the placemarks
            mainViewController.map.removeAnnotations(mainViewController.map.annotations)
            var objectAnnotation = MKPointAnnotation()
            objectAnnotation.coordinate = placemarkArray[indexPath.row].location!.coordinate
            print(objectAnnotation.coordinate.latitude)
            print(objectAnnotation.coordinate.longitude)
            objectAnnotation.title = addresses[indexPath.row]
            mainViewController.map.addAnnotation(objectAnnotation)

            var span = MKCoordinateSpanMake(0.2, 0.2)
            var region = MKCoordinateRegion(center: objectAnnotation.coordinate, span: span)
            mainViewController.map.setRegion(region,animated:true)
            var pinAnnotationView = MKPinAnnotationView(annotation: objectAnnotation, reuseIdentifier: nil)
            pinAnnotationView.animatesDrop = true
        }
                removeFromSuperview()
        mainViewController.navigationController!.navigationBar.hidden = false

    }
}

extension AddressTableView:UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("AddressCell") as UITableViewCell!
        cell.textLabel?.numberOfLines = 3
        cell.textLabel?.font = UIFont(name: "Helvetica Neue Light", size: 8)
        
        if addresses.count > indexPath.row {
            cell.textLabel?.text = addresses[indexPath.row]
        } else {
            cell.textLabel?.text = "None of the above"
        }
        return cell
    }
}