//
//  InterfaceController.swift
//  WatchSpriteKit WatchKit Extension
//
//  Created by Adam Eri on 08.04.18.
//  Copyright © 2018 blackmirror media. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit
import SceneKit

class InterfaceController: WKInterfaceController {

  /// During the initialization of your interface controller, WatchKit creates
  /// a new instance of this class and assigns it to your outlet. At that point,
  /// you can use the object in your outlet to make changes to the SpriteKit
  /// scene.
  /// The SpriteKit scene in your Watch app must be connected to a
  /// WKInterfaceSKScene outlet in your WatchKit extension for the scene to
  /// be visible in your watchOS app's user interface.
  @IBOutlet weak var sceneInterface: WKInterfaceSKScene!

  /// The workout session to track the activity in.
  private var workoutSession: HKWorkoutSession?

  /// Private HealthStore instance
  private let healthStore = HKHealthStore()

  /// The heart rate query needed to fetch the heart rate.
  private var heartRateQuery: HKObserverQuery?

  /// The current heart rate of the user is displayed there.
  @IBOutlet public var heartRateLabel: WKInterfaceLabel!

  override func awake(withContext context: Any?) {
    super.awake(withContext: context)

    self.requestAuthorization()

    /// Creating an observer, so updates are received whenever HealthKit’s
    // heart rate data changes.
    guard let sampleType: HKSampleType =
      HKObjectType.quantityType(forIdentifier: .heartRate) else {
        return
    }

    self.heartRateQuery = HKObserverQuery.init(
      sampleType: sampleType,
      predicate: nil) { [weak self] _, _, error in
        guard error == nil else {
          print(error!)
          return
        }

        /// When the completion is called, an other query is executed
        /// to fetch the latest heart rate
        self?.fetchLatestHeartRateSample(completion: { sample in
          guard let sample = sample else {
            return
          }

          /// The completion in called on a background thread, but we
          /// need to update the UI on the main.
          DispatchQueue.main.async {

            /// Converting the heart rate to bpm
            let heartRateUnit = HKUnit(from: "count/min")
            let heartRate = sample
              .quantity
              .doubleValue(for: heartRateUnit)

            /// Updating the UI with the retrieved value
            self?.heartRateLabel.setText("\(Int(heartRate))")
          }
        })
    }

    if let query = self.heartRateQuery {
      self.healthStore.execute(query)
    }

  }

  override func willActivate() {
    // This method is called when watch view controller
    // is about to be visible to user
    super.willActivate()
  }

  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }

  // MARK: - HeatlhKit Operations

  private func fetchLatestHeartRateSample(
    completion: @escaping (_ sample: HKQuantitySample?) -> Void) {

    /// Create sample type for the heart rate
    guard let sampleType = HKObjectType
      .quantityType(forIdentifier: .heartRate) else {
        completion(nil)
        return
    }

    /// Predicate for specifiying start and end dates for the query
    let predicate = HKQuery
      .predicateForSamples(
        withStart: Date.distantPast,
        end: Date(),
        options: .strictEndDate)

    /// Set sorting by date.
    let sortDescriptor = NSSortDescriptor(
      key: HKSampleSortIdentifierStartDate,
      ascending: false)

    /// Create the query
    let query = HKSampleQuery(
      sampleType: sampleType,
      predicate: predicate,
      limit: Int(HKObjectQueryNoLimit),
      sortDescriptors: [sortDescriptor]) { (_, results, error) in

        guard error == nil else {
          print("Error: \(error!.localizedDescription)")
          return
        }

        guard let results = results, results.count > 0 else {
          return
        }

        completion(results[0] as? HKQuantitySample)
    }

    self.healthStore.execute(query)
  }

  /// Requests authorisation from the user to be able to save workouts
  /// to heathkit.
  private func requestAuthorization() {
    guard HKHealthStore.isHealthDataAvailable() else {
      print("HealthKit is not avaliable on the device")
      return
    }

    self
      .healthStore
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

}
