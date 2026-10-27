//
//  LocationFetcher.swift
//  Landmark
//

import CoreLocation

/// The location lookups the add-landmark flow needs, so tests can swap in a mock.
protocol LocationProviding: AnyObject {
    func currentLocation() async -> CLLocation?
    func address(for location: CLLocation) async -> String?
}

/// One-shot async wrapper around `CLLocationManager.requestLocation()` plus reverse geocoding.
final class LocationFetcher: NSObject, CLLocationManagerDelegate, LocationProviding {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation?, Never>?

    override init() {
        super.init()
        self.manager.desiredAccuracy = kCLLocationAccuracyBest
        self.manager.delegate = self
    }

    /// Returns the user's current location, or nil if unavailable / not authorized.
    func currentLocation() async -> CLLocation? {
        switch self.manager.authorizationStatus {
        case .denied, .restricted:
            return nil
        default:
            break
        }

        // Only one request at a time.
        guard self.continuation == nil else { return nil }

        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            self.manager.requestLocation()
        }
    }

    /// Returns a human readable address for the location, or nil if one can't be determined.
    func address(for location: CLLocation) async -> String? {
        guard let placemark = try? await CLGeocoder().reverseGeocodeLocation(location).first else {
            return nil
        }

        let street = [placemark.subThoroughfare, placemark.thoroughfare]
            .compactMap { $0 }
            .joined(separator: " ")
        let parts = [street, placemark.locality, placemark.administrativeArea, placemark.postalCode]
            .compactMap { $0 }
            .filter { !$0.isEmpty }

        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.continuation?.resume(returning: locations.last)
        self.continuation = nil
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        debugPrint("LocationFetcher failed: \(error)")
        self.continuation?.resume(returning: nil)
        self.continuation = nil
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // If permission is granted while a request is pending, make sure it's issued.
        if self.continuation != nil,
           manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted
        {
            self.continuation?.resume(returning: nil)
            self.continuation = nil
        }
    }
}
