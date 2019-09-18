//
//  ProjectBannerViewController.swift
//  ProjectManager
//
//  Created by Tomasz Jurek on 09/05/2019.
//  Copyright © 2019 Tomasz Jurek. All rights reserved.
//

import UIKit
import CoreData

class ProjectBannerViewController: UIViewController {
    
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var projectPriorityTextfield: UILabel!
    @IBOutlet weak var projectDueTextfield: UILabel!
    @IBOutlet weak var projectNotesTextfield: UILabel!
    @IBOutlet weak var hiddenPriorityTextfield: UILabel!
    @IBOutlet weak var hiddenNotesTextfield: UILabel!
    @IBOutlet weak var hiddenTimeProgressionLabel: UILabel!
    @IBOutlet weak var hiddenTaskProgressionLabel: UILabel!
    

    var projectName:String?
    var projectPriority:String?
    var projectDate:Date?
    var projectStartDate:Date?
    var projectNotes:String?
    var colour:UIColor?
    let date = Date()
    var tasksPercentage: CGFloat = 0.0
    
    
    let timePercentageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 32)
        return label
    }()
    
    let taskPercentageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 32)
        return label
    }()
    
    
    func calculatePercentage() -> CGFloat{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        
        let startDate = projectStartDate!.timeIntervalSince1970
        let endDate = projectDate!.timeIntervalSince1970
        let currentDate = date.timeIntervalSince1970
        
        let percentage = (CGFloat(currentDate) - CGFloat(startDate)) / (CGFloat(endDate) - CGFloat(startDate))
        return percentage
    }
    

    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        //adds two subviews that are two labels
        view.addSubview(timePercentageLabel)
        view.addSubview(taskPercentageLabel)
        
        timePercentageLabel.center = view.center
        timePercentageLabel.frame = CGRect(x: 37, y: 35, width: 100, height: 100)
        
        taskPercentageLabel.center = view.center
        taskPercentageLabel.frame = CGRect(x: 178, y: 35, width: 100, height: 100)
        
        //hides static labels
        hiddenNotesTextfield.alpha = 0
        hiddenPriorityTextfield.alpha = 0
        hiddenTimeProgressionLabel.alpha = 0
        hiddenTaskProgressionLabel.alpha = 0
        
        projectPriorityTextfield.textColor = colour
        projectNameLabel.text = projectName
        projectPriorityTextfield.text = projectPriority
        projectDueTextfield.text = projectDate?.offsetFrom(date: date, messageFormat: "extended")
        projectNotesTextfield.text = projectNotes
        if projectNameLabel.text != nil {
            animateTimeCircle()
            retireveData()
            animateTasksCircle(tasksPercentage)
           
        }
    }
    
    //animates the task circle
    func animateTasksCircle(_ taskPercentage: CGFloat){
        self.taskPercentageLabel.text = "\(Int(tasksPercentage * 100))%"
        let shaperLayer = CAShapeLayer()
        var start = view.center
        start.y = 85
        start.x = 225
        
        let trackLayer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 50, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = CAShapeLayerLineCap.round
        trackLayer.position = start
        
        view.layer.addSublayer(trackLayer)
        
        shaperLayer.path = circularPath.cgPath
        shaperLayer.lineCap = CAShapeLayerLineCap.round
        shaperLayer.fillColor = UIColor.clear.cgColor
        shaperLayer.strokeColor = UIColor.blue.cgColor
        shaperLayer.lineWidth = 10
        shaperLayer.strokeEnd = 0
        shaperLayer.position = start
        shaperLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        
        view.layer.addSublayer(shaperLayer)
        
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = tasksPercentage
        basicAnimation.duration = 1
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        shaperLayer.add(basicAnimation, forKey: "fillUp")
    }
    
    //Collects all percentages for each task in project and calculates average percentage
    func retireveData(){
        var percentArray: [CGFloat] = []

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "project = %@", projectName!)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject]{
                percentArray.append(data.value(forKey: "percentComplete") as! CGFloat)
            }
        }catch{
            print("Fail")
        }
        let total = percentArray.reduce(0, +)
        tasksPercentage = total / CGFloat(percentArray.count)
        if tasksPercentage.isNaN{
             tasksPercentage = 0.0
        }

        
    }
    
    //Animates the time circle
    func animateTimeCircle(){
        let shaperLayer = CAShapeLayer()
        self.timePercentageLabel.text = "\(Int(calculatePercentage() * 100))%"
        
        
        hiddenNotesTextfield.alpha = 0.5
        hiddenPriorityTextfield.alpha = 0.8
        hiddenTimeProgressionLabel.alpha = 0.8
        hiddenTaskProgressionLabel.alpha = 0.8
        
        var start = view.center
        start.y = 85
        start.x = 85
        
        let trackLayer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 50, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = CAShapeLayerLineCap.round
        trackLayer.position = start
        
        view.layer.addSublayer(trackLayer)
        
        shaperLayer.path = circularPath.cgPath
        shaperLayer.lineCap = CAShapeLayerLineCap.round
        shaperLayer.fillColor = UIColor.clear.cgColor
        shaperLayer.strokeColor = colour?.cgColor
        shaperLayer.lineWidth = 10
        shaperLayer.strokeEnd = 0
        shaperLayer.position = start
        shaperLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        
        view.layer.addSublayer(shaperLayer)
        
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = calculatePercentage()
        basicAnimation.duration = 1
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        shaperLayer.add(basicAnimation, forKey: "fillUp")
    }
}
    


