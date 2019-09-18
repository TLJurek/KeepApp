//
//  AddProjectViewController.swift
//  ProjectManager
//
//  Created by Tomasz Jurek on 09/05/2019.
//  Copyright © 2019 Tomasz Jurek. All rights reserved.
//

import UIKit
import CoreData

//To edit the project or task, slide it to the right.
class AddProjectViewController: UIViewController {

    @IBOutlet weak var projectTitleLabel: UILabel!
    @IBOutlet weak var projectNameTextfield: UITextField!
    @IBOutlet weak var projectNotesTextfield: UITextField!
    @IBOutlet weak var projectDueDatePicker: UIDatePicker!
    @IBOutlet weak var projectStartDatePicker: UIDatePicker!
    @IBOutlet weak var prioritySegment: UISegmentedControl!
    
    var datePicker: UIDatePicker?
    var date:Date?
    var priority:String  = ""
    var calendarBool: Bool = false
    var projectEdit:String?
    var editingBool: Bool = false
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let calendarManager = CalendarManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddProjectViewController.viewTapped(gestureRecogniser:)))
        
        view.addGestureRecognizer(tapGesture)
        
        //If the project is set by edit button, populate the popover fields
        if let project = projectEdit{
            self.editingBool = true
            projectTitleLabel.text = String("Edit: \(project)")
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
            fetchRequest.predicate = NSPredicate(format: "name == %@", project)
            
            do {
                let result = try managedContext.fetch(fetchRequest)
                
                for data in result as! [NSManagedObject]{
                    projectNameTextfield.text = data.value(forKey: "name") as? String
                    projectNotesTextfield.text = data.value(forKey: "notes") as? String
                    projectStartDatePicker.date = (data.value(forKey: "startDate") as? Date)!
                    projectDueDatePicker.date = (data.value(forKey: "date") as? Date)!
                    self.priority = (data.value(forKey: "priority") as? String)!
                    
                }
            }catch{
                print("Failed to populate popover.")
            }
            
        }

    }
    
    @objc func viewTapped(gestureRecogniser: UITapGestureRecognizer){
        view.endEditing(true)
    }
    

    @IBAction func addToCalendarSwitch(_ sender: UISwitch) {
        if sender.isOn{
            calendarBool = true
        } else {
            calendarBool = false
        }
    }
    
    @IBAction func projectPrioritySegment(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            self.priority = "Low"
        }
        else if sender.selectedSegmentIndex == 1{
            self.priority = "Medium"
        }
        else if sender.selectedSegmentIndex == 2{
            self.priority = "High"
        }else{
            self.priority = "No priority set"
        }
    }
 
    @IBAction func saveProjectButton(_ sender: UIButton) {
        if editingBool{
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
            fetchRequest.predicate = NSPredicate(format: "name == %@", projectEdit!)
            do{
                let test = try managedContext.fetch(fetchRequest)
                let objectUpdate = test[0] as! NSManagedObject
                objectUpdate.setValue(projectNameTextfield.text, forKey: "name")
                objectUpdate.setValue(projectNotesTextfield.text, forKey: "notes")
                objectUpdate.setValue(projectStartDatePicker.date, forKey: "startDate")
                objectUpdate.setValue(projectDueDatePicker.date, forKey: "date")
                objectUpdate.setValue(self.priority, forKey: "priority")
                do{
                    try managedContext.save()
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
        
        }else{
    
        let newProject = Project(context: context)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        
        if projectNameTextfield.text != ""
        {
            newProject.name = projectNameTextfield.text
            newProject.notes = projectNotesTextfield.text
            newProject.date = projectDueDatePicker.date
            newProject.startDate = projectStartDatePicker.date
            newProject.priority = self.priority
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            if calendarBool{
            calendarManager.addEventToCalendar(title: "\(projectNameTextfield.text!) - \(self.priority) priority", description: projectNotesTextfield.text, startDate: projectDueDatePicker.date, endDate: projectDueDatePicker.date)
            
            }
            view.endEditing(true)
        } else {
            //Alert
            let alert = UIAlertController(title: "Missing project name",message: "Please enter an project name",preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "animate"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
            dismiss(animated: true, completion: nil)
        }
    }
}
