//
//  AppDelegate.swift
//  StanfordAlgorithms
//
//  Created by Uladzimir Papko on 10/9/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Task6.executeQuestion1()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
