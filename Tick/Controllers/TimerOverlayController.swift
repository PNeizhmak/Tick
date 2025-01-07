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

    init() {
        guard let screen = NSScreen.main else {
            fatalError("No main screen available.")
        }
        
        let screenFrame = screen.frame
        let visibleFrame = screen.visibleFrame
        let menuBarHeight = screenFrame.height - (visibleFrame.origin.y + visibleFrame.height)

        let overlayWindow = NSPanel(
            contentRect: NSRect(x: screenFrame.origin.x,
                                y: screenFrame.origin.y + screenFrame.height - menuBarHeight,
                                width: screenFrame.width,
                                height: menuBarHeight),
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        overlayWindow.isFloatingPanel = true
        overlayWindow.level = .statusBar
        overlayWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        overlayWindow.backgroundColor = .clear
        overlayWindow.isOpaque = false
        overlayWindow.ignoresMouseEvents = true

        super.init(window: overlayWindow)
        setupContent()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupContent() {
        guard let contentView = window?.contentView else { return }

        progressBar = NSView(frame: .zero)
        progressBar.wantsLayer = true
        progressBar.layer?.backgroundColor = NSColor.systemBlue.withAlphaComponent(0.8).cgColor
        progressBar.layer?.cornerRadius = 2.0
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(progressBar)

        progressWidthConstraint = progressBar.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            progressBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            progressBar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            progressBar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            progressWidthConstraint
        ])
    }

    func update(progress: Double, color: NSColor) {
        guard let totalWidth = window?.contentView?.bounds.width else { return }
        progressWidthConstraint.constant = max(CGFloat(progress) * totalWidth, 0)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.window?.contentView?.layoutSubtreeIfNeeded()
        }

        if progressBar.layer?.backgroundColor != color.withAlphaComponent(0.4).cgColor {
            let flashAnimation = CABasicAnimation(keyPath: "opacity")
            flashAnimation.fromValue = 1.0
            flashAnimation.toValue = 0.3
            flashAnimation.duration = 0.2
            flashAnimation.autoreverses = true
            flashAnimation.repeatCount = 1
            progressBar.layer?.add(flashAnimation, forKey: "flash")
        }

        progressBar.layer?.backgroundColor = color.withAlphaComponent(0.4).cgColor
    }
    
    func currentProgressBarColor() -> NSColor? {
        guard let cgColor = progressBar.layer?.backgroundColor else {
            return nil
        }
        return NSColor(cgColor: cgColor)
    }
}
