import CoreData
import MapKit
import Foundation

@objc(Location)
public class Location: NSManagedObject {}

extension Location: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public var title: String? {
        locationDescription.isEmpty ? "(No Description)" : locationDescription
    }
    
    public var subtitle: String? {
        category
    }
}
