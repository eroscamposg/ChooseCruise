//
//  IntentHandler.swift
//  Extension
//
//  Created by Eros Campos on 7/17/20.
//  Copyright © 2020 Eros Campos. All rights reserved.
//

import Intents
import UIKit

class IntentHandler: INExtension, INGetRideStatusIntentHandling, INListRideOptionsIntentHandling, INRequestRideIntentHandling, INCancelRideIntentHandling {
    
    //MARK: - Methods to provide METADATA to the ride
    func handle(cancelRide intent: INCancelRideIntent, completion: @escaping (INCancelRideIntentResponse) -> Void) {
        let result = INCancelRideIntentResponse(code: .success, userActivity: nil)
        completion(result)
    }
    
    func handle(sendRideFeedback sendRideFeedbackintent: INSendRideFeedbackIntent, completion: @escaping (INSendRideFeedbackIntentResponse) -> Void) {
        let result = INSendRideFeedbackIntentResponse(code: .success, userActivity: nil)
        completion(result)
    }
    
    //Figure out where a ride is and report if the data is enought to proceed
    func handle(intent: INGetRideStatusIntent, completion: @escaping (INGetRideStatusIntentResponse) -> Void) {
        //On a normal app, you would get the information of the ride from a server, and send it back to the user
        
        let result = INGetRideStatusIntentResponse(code: .success, userActivity: nil)
        completion(result)
    }
    
    //MARK: - Optional Methods - SIRI - RESOLVE STEP: Asynchronus fetch data
    //If we dont have a valid location for pickup, request one
    func resolvePickupLocation(for intent: INRequestRideIntent, with completion: @escaping (INPlacemarkResolutionResult) -> Void) {
        let result: INPlacemarkResolutionResult
        
        if let requestedLocation = intent.pickupLocation {
            //We have a valid pickup location, return success!
            result = INPlacemarkResolutionResult.success(with: requestedLocation)
        } else {
            //No pickup location yet, mark this as outstanding
            result = INPlacemarkResolutionResult.needsValue()
        }
        
        completion(result)
    }

    //If we dont have a valid location for dropoff, request one
    func resolveDropOffLocation(for intent: INRequestRideIntent, with completion: @escaping (INPlacemarkResolutionResult) -> Void) {
        let result: INPlacemarkResolutionResult
        
        if let requestedLocation = intent.dropOffLocation {
            result = INPlacemarkResolutionResult.success(with: requestedLocation)
        } else {
            result = INPlacemarkResolutionResult.needsValue()
        }
        
        completion(result)
    }
    
    //MARK: - Send Updates
    func startSendingUpdates(for intent: INGetRideStatusIntent, to observer: INGetRideStatusIntentResponseObserver) {
    }
    
    func stopSendingUpdates(for intent: INGetRideStatusIntent) {
    }
    
    
    //MARK: - Show the list of available rides
    func handle(intent: INListRideOptionsIntent, completion: @escaping (INListRideOptionsIntentResponse) -> Void) {
        let result = INListRideOptionsIntentResponse(code: .success, userActivity: nil)
        
        //Create ride options: Car rides
        let mini = INRideOption(name: "Mini Cooper", estimatedPickupDate: Date(timeIntervalSinceNow: 1000))
        let accord = INRideOption(name: "Honda Accord", estimatedPickupDate: Date(timeIntervalSinceNow: 800))
        let ferrari = INRideOption(name: "Ferrari F430", estimatedPickupDate: Date(timeIntervalSinceNow: 300))
        
        ferrari.disclaimerMessage = "This vehicle is bad for the environment"
        
        result.expirationDate = Date(timeIntervalSinceNow: 3600)
        result.rideOptions = [mini, accord, ferrari]
        
        completion(result)
    }
    
    //MARK: - Create a ride when it has been requested by APPLE MAPS or SIRI
    //This is called when the user has picked out the ride they want – using Siri or Maps – and wants to confirm the booking and get the car
    func handle(intent: INRequestRideIntent, completion: @escaping (INRequestRideIntentResponse) -> Void) {
        let result = INRequestRideIntentResponse(code: .success, userActivity: nil)
        
        //Object that represents the ride
        let status = INRideStatus()
        
        //1. Create a uniqyue value that represents the ride in the backend
        status.rideIdentifier = "abc123"
        
        //2. Give it the pickup and dropoff location that the user already agreed on
        status.pickupLocation = intent.pickupLocation
        status.dropOffLocation = intent.dropOffLocation
        
        //3. Mark it as confirmed. Deliver the ride
        status.phase = INRidePhase.confirmed
        
        //4. Say we will be there in around 15min
        status.estimatedPickupDate = Date(timeIntervalSinceNow: 900)
        
        //5. Create a new vehicle and configure it properly
        let vehicle = INRideVehicle()
        
        //5.1 WORKAROUND: Load the car image into
        vehicle.mapAnnotationImage = INImage(url: URL(string: "https://w7.pngwing.com/pngs/492/796/png-transparent-bmw-m5-car-bmw-x5-2018-bmw-5-series-bmw-sedan-car-performance-car.png")!)
        
        //5.2. Set the vehicle current location to where the user wants to go - somewhat faraway for testing purpouses
        vehicle.location = intent.dropOffLocation!.location
        
        //6. Assign the configured vehicle to status vehicle
        status.vehicle = vehicle
        
        //7. Attach the finished INRideStatus to the result and send it back
        result.rideStatus = status
        completion(result)
    }
}
