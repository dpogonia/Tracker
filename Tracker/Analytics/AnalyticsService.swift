import Foundation

#if canImport(AppMetricaCore)
import AppMetricaCore
#endif

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

    func report(
        event: AnalyticsEvent,
        screen: AnalyticsScreen,
        item: AnalyticsItem? = nil
    ) {
        var parameters = [
            "event": event.rawValue,
            "screen": screen.rawValue
        ]
        if let item {
            parameters["item"] = item.rawValue
        }
#if canImport(AppMetricaCore)
        AppMetrica.reportEvent(name: screen.rawValue, parameters: parameters, onFailure: nil)
#endif
        print("AppMetrica:", parameters)
    }
}
