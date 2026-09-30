import Foundation
import ServiceManagement

@available(macOS 13.0, *)
@MainActor
public final class LaunchAtLogin: ObservableObject {
    public static let shared = LaunchAtLogin()
    
    @Published public var isEnabled: Bool = false
    
    private init() {
        self.isEnabled = (SMAppService.mainApp.status == .enabled)
    }
    
    public func toggle() {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
            self.isEnabled = (SMAppService.mainApp.status == .enabled)
        } catch {
            print("Failed to toggle LaunchAtLogin: \(error.localizedDescription)")
            self.isEnabled = (SMAppService.mainApp.status == .enabled)
        }
    }
}
