
import Foundation
import CoreData


extension Direction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Direction> {
        return NSFetchRequest<Direction>(entityName: "Direction")
    }

    @NSManaged public var distance: Double
    @NSManaged public var endPoint: String?
    @NSManaged public var startPoint: String?
    @NSManaged public var transportType: String?
    @NSManaged public var historyData: HistoryData?

}

extension Direction : Identifiable {

}
