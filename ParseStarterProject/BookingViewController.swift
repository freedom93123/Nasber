//
//  BookingViewController.swift
//  ParseStarterProject
//
//  Created by FOEIT on 2/24/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Parse

class BookingViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate {
    
    var locationManager:CLLocationManager!
    
    @IBOutlet var driverLocTF: UITextField!
    
    @IBOutlet var origin: UITextField!
    @IBOutlet var destination: UITextField!
    @IBOutlet var enterButtonArray: [UIButton]!
    
    @IBOutlet var totalTimeLabel: UILabel!
    //global variable to associate each UITextField with its corresponding MKMapItem:
    var locationTuples: [(textField: UITextField!, mapItem: MKMapItem?)]!
    
    //locationsArray filters out the indices of locationTuples containing nil MKMapItems and since the app will fetch a round-trip route, filtered += [filtered.first!] copies the tuple at the first index to the end of the array.
    var locationsArray: [(textField: UITextField!, mapItem: MKMapItem?)] {
        var filtered = locationTuples.filter({ $0.mapItem != nil })
        if filtered.first != nil {
            filtered += [filtered.first!]
        }
        return filtered
    }
    
    @IBOutlet var map: MKMapView!
    @IBOutlet var submitRequest: UIButton!
    @IBOutlet var meetingStart: UITextField!
    @IBOutlet var meetingEnd: UITextField!
    
    
    var matchingItems: [MKMapItem] = [MKMapItem]()
    
    var eyePressed = true
    var meetingST = NSDate()
    var meetingET = NSDate()
    var totalTIme = NSDate()
    var tripSTFromDB:[NSDate] = [NSDate]()
    var tripETFromDB:[NSDate] = [NSDate]()
    
    var timeFFRider = NSTimeInterval()
    var timeFOriginToDestination = NSTimeInterval()
    var timeFDestinationToOrigin = NSTimeInterval()
    
