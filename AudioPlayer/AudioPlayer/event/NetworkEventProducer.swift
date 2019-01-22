//
//  NetworkEventProducer.swift
//  AudioPlayer
//
//  Created by Kevin DELANNOY on 08/03/16.
//  Copyright © 2016 Kevin Delannoy. All rights reserved.
//

import Foundation

private extension Selector {
    /// The selector to call when reachability status changes.
    static let reachabilityStatusChanged =
        #selector(NetworkEventProducer.reachabilityStatusChanged(note:))
}

/// A `NetworkEventProducer` generates `NetworkEvent`s when there is changes on the network.
class NetworkEventProducer: NSObject, EventProducer {
    /// A `NetworkEvent` is an event a network monitor.
    ///
    /// - networkChanged: The network changed.
    /// - connectionRetrieved: The connection is now up.
    /// - connectionLost: The connection has been lost.
    enum NetworkEvent: Event {
        case networkChanged
        case connectionRetrieved
        case connectionLost
    }

    /// The reachability to work with.
    let reachability: Reachability?

    /// The date at which connection was lost.
    private(set) var connectionLossDate: NSDate?

    /// The listener that will be alerted a new event occured.
    weak var eventListener: EventListener?

    /// A boolean value indicating whether we're currently listening to events on the player.
    private var listening = false

    /// The last status received.
    private var lastConnection: Reachability.Connection?

    /// Initializes a `NetworkEventProducer` with a reachability.
    ///
    /// - Parameter reachability: The reachability to work with.
    init(reachability: Reachability?) {
        lastConnection = reachability?.connection ?? Reachability.Connection.none
        self.reachability = reachability

        if lastConnection == Reachability.Connection.none {
            connectionLossDate = NSDate()
        }
    }

    /// Stops producing events on deinitialization.
    deinit {
        stopProducingEvents()
    }

    /// Starts listening to the player events.
    func startProducingEvents() {
        guard !listening, let reachability = reachability else {
            return
        }

        //Saving current status
        lastConnection = reachability.connection

        //Starting to listen to events
        NotificationCenter.default.addObserver(
            self,
            selector: .reachabilityStatusChanged,
            name: Notification.Name.reachabilityChanged,
            object: reachability)
        try? reachability.startNotifier()

        //Saving that we're currently listening
        listening = true
    }

    /// Stops listening to the player events.
    func stopProducingEvents() {
        guard listening, let reachability = reachability else {
            return
        }

        //Stops listening to events
        NotificationCenter.default.removeObserver(
            self, name: Notification.Name.reachabilityChanged, object: reachability)
        reachability.stopNotifier()

        //Saving that we're not listening anymore
        listening = false
    }

    /// The method that will be called when Reachability generates an event.
    ///
    /// - Parameter note: The notification information.
    @objc fileprivate func reachabilityStatusChanged(note: NSNotification) {
        guard let reachability = reachability else { return }
        let newConnection = reachability.connection
        if newConnection != lastConnection {
            if newConnection == Reachability.Connection.none {
                connectionLossDate = NSDate()
                eventListener?.onEvent(NetworkEvent.connectionLost, generetedBy: self)
            } else if lastConnection == Reachability.Connection.none {
                eventListener?.onEvent(NetworkEvent.connectionRetrieved, generetedBy: self)
                connectionLossDate = nil
            } else {
                eventListener?.onEvent(NetworkEvent.networkChanged, generetedBy: self)
            }
            lastConnection = newConnection
        }
    }
}
