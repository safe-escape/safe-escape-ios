//
//  LocationUsecase.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/23/25.
//

import Foundation
import CoreLocation

class LocationUsecase: NSObject {
    static let shared = LocationUsecase()
    
    private var locationManager: CLLocationManager!
    private var continuation: CheckedContinuation<Coordinate, Error>?
    
    // 캐시된 위치 정보
    private var cachedLocation: Coordinate?
    private var cacheTimestamp: Date?
    private let cacheValidityDuration: TimeInterval = 60 // 1분
    
    override private init() {
        super.init()
        DispatchQueue.main.async {
            self.setupLocationManager()
        }
    }
    
    private func setupLocationManager() {
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        // 빠른 응답을 위해 정확도를 조금 낮춤 (약 10m 정확도)
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.distanceFilter = 50 // 50m 이상 이동할 때만 업데이트
    }
    
    // 사용자 현재 위치
    func getCurrentLocation() async throws -> Coordinate {
        // 캐시된 위치가 유효한지 확인 (캐시 시간을 1분으로 단축)
        if let cachedLocation = cachedLocation,
           let cacheTimestamp = cacheTimestamp,
           Date().timeIntervalSince(cacheTimestamp) < cacheValidityDuration {
            return cachedLocation
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                // 이미 요청이 진행 중인지 확인
                guard self.continuation == nil else {
                    continuation.resume(throwing: LocationError.requestInProgress)
                    return
                }
                
                self.continuation = continuation
                
                let status = self.locationManager.authorizationStatus
                
                switch status {
                case .notDetermined:
                    self.locationManager.requestWhenInUseAuthorization()
                case .denied, .restricted:
                    self.continuation = nil
                    continuation.resume(throwing: LocationError.permissionDenied)
                case .authorizedWhenInUse, .authorizedAlways:
                    if CLLocationManager.locationServicesEnabled() {
                        // 빠른 위치 가져오기를 위해 startUpdatingLocation 사용
                        self.locationManager.startUpdatingLocation()
                        
                        // 2초 타임아웃 설정
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            if self.continuation != nil {
                                self.locationManager.stopUpdatingLocation()
                                self.continuation?.resume(throwing: LocationError.timeout)
                                self.continuation = nil
                            }
                        }
                    } else {
                        self.continuation = nil
                        continuation.resume(throwing: LocationError.locationServicesDisabled)
                    }
                @unknown default:
                    self.continuation = nil
                    continuation.resume(throwing: LocationError.unknown)
                }
            }
        }
    }
    
    // 두 좌표간 직선 거리 계산
    func getDirectDistance(from start: Coordinate, to end: Coordinate) -> Double {
        let startLocation = CLLocation(latitude: start.latitude, longitude: start.longitude)
        let endLocation = CLLocation(latitude: end.latitude, longitude: end.longitude)
        
        return startLocation.distance(from: endLocation)
    }
    
    private func calculateDistance(from: Coordinate, to: Coordinate) -> Double {
        let earthRadius = 6371.0 // 지구 반지름 (km)
        
        let lat1Rad = from.latitude * .pi / 180
        let lat2Rad = to.latitude * .pi / 180
        let deltaLatRad = (to.latitude - from.latitude) * .pi / 180
        let deltaLonRad = (to.longitude - from.longitude) * .pi / 180
        
        let a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
                cos(lat1Rad) * cos(lat2Rad) *
                sin(deltaLonRad / 2) * sin(deltaLonRad / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        return earthRadius * c
    }

    // 좌표가 폴리곤 안에 위치해있는지 판단 (Winding Number 알고리즘 사용)
    func isCoordinateInsidePolygon(point: Coordinate,polygon: [Coordinate]) -> Bool {
        guard polygon.count >= 3 else { return false }
        var windingNumber = 0

        for i in 0..<polygon.count {
            let p1 = polygon[i]
            let p2 = polygon[(i + 1) % polygon.count]

            if p1.latitude <= point.latitude {
                if p2.latitude > point.latitude { // upward crossing
                    if isLeft(p1, p2, point) > 0 {
                        windingNumber += 1
                    }
                }
            } else {
                if p2.latitude <= point.latitude { // downward crossing
                    if isLeft(p1, p2, point) < 0 {
                        windingNumber -= 1
                    }
                }
            }
        }

        return windingNumber != 0
    }

    // Winding Number
    // 벡터 cross product: point가 p1→p2 벡터 왼쪽에 있으면 양수
    private func isLeft(
        _ p1: Coordinate,
        _ p2: Coordinate,
        _ point: Coordinate
    ) -> Double {
        return (p2.longitude - p1.longitude) * (point.latitude - p1.latitude)
             - (point.longitude - p1.longitude) * (p2.latitude - p1.latitude)
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationUsecase: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            manager.stopUpdatingLocation()
            continuation?.resume(throwing: LocationError.locationNotFound)
            continuation = nil
            return
        }
        
        let coordinate = Coordinate(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        
        // 위치 정보 캐시 저장
        cachedLocation = coordinate
        cacheTimestamp = Date()
        
        // 위치 업데이트 중지
        manager.stopUpdatingLocation()
        
        continuation?.resume(returning: coordinate)
        continuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
        continuation?.resume(throwing: LocationError.locationFailed(error))
        continuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard let continuation = continuation else { return }
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            if CLLocationManager.locationServicesEnabled() {
                manager.startUpdatingLocation()
                
                // 2초 타임아웃 설정
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    if self.continuation != nil {
                        manager.stopUpdatingLocation()
                        self.continuation?.resume(throwing: LocationError.timeout)
                        self.continuation = nil
                    }
                }
            } else {
                continuation.resume(throwing: LocationError.locationServicesDisabled)
                self.continuation = nil
            }
        case .denied, .restricted:
            continuation.resume(throwing: LocationError.permissionDenied)
            self.continuation = nil
        case .notDetermined:
            // 계속 대기
            break
        @unknown default:
            continuation.resume(throwing: LocationError.unknown)
            self.continuation = nil
        }
    }
}

// MARK: - LocationError
enum LocationError: Error, LocalizedError {
    case permissionDenied
    case locationServicesDisabled
    case locationNotFound
    case locationFailed(Error)
    case requestInProgress
    case timeout
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "위치 접근 권한이 거부되었습니다."
        case .locationServicesDisabled:
            return "위치 서비스가 비활성화되어 있습니다."
        case .locationNotFound:
            return "현재 위치를 찾을 수 없습니다."
        case .locationFailed(let error):
            return "위치 조회 실패: \(error.localizedDescription)"
        case .requestInProgress:
            return "이미 위치 요청이 진행 중입니다."
        case .timeout:
            return "위치 조회 시간이 초과되었습니다."
        case .unknown:
            return "알 수 없는 위치 오류가 발생했습니다."
        }
    }
}

