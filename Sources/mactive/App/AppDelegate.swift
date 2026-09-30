import AppKit
import SwiftUI

@MainActor
public final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private let taskStore = TaskStore()
    private var eventMonitor: Any?
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        // Ensure app behaves as an accessory (Menu Bar only, no Dock icon)
        NSApp.setActivationPolicy(.accessory)
        
        setupStatusItem()
        setupPopover()
        
        taskStore.onCountChanged = { [weak self] in
            Task { @MainActor [weak self] in
                self?.updateStatusItem()
            }
        }
        
        updateStatusItem()
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let button = statusItem?.button else { return }
        
        button.target = self
        button.action = #selector(statusItemClicked(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }
    
    private func setupPopover() {
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 360, height: 460)
        popover.behavior = .transient
        popover.animates = true
        
        let contentView = ContentView(store: taskStore)
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover
    }
    
    public func updateStatusItem() {
        guard let button = statusItem?.button else { return }
        
        let pending = taskStore.activeCount
        let iconName = pending > 0 ? "checklist" : "checkmark.circle"
        
        let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        if let image = NSImage(systemSymbolName: iconName, accessibilityDescription: "Mactive")?.withSymbolConfiguration(config) {
            image.isTemplate = true
            button.image = image
            button.imagePosition = .imageLeft
        }
        
        if taskStore.showCountInMenuBar && pending > 0 {
            let font = NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .bold)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .baselineOffset: -0.5
            ]
            button.attributedTitle = NSAttributedString(string: " \(pending)", attributes: attributes)
        } else {
            button.attributedTitle = NSAttributedString(string: "")
        }
        
        button.toolTip = "Mactive - \(pending) tugas menunggu"
    }
    
    @objc private func statusItemClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else {
            togglePopover(sender)
            return
        }
        
        // Right click or Control+Click shows quick menu
        if event.type == .rightMouseUp || (event.type == .leftMouseUp && event.modifierFlags.contains(.control)) {
            showContextMenu(sender)
        } else {
            togglePopover(sender)
        }
    }
    
    private func togglePopover(_ sender: NSStatusBarButton) {
        guard let popover = popover else { return }
        
        if popover.isShown {
            closePopover()
        } else {
            showPopover(sender)
        }
    }
    
    private func showPopover(_ sender: NSStatusBarButton) {
        guard let popover = popover else { return }
        
        popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
        
        // Activate app so TextField receives key focus immediately
        NSApp.activate(ignoringOtherApps: true)
        
        // Start monitor for outside clicks (transient backup)
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.closePopover()
            }
        }
    }
    
    private func closePopover() {
        popover?.performClose(nil)
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
    
    private func showContextMenu(_ sender: NSStatusBarButton) {
        let menu = NSMenu()
        
        let pending = taskStore.activeCount
        let statusTitle = pending > 0 ? "\(pending) tugas belum selesai" : "Semua tugas selesai ✨"
        let headerItem = NSMenuItem(title: statusTitle, action: nil, keyEquivalent: "")
        headerItem.isEnabled = false
        menu.addItem(headerItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let openItem = NSMenuItem(title: "Buka Mactive", action: #selector(openFromMenu), keyEquivalent: "m")
        openItem.target = self
        menu.addItem(openItem)
        
        let clearItem = NSMenuItem(title: "Hapus yang Sudah Selesai", action: #selector(clearCompletedFromMenu), keyEquivalent: "")
        clearItem.target = self
        menu.addItem(clearItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Keluar dari Mactive", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        self.statusItem?.menu = menu
        self.statusItem?.button?.performClick(nil)
        self.statusItem?.menu = nil // Reset so normal left-click continues to toggle popover
    }
    
    @objc private func openFromMenu() {
        if let button = statusItem?.button {
            showPopover(button)
        }
    }
    
    @objc private func clearCompletedFromMenu() {
        taskStore.clearCompleted()
    }
    
    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
