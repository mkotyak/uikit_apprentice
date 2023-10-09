import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    @IBOutlet var mapView: MKMapView!
    
    private var locations: [Location] = []
    
    var managedObjectContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLocations()
    }
    
    // MARK: - Actions
    
    @IBAction func showUser() {
        let region = MKCoordinateRegion(
            center: mapView.userLocation.coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        )
        
        mapView.setRegion(
            mapView.regionThatFits(region),
            animated: true
        )
    }
    
    @IBAction func showLocations() {
        
    }
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    
}

// MARK: - Helper methods

extension MapViewController {
    func updateLocations() {
        mapView.removeAnnotations(locations)
        
        let entity = Location.entity()
        
        let fetchRequest = NSFetchRequest<Location>()
        fetchRequest.entity = entity
        
        locations = try! managedObjectContext.fetch(fetchRequest)
        
        mapView.addAnnotations(locations)
    }
}
