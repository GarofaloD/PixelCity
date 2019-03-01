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


class MapViewController: UIViewController {
    
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
        
        
        
    }
    


    //MARK:- Buttons
    @IBAction func centerWhenPressed(_ sender: UIButton) {
        //Checking on status of auth and recentering
        if authStatus == .authorizedAlways || authStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
        
    }
    
    
    
    
    
    //MARK:- Custom functions
    
    
    

}

//Extension for the delegation of Map Kit
extension MapViewController: MKMapViewDelegate {
    
    func centerMapOnUserLocation(){
        //Grabbing coordinates from the user, setting up a radius from that specific coordinates and setting the focus of the map on that specific radius
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius * 2, longitudinalMeters: regionRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
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
