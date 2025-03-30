//
//  MenuManagerTests.swift
//  TickTests
//
//  Created by Pavel Neizhmak on 04/01/2025.
//

import XCTest
@testable import Tick

final class MenuManagerTests: XCTestCase {
    private var statusItem: NSStatusItem!
    private var appDelegate: AppDelegate!
    private var menuManager: MenuManager!
    
    override func setUpWithError() throws {
        super.setUp()
        PreferencesManager.resetForTesting()
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        appDelegate = AppDelegate()
        menuManager = MenuManager(statusItem: statusItem, appDelegate: appDelegate)
    }
    
    override func tearDownWithError() throws {
        menuManager = nil
        appDelegate = nil
        statusItem = nil
        PreferencesManager.resetForTesting()
        super.tearDown()
    }
    
    func testInitialization() throws {
        XCTAssertNotNil(menuManager)
    }
    
    func testSetupMenu() throws {
        menuManager.setupMenu()
        XCTAssertNotNil(statusItem.menu)
        XCTAssertGreaterThan(statusItem.menu?.items.count ?? 0, 0)
    }
    
    func testUpdateTimerItemWithActiveTimer() throws {
        menuManager.setupMenu()
        menuManager.updateTimerItem(with: 300) // 5 minutes
        
        let timerItem = statusItem.menu?.items.first
        XCTAssertNotNil(timerItem)
        XCTAssertEqual(timerItem?.title, "Timer: 05:00")
        
        // Check stop timer item is present
        let stopItem = statusItem.menu?.items[1]
        XCTAssertNotNil(stopItem)
        XCTAssertEqual(stopItem?.title, "Stop Timer")
    }
    
    func testUpdateTimerItemWithInactiveTimer() throws {
        menuManager.setupMenu()
        menuManager.updateTimerItem(with: nil)
        
        let timerItem = statusItem.menu?.items.first
        XCTAssertNotNil(timerItem)
        XCTAssertEqual(timerItem?.title, "No Timer Active")
        
        // Check stop timer item is not present
        let stopItem = statusItem.menu?.items[1]
        XCTAssertNotEqual(stopItem?.title, "Stop Timer")
    }
    
    func testResetStatusBarIcon() throws {
        menuManager.resetStatusBarIcon()
        XCTAssertNotNil(statusItem.button?.image)
        XCTAssertEqual(statusItem.button?.toolTip, "Tick App")
    }
    
    func testRefreshPresetsWithNoPresets() throws {
        menuManager.setupMenu()
        menuManager.refreshPresets()
        
        let presetsMenu = statusItem.menu?.items
            .first(where: { $0.title == "Timer Presets" })?
            .submenu
        
        XCTAssertNotNil(presetsMenu)
        let noPresetsItem = presetsMenu?.items.first
        XCTAssertEqual(noPresetsItem?.title, "No Presets")
        XCTAssertFalse(noPresetsItem?.isEnabled ?? true)
    }
    
    func testRefreshPresetsWithPresets() throws {
        // Add a test preset
        let preset = Preset.mock()
        PreferencesManager.shared.addPreset(preset)
        
        menuManager.setupMenu()
        menuManager.refreshPresets()
        
        let presetsMenu = statusItem.menu?.items
            .first(where: { $0.title == "Timer Presets" })?
            .submenu
        
        XCTAssertNotNil(presetsMenu)
        let presetItem = presetsMenu?.items.first
        XCTAssertEqual(presetItem?.title, "Test Preset (5:00)")
        
        // Cleanup
        PreferencesManager.shared.deletePreset(id: preset.id)
    }
    
    func testUpdateMonitorSelection() throws {
        menuManager.setupMenu()
        menuManager.updateMonitorSelection()
        
        let monitorMenu = statusItem.menu?.items
            .first(where: { $0.title == "Preferences" })?
            .submenu?
            .items
            .first(where: { $0.title == "Show Timer On" })?
            .submenu
        
        XCTAssertNotNil(monitorMenu)
        XCTAssertEqual(monitorMenu?.items.count, NSScreen.screens.count)
    }
} 
