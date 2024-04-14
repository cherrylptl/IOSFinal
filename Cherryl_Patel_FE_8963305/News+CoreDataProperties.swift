
import Foundation
import CoreData


extension News {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<News> {
        return NSFetchRequest<News>(entityName: "News")
    }

    @NSManaged public var author: String?
    @NSManaged public var cityName: String?
    @NSManaged public var discription: String?
    @NSManaged public var source: String?
    @NSManaged public var title: String?
    @NSManaged public var historyData: HistoryData?

}

extension News : Identifiable {

}
