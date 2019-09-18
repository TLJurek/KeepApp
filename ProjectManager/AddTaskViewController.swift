//
//  AddTaskViewController.swift
//  ProjectManager
//
//  Created by Tomasz Jurek on 10/05/2019.
//  Copyright © 2019 Tomasz Jurek. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class AddTaskViewController: UIViewController {
    
    //Labels
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    
    //Textfields
    @IBOutlet weak var taskNameTextfield: UITextField!
    @IBOutlet weak var taskNotesTextfield: UITextField!
    
    //Datepickers
    @IBOutlet weak var dateStartDatePicker: UIDatePicker!
    @IBOutlet weak var dateDueDatePicker: UIDatePicker!
    
    //Other
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var percentageSlider: UISlider!
    
    
    var currentProject:Project?
    var notifcationBool:Bool = false
    var editingBool: Bool = false
    var taskPercentage:Float = 0
    var taskToEdit: String?
    
    let center = UNUserNotificationCenter.current()
    let notifications = NotificationManager()

    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        projectNameLabel.text = currentProject?.name
        percentageLabel.text = String(Int(taskPercentage))
        
        
        if let task = taskToEdit{
            self.editingBool = true
            projectNameLabel.text = String("Edit: \(task)")
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
            fetchRequest.predicate = NSPredicate(format: "taskName == %@", task)
            
            do {
                let result = try managedContext.fetch(fetchRequest)
                
                for data in result as! [NSManagedObject]{
                    let taskNotification: Bool = (data.value(forKey: "taskNotification") as? Bool)!
                    let sliderPercentage: Float = (data.value(forKey: "percentComplete") as? Float)!
                    
                    taskNameTextfield.text = data.value(forKey: "taskName") as? String
                    taskNotesTextfield.text = data.value(forKey: "notes") as? String
                    dateStartDatePicker.date = (data.value(forKey: "taskStartDate") as? Date)!
                    dateDueDatePicker.date = (data.value(forKey: "taskEndDate") as? Date)!
                    
                    notificationSwitch.setOn(taskNotification, animated: true)
                    percentageSlider.setValue(sliderPercentage, animated: true)
                    percentageLabel.text = String(format: "%.0f", sliderPercentage*100)
                }
            }catch{
                print("fail")
            }
        }
    }
    
    @IBAction func notificationSwitch(_ sender: UISwitch) {
        if sender.isOn{
            center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                if granted {
                    self.notifcationBool = true
                } else {
                    self.notifcationBool = false
                }
            }
        }else{
            self.notifcationBool = false
        }
    }
    
    @IBAction func percentageSlider(_ sender: UISlider) {
        percentageLabel.text = String(Int(sender.value * 100))
        taskPercentage = Float(sender.value)
        
    }
    
    @IBAction func saveTask(_ sender: UIButton) {
        if editingBool{
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
            fetchRequest.predicate = NSPredicate(format: "taskName == %@", taskToEdit!)
            do{
            let test = try managedContext.fetch(fetchRequest)
                let objectUpdate = test[0] as! NSManagedObject
                objectUpdate.setValue(taskNameTextfield.text, forKey: "taskName")
                objectUpdate.setValue(taskNotesTextfield.text, forKey: "notes")
                objectUpdate.setValue(dateStartDatePicker.date, forKey: "taskStartDate")
                objectUpdate.setValue(dateDueDatePicker.date.addingTimeInterval(-5), forKey: "taskEndDate")
                objectUpdate.setValue(notifcationBool, forKey: "taskNotification")
                objectUpdate.setValue(taskPercentage, forKey: "percentComplete")
                do{
                    try managedContext.save()
                    if notifcationBool{
                        notifications.scheduleLocal(scheduledDate: dateDueDatePicker.date, title: taskNameTextfield.text!)
                    }
                }
                catch{
                    print(error)
                }
            }
            catch{
                print(error)
            }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "animate"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        dismiss(animated: true, completion: nil)
        }
        else{
        let task = Task(context: context)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.dateFormat = "dd-MM-yyyy"
        //let selectedDate = dateFormatter.string(from: dateDueDatePicker.date)
        
        task.project = currentProject?.name
        task.taskName = taskNameTextfield.text
        task.taskStartDate = dateStartDatePicker.date
        task.notes = taskNotesTextfield.text
        task.taskEndDate = dateDueDatePicker.date.addingTimeInterval(-5)
        task.taskNotification = notifcationBool
            if notifcationBool{
                notifications.scheduleLocal(scheduledDate: dateDueDatePicker.date, title: taskNameTextfield.text!)
            }
        task.percentComplete = taskPercentage
        
        
        
        currentProject?.addToTasks(task)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "animate"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        dismiss(animated: true, completion: nil)
        }
    }
}
