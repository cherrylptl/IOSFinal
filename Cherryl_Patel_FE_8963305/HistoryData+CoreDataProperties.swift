
import Foundation
import CoreData


extension HistoryData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HistoryData> {
        return NSFetchRequest<HistoryData>(entityName: "HistoryData")
    }

    @NSManaged public var historyID: Int16
    @NSManaged public var direction: NSSet?
    @NSManaged public var news: NSSet?
    @NSManaged public var weatherData: NSSet?

}

// MARK: Generated accessors for direction
extension HistoryData {

    @objc(addDirectionObject:)
    @NSManaged public func addToDirection(_ value: Direction)

    @objc(removeDirectionObject:)
    @NSManaged public func removeFromDirection(_ value: Direction)

    @objc(addDirection:)
    @NSManaged public func addToDirection(_ values: NSSet)

    @objc(removeDirection:)
    @NSManaged public func removeFromDirection(_ values: NSSet)

}

// MARK: Generated accessors for news
extension HistoryData {

    @objc(addNewsObject:)
    @NSManaged public func addToNews(_ value: News)

    @objc(removeNewsObject:)
    @NSManaged public func removeFromNews(_ value: News)

    @objc(addNews:)
    @NSManaged public func addToNews(_ values: NSSet)

    @objc(removeNews:)
    @NSManaged public func removeFromNews(_ values: NSSet)

}

// MARK: Generated accessors for weatherData
extension HistoryData {

    @objc(addWeatherDataObject:)
    @NSManaged public func addToWeatherData(_ value: WeatherData)

    @objc(removeWeatherDataObject:)
    @NSManaged public func removeFromWeatherData(_ value: WeatherData)

    @objc(addWeatherData:)
    @NSManaged public func addToWeatherData(_ values: NSSet)

    @objc(removeWeatherData:)
    @NSManaged public func removeFromWeatherData(_ values: NSSet)

}

extension HistoryData : Identifiable {

}
