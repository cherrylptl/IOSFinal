import UIKit
import CoreLocation
import MapKit
import CoreData

class DirectionViewController: UIViewController,UITabBarDelegate,CLLocationManagerDelegate,MKMapViewDelegate{

    
    @IBAction func carButton(_ sender: Any) {
        currentTransportType = .automobile
                showRouteWithCurrentTransportType()
    }

    @IBAction func bikeButton(_ sender: Any) {
        currentTransportType = .automobile
                showRouteWithCurrentTransportType()
    }

    @IBAction func walkButton(_ sender: Any) {
        currentTransportType = .walking
                showRouteWithCurrentTransportType()
    }
    
    @IBAction func busButton(_ sender: Any) {
        currentTransportType = .transit
                showRouteWithCurrentTransportType()
    }
    
    @IBOutlet weak var mapView: MKMapView!
    

    @IBOutlet weak var zoomSlider: UISlider!
    
    @IBAction func homeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addButton(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Where would you like to go?", message: "Enter your destination", preferredStyle: .alert)

         
           alertController.addTextField { textField in
               textField.placeholder = "Start Location"
               self.startLocationTextField = textField
           }

           alertController.addTextField { textField in
               textField.placeholder = "End Location"
               self.endLocationTextField = textField
           }

           let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)

           let directionButton = UIAlertAction(title: "Direction", style: .default) { _ in
               let startText = self.startLocationTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
               let endText = self.endLocationTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
               if startText.isEmpty {
                   // Use current location as the start point
                   self.convertAddress(startAddress: "", endAddress: endText)
               } else if !endText.isEmpty {
                   // Both start and end locations provided
                   self.convertAddress(startAddress: startText, endAddress: endText)
               } else {
                   print("Please enter both start and end locations")
               }
           }

           alertController.addAction(cancelButton)
           alertController.addAction(directionButton)

