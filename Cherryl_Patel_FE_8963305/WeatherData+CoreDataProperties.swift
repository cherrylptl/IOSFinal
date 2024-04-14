import Foundation
import CoreData


extension WeatherData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeatherData> {
        return NSFetchRequest<WeatherData>(entityName: "WeatherData")
    }

    @NSManaged public var cityName: String?
    @NSManaged public var humidity: Int16
    @NSManaged public var temperature: Double
    @NSManaged public var wind: Double
    @NSManaged public var historyData: HistoryData?
    @NSManaged public var date: String?
    @NSManaged public var time: String?

}

extension WeatherData : Identifiable {

}
