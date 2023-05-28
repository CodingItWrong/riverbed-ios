import UIKit
import MapKit
import CoreLocation

class GeolocationElementCell: UITableViewCell,
                              ElementCell,
                              UITextFieldDelegate,
                              CLLocationManagerDelegate {

    weak var delegate: ElementCellDelegate?

    private lazy var locationManager = CLLocationManager()

    private var requestedLocation = false

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

    func update(for element: Element, and card: Card, allElements: [Element]) {
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
        } else {
            latitudeTextField.text = ""
            longitudeTextField.text = ""
        }
        updateMapFromCoordinate()

        updateLocationButtonEnabledness()
    }

    @IBAction func getDirections() {
        // TODO: implement
        print("getDirections")
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        let isEnabled = !editing

        [
            directionsButton,
            latitudeTextField,
            longitudeTextField
        ].forEach { $0.isEnabled = isEnabled }
        updateLocationButtonEnabledness()

        mapView.isZoomEnabled = isEnabled
        mapView.isScrollEnabled = isEnabled
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateMapFromCoordinate()
        passUpdatedValueToDelegate()
    }

    @objc func didTapOnMapView(sender: UITapGestureRecognizer) {
        guard case .ended = sender.state else { return } // may not be needed for single tap

        // get coordinate
        let point = sender.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)

        // update pin and fields with coordinate
        latitudeTextField.text = String(format: "%.5f", coordinate.latitude)
        longitudeTextField.text = String(format: "%.5f", coordinate.longitude)

        updateMapFromCoordinate()
        passUpdatedValueToDelegate()
    }

    func updateMapFromCoordinate() {
        if let latitudeString = latitudeTextField.text,
           let longitudeString = longitudeTextField.text,
           let latitudeDouble = Double(latitudeString),
           let longitudeDouble = Double(longitudeString) {
            let coordinate = CLLocationCoordinate2D(latitude: latitudeDouble,
                                                    longitude: longitudeDouble)
            pin.coordinate = coordinate
            mapView.region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01,
                                       longitudeDelta: 0.01))
            mapView.addAnnotation(pin)
        } else {
            mapView.removeAnnotation(pin)
        }

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

    @IBAction func getCurrentLocation() {
        locationManager.delegate = self
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            requestedLocation = true
            locationManager.requestLocation()
        case .denied, .restricted:
            preconditionFailure("Button should have been disabled")
        @unknown default:
            print("Got an unexpected authorization status: \(String(describing: status))")
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        updateLocationButtonEnabledness()

        let status = locationManager.authorizationStatus
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        case .notDetermined:
            print("Still getting 'not determined' status after a change")
        case .denied, .restricted:
            print("Location permission was denied")
        @unknown default:
            print("Got an unexpected authorization status: \(String(describing: status))")
        }
    }

    func updateLocationButtonEnabledness() {
        if !isEditing {
            currentLocationButton.isEnabled = false
        }

        let status = locationManager.authorizationStatus
        switch status {
        case .denied, .restricted:
            currentLocationButton.isEnabled = false
        case .notDetermined, .authorizedAlways, .authorizedWhenInUse:
            currentLocationButton.isEnabled = true
        @unknown default:
            print("Got an unexpected authorization status: \(String(describing: status))")
            currentLocationButton.isEnabled = true
        }
    }

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        // delegate method sometimes called pre-emptively, like upon early instantiation
        guard requestedLocation == true else { return }
        requestedLocation = false

        guard let location = locations.first else { return }
        let coordinate = location.coordinate

        latitudeTextField.text = String(format: "%.5f", coordinate.latitude)
        longitudeTextField.text = String(format: "%.5f", coordinate.longitude)

        updateMapFromCoordinate()
        passUpdatedValueToDelegate()
    }

    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("Error getting location: \(String(describing: error))")
    }
}
