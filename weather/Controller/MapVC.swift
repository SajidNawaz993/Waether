//
//  ViewController.swift
//  weather
//
//  Created by Sajid Nawaz on 6/18/19.
//  Copyright © 2019 Sajid Nawaz. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController ,MKMapViewDelegate, CLLocationManagerDelegate {

    // ------------------------------------------------
    // MARK: outlets
    // ------------------------------------------------
    
     @IBOutlet weak var mapView: MKMapView!
     @IBOutlet weak var locationNamelbl: UILabel!
     @IBOutlet weak var templbl: UILabel!
    
    // ------------------------------------------------
    // MARK: variable
    // ------------------------------------------------
   
    let apiCaller = APICaller()
    let locationManager = CLLocationManager()
    var curlat = 0.0 , curlng = 0.0
    
    // ------------------------------------------------
    // MARK: View life cycle method
    // ------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //for location
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest //kCLLocationAccuracyNearestTenMeters
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        //add tap gesture to map
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.addPin))
        self.mapView.addGestureRecognizer(tapGesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // ------------------------------------------------
    // MARK: Delegate method
    // ------------------------------------------------
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        curlat = locations.last!.coordinate.latitude
        curlng = locations.last!.coordinate.longitude
        getWeatherUpdate()
        let meters: Int = 5 * 3300
        let region: MKCoordinateRegion = MKCoordinateRegion(center: locations.last!.coordinate, latitudinalMeters: CLLocationDistance(meters), longitudinalMeters: CLLocationDistance(meters))
        mapView.setRegion(region, animated: false)
    }
    
    
    
    // ------------------------------------------------
    // MARK: custom method
    // ------------------------------------------------
    
    @objc func addPin(_ sender: UITapGestureRecognizer) {
        
        let location = sender.location(in: self.mapView)
        let locValue = self.mapView.convert(location, toCoordinateFrom: self.mapView)
       
        let meters: Int = 5 * 3300
        let region: MKCoordinateRegion = MKCoordinateRegion(center: locValue, latitudinalMeters: CLLocationDistance(meters), longitudinalMeters: CLLocationDistance(meters))
        mapView.setRegion(region, animated: false)
        curlat = locValue.latitude
        curlng = locValue.longitude
        getWeatherUpdate()
        
        
    }
    
    // ------------------------------------------------
    // MARK: Api Call method
    // ------------------------------------------------
    
    private func getWeatherUpdate() {
        
        let url = "\(baseUrl)data/2.5/weather?lat=\(curlat)&lon=\(curlng)&appid=0a04048b63045f06ebe828e4cd3aa4db"
        
        
        if(HelperFuntions.isInternetAvailable())
        {
            
            LoadingOverlay.shared.showOverlay(view: UIApplication.shared.keyWindow!)
            
            apiCaller.sendAPICall("Get",
                                  methodNameWithBaseURL: url,
                                  params: nil,
                                  completed: {(succeeded:Bool, responseResult: AnyObject?)-> () in
                                    
                                    if(succeeded){
                                        
                                        DispatchQueue.main.async(execute: { () -> Void in
                                            
                                            LoadingOverlay.shared.hideOverlayView()
                                            if let status = responseResult?.object(forKey: "cod") as? Int {
                                                
                                                if status == 200 {
                                                    if let maindic = responseResult?.object(forKey: "main") as? NSDictionary {
                                                        if let temp = maindic.object(forKey: "temp") as? Double {
                                                            let celcius = temp - 273.15
                                                            self.templbl.text = "Temperature: " + String(format: "%.0f", celcius) + "°C"
                                                        }
                                                    }
                                                    
                                                    if let name = responseResult?.object(forKey: "name") as? String {
                                                        self.locationNamelbl.text = "Location: \(name)"
                                                    }
                                                    
                                                }else {
                                                    
                                                }
                                            }
                                        })
                                        
                                        
                                    } else {
                                        
                                        DispatchQueue.main.async(execute: { () -> Void in
                                            
                                            LoadingOverlay.shared.hideOverlayView()
                                            
                                        })
                                    }
                                    
            })
            
        }
        else
        {
            HelperFuntions.DisplayMessageHelperWithcallbackOk(userMessage: internetNot, title: "Alert", myController: self, completion: { (bool) in
                
            })
        }
        
     
    }
    
}

