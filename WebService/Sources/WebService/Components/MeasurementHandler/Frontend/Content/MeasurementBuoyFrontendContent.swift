import Apodini
import FluentKit
import Shared
import Foundation

struct MeasurementBuoyFrontendContent: Content, Decodable {
    public var measurements: [MeasurementFrontendBuoyValueContent]
}

struct MeasurementFrontendBuoyValueContent: Content, Decodable {
    public var sensorTypeID: SensorTypeContent
    public var date: Date
    public var value: Double
}
