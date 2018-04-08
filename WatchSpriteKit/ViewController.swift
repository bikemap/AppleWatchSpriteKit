//
//  ViewController.swift
//  WatchSpriteKit
//
//  Created by Adam Eri on 08.04.18.
//  Copyright © 2018 blackmirror media. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    /// Requests authorisation from the user to be able to save workouts
    /// to heathkit.

    let healthStore = HKHealthStore()

    guard HKHealthStore.isHealthDataAvailable() else {
      print("HealthKit is not avaliable on the device")
      return
    }

    healthStore
      .requestAuthorization(
        toShare: [
          HKWorkoutType.workoutType(),
          HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
          HKObjectType.quantityType(forIdentifier: .heartRate)!
        ],
        read: [
          HKObjectType.quantityType(forIdentifier: .heartRate)!
        ],
        completion: { success, error in
          print("success", success)
          print("error", error ?? "no error")
      })

  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

