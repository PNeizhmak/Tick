//
//  TimerOverlayController.swift
//  Tick
//
//  Created by Pavel Neizhmak on 01/01/2025.
//

import Cocoa

class TimerOverlayController: NSWindowController {
    private var progressBar: NSView!
    private var progressWidthConstraint: NSLayoutConstraint!
    private var overlayWindows: [NSWindow] = []
    private var progressBars: [NSView] = []
    private var progressWidthConstraints: [NSLayoutConstraint] = []
    private var timerManager: TimerManager?

    init(timerManager: TimerManager? = nil) {
        self.timerManager = timerManager
        
        let dummyWindow = NSPanel(
            contentRect: .zero,
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        super.init(window: dummyWindow)
        
        setupOverlayWindows()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTimerManager(_ manager: TimerManager) {
        self.timerManager = manager
    }

    private func setupOverlayWindows() {
        // Clear existing windows
        overlayWindows.forEach { $0.close() }
        overlayWindows.removeAll()
        progressBars.removeAll()
        progressWidthConstraints.removeAll()

        let selectedMonitors = PreferencesManager.shared.getSelectedMonitors()

        print("Setting up overlay windows:")
        print("Selected monitors: \(selectedMonitors)")
        print("Available screens: \(NSScreen.screens.map { $0.localizedName })")

        for screen in NSScreen.screens {
            if selectedMonitors.contains(screen.localizedName) {
                print("Creating overlay for screen: \(screen.localizedName)")
                createOverlayWindow(for: screen)
            }
        }
    }

    private func createOverlayWindow(for screen: NSScreen) {
        let screenFrame = screen.frame
        let visibleFrame = screen.visibleFrame
        let menuBarHeight = max(screenFrame.height - (visibleFrame.origin.y + visibleFrame.height), 22.0)

        print("Creating window for screen: \(screen.localizedName)")
        print("Screen frame: \(screenFrame)")
        print("Visible frame: \(visibleFrame)")
        print("Menu bar height: \(menuBarHeight)")

        let windowFrame = NSRect(
            x: screenFrame.origin.x,
            y: screenFrame.origin.y + screenFrame.height - menuBarHeight,
            width: screenFrame.width,
            height: menuBarHeight
        )

        let overlayWindow = NSPanel(
            contentRect: windowFrame,
            styleMask: [.nonactivatingPanel, .fullSizeContentView, .borderless],
            backing: .buffered,
            defer: false
        )
        
        overlayWindow.isFloatingPanel = true
        overlayWindow.level = .statusBar
        overlayWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        overlayWindow.backgroundColor = .clear
        overlayWindow.isOpaque = false
        overlayWindow.ignoresMouseEvents = true
        overlayWindow.hasShadow = false
        
        let progressBar = NSView(frame: .zero)
        progressBar.wantsLayer = true
        progressBar.layer?.backgroundColor = NSColor.systemBlue.withAlphaComponent(0.8).cgColor
        progressBar.layer?.cornerRadius = 2.0
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        
        if overlayWindow.contentView == nil {
            overlayWindow.contentView = NSView(frame: NSRect(x: 0, y: 0, width: screenFrame.width, height: menuBarHeight))
        }
        
        overlayWindow.contentView?.addSubview(progressBar)

        let progressWidthConstraint = progressBar.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            progressBar.leadingAnchor.constraint(equalTo: overlayWindow.contentView!.leadingAnchor),
            progressBar.topAnchor.constraint(equalTo: overlayWindow.contentView!.topAnchor, constant: 0),
            progressBar.bottomAnchor.constraint(equalTo: overlayWindow.contentView!.bottomAnchor, constant: 0),
            progressWidthConstraint
        ])

        overlayWindows.append(overlayWindow)
        progressBars.append(progressBar)
        progressWidthConstraints.append(progressWidthConstraint)

        DispatchQueue.main.async {
            overlayWindow.setFrame(windowFrame, display: true)
            
            if let windowScreen = overlayWindow.screen, windowScreen != screen {
                print("Window was assigned to wrong screen, fixing...")
                overlayWindow.setFrame(windowFrame, display: true)
            }
        }

        print("Window created successfully for screen: \(screen.localizedName)")
        print("Window frame: \(overlayWindow.frame)")
        print("Window screen: \(overlayWindow.screen?.localizedName ?? "unknown")")
    }

    func update(progress: Double, color: NSColor) {
        for (index, window) in overlayWindows.enumerated() {
            guard let totalWidth = window.contentView?.bounds.width else { continue }
            progressWidthConstraints[index].constant = max(CGFloat(progress) * totalWidth, 0)

            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.3
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                window.contentView?.layoutSubtreeIfNeeded()
            }

            if progressBars[index].layer?.backgroundColor != color.withAlphaComponent(0.4).cgColor {
                let flashAnimation = CABasicAnimation(keyPath: "opacity")
                flashAnimation.fromValue = 1.0
                flashAnimation.toValue = 0.3
                flashAnimation.duration = 0.2
                flashAnimation.autoreverses = true
                flashAnimation.repeatCount = 1
                progressBars[index].layer?.add(flashAnimation, forKey: "flash")
            }

            progressBars[index].layer?.backgroundColor = color.withAlphaComponent(0.4).cgColor
        }
    }
    
    func currentProgressBarColor() -> NSColor? {
        guard let firstBar = progressBars.first,
              let cgColor = firstBar.layer?.backgroundColor else {
            return nil
        }
        return NSColor(cgColor: cgColor)
    }

    func showWindows() {
        print("Showing \(overlayWindows.count) windows")
        overlayWindows.forEach { window in
            print("Showing window at frame: \(window.frame)")
            print("Window screen: \(window.screen?.localizedName ?? "unknown")")
            
            if let screen = window.screen {
                let screenFrame = screen.frame
                let visibleFrame = screen.visibleFrame
                let menuBarHeight = max(screenFrame.height - (visibleFrame.origin.y + visibleFrame.height), 22.0)
                
                let windowFrame = NSRect(
                    x: screenFrame.origin.x,
                    y: screenFrame.origin.y + screenFrame.height - menuBarHeight,
                    width: screenFrame.width,
                    height: menuBarHeight
                )
                
                window.setFrame(windowFrame, display: true)
            }
            
            window.orderFront(nil)
            window.makeKeyAndOrderFront(nil)
        }
    }

    func hideWindows() {
        print("Hiding \(overlayWindows.count) windows")
        overlayWindows.forEach { $0.orderOut(nil) }
    }

    func refreshWindows() {
        print("Refreshing overlay windows")
        // Store current timer state if running
        let wasRunning = timerManager?.isTimerRunning ?? false
        let currentProgress = timerManager?.remainingTime ?? 0
        let currentColor = currentProgressBarColor()
        
        hideWindows()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.setupOverlayWindows()
            
            if wasRunning {
                self.update(progress: currentProgress / (self.timerManager?.totalTime ?? 1), color: currentColor ?? .systemBlue)
                self.showWindows()
            }
        }
    }
}
