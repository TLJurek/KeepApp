//
//  NotificationManager.swift
//  ProjectManager
//
//  Created by Tomasz Jurek on 13/05/2019.
//  Copyright © 2019 Tomasz Jurek. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager{
    
    let dateNow = Date()
    let calendar = Calendar.current
    var dateComponents = DateComponents()
    let notificationCenter = UNUserNotificationCenter.current()
    
    
    func scheduleLocal(scheduledDate: Foundation.Date, title: String) {

        let content = UNMutableNotificationContent()
        content.title = "\(title) is overdue!"
        content.body = "Scheduled for \(scheduledDate.toString(dateFormat: "dd-MM-yyyy"))"
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        let dateShifted = scheduledDate
        let triggerDate = calendar.dateComponents([.year,.month,.day,.hour,.minute,.second], from: dateShifted)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let identifier = "Local Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request, withCompletionHandler: nil)

    }
}
