//
//  NotificationManager.swift
//  CookIt
//
//  Created by Artem Golovchenko on 2025-03-09.
//

import Foundation
import UserNotifications
import CoreLocation

final class NotificationManager {
    
    static let shared = NotificationManager()
    
    func askAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }
    //UIApplication.shared. ...iconBadgeNumber = 0
    func sceduleNotification() {
        
        let content = UNMutableNotificationContent()
        content.title = "Hello, World!"
        content.body = "Hello, World!"
        content.sound = .default
        content.badge = 1
        
        //time
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
       //calendar
        var date = DateComponents()
        date.hour = 15
        date.minute = 7
        //date.weekday = 1
        
        let trigger2 = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        
        //location
        let coordinates = CLLocationCoordinate2D(latitude: 40.00, longitude: 50.00)
        let region = CLCircularRegion(center: coordinates, radius: 100, identifier: UUID().uuidString)
        region.notifyOnEntry = true
        
        let trigger3 = UNLocationNotificationTrigger(region: region, repeats: true)
        
        
        let request = UNNotificationRequest(identifier: "test", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        
    }
    
    func cancelNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
}
