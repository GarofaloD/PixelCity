//
//  MapViewController.swift
//  PixelCity
//
//  Created by Daniel Garofalo on 2/28/19.
//  Copyright © 2019 Daniel Garofalo. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class MapViewController: UIViewController, UIGestureRecognizerDelegate {
    
    //MARK:- Properties
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    let authStatus = CLLocationManager.authorizationStatus()
    let regionRadius : Double = 1000 //Radius from the coordinate. In this case, 100sqmts
    
    
    
    //MARK:- Outlets
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        //Both need to be delegated
        mapView.delegate = self
        locationManager.delegate = self
        
        //Verification on auth to get location needs to load on memory before anything else
        configureLocationServices()
        //Double tap capability
        addDoubleTap()
        
    }
    


    //MARK:- Buttons
    @IBAction func centerWhenPressed(_ sender: UIButton) {
        //Checking on status of auth and recentering
        if authStatus == .authorizedAlways || authStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
        
    }
    
    
    
    
    
    //MARK:- Custom functions
    
    //Double tap to set up custom location AND drop pin
    func addDoubleTap(){
        //Creates and configures and delegates the gesture recognizer TO THIS CLASS, using the location passed on the map view delegate
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self //requires the gesture recognizer protocol
        mapView.addGestureRecognizer(doubleTap)
    }
    
    
    
    
    
    

}

//Extension for the delegation of Map Kit
extension MapViewController: MKMapViewDelegate {
    
    
    //Pin customizton
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        //this customization will apply to any location but the one from the user. Therefore, the original location will stay on blue
        if annotation is MKUserLocation {
            return nil
        }
        
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9960784314, green: 0.6509803922, blue: 0.137254902, alpha: 1)
        pinAnnotation.animatesDrop = true
        
        return pinAnnotation
        
    }
    
    
    
    
    
    func centerMapOnUserLocation(){
        //Grabbing coordinates from the user, setting up a radius from that specific coordinates and setting the focus of the map on that specific radius
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius * 2, longitudinalMeters: regionRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //base function for doubletap. Requires for the tap on the map to be passed in so the pin will be dropped on the location specified on the map
    @objc func dropPin(sender: UITapGestureRecognizer){
        
        //Pins need to be removed so we dont have duplicates
        removePin()
        
        //touch point
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        //Creates the pin(annotation) and adds it to the UI
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        
        //Centers the map on the new location of the pin
        let coordinateRegion = MKCoordinateRegion(center: touchCoordinate, latitudinalMeters: regionRadius * 2, longitudinalMeters: regionRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    
    //Removes the pin for the array of pins
    func removePin(){
        for annotation in mapView.annotations{
            mapView.removeAnnotation(annotation)
        }
    }
    
    
    
}


//Extension for the delegation of Location Management
extension MapViewController : CLLocationManagerDelegate {
    
    //Checking for status of auth to check on location
    func configureLocationServices() {
        if authStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    //racking the auth change on the
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
    
    
    
    
    
    
}
