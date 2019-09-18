//
//  Extensions.swift
//  ProjectManager
//
//  Created by Tomasz Jurek on 09/05/2019.
//  Copyright © 2019 Tomasz Jurek. All rights reserved.
//

import Foundation
import UIKit

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

//hackingwithswift.com snippet with expanded handling
extension Date {
    
    func offsetFrom(date : Date, messageFormat: String) -> String {
        let dayHourMinuteSecond: Set<Calendar.Component> = [.day, .hour]
        var difference = NSCalendar.current.dateComponents(dayHourMinuteSecond, from: date, to: self);
        let hours = "\(difference.hour ?? 0)"
        let days = "\(difference.day ?? 0)"
        var message: String = ""
        switch messageFormat {
        case "extended":
            if difference.hour! == 1 && difference.day! == 1{
                message = "Due in \(days) day and \(hours) hour"
            }
            
            else if difference.hour! == 1 && difference.day! > 1{
                message = "Due in \(days) days and \(hours) hour"
            }
            
            else if difference.hour! > 1 && difference.day! == 1{
                message = "Due in \(days) day and \(hours) hours"
            }
            
            else if difference.hour! > 1 && difference.day! > 1{
                message = "Due in \(days) days and \(hours) hours"
            }
            
            else if difference.hour! == 0 && difference.day! == 1{
                message = "Due in \(days) day"
            }
            
            else if difference.day! == 0{
                message = "Due in \(hours) hours"
            }else{
                message = "Due date passed"
            }
        case "day":
                message = "\(days)"
        
        case "hour":
                message = "\(hours)"
            
        default:
                message = "\(days) days, \(hours) hours."
        }
        
        

        return message
    }
    
}
