//
//  AppDelegate.swift
//  julius-ceasar
//
//  Created by Anton Khomyakov on 27.04.2021.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var mainWindow: NSWindow!
    var multiWindow: NSWindow!
    
    var mainHostingView: NSHostingView<MainViewWrapper>!
    var authHostingView: NSHostingView<AuthViewWrapper>!
     
    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        let newMenu = NSMenu(title: "MyMenu")
        let newMenuItem = NSMenuItem(title: "Common Items", action: Selector(("selectDockMenuItem:")), keyEquivalent: "")
        newMenuItem.tag = 1
        newMenu.addItem(newMenuItem)
        return newMenu
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication)
    -> Bool {
        true
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Create the mainWindow and set the content view.
        mainWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        
        mainWindow.isReleasedWhenClosed = true
        mainWindow.setFrameAutosaveName("Main Window")
        
        authHostingView = NSHostingView(
            rootView: AuthViewWrapper(parent: self))
        
        setAuth()
        
        ServiceLayer.instance.telegramService.run()
    }
    
    
    func openMultiWindow<RootView>(rootView: RootView,
                                  title: String) where RootView : View {
        
        if multiWindow == nil {
            multiWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered, defer: false)
            
            
            multiWindow.isReleasedWhenClosed = true
            multiWindow.setFrameAutosaveName("Multi Window")
        }
        
        
        multiWindow.title = title
        multiWindow?.setIsVisible(true);
        mainWindow?.setIsVisible(false)
        multiWindow.center()
        multiWindow.contentView = NSHostingView(rootView: rootView)
        multiWindow.makeKeyAndOrderFront(nil)
    }
    
    func setMain() {
        // initialize after auth
        if mainHostingView == nil {
            mainHostingView = NSHostingView(
                rootView: MainViewWrapper(parent: self))
        }
        
        multiWindow?.setIsVisible(false)
        mainWindow?.setIsVisible(true);
        mainWindow.center()
        mainWindow.contentView = mainHostingView
        mainWindow.makeKeyAndOrderFront(nil)
    }
    
    func setAuth() {
        multiWindow?.setIsVisible(false)
        mainWindow?.setIsVisible(true);
        mainWindow.center()
        mainWindow.contentView = authHostingView
        mainWindow.makeKeyAndOrderFront(nil)
    }
    
    func reloadAuth() {
        setAuth()
        ServiceLayer.instance.telegramService.run()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
