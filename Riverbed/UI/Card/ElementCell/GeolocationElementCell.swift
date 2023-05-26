import UIKit
import MapKit

class GeolocationElementCell: UITableViewCell, ElementCell {

    weak var delegate: ElementCellDelegate?

    enum ValueKey: String {
        case latitude = "lat"
        case longitude = "lng"
    }

    @IBOutlet private(set) var elementLabel: UILabel!
    @IBOutlet private(set) var latitudeTextField: UITextField!
    @IBOutlet private(set) var longitudeTextField: UITextField!
    @IBOutlet private(set) var mapView: MKMapView!
    @IBOutlet private(set) var currentLocationButton: UIButton!
    @IBOutlet private(set) var directionsButton: UIButton!

    func update(for element: Element, and card: Card) {
        elementLabel.text = element.attributes.name

        let value = card.attributes.fieldValues[element.id]
        if case let .dictionary(dictValue) = value,
           let latitudeString = dictValue[ValueKey.latitude.rawValue],
           let longitudeString = dictValue[ValueKey.longitude.rawValue] {
            latitudeTextField.text = latitudeString
            longitudeTextField.text = longitudeString

            if let latitudeDouble = Double(latitudeString),
               let longitudeDouble = Double(longitudeString) {
                let coordinate = CLLocationCoordinate2D(latitude: latitudeDouble,
                                                        longitude: longitudeDouble)
                mapView.region = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01,
                                           longitudeDelta: 0.01))
                let pin = MKPointAnnotation()
                pin.coordinate = coordinate
                mapView.addAnnotation(pin)
            }
        }
    }

    @IBAction func getCurrentLocation() {
        // TODO: implement
        print("getCurrentLocation")
    }

    @IBAction func getDirections() {
        // TODO: implement
        print("getDirections")
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        let isEnabled = !editing

        [
            currentLocationButton,
            directionsButton,
            latitudeTextField,
            longitudeTextField
        ].forEach { $0.isEnabled = isEnabled }

        mapView.isZoomEnabled = isEnabled
        mapView.isScrollEnabled = isEnabled
    }
}