    //perform function when user tap on submit booking request button
    @IBAction func submitBookRequest(sender: AnyObject) {
        
        // Date comparision to compare meeting start date and meeting end date.
        if origin.text == "" || destination.text == "" || meetingStart.text == "" || meetingEnd.text == "" {
            
            self.displayAlert("Invalid date and locations", message: "Please enter origin, destination, meeting start time and meeting end time to submit a booking request")
            
        } else {
            
            var dateComparisionResult:NSComparisonResult = meetingST.compare(meetingET)
            
            if dateComparisionResult == NSComparisonResult.OrderedAscending
            {
                // Meeting start date is smaller than end date.
                let years = meetingET.yearsFrom(meetingST)
                let months = meetingET.monthsFrom(meetingST)
                let weeks = meetingET.weeksFrom(meetingST)
                let days = meetingET.daysFrom(meetingST)
                let hours = meetingET.hoursFrom(meetingST)
                let minutes = meetingET.minutesFrom(meetingST)
                
                
                if years == 0 && months == 0 && weeks == 0 && days == 0 {
                    
                    let timeOffset = meetingET.offsetFrom(meetingST)
                    print("\(NSTimeInterval(timeOffset))")
                    let formatter = NSDateFormatter()
                    formatter.dateStyle = .MediumStyle
                    formatter.timeStyle = .ShortStyle
                    
                    let buffer: NSTimeInterval = 30*60
                    let driverDepartTime = meetingST.dateByAddingTimeInterval(-(timeFFRider + timeFOriginToDestination + buffer))
                    let tripEndTime = meetingET.dateByAddingTimeInterval(timeFDestinationToOrigin + buffer)
                    let driverArrivalTime = meetingST.dateByAddingTimeInterval(-timeFFRider)
                    
                    //totalTIme = formatter.dateFromString(tripEndTime.offsetFrom(driverDepartTime))!
                    
                    print(formatter.stringFromDate(driverDepartTime))
                    print(formatter.stringFromDate(tripEndTime))
                    
                    //Retrieve all meeting time and compare them to implement DSS feature
                    var query = PFQuery(className:"bookingRequest")
                    query.whereKey("driverResponsible", equalTo:"driver")
                    query.findObjectsInBackgroundWithBlock {
                        
                        (objects: [AnyObject]?, error: NSError?) -> Void in
                        
                        if let objects = objects as? [PFObject] {
                            
                            var objectCount = 0
                            var driverAvailability:[Bool]! = [Bool]()
                            var driverAvailable:Bool
                            
                            for object in objects {
                                // Do something
                                self.tripSTFromDB.append(object["driverDepartTime"] as! NSDate)
                                self.tripETFromDB.append(object["tripEndTime"] as! NSDate)
                                print(driverDepartTime)
                                print(tripEndTime)
                                objectCount++;
                                
                            }
                            
                            //compare booking time
                            print(objectCount)
                            for var i = 0; i<objectCount; i++ {
                                if driverDepartTime < self.tripSTFromDB[i] && tripEndTime < self.tripSTFromDB[i]{
                                    driverAvailability.append(true)
                                } else if driverDepartTime > self.tripETFromDB[i] && tripEndTime > self.tripETFromDB[i] {
                                    driverAvailability.append(true)
                                } else {
                                    driverAvailability.append(false)
                                }
                                
                                if i > 0 {
                                    if driverAvailability[i-1] && driverAvailability[i]{
                                        driverAvailability[i] = true
                                    } else {
                                        driverAvailability[i] = false
                                    }
                                }
                            }
                            
                            driverAvailable = driverAvailability[objectCount-1]
                            print(driverAvailable)
                            
                            if driverAvailable == true {
                                //save the booking request
                                let bookingRequest = PFObject(className:"bookingRequest")
                                
                                if PFUser.currentUser()?.username != nil && self.driverLocTF.text != ""{
                                    bookingRequest["username"] = PFUser.currentUser()?.username!
                                    bookingRequest["driverLocation"] = self.driverLocTF.text
                                    bookingRequest["origin"] = self.origin.text
                                    bookingRequest["destination"] = self.destination.text
                                    bookingRequest["meetingST"] = self.meetingST
                                    bookingRequest["meetingET"] = self.meetingET
                                    bookingRequest["driverDepartTime"] = driverDepartTime
                                    bookingRequest["tripEndTime"] = tripEndTime
                                    bookingRequest["driverResponsible"] = "driver"
                                    
                                    /* Futher enhancement on multiple driver
                                     var query = PFQuery(className:"driverLocation")
                                     query.whereKey("username", equalTo:"driver")
                                     query.findObjectsInBackgroundWithBlock {
                                     
                                     (objects: [AnyObject]?, error: NSError?) -> Void in
                                     
                                     if let objects = objects as? [PFObject] {
                                     
                                     for object in objects {
                                     
                                     if error == nil {
                                     if let driverusername = object["username"] as String {
                                     bookingRequest["driverResponsible"] = driverusername
                                     }
                                     } else {
                                     self.displayAlert("No driver", message: "The driver is not found")
                                     }
                                     }
                                     }
                                     }*/
                                    
                                    bookingRequest.saveInBackgroundWithBlock {
                                        (success: Bool, error: NSError?) -> Void in
                                        if (success) {
                                            // The object has been saved.
                                            self.totalTimeLabel.text = "The driver will arrived at: \(formatter.stringFromDate(driverArrivalTime))"
                                            print("object has been saved")
                                            self.displayAlert("Booking Approved", message: "The booking request has been successfully saved")
                                        } else {
                                            // There was a problem, check error.description
                                        }
                                    }
                                }
                                
                                //Booking rejected by the system
                            } else {
                                
                                self.displayAlert("Booking Rejected", message: "Please pick a New booking Time.\n" + "Suggested new Booking Time:")
                            }
                            
                            print(self.tripSTFromDB)
                            print(self.tripETFromDB)
                        } else {
                            print(error)
                        }
                    }
                    
                    
                    
                } else {
                    
                    let timeOffset = meetingET.offsetFrom(meetingST)
                    self.displayAlert("Invalid date", message: "The duration of the meeting is too long : \(timeOffset)")
                }
            }
                
            else if dateComparisionResult == NSComparisonResult.OrderedDescending
            {
                // Meeting start date is greater than end date.
                self.displayAlert("Invalid date", message: "Meeting start time should be before meeting end time")
                
            }
            else if dateComparisionResult == NSComparisonResult.OrderedSame
            {
                // Meeting date and end date are same.
                self.displayAlert("Invalid date", message: "Meeting start date and end date are the same")
            }
        }
    }
    
