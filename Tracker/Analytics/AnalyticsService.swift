import Foundation

#if canImport(AppMetricaCore)
import AppMetricaCore
#endif

enum AnalyticsEvent: String {
    case open
    case close
    case click
}

enum AnalyticsItem: String {
    case addTrack = "add_track"
    case track
    case filter
    case edit
    case delete
}

final class AnalyticsService {
    static let shared = AnalyticsService()

    private init() {}

    func activate() {
#if canImport(AppMetricaCore)
        guard
            let apiKey = Bundle.main.object(forInfoDictionaryKey: "APPMETRICA_API_KEY") as? String,
            !apiKey.isEmpty,
            let configuration = AppMetricaConfiguration(apiKey: apiKey)
        else { return }
        AppMetrica.activate(with: configuration)
#endif
    }

    func report(event: AnalyticsEvent, item: AnalyticsItem? = nil) {
        var parameters = [
            "event": event.rawValue,
            "screen": "Main"
        ]
        if let item {
            parameters["item"] = item.rawValue
        }
#if canImport(AppMetricaCore)
        AppMetrica.reportEvent(name: "Main", parameters: parameters, onFailure: nil)
#endif
        print("AppMetrica:", parameters)
    }
}
