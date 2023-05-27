import UIKit
import MapKit

class GeolocationElementCell: UITableViewCell, ElementCell, UITextFieldDelegate {

    weak var delegate: ElementCellDelegate?

    private var element: Element?

    enum ValueKey: String {
        case latitude = "lat"
        case longitude = "lng"
    }

    @IBOutlet private(set) var elementLabel: UILabel!
    @IBOutlet private(set) var latitudeTextField: UITextField!
    @IBOutlet private(set) var longitudeTextField: UITextField!
    @IBOutlet private(set) var currentLocationButton: UIButton!
    @IBOutlet private(set) var directionsButton: UIButton!
    @IBOutlet private(set) var mapView: MKMapView! {
        didSet {
            let tapRecognizer = UITapGestureRecognizer(target: self,
                                                       action: #selector(didTapOnMapView(sender:)))
            mapView.addGestureRecognizer(tapRecognizer)
        }
    }

    private let pin = MKPointAnnotation()

    func update(for element: Element, and card: Card) {
        self.element = element

        elementLabel.text = element.attributes.name

        [latitudeTextField, longitudeTextField].forEach { (field) in
            field?.layer.cornerRadius = 5
            field?.layer.borderWidth = 1
            field?.layer.borderColor = UIColor.separator.cgColor
        }

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
                pin.coordinate = coordinate
                mapView.addAnnotation(pin)
            } else {
                mapView.removeAnnotation(pin)
            }
        } else {
            mapView.removeAnnotation(pin)
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

    func textFieldDidChangeSelection(_ textField: UITextField) {
        passUpdatedValueToDelegate()
    }

    @objc func didTapOnMapView(sender: UITapGestureRecognizer) {
        guard case .ended = sender.state else { return } // may not be needed for single tap

        // get coordinate
        let point = sender.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)

        // update pin and fields with coordinate
        pin.coordinate = coordinate
        mapView.region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01,
                                   longitudeDelta: 0.01))
        latitudeTextField.text = String(coordinate.latitude)
        longitudeTextField.text = String(coordinate.longitude)

        passUpdatedValueToDelegate()
    }

    func passUpdatedValueToDelegate() {
        guard let element = element else { return }

        if let latitudeString = latitudeTextField.text,
           let longitudeString = longitudeTextField.text {
            let coords = FieldValue.dictionary([
                ValueKey.latitude.rawValue: latitudeString,
                ValueKey.longitude.rawValue: longitudeString
            ])
            delegate?.update(value: coords, for: element)
        } else {
            delegate?.update(value: nil, for: element)
        }
    }
}
