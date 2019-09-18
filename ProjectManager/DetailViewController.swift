//
//  DetailViewController.swift
//  ProjectManager
//
//  Created by Tomasz Jurek on 09/05/2019.
//  Copyright © 2019 Tomasz Jurek. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate{

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var detailDescriptionLabel: UILabel!

    
    var managedObjectContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var fetchRequest: NSFetchRequest<Task>!
    var tasks: [Task]!
    var taskToEdit: String?
    let shaperLayer = CAShapeLayer()
    let dateNow = Date()
    var percentageArray: [Float] = []


    func configureView(){
        
    }
    
    @objc func loadList(){
        //reloads data in the table
        self.taskToEdit = nil
        self.tableView.reloadData()
    }

    override func viewDidLoad(){
        
        super.viewDidLoad()
        
        //sets up obeserver and envokes loadList to refresh the banner view with new task data that has been created/updated
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)

        configureView()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }
    
    //Segues for banner and add task views.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "projectBannerView"
        {
            if let bannerViewController = segue.destination as? ProjectBannerViewController{
                bannerViewController.projectName = project?.name
                bannerViewController.projectPriority = project?.priority
                bannerViewController.projectNotes = project?.notes
                bannerViewController.projectDate = project?.date
                bannerViewController.projectStartDate = project?.startDate
                
                if project?.priority == "Low"{
                    bannerViewController.colour = UIColor.green
                }
                    
                else if project?.priority == "Medium"{
                    bannerViewController.colour = UIColor.yellow
                }
                    
                else if project?.priority == "High"{
                    bannerViewController.colour = UIColor.red
                }
            }
        }
        
        if segue.identifier == "addTask"
        {
            if let AddTaskViewController = segue.destination as? AddTaskViewController{
                AddTaskViewController.currentProject = project
                AddTaskViewController.taskToEdit = self.taskToEdit
            }
        }
    }
    

    var project: Project? {
        didSet {
            configureView()
            
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    //The edit slide function added to task, activate by sliding task to right side
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let cell = tableView.cellForRow(at: indexPath) as! TaskTableViewCell
        self.taskToEdit = cell.taskNameLabel.text
        
        let edit = UIContextualAction(style: .normal, title: "Edit") {
            (contextualAction, view, actionPerformed: (Bool) -> ()) in
            
            //performs segue to addTask that will be populated with current data
            self.performSegue(withIdentifier: "addTask", sender: nil)
            actionPerformed(true)
            
        }
        edit.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        return UISwipeActionsConfiguration(actions: [edit])
    }

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.delete(self.fetchedResultsController.object(at: indexPath))
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
        
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        //Creates instance of the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        self.configureCell(cell, indexPath: indexPath)
        percentageArray.append((self.fetchedResultsController.fetchedObjects?[indexPath.row].percentComplete)!)
        
        
        
        //calculation for the date circle percentage
        let date: Date = (self.fetchedResultsController.fetchedObjects?[indexPath.row].taskEndDate)!
        let startDate: Date = (self.fetchedResultsController.fetchedObjects?[indexPath.row].taskStartDate)!
        let datePercentage: CGFloat = (calculatePercentages(date, startDate))
        let taskPercentage: CGFloat = CGFloat((self.fetchedResultsController.fetchedObjects?[indexPath.row].percentComplete)!)
        
        //Loading the percentages for circle renders
        cell.load(daysPercentage: datePercentage, taskPercentage: taskPercentage)
        
        //setting start date to label
        cell.taskStartDateLabel.text = startDate.toString(dateFormat: "dd-MM-yyyy")
        
        //setting task name to the label
        cell.taskNameLabel.text = self.fetchedResultsController.fetchedObjects?[indexPath.row].taskName
        
        //setting notes
        cell.taskNotesLabel.text = self._fetchedResultsController?.fetchedObjects?[indexPath.row].notes
        
        //setting task end date and converting date to string
        cell.taskDateLabel.text = self._fetchedResultsController?.fetchedObjects?[indexPath.row].taskEndDate?.toString(dateFormat: "dd-MM-yyyy")
        
        //setting inside circle label to days left using offsetFrom extension function from Extensions.swift
        cell.circleCounterLabel.text = self._fetchedResultsController?.fetchedObjects?[indexPath.row].taskEndDate?.offsetFrom(date: dateNow, messageFormat: "day")

        //Setting label to the percentage for task
        let IntPercent: Int = Int(taskPercentage * 100)
        cell.percentageLabel.text = String(IntPercent)
        
        //checks if notifications are enabled, if so it shows a green bell
        if (self._fetchedResultsController?.fetchedObjects?[indexPath.row].taskNotification)! {
        cell.notificationEnabledImage.alpha = 1
        } else {
            cell.notificationEnabledImage.alpha = 0
        }
        
        //check for individual day left for grammar adjustment
        if cell.circleCounterLabel.text == "1"{
            cell.circleDescriptionLabel.text = "Day left"
        }
        
        //Switch to hours if no days left
        if cell.circleCounterLabel.text == "0"{
            let hoursLeft = self._fetchedResultsController?.fetchedObjects?[indexPath.row].taskEndDate?.offsetFrom(date: dateNow, messageFormat: "hour")
            cell.circleCounterLabel.text = hoursLeft
            if hoursLeft == "1"{
                cell.circleDescriptionLabel.text = "Hour left"
            } else {
                cell.circleDescriptionLabel.text = "Hours left"
            }
            
            
        }
            return cell
    }
    
    //calculates percentage left towards the end date
    func calculatePercentages(_ projectDate: Date, _ startDate: Date) -> CGFloat{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        
        let startDate = startDate.timeIntervalSince1970
        let endDate = projectDate.timeIntervalSince1970
        let currentDate = dateNow.timeIntervalSince1970
        
        let percentage = (CGFloat(currentDate) - CGFloat(startDate)) / (CGFloat(endDate) - CGFloat(startDate))
        return percentage
    }
    
    func configureCell(_ cell: UITableViewCell, indexPath: IndexPath) {

    }
    
    var _fetchedResultsController: NSFetchedResultsController<Task>? = nil
    
    var fetchedResultsController: NSFetchedResultsController<Task> {
        
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        
        let currentProject  = self.project
        let request:NSFetchRequest<Task> = Task.fetchRequest()
        request.fetchBatchSize = 10
        let taskNameSortDescriptor = NSSortDescriptor(key: "taskName", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        request.sortDescriptors = [taskNameSortDescriptor]
        if(self.project != nil){
            let predicate = NSPredicate(format: "taskProject = %@", currentProject!)
            request.predicate = predicate
        }
        else {
            let predicate = NSPredicate(format: "project = %@", "Empty")
            request.predicate = predicate
        }
        
        let frc = NSFetchedResultsController<Task>(
            fetchRequest: request,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: #keyPath(Task.project),
            cacheName:nil)
        frc.delegate = self
        _fetchedResultsController = frc
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        return frc as! NSFetchedResultsController<NSFetchRequestResult> as! NSFetchedResultsController<Task>
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    //must have a NSFetchedResultsController to work
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case NSFetchedResultsChangeType(rawValue: 0)!:
            break
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.configureCell(tableView.cellForRow(at: indexPath!)!, indexPath: newIndexPath!)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            fatalError()
        }
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}

