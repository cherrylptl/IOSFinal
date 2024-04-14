import UIKit
import CoreData
import CoreLocation

class WeatherViewController: UIViewController,CLLocationManagerDelegate {

     @IBOutlet weak var searchCity: UILabel!
     @IBOutlet weak var city: UILabel!
     @IBOutlet weak var weather: UILabel!
     @IBOutlet weak var weatherIcon: UIImageView!
     @IBOutlet weak var temperature: UILabel!
     @IBOutlet weak var humidity: UILabel!
     @IBOutlet weak var windSpeed: UILabel!
    
   
    @IBAction func homeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func addButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Where would you like to go?\nEnter your new destination here", message: nil, preferredStyle: .alert)
            
            var destinationTextField: UITextField?
            
            alertController.addTextField { textField in
                textField.placeholder = "Destination"
                destinationTextField = textField
            }
            
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        let goButton = UIAlertAction(title: "Go", style: .default) { [self] _ in
                if let destination = destinationTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    // Convert the destination address to location and retrieve weather data
                    self.convertAddress(address: destination)
                }
            }
            
            alertController.addAction(cancelButton)
            alertController.addAction(goButton)
            
            present(alertController, animated: true)
        }
       
     var Locationlatitude : Double = 0.0
     var Locationlongitude : Double = 0.0
     let apiKeyID = "d324702e67d2d8f98ceb69c10631e313"
     
     let locationManager : CLLocationManager = CLLocationManager()
     var historydata: [HistoryData]=[]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
       
       
    }
    func fetchHistoryData() {
 
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            // Fetch HistoryData
            let historyFetchRequest: NSFetchRequest<HistoryData> = HistoryData.fetchRequest()
            do {
                historydata = try context.fetch(historyFetchRequest)
            } catch {
                print("Error fetching HistoryData: \(error.localizedDescription)")
            }
        }
   
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
          if let location = locations.first {
            Locationlatitude = location.coordinate.latitude
            Locationlongitude = location.coordinate.longitude
            getWeather(latitude: Locationlatitude, longitude: Locationlongitude,destination: "")
              locationManager.stopUpdatingLocation()
          }
        }

    //Get Weather Data
    func getWeather(latitude: Double, longitude: Double, destination: String) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKeyID)&units=metric") else {
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

                DispatchQueue.main.async {
                    self.city.text = weatherData.name
                    self.searchCity.text = weatherData.name
                    self.weather.text = weatherData.weather.last?.main
                    
                    if let url = URL(string: "https://openweathermap.org/img/wn/\(weatherData.weather.last?.icon ?? "").png") {
                        self.getWeatherIcon(from: url)
                    }
                    
                    self.temperature.text = "\(weatherData.main.temp) °C"
                    self.humidity.text = "Humidity: \(weatherData.main.humidity) %"
                    self.windSpeed.text = "Wind: \(weatherData.wind.speed!*3.6.rounded()) km/h"
                }
                // Call the method to save weather data to Core Data here
                self.saveWeatherDataToCoreData(cityName: weatherData.name, humidity: weatherData.main.humidity, temperature: weatherData.main.temp, wind: weatherData.wind.speed!*3.6.rounded())
               
            } catch {
                print("Error decoding JSON:", error)
            }
            
        }
        task.resume()
    }


    func saveWeatherDataToCoreData(cityName: String, humidity: Int, temperature: Double, wind: Double) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let weatherEntity = NSEntityDescription.entity(forEntityName: "WeatherData", in: managedContext)!

        let weatherObject = WeatherData(entity: weatherEntity, insertInto: managedContext)
        weatherObject.cityName = cityName
        weatherObject.humidity = Int16(humidity)
        weatherObject.temperature = temperature
        weatherObject.wind = wind
        // Get the current date
        let currentDate = Date()

        // Create a date formatter for the date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium

        // Create a date formatter for the time
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .medium

        // Format the current date and time separately as strings
        let formattedDate = dateFormatter.string(from: currentDate)
        let formattedTime = timeFormatter.string(from: currentDate)
        
        weatherObject.time = formattedTime
        weatherObject.date = formattedDate

        do {
            try managedContext.save()
            print("Weather data saved to CoreData")

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
                    fetchHistoryData()
                    newHistoryData.historyID = 1
                    historyData = newHistoryData
                }
            } catch {
                print("Error fetching or creating HistoryData:", error)
                return
            }

            // Associate WeatherData with HistoryData
            weatherObject.historyData = historyData
            try managedContext.save()
            print("Weather data associated with HistoryData")

        } catch let error as NSError {
            print("Could not save weather data to CoreData. \(error), \(error.userInfo)")
        }
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
              self.weatherIcon.image = image
            }
          }.resume()
        }
    
    // convert string address to location
    func convertAddress(address: String) {
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(address) { placemarks, error in
            guard let placemarks = placemarks, let location = placemarks.first?.location else {
                print("No location found")
                return
            }
            print(location)
         
            self.locationManager.stopUpdatingLocation()
            
            self.getWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, destination: address)
        }
    }

    
}