           present(alertController, animated: true)
       }

    
    private var locationManager = CLLocationManager()
    
    private var location: CLLocation?
    
    
    var userLocation: CLLocation?
    var startLocationTextField: UITextField?
    var endLocationTextField: UITextField?
    var currentTransportType: MKDirectionsTransportType = .automobile
    
    let content = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var startPoint: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Set up map view
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        // Set up zoom slider
        zoomSlider.minimumValue = 0
        zoomSlider.maximumValue = 20
        zoomSlider.value = 10 // Set initial zoom level
        zoomSlider.addTarget(self, action: #selector(zoomSliderValueChanged(_:)), for: .valueChanged)
    
    }
    
    // Function to show route with the current transport type
    private func showRouteWithCurrentTransportType() {
        guard let endLocationText = endLocationTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            !endLocationText.isEmpty else {
                print("Please enter both start and end locations")
            let alert = UIAlertController(title: "Alert", message: "Please enter both start and end locations", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
                return
        }

        if let startLocationText = startLocationTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !startLocationText.isEmpty {
            // Start location is provided by the user
            convertAddress(startAddress: startLocationText, endAddress: endLocationText)
        } else if userLocation != nil {
            // Use user's current location as the start point
            convertAddress(startAddress: nil, endAddress: endLocationText)
        } else {
            print("User location not available")
        }
    }

    
    @objc func zoomSliderValueChanged(_ sender: UISlider) {
        let zoomLevel = Double(sender.value)
        updateMapZoomLevel(zoomLevel: zoomLevel, location: location)
    }

    func updateMapZoomLevel(zoomLevel: Double, location: CLLocation?) {
        guard let location = location else {
            return
        }

        let updatedZoomLevel = 20 - zoomLevel
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: updatedZoomLevel, longitudeDelta: updatedZoomLevel)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            manager.startUpdatingLocation()
            self.location = location
            self.userLocation=location
        }
    }
    
    // Convert String address to location
    func convertAddress(startAddress: String?, endAddress: String) {
        let geoCoder = CLGeocoder()

        if let startText = startAddress, !startText.isEmpty {
            // Start location is provided by the user
            geoCoder.geocodeAddressString(startText) { startPlacemarks, error in
                if let startPlacemark = startPlacemarks?.first, let startLocation = startPlacemark.location {
                    self.geoCodeEndAddress(geoCoder: geoCoder, endAddress: endAddress, startLocation: startLocation)
                } else {
                    print("Start location not found")
                }
            }
        } else {
            // Use current location as the start point
            guard let userLocation = userLocation else {
                print("User location not available")
                return
            }
            self.geoCodeEndAddress(geoCoder: geoCoder, endAddress: endAddress, startLocation: userLocation)
        }
    }
    
    private func geoCodeEndAddress(geoCoder: CLGeocoder, endAddress: String, startLocation: CLLocation) {
        geoCoder.geocodeAddressString(endAddress) { endPlacemarks, error in
            if let endPlacemark = endPlacemarks?.first, let endLocation = endPlacemark.location {
                // Show route on the map
                self.showRoute(sourceCoordinate: startLocation.coordinate, destinationCoordinate: endLocation.coordinate, transportType: self.currentTransportType)
            } else {
                print("End location not found")
            }
        }
    }
 
    func showRoute(sourceCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D, transportType: MKDirectionsTransportType) {
        // Remove previous overlays and annotations
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        
        // Add annotations for source and destination
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.coordinate = sourceCoordinate
        sourceAnnotation.title = "Start Location"
        mapView.addAnnotation(sourceAnnotation)
        
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.coordinate = destinationCoordinate
        destinationAnnotation.title = "End Location"
        mapView.addAnnotation(destinationAnnotation)

        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        let destinationRequest = MKDirections.Request()

        // Start and end points
        destinationRequest.source = sourceItem
        destinationRequest.destination = destinationItem
        destinationRequest.transportType = transportType

        // Submit request to calculate directions
        let directions = MKDirections(request: destinationRequest)

        directions.calculate { (response, error) in
            // Handle response and error
            guard let route = response?.routes.first, error == nil else {
                print("Error calculating directions:", error?.localizedDescription ?? "Unknown error")
                return
            }

            // Adding overlay to the map for the route
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            
            
            // Print route information
            print("Start Location: \( self.startLocationTextField?.text ?? "Unknown")")
            print("End Location: \( self.endLocationTextField?.text ?? "Unknown")")
            print("Distance: \(route.distance / 1000.0) Km")
            print("Transportation Type: \(self.getTransportTypeString(from: transportType))")
            
            self.saveRouteToCoreData(startLocation: self.startLocationTextField?.text ?? "Unknown", endLocation: self.endLocationTextField?.text ?? "Unknown", distance: route.distance / 1000.0, transportType:transportType)
            
        }
    }

    func getTransportTypeString(from transportType: MKDirectionsTransportType) -> String {
        switch transportType {
        case .automobile:
            return "Car"
        case .walking:
            return "Walking"
        case .transit:
            return "Transit"
        default:
            return "Unknown"
        }
    }

    // Create a polyline overlay
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            // Set different line styles based on transport type
            switch currentTransportType {
            case .automobile:
                renderer.strokeColor = .systemBlue // Solid blue line for automobile
            case .walking:
                renderer.strokeColor = .systemOrange // Dashed green line for walking
                renderer.lineDashPattern = [2, 5]
            case .transit:
                renderer.strokeColor = .systemOrange // Orange line for transit
            default:
                renderer.strokeColor = .systemBlue // Default to blue for any other transport type
            }
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer()
    }

    func saveRouteToCoreData(route: MKRoute, startPoint: MKPlacemark, endPoint: MKPlacemark, transportType: MKDirectionsTransportType) {
        let entity = NSEntityDescription.entity(forEntityName: "Direction", in: content)!
        let routeObject = NSManagedObject(entity: entity, insertInto: content)
        
        // Convert MKPlacemark to string
        let startPointString = "\(startPoint.coordinate.latitude), \(startPoint.coordinate.longitude)"
        let endPointString = "\(endPoint.coordinate.latitude), \(endPoint.coordinate.longitude)"
        
        // Set properties of routeObject
        routeObject.setValue(route.distance, forKey: "distance")
        routeObject.setValue(startPointString, forKey: "startPoint")
        routeObject.setValue(endPointString, forKey: "endPoint")
        routeObject.setValue(transportType.rawValue.trailingZeroBitCount, forKey: "transportType")
        
        // Save changes
        do {
            try content.save()
            print("Route saved to CoreData")
        } catch {
            print("Error saving route to CoreData: \(error.localizedDescription)")
        }
    }

    
    func saveRouteToCoreData(startLocation: String?, endLocation: String, distance: CLLocationDistance, transportType: MKDirectionsTransportType) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let directionEntity = NSEntityDescription.entity(forEntityName: "Direction", in: managedContext)!
        let directionObject = Direction(entity: directionEntity, insertInto: managedContext)
        
        // Set properties of directionObject
        if(startLocation == ""){
            directionObject.startPoint = "Cupertino"
        }
        else{
            directionObject.startPoint = startLocation
        }
       
        directionObject.endPoint = endLocation
        directionObject.distance = distance
        directionObject.transportType = self.getTransportTypeString(from: transportType)
        
        // Create or fetch HistoryData
        let historyDataFetchRequest: NSFetchRequest<HistoryData> = HistoryData.fetchRequest()
        historyDataFetchRequest.predicate = NSPredicate(format: "historyID == %@", startLocation!)
        let historyData: HistoryData
        do {
            let results = try managedContext.fetch(historyDataFetchRequest)
            if let existingHistoryData = results.first {
                historyData = existingHistoryData
            } else {
                let newHistoryData = HistoryData(context: managedContext)
                newHistoryData.historyID = 1
                historyData = newHistoryData
            }
        } catch {
            print("Error fetching or creating HistoryData:", error)
            return
        }
        
        // Associate Direction with HistoryData
        directionObject.historyData = historyData
        
        do {
            try managedContext.save()
            print("Route saved to CoreData")
        } catch let error as NSError {
            print("Could not save route to CoreData. \(error), \(error.userInfo)")
        }
    }

}
