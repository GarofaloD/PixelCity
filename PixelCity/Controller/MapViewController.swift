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
import Alamofire
import AlamofireImage


class MapViewController: UIViewController, UIGestureRecognizerDelegate {
    
    
    //MARK:- Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpImageView: UIView!
    @IBOutlet weak var pullUpImageViewHeightConstraint: NSLayoutConstraint!
    
    
    //MARK:- Properties
    var locationManager = CLLocationManager()
    let authStatus = CLLocationManager.authorizationStatus()
    let regionRadius : Double = 1000 //Radius from the coordinate. In this case, 100sqmts
    var spinner : UIActivityIndicatorView?
    var progressLabel : UILabel?
    var screenSize = UIScreen.main.bounds
    var collectionView : UICollectionView?
    var flowLayout = UICollectionViewFlowLayout() //To create a collection view programaticcaly, you need to add a layout
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        //Both need to be delegated
        mapView.delegate = self
        locationManager.delegate = self
        
        //Verification on auth to get location needs to load on memory before anything else
        configureLocationServices()
        //Double tap capability
        addDoubleTap()
        //Instance of collectionView
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 0.4240557899)
        
        pullUpImageView.addSubview(collectionView!)
        
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
    
    //Gesture recognizer to animate the photos view down
    func addSwipe(){
        //Creation of the swipe gesture and adding it to the photos view
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(MapViewController.animateViewDown))
        swipe.direction = .down
        pullUpImageView.addGestureRecognizer(swipe)
    }
    
    
    
    // Base function for animating the photos view (UP)
    func animateViewUp(){
        pullUpImageViewHeightConstraint.constant = 300
        //Animate view
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    // Base function for animating the photos view (DOWN)
    @objc func animateViewDown(){
        //each time the user manually swipes down, the netwok sessions will be cancelled and the frame that hold s the collection view will be hidden
        cancelAllSessions()
        pullUpImageViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    //Adding spinner to indicate activity
    func addSpinner(){
        //Customization of the spinner and adding it specifically to the pullUpView
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: 130)
        spinner?.style = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    
    //Removing spinner
    func removeSpinner(){
        //If there is an spinner already in place, remove it
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    //Add progress label
    func addProgressLabel(){
        progressLabel = UILabel()
        progressLabel?.frame = CGRect(x: (screenSize.width / 2) - 150, y: 150, width: 300, height: 20)
        progressLabel?.font = UIFont(name: "Avenir Next", size: 14)
        progressLabel?.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        progressLabel?.textAlignment = .center
        progressLabel?.text = "LOADING..."
        collectionView?.addSubview(progressLabel!)
    }
    
    //Remove status label
    func removeProgressLabel(){
        if progressLabel != nil {
            progressLabel?.removeFromSuperview()
        }
    }
    
} //EOC












//Extension for the delegation of Map Kit
extension MapViewController: MKMapViewDelegate {
    
    
    //Pin customizaton
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //this customization will apply to any location but the one from the user. Therefore, the original location will stay on blue
        if annotation is MKUserLocation {
            return nil
        }
        //Creation and customization of the pin
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9960784314, green: 0.6509803922, blue: 0.137254902, alpha: 1)
        pinAnnotation.animatesDrop = true
        //Pin needs to be returned, according to func specification
        return pinAnnotation
    }
  
    //Center the map on the location specified
    func centerMapOnUserLocation(){
        //Grabbing coordinates from the user, setting up a radius from that specific coordinates and setting the focus of the map on that specific radius
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius * 2, longitudinalMeters: regionRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //base function for doubletap. Requires for the tap on the map to be passed in so the pin will be dropped on the location specified on the map
    @objc func dropPin(sender: UITapGestureRecognizer){
        
        //Pins need to be removed so we dont have duplicates, every time a pin is dropped
        removePin()
        //Remove any previous spinner everytime a new pin is dropped
        removeSpinner()
        //Remove any previous progresslabels everytime a new pin is dropped
        removeProgressLabel()
        //Remove existing sessions before adding a new pin
        cancelAllSessions()
        //Animate the image view up when dropping the pin
        
        //This will: clear the images from the collection view, from the list of urls and reload the collection view
        imageUrlArray = []
        imageArray = []
        collectionView?.reloadData()
        
        //shows the collectionview that will display the images once downloaded
        animateViewUp()
        //Showing spinner on the pullUpView everytime we drop a pin
        addSpinner()
        //Animate the image view down when swiping down
        addSwipe()
        //Add progress label
        addProgressLabel()
    
        //touch point
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        //Creates the pin(annotation) and adds it to the UI
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        
        //TEST
        //print(flickrUrl(forApiKey: FLICKR_API_KEY, withAnnotation: annotation, addNumberOfPhotos: 40))
        
        //Centers the map on the new location of the pin
        let coordinateRegion = MKCoordinateRegion(center: touchCoordinate, latitudinalMeters: regionRadius * 2, longitudinalMeters: regionRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
        
        retrieveUrls(forAnnotation: annotation) { (finished) in
            if finished {
                self.retrieveImages(handler: { (finished) in
                    if finished {
                        //hide spinner
                        self.removeSpinner()
                        //hide label
                        self.removeProgressLabel()
                        //reload collectionview
                        self.collectionView?.reloadData()
                        
                    }
                })
            }
        }
    }
    
    
    //Removes the pin for the array of pins
    func removePin(){
        for annotation in mapView.annotations{
            mapView.removeAnnotation(annotation)
        }
    }
    
    //Retrieving urls for individual pics
    func retrieveUrls(forAnnotation annotation: DroppablePin, handler: @escaping (_ status: Bool) -> ()) {
        
        Alamofire.request(flickrUrl(forApiKey: FLICKR_API_KEY, withAnnotation: annotation, addNumberOfPhotos: 40)).responseJSON { (response) in
            //print(response)
            handler(true)
            
            guard let json = response.result.value as? Dictionary<String,AnyObject> else { return }
            let photosDict = json["photos"] as? Dictionary<String, AnyObject>
            let photosDictArray = photosDict?["photo"] as! [Dictionary<String,AnyObject>]
            
            for photo in photosDictArray {
                let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                self.imageUrlArray.append(postUrl)
            }
            handler(true)
        }
    }
    
    //Saving the images to be displayed
    func retrieveImages(handler: @escaping (_ status: Bool) -> ()){
        //for each url saved on the array of the images url
        for url in imageUrlArray{
            Alamofire.request(url).responseImage(completionHandler: { (response) in
                //get the image and save the image on the array of images
                guard let image = response.result.value else {return}
                self.imageArray.append(image)
                self.progressLabel!.text = "\(self.imageArray.count)/40 IMAGES DOWNLOADED"
                
                //Then, compare the amount of urls with the amount of images downloadded.If they are the same the process is over
                if self.imageArray.count == self.imageUrlArray.count {
                    handler(true)
                    print(self.imageArray)
                }
            })
        }
    }
    
    //Cancel all network sessions
    func cancelAllSessions(){
        //get the network functions
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            //Cancel all the network functions by grabing each value into theur array and deleting them
            sessionDataTask.forEach({ $0.cancel() })
            downloadData.forEach({ $0.cancel() })
        }
    }

} //EOC


//Extension for the delegation of Location Management
extension MapViewController : CLLocationManagerDelegate {
    
    //Checking for status of auth to check on location. This needs to be requested and reverified
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
    
    
} //EOC



extension MapViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    //Number of sections
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //Number of items
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    //Content of items
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else { return UICollectionViewCell() }
        let imageFromIndex = imageArray[indexPath.row]
        let imageView = UIImageView(image: imageFromIndex)
        cell.addSubview(imageView)
        return cell
    }
    
    
}
