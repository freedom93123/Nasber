//
//  BookingViewController.swift
//  ParseStarterProject
//
//  Created by FOEIT on 2/24/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import MapKit

class BookingViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate {
    
    var locationManager:CLLocationManager!
    
    @IBOutlet var origin: UITextField!
    @IBOutlet var destination: UITextField!
    
    @IBOutlet var map: MKMapView!
    
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    
    var matchingItems: [MKMapItem] = [MKMapItem]()
    var Location: String = ""
    //var firstatmpt = 1
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        var location:CLLocationCoordinate2D = manager.location!.coordinate
        let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.setRegion(region, animated: true)
        
        //Remove pin on the map
        self.map.removeAnnotations(map.annotations)
        
        //Display pin on the map
        //var pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        var objectAnnotation = MKPointAnnotation()
        //objectAnnotation.coordinate = pinLocation
        objectAnnotation.title = "Your location"
        self.map.addAnnotation(objectAnnotation)
    }
    
    @IBAction func searchOrigin(sender: AnyObject) {
        sender.resignFirstResponder()
        map.removeAnnotations(map.annotations)
        self.performSearch(origin.text!)
    }
    
    @IBAction func searchDestination(sender: AnyObject) {
        sender.resignFirstResponder()
        map.removeAnnotations(map.annotations)
        self.performSearch(destination.text!)
    }
    
    //perform search on location
    func performSearch(var Location: String) {
        
        locationManager.stopUpdatingLocation()
        matchingItems.removeAll()
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = Location
        request.region = map.region
        
        let search = MKLocalSearch(request: request)
        
        search.startWithCompletionHandler({(response:
            MKLocalSearchResponse?,
            error: NSError?) in
            
            if error != nil {
                print("Error occured in search: \(error!.localizedDescription)")
            } else if response!.mapItems.count == 0 {
                print("No matches found")
            } else {
                print("Matches found")
                
                for item in response!.mapItems as! [MKMapItem] {
                    print("Name = \(item.name)")
                    print("Phone = \(item.phoneNumber)")
                    
                    Location = item.name!
                    self.matchingItems.append(item as MKMapItem)
                    print("Matching items = \(self.matchingItems.count)")
                    
                    var annotation = MKPointAnnotation()
                    annotation.coordinate = item.placemark.coordinate
                    annotation.title = item.name
                    self.map.addAnnotation(annotation)
                }
            }
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.origin.delegate = self;
        self.destination.delegate = self;
        //dismiss the keyboard when tap on the screen
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization() //prompt user to give authorization to access location tracking
        //locationUpdate: while firstatmpt == 1 {
        locationManager.startUpdatingLocation()
        /*    firstatmpt++
        }
        if firstatmpt > 1 {*/
            //locationManager.stopUpdatingLocation()
        //}
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleSwipes(sender:UISwipeGestureRecognizer){
        if (sender.direction == .Right) {
            self.performSegueWithIdentifier("loginRider", sender: self)
        }
            
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
            }
    

}
