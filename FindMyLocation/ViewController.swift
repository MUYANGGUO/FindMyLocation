//
//  ViewController.swift
//  FindMyLocation
//
//  Created by Muyang on 5/27/18.
//  Copyright © 2018 Muyang. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class ViewController: UIViewController,CLLocationManagerDelegate {

    var ref:DatabaseReference?

    var latitude: Double?
    var longitude: Double?
    var altitude: Double?
    var city: String?
    let locationManager = CLLocationManager()
    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var myLatitude: UITextField!
    @IBOutlet weak var myLongitude: UITextField!
    @IBOutlet weak var myAltitude: UITextField!
@IBOutlet weak var weatherLabel: UITextField!


@IBOutlet weak var myCity: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        // Do any additional setup after loading the view, typically from a nib.

        ref = Database.database().reference()
}

func locationManager(_ _manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        if status == .authorizedWhenInUse{
    print("GPS allowed")
            myMap.showsUserLocation = true
}
        else{
            print("GPS not allowed.")
            return
}
}


func locationManager(_ _manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
    let myCoordinate = locationManager.location?.coordinate
    altitude = locationManager.location?.altitude
    latitude = myCoordinate?.latitude
    longitude = myCoordinate?.longitude

    myLatitude.text = String(latitude!)
    myLongitude.text = String(longitude!)
    myAltitude.text = String(altitude!)

    //ref?.child("latitude").childByAutoId().setValue(latitude)   //latitude database
    //ref?.child("longitude").childByAutoId().setValue(longitude) //longitude database
}

@IBAction func showcitynametapped(_sender: Any){
    let geoCoder = CLGeocoder()
    let location = CLLocation(latitude: latitude!, longitude: longitude!)
    geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in

    // Place details
    var placeMark: CLPlacemark!
    placeMark = placemarks?[0]
    self.city = placeMark.locality!
    self.myCity.text = self.city
    self.getWeather()
    })

    ref?.child("city").childByAutoId().setValue(city)  //City Database
ref?.child("latitude").childByAutoId().setValue(latitude)   //latitude database
ref?.child("longitude").childByAutoId().setValue(longitude) //longitude database
}

func getWeather() {
    let session = URLSession.shared
    self.city = self.city!.replacingOccurrences(of: " ", with: "+")
    let weatherURL = URL(string: "http://api.openweathermap.org/data/2.5/weather?q="+self.city!+",us&units=imperial&APPID=69229f2152b7a0e97badabe1d2386fcb")!
    let dataTask = session.dataTask(with: weatherURL) {
    (data: Data?, response: URLResponse?, error: Error?) in
    if let error = error {
    print("Error:\n\(error)")
    } else {
    if let data = data {
    let dataString = String(data: data, encoding: String.Encoding.utf8)
    print("All the weather data:\n\(dataString!)")
    if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
    if let mainDictionary = jsonObj!.value(forKey: "main") as? NSDictionary {
    if let temperature = mainDictionary.value(forKey: "temp") {
    DispatchQueue.main.async {
    self.weatherLabel.text = "Temperature: \(self.fixTempForDisplay(temp: temperature as! Double))°F"
    }
    }
    } else {
    print("Error: unable to find temperature in dictionary")
    }
    } else {
    print("Error: unable to convert json data")
    }
    } else {
    print("Error: did not receive data")
    }
    }
    }
    dataTask.resume()
}


func fixTempForDisplay(temp: Double) -> String {
    let temperature = round(temp)
    let temperatureString = String(format: "%.0f", temperature)

    ref?.child("temperature").childByAutoId().setValue(temperature) //temperature database

    return temperatureString
    }


@IBAction func resetbuttonpressed(_sender: Any){
self.myCity.text = ""
self.weatherLabel.text = ""
}

        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }

}

