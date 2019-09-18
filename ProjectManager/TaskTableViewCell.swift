//
//  TaskTableViewCell.swift
//  ProjectManager
//
//  Created by Tomasz Jurek on 11/05/2019.
//  Copyright © 2019 Tomasz Jurek. All rights reserved.
//

import UIKit



class TaskTableViewCell: UITableViewCell{

    @IBOutlet weak var taskNotesLabel: UILabel!
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var taskDateLabel: UILabel!
    @IBOutlet weak var taskStartDateLabel: UILabel!
    @IBOutlet weak var notificationEnabledImage: UIImageView!
    @IBOutlet weak var circleCounterLabel: UILabel!
    @IBOutlet weak var circleDescriptionLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    


    var daysPercentage: CGFloat = 0
    var taskPercentage: CGFloat = 0
    
    
    override func awakeFromNib() {

            super.awakeFromNib()
        
    }
    func load(daysPercentage: CGFloat, taskPercentage: CGFloat) {
        self.daysPercentage = daysPercentage
        self.taskPercentage = taskPercentage

        
        animateCircle(CGFloat(daysPercentage))
        animateProgress(CGFloat(taskPercentage))
    }
    

    
    func animateCircle(_ daysPercentage: CGFloat){
        let shaperLayer = CAShapeLayer()
        var start = self.center
        start.y = 58
        start.x = 68
        
        let trackLayer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 40, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 3
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = CAShapeLayerLineCap.round
        trackLayer.position = start
        
        self.layer.addSublayer(trackLayer)
        
        shaperLayer.path = circularPath.cgPath
        shaperLayer.lineCap = CAShapeLayerLineCap.round
        shaperLayer.fillColor = UIColor.clear.cgColor
        shaperLayer.strokeColor = UIColor.red.cgColor
        shaperLayer.lineWidth = 2
        shaperLayer.strokeEnd = 0
        shaperLayer.position = start
        shaperLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        
        self.layer.addSublayer(shaperLayer)
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = daysPercentage
        basicAnimation.duration = 1
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        shaperLayer.add(basicAnimation, forKey: "fillUp")
    }
    
    func animateProgress(_ taskPercentage: CGFloat){
        let shaperLayer = CAShapeLayer()
        var start = self.center
        start.y = 58
        start.x = 170
        
        let trackLayer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 40, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 3
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = CAShapeLayerLineCap.round
        trackLayer.position = start
        
        self.layer.addSublayer(trackLayer)
        
        shaperLayer.path = circularPath.cgPath
        shaperLayer.lineCap = CAShapeLayerLineCap.round
        shaperLayer.fillColor = UIColor.clear.cgColor
        shaperLayer.strokeColor = UIColor.blue.cgColor
        shaperLayer.lineWidth = 2
        shaperLayer.strokeEnd = 0
        shaperLayer.position = start
        shaperLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        
        self.layer.addSublayer(shaperLayer)
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = taskPercentage
        basicAnimation.duration = 1
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        shaperLayer.add(basicAnimation, forKey: "fillUp")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
