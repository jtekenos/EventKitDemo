//
//  ViewController.swift
//  EventKitDemo
//
//  Created by Jess on 2015-12-03.
//  Copyright © 2015 Jess. All rights reserved.
//

import UIKit
//make sure to import EventKit
import EventKit

class ViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var lbl_eventName: UITextField!
    @IBOutlet weak var lbl_eventDuration: UITextField!
    
    var eventName: String = ""
    var eventDuration: Double = 0
    var savedEventId : String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //create event store
    
    let eventStore = EKEventStore()
    
    //one object created with an event store can't be used with another event store elsewhere in the application. 
    //Thus, event store should be a singleton (single instance per app). 
    
    
    //permission to access the calendar needs to be requested if it is not already available. Otherwise, nothing would work and no notifications would be given. This is done with authorizationStatusForEntityType(). 
    
    //again, an event created in this store will not work with any other store.
    @IBAction func addEventToCalendar(sender: AnyObject) {
        
        eventName = lbl_eventName.text!
        eventDuration = Double(lbl_eventDuration.text!)!
        let eventDate = datePicker.date
        let endDate = eventDate.dateByAddingTimeInterval(60 * 60 * eventDuration)

        
        if (EKEventStore.authorizationStatusForEntityType(.Event) != EKAuthorizationStatus.Authorized) {
            eventStore.requestAccessToEntityType(.Event, completion: {
                granted, error in
                self.createEvent(self.eventStore, title: self.eventName, startDate: eventDate, endDate: endDate)
            })
        } else {
            //if permission was already given, create event
            createEvent(eventStore, title: self.eventName, startDate: eventDate, endDate: endDate)
        }

    }
    
    /* CreateEvent constructor creates the event. No need to check for authorization because addEventToCalendar checks. */
    func createEvent(eventStore: EKEventStore, title: String, startDate: NSDate, endDate: NSDate) {
        let event = EKEvent(eventStore: eventStore)
        
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = eventStore.defaultCalendarForNewEvents
        do {
            try eventStore.saveEvent(event, span: .ThisEvent)
            savedEventId = event.eventIdentifier
        } catch let error as NSError {
            print("Error creating an Event \(error)")
        }
    }
    
    
    @IBAction func removeEvent(sender: UIButton) {
        if (EKEventStore.authorizationStatusForEntityType(.Event) != EKAuthorizationStatus.Authorized) {
            eventStore.requestAccessToEntityType(.Event, completion: { (granted, error) -> Void in
                self.deleteEvent(self.eventStore, eventIdentifier: self.savedEventId)
            })
        } else {
            deleteEvent(eventStore, eventIdentifier: savedEventId)
        }
        lbl_eventName.text = ""
        lbl_eventDuration.text = ""
    }
    
    //method to actually delete the event
    func deleteEvent(eventStore: EKEventStore, eventIdentifier: String) {
        let eventToRemove = eventStore.eventWithIdentifier(eventIdentifier)
        if (eventToRemove != nil) {
            do {
                try eventStore.removeEvent(eventToRemove!, span: .ThisEvent)
            } catch let error as NSError {
                print("Error deleting event \(error)")
            }
        }
    }
    


}

