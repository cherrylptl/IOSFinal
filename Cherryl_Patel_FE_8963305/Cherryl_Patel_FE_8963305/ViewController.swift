import UIKit
import CoreData
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var temperature: UILabel!
    
    @IBOutlet weak var humidity: UILabel!
    
    @IBOutlet weak var wind: UILabel!
    
    var Locationlatitude : Double = 0.0
    var Locationlongitude : Double = 0.0
    let apiKeyID = "d324702e67d2d8f98ceb69c10631e313"
    var historydata: [HistoryData]=[]
    
    
    @IBOutlet weak var weatherImage: UIImageView!

    let locationManager : CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        fetchHistoryData()

    }
    
    //location manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{

            render (location)
            Locationlatitude = location.coordinate.latitude
            Locationlongitude = location.coordinate.longitude
            getWeather(latitude: Locationlatitude, longitude: Locationlongitude)
        }
    }

    func render (_ location: CLLocation) {

        let coordinate = CLLocationCoordinate2D (latitude: location.coordinate.latitude, longitude: location.coordinate.longitude )

        //span settings determine how much to zoom into the map - defined details
        let span = MKCoordinateSpan(latitudeDelta: 4.9, longitudeDelta: 4.9)

        let region = MKCoordinateRegion(center: coordinate, span: span)

        let pin = MKPointAnnotation ()

        pin.coordinate = coordinate

        mapView.addAnnotation(pin)

        mapView.setRegion(region, animated: true)

    }
    
    
    //Get Weather Data
       func getWeather(latitude: Double, longitude: Double) {
           
         guard
           let url = URL(string:"https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKeyID)&units=metric")
         else {
           return
         }
           
         let task = URLSession.shared.dataTask(with: url) { data, response, error in
           if let error = error {
             print("Error:", error)
             return
           }

           guard let data = data else {
             print("No data Found")
             return
           }

           do {
             let jsonDecoder = JSONDecoder()
             let weatherData = try jsonDecoder.decode(Temperatures.self, from: data)

             //Update UI
             DispatchQueue.main.async {
                 
               //Set Weather
               if let url = URL(
                 string: "https://openweathermap.org/img/wn/\(weatherData.weather.last?.icon ?? "").png"
               ) {
                   
               //Set Weather Image
               self.getWeatherIcon(from: url)
               }
                 
               //Set Temperature
               self.temperature.text = "\(weatherData.main.temp) °C"
                 
               //Set Humidity
               self.humidity.text = "Humdity : \(weatherData.main.humidity) %"
                 
               //Set Wind Speed
               self.wind.text = "Wind : \(weatherData.wind.speed!*3.6.rounded()) km/h"
             }

           } catch {
             print("Error decoding JSON:", error)
           }
         }
         task.resume()
       }

       func getWeatherIcon(from url: URL) {
         URLSession.shared.dataTask(with: url) { (data, response, error) in
           guard let data = data else { return }

           if let error = error {
             print("Error downloading image: \(error.localizedDescription)")
             return
           }

           guard let image = UIImage(data: data) else {
             print("Failed to create image from data")
             return
           }

           DispatchQueue.main.async {
               
           //Set Weather Image
           self.weatherImage.image = image
           }
         }.resume()
       }
    
    func fetchHistoryData() {
 
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            // Fetch HistoryData
            let historyFetchRequest: NSFetchRequest<HistoryData> = HistoryData.fetchRequest()
            do {
                historydata = try context.fetch(historyFetchRequest)
                
                // Check if historydata is empty
                if historydata.isEmpty {
                    
                    // Add preloaded news data
                    saveNewsToCoreData(author: "Sarah Li", cityName: "Vancouver", discription: "Vancouver City Council has unanimously approved a comprehensive climate change action plan aimed at reducing greenhouse gas emissions and building resilience to climate impacts. The plan includes measures to promote renewable energy", source: "The Vancouver Sun", title: "Vancouver City Council Approves")
                    
                    saveNewsToCoreData(author: "Jessica Nguyen", cityName: "Montreal", discription: "Montreal Mayor Marie Leclerc has announced the launch of a new initiative aimed at supporting local businesses affected by the COVID-19 pandemic. ", source: "CBC News Montreal", title: "Montreal Mayor Unveils Support Package")
                    
                    saveNewsToCoreData(author: "Daniel Wong", cityName: "Calgary", discription: "Calgary has been selected as the host city for the upcoming International Technology Conference, bringing together industry leaders, innovators, and researchers from around the world. ", source: "CTV News Calgary", title: "Host City for International Technology Conference")
                    
                    saveNewsToCoreData(author: "Emily Patel", cityName: "Ottawa", discription: "Ottawa Mayor Sarah Thompson has announced the launch of a new bike share program aimed at promoting sustainable transportation options and reducing traffic congestion in the city.", source: "Ottawa Citizen", title: "New Bike Share Program to Encourage Sustainable Transportation")
                    
                    saveNewsToCoreData(author: "Michael Brown", cityName: "Halifax", discription: "Halifax City Council has approved a major waterfront development plan aimed at revitalizing the city's downtown core and enhancing public access to the waterfront.", source: "Global News Halifax", title: "Greenlights Waterfront Development Plan")
                    
                    historydata = try context.fetch(historyFetchRequest)
                    
                }
            } catch {
                print("Error fetching HistoryData: \(error.localizedDescription)")
            }
        }
    
        func saveNewsToCoreData(author:String, cityName: String, discription:String,source:String,title:String) {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
    
            let managedContext = appDelegate.persistentContainer.viewContext
            let newsEntity = NSEntityDescription.entity(forEntityName: "News", in: managedContext)!
    
            let newsObject = NSManagedObject(entity: newsEntity, insertInto: managedContext) as! News
            newsObject.author = author
            newsObject.cityName = cityName
            newsObject.discription = discription
            newsObject.source = source
            newsObject.title = title
    
            // Create or fetch HistoryData
            let historyDataFetchRequest: NSFetchRequest<HistoryData> = HistoryData.fetchRequest()
            historyDataFetchRequest.predicate = NSPredicate(format: "historyID == %@", cityName)
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
    
            // Associate News with HistoryData
            newsObject.historyData = historyData
    
            do {
                try managedContext.save()
                print("News saved to CoreData")
            } catch let error as NSError {
                print("Could not save news to CoreData. \(error), \(error.userInfo)")
            }
        }
}