    //A general alert message which is reuseable
    func displayAlert(title: String, message: String) {
        
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if self.map.annotations.count > 2 {
            self.map.removeAnnotations(self.map.annotations)
        }
        
        /*var query = PFQuery(className:"driverLocation")
         query.whereKey("username", equalTo:"driver")
         
         query.findObjectsInBackgroundWithBlock {
         
         (objects: [AnyObject]?, error: NSError?) -> Void in
         
         if error == nil {
         
         if let objects = objects as? [PFObject] {
         
         for object in objects {
         
         if let driverLocation = object["driverLocation"] as? PFGeoPoint {
         */
        //Set default location to Empire Gallery
        let driverCLLocation = CLLocation(latitude: 3.08195973138802, longitude: 101.582793490961)
        
        //driver location
        CLGeocoder().reverseGeocodeLocation(driverCLLocation, completionHandler: {(placemarks:[CLPlacemark]?, error:NSError?) -> Void in
            if let placemarks = placemarks {
                let placemark = placemarks[0]
                self.locationTuples[0].mapItem = MKMapItem(placemark: MKPlacemark(coordinate: placemark.location!.coordinate, addressDictionary:placemark.addressDictionary as! [String:AnyObject]?))
                self.driverLocTF.text = ("Empire Shopping Gallery | " + self.formatAddressFromPlacemark(placemark))
                //The above code finds and selects the Enter button with tag 1, i.e. the Enter button next to the origin UITextField also with tag 1, so that the button’s text changes to ✓ to reflect its selected state.
                //self.enterButtonArray.filter{$0.tag == 1}.first!.selected = true
                
                //Create annotation for the placemarks
                var driverAnnotation = CustomPointAnnotation()
                driverAnnotation.coordinate = driverCLLocation.coordinate
                driverAnnotation.title = "Driver Location"
                driverAnnotation.imageName = "car.png"
                
                //var pinAnnotationView = MKAnnotationView(annotation: driverAnnotation, reuseIdentifier: nil)
                //pinAnnotationView.image = UIImage(named:"car.png")
                
                self.map.addAnnotation(driverAnnotation)
            }
        })
        /*               }
         }
         }
         }
         }*/
        
        
        //current user location
        //Reverse geocoding is the process of turning a location’s coordinates into a human-readable address.
        CLGeocoder().reverseGeocodeLocation(locations.last!, completionHandler: {(placemarks:[CLPlacemark]?, error:NSError?) -> Void in
                if let placemarks = placemarks {
                    let placemark = placemarks[0]
                    self.locationTuples[1].mapItem = MKMapItem(placemark:
                        MKPlacemark(coordinate: placemark.location!.coordinate,
                            addressDictionary: placemark.addressDictionary as! [String:AnyObject]?))
                    self.origin.text = self.formatAddressFromPlacemark(placemark)
                    //The above code finds and selects the Enter button with tag 1, i.e. the Enter button next to the origin UITextField also with tag 1, so that the button’s text changes to ✓ to reflect its selected state.
                    self.enterButtonArray.filter{$0.tag == 2}.first!.selected = true
                    
                    var riderAnnotation = MKPointAnnotation()
                    riderAnnotation.coordinate = locations.last!.coordinate
                    riderAnnotation.title = self.origin.text
                    
                    var pinAnnotationView = MKPinAnnotationView(annotation: riderAnnotation, reuseIdentifier: nil)
                    pinAnnotationView.animatesDrop = false
                    
                    self.map.addAnnotation(riderAnnotation)
                }
        })
        self.map.showAnnotations(self.map.annotations, animated: true)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    @IBAction func addressEntered(sender: UIButton) {
        view.endEditing(true)
        // use sender.tag to find the corresponding text field.
        let currentTextField = locationTuples[sender.tag-1].textField
        
        if currentTextField != nil{
            
            map.removeAnnotations(map.annotations)
            matchingItems.removeAll()
            
            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = currentTextField.text
            request.region = map.region
            
            let search = MKLocalSearch(request: request)
            
            search.startWithCompletionHandler({(response:
                MKLocalSearchResponse?,
                error: NSError?) in
                
                if error != nil {
                    self.displayAlert("Error occured in search", message: "Search could not be completed")
                    print("Error occured in search: \(error!.localizedDescription)")
                } else if response!.mapItems.count == 0 {
                    self.displayAlert("No matches found", message: "")
                    print("No matches found")
                } else {
                    print("Matches found")
                    
                    var addresses = [String]()
                    var placemarks = [CLPlacemark]()
                    
                    for item in response!.mapItems as! [MKMapItem] {
                        print("Name = \(item.name)")
                        print("Phone = \(item.phoneNumber)")
                        
                        self.matchingItems.append(item as MKMapItem)
                        print("Matching items = \(self.matchingItems.count)")
                        
                        var annotation = MKPointAnnotation()
                        var pinAnnotationView = MKPinAnnotationView()
                        
                        //remove "Optional"
                        var newitemName = item.name!.stringByReplacingOccurrencesOfString("Optional", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                        
                        addresses.append("\(newitemName) | " + self.formatAddressFromPlacemark(item.placemark))
                        placemarks.append(item.placemark)
                        
                        /*
                         annotation.coordinate = item.placemark.coordinate
                         annotation.title = item.name
                         self.map.addAnnotation(annotation)
                         
                         var span = MKCoordinateSpanMake(0.2, 0.2)
                         var region = MKCoordinateRegion(center: item.placemark.coordinate, span: span)
                         self.map.setRegion(region,animated:true)
                         pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
                         pinAnnotationView.animatesDrop = true
                         
                         */
                        
                    }
                    self.map.showAnnotations(self.map.annotations, animated: false)
                    self.navigationController!.navigationBar.hidden = true
                    self.showAddressTable(addresses, textField:currentTextField,
                        placemarks:placemarks, sender:sender)
                }
            })
            
            // Forward geocode the address using CLGeocoder's geocodeAddressString(_:completionHandler:).
            /*CLGeocoder().geocodeAddressString(currentTextField.text!,
             completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
             if let placemarks = placemarks {
             var addresses = [String]()
             for placemark in placemarks {
             addresses.append(self.formatAddressFromPlacemark(placemark))
             }
             self.showAddressTable(addresses, textField:currentTextField,
             placemarks:placemarks, sender:sender)
             } else {
             self.showAlert("Address not found.")
             }
             })*/
        }
    }
    
    @IBAction func searchOrigin(sender: AnyObject) {
        locationManager.stopUpdatingLocation()
        view.endEditing(true)
    }
    
    @IBAction func searchDestination(sender: AnyObject) {
        view.endEditing(true)
        locationManager.stopUpdatingLocation()
    }
    
    //create an AddressTable and set its addresses array using the CLPlacemarks returned by geocodeAddressString(_:completionHandler:).
    func showAddressTable(addresses: [String], textField: UITextField,
                          placemarks: [CLPlacemark], sender: UIButton) {
        let addressTableView = AddressTableView(frame: UIScreen.mainScreen().bounds, style: UITableViewStyle.Plain)
        addressTableView.addresses = addresses
        addressTableView.currentTextField = textField
        addressTableView.placemarkArray = placemarks
        addressTableView.mainViewController = self
        addressTableView.sender = sender
        addressTableView.delegate = addressTableView
        addressTableView.dataSource = addressTableView
        view.addSubview(addressTableView)
    }
    
    //convert the location data into a readable address:
    func formatAddressFromPlacemark(placemark: CLPlacemark) -> String {
        return (placemark.addressDictionary!["FormattedAddressLines"] as! [String]).joinWithSeparator(", ")
    }
    
    //alert message
    func showAlert(alertString: String) {
        let alert = UIAlertController(title: nil, message: alertString, preferredStyle: .Alert)
        let okButton = UIAlertAction(title: "OK",
                                     style: .Cancel) { (alert) -> Void in
        }
        alert.addAction(okButton)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if textField == meetingStart {
            let datePicker = UIDatePicker()
            textField.inputView = datePicker
            datePicker.minuteInterval = 30
            let currentDate = NSDate()
            datePicker.minimumDate = currentDate
            datePicker.addTarget(self, action: "datePickerChangedms:", forControlEvents: .ValueChanged)
        } else if textField == meetingEnd {
            let datePicker = UIDatePicker()
            textField.inputView = datePicker
            datePicker.minuteInterval = 30
            let currentDate = NSDate()
            datePicker.minimumDate = currentDate
            datePicker.addTarget(self, action: "datePickerChangedme:", forControlEvents: .ValueChanged)
        }
    }
    
    func datePickerChangedms(sender:UIDatePicker){
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        meetingStart.text = formatter.stringFromDate(sender.date)
        meetingST = sender.date
    }
    
    func datePickerChangedme(sender:UIDatePicker){
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        meetingEnd.text = formatter.stringFromDate(sender.date)
        meetingET = sender.date
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        /*
         if textField.tag == 1 {
         self.performSearch(pickUpLoc.text!)
         }*/
        
        if textField.tag == 2{
            //self.performSearch(origin.text!)
        }
        
        if textField.tag == 3{
            //self.performSearch(destination.text!)
        }
        
        //Draw polylines when there are inputs for both origin and destination
        //Calculate the ETA required to reach the destination from origin
        if locationTuples[2].mapItem != nil {
            
            self.map.removeAnnotations(map.annotations)
            self.map.removeOverlays(map.overlays)
            locationManager.stopUpdatingLocation()
            
            var RiderAnnotation = MKPointAnnotation()
            RiderAnnotation.coordinate = self.locationTuples[1].mapItem!.placemark.coordinate
            RiderAnnotation.title = self.locationTuples[1].mapItem!.name
            self.map.addAnnotation(RiderAnnotation)
            
            var DestinationAnnotation = CustomPointAnnotation()
            DestinationAnnotation.coordinate = self.locationTuples[2].mapItem!.placemark.coordinate
            DestinationAnnotation.title = self.locationTuples[2].mapItem!.name
            DestinationAnnotation.imageName = "destination_icon"
            self.map.addAnnotation(DestinationAnnotation)
            
            self.totalTimeLabel.alpha = 1
            if locationsArray.first != nil {
                view.endEditing(true)
                //calculate the route starting at index 0 of locationArray, with an initial total time of 0 and an initially empty route array.
                calculateSegmentDirections(0, time: 0, routes: [])
            }
            
        }
        
    }
    
    /*
    //perform search on location
    func performSearch(var Location: String){
        
        map.removeAnnotations(map.annotations)
        matchingItems.removeAll()
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = Location
        request.region = map.region
        
        let search = MKLocalSearch(request: request)
        
        search.startWithCompletionHandler({(response:
            MKLocalSearchResponse?,
            error: NSError?) in
            
            if error != nil {
                self.displayAlert("Error occured in search", message: "Search could not be completed")
                print("Error occured in search: \(error!.localizedDescription)")
            } else if response!.mapItems.count == 0 {
                self.displayAlert("No matches found", message: "")
                print("No matches found")
            } else {
                print("Matches found")
                
                for item in response!.mapItems as! [MKMapItem] {
                    print("Name = \(item.name)")
                    print("Phone = \(item.phoneNumber)")
                    
                    var Location: String = ""
                    Location = item.name!
                    self.matchingItems.append(item as MKMapItem)
                    print("Matching items = \(self.matchingItems.count)")
                    
                    var annotation = MKPointAnnotation()
                    var pinAnnotationView = MKPinAnnotationView()
                    annotation.coordinate = item.placemark.coordinate
                    annotation.title = item.name
                    self.map.addAnnotation(annotation)
                    
                    var span = MKCoordinateSpanMake(0.2, 0.2)
                    var region = MKCoordinateRegion(center: item.placemark.coordinate, span: span)
                    self.map.setRegion(region,animated:true)
                    pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
                    pinAnnotationView.animatesDrop = true
                    
                }
                
                self.map.showAnnotations(self.map.annotations, animated: true)
                
            }
        })
    }
    */
    
    //This funcion accepts a mutable array of segment routes and a mutable time variable.
    func calculateSegmentDirections(index: Int,
                                    var time: NSTimeInterval, var routes: [MKRoute]) {
        // Create an MKDirectionsRequest by setting the MKMapItem at a given index of the locationArray as the origin and setting the MKMapItem at the next index as the destination.
        let request: MKDirectionsRequest = MKDirectionsRequest()
        request.source = locationsArray[index].mapItem
        request.destination = locationsArray[index+1].mapItem
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
                
                // Add the quickest route for this current segment to the routes array passed in as a parameter
                routes.append(quickestRouteForSegment)
                // Add this new route’s expected travel time to the time parameter.
                time += quickestRouteForSegment.expectedTravelTime
                
                if index == 0 {
                    self.timeFFRider = time
                } else if index == 1 {
                    self.timeFOriginToDestination = time - self.timeFFRider
                } else if index == 2 {
                    self.timeFDestinationToOrigin = time - self.timeFFRider - self.timeFOriginToDestination

                }
                // recursively call calculateSegmentDirections(_:time:routes:) with an incremented index and the updated time and route values.
                if index+2 < self.locationsArray.count {
                    self.calculateSegmentDirections(index+1, time: time, routes: routes)
                    
                } else {
                    
                    //pass in ETA from origin to destination for Rider View
                    self.showRoute(routes, time: self.timeFOriginToDestination)
                }
            } else if let _ = error {
                self.showAlert("Direction not available")
            }
        })
    }
    
    //This function loops through each MKRoute and adds its polyline to the map.
    func showRoute(routes: [MKRoute],time: NSTimeInterval){
        for i in 0..<routes.count {
            plotPolyline(routes[i])
        }
        printTimeToLabel(time)
    }
    
    //Display route on the map
    func plotPolyline(route: MKRoute) {
        //Adds the MKRoute's polyline to the map as an overlay.
        map.addOverlay(route.polyline)
        // If the plotted route is the first overlay, sets the map's visible area so it's just big enough to fit the overlay with 10 extra points of padding.
        if map.overlays.count == 2 {
            map.setVisibleMapRect(route.polyline.boundingMapRect,
                                  edgePadding: UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0),
                                  animated: false)
        }
            //If the plotted route is not the first, set the map's visible area to the union of the new and old visible map areas with 10 extra points of padding.
            //When plot more than one line
        /*else {
            let polylineBoundingRect =  MKMapRectUnion(map.visibleMapRect,
                                                       route.polyline.boundingMapRect)
            map.setVisibleMapRect(polylineBoundingRect,
                                  edgePadding: UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0),
                                  animated: false)
        }*/
    }
    
    //print the ETA
    func printTimeToLabel(time: NSTimeInterval) {
        let timeString = stringFromTimeInterval(time)
        totalTimeLabel.text = "Travelling Time From Origin to Destination: \(timeString)"
    }
    
    //format the ETA
    func stringFromTimeInterval(interval:NSTimeInterval) -> NSString {
        
        var ti = NSInteger(interval)
        var seconds = ti % 60
        var minutes = (ti / 60) % 60
        var hours = (ti / 3600)
        
        return NSString(format: "%02d:%02d:%02d",hours,minutes,seconds)
    }
    
    //This gives each route segment a different color.
    func mapView(map: MKMapView,
                 rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer! {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        if (overlay is MKPolyline) {
            /*if map.overlays.count == 1 {
                polylineRenderer.strokeColor =
                    UIColor.blueColor().colorWithAlphaComponent(0.50)
            } else */if map.overlays.count == 2 {
                polylineRenderer.strokeColor =
                    UIColor.greenColor().colorWithAlphaComponent(0.75)
            } /*else if map.overlays.count == 3 {
                polylineRenderer.strokeColor =
                    UIColor.redColor().colorWithAlphaComponent(0.50)
            }*/
            
            polylineRenderer.lineWidth = 5
        }
        return polylineRenderer
        
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.driverLocTF.text = ""
        //pre-populate the array with tuples, each containing a text field and a nil value in place of the MKMapItem that may eventually be associated with that text field.
        locationTuples = [(driverLocTF,nil), (origin, nil), (destination, nil)]
        
        //addActivityIndicator()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        map.delegate = self;
        self.origin.delegate = self;
        self.destination.delegate = self;
        self.meetingStart.delegate = self;
        self.meetingEnd.delegate = self;
        //dismiss the keyboard when tap on the screen
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization() //prompt user to give authorization to access location tracking
        locationManager.startUpdatingLocation()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        let button = UIButton()
        button.frame = CGRectMake(0, 0, 30, 30) //won't work if you don't set frame
        button.setImage(UIImage(named: "eye_open.png"), forState: .Normal)
        button.addTarget(self, action: Selector("eyeButtonPressed"), forControlEvents: .TouchUpInside)
        
        let barButton = UIBarButtonItem()
        barButton.customView = button
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    func eyeButtonPressed(){
        if eyePressed == true {
            origin.alpha = 0
            destination.alpha = 0
            submitRequest.alpha = 0
            totalTimeLabel.alpha = 0
            meetingStart.alpha = 0
            meetingEnd.alpha = 0
            for buttons in enterButtonArray {
                buttons.hidden = true
            }
            eyePressed = false
            
        } else {
            origin.alpha = 1
            destination.alpha = 1
            submitRequest.alpha = 1
            totalTimeLabel.alpha = 1
            meetingStart.alpha = 1
            meetingEnd.alpha = 1
            for buttons in enterButtonArray {
                buttons.hidden = false
            }
            eyePressed = true
        }
    }
    
    func textField(textField: UITextField,
                   shouldChangeCharactersInRange range: NSRange,
                                                 replacementString string: String) -> Bool {
        
        locationTuples[textField.tag-1].mapItem = nil
        return true
    }
    
    //The if-else conditional prevents the segue if a origin and at least one destination haven’t been set.
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if locationTuples[0].mapItem == nil ||
            (locationTuples[1].mapItem == nil && locationTuples[2].mapItem == nil) {
            showAlert("Please enter a valid starting point and at least one destination.")
            return false
        } else {
            return true
        }
        
    }
}




