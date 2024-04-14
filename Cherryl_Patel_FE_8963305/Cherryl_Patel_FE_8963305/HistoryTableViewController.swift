import UIKit
import CoreData

class HistoryTableViewController: UITableViewController {
    
    var historydata: [HistoryData]=[]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register custom cell classes with the table view
        tableView.register(UINib(nibName: "DirectionTableViewCell", bundle: nil), forCellReuseIdentifier: "DirectionCell")
        tableView.register(UINib(nibName: "NewsHistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "NewsHistoryCell")
        tableView.register(UINib(nibName: "WeatherTableViewCell", bundle: nil), forCellReuseIdentifier: "WeatherCell")
            
        fetchHistoryData()
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

    override func numberOfSections(in tableView: UITableView) -> Int {
            return 1 // One section for each type of data
        }
        

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historydata.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let history = historydata[indexPath.row]
        
        if let directionSet = history.direction as? Set<Direction>, let direction = directionSet.first {
            // Direction cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "DirectionCell", for: indexPath) as! DirectionTableViewCell
            // Configure DirectionTableViewCell with direction data
            cell.city.text = direction.startPoint
            cell.dataFrom.text = "From Map"
            cell.startPoint.text = direction.startPoint
            cell.endPoint.text = direction.endPoint
            cell.travelMethod.text = direction.transportType
            cell.totalDistance.text = "\(String(format: "%.2f", direction.distance)) Km"
            cell.sceneType.text = "Direction"
            return cell
        } else if let newsSet = history.news as? Set<News>, let news = newsSet.first {
            // News cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsHistoryCell", for: indexPath) as! NewsHistoryTableViewCell
            // Configure NewsTableViewCell with article data
            cell.sceneType.text = "News"
            cell.cityName.text = news.cityName 
            cell.dataFrom.text = "From News"
            cell.title.text = news.title
            cell.discription.text = news.discription
            cell.source.text = news.source
            cell.author.text = news.author
            return cell
        } else if let weatherSet = history.weatherData as? Set<WeatherData>, let weather = weatherSet.first {
            // Weather cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath) as! WeatherTableViewCell
            
            // Configure WeatherTableViewCell with weather data
            cell.city.text = weather.cityName
            cell.dataFrom.text = "From Weather"
            cell.date.text = weather.date
            cell.time.text = weather.time
            cell.temp.text = "\(weather.temperature) °C"
            cell.humidity.text = "\(weather.humidity)%"
            cell.wind.text = "\(weather.wind) km/h"
            cell.sceneType.text = "Weather"
            return cell
        } else {
            // Fallback cell if none of the data types match
            let cell = tableView.dequeueReusableCell(withIdentifier: "FallbackCell", for: indexPath)
            // Configure fallback cell
            cell.textLabel?.text = "Unknown data type"
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove the item from the data source
            let deletedHistory = historydata.remove(at: indexPath.row)
            print("Deleting item at index:", indexPath.row)
            // Remove the item from Core Data
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            context.delete(deletedHistory)
            
            // Save the changes to Core Data
            do {
                try context.save()
                print("History data deleted successfully")
                
                // Fetch data again
                fetchHistoryData()
                
                // Reload the table view
                tableView.reloadData()
            } catch {
                print("Error deleting history data: \(error.localizedDescription)")
            }
        }
    }

}
