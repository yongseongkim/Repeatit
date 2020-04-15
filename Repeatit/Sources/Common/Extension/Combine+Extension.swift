//
//  Combine+Extension.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/04/12.
//

import Combine
import UIKit

protocol CombineCompatible {
}

final class UIControlSubscription<S: Subscriber, C: UIControl>: Subscription where S.Input == C {
    private var subscriber: S?
    private let control: C

    init(subscriber: S, control: C, event: UIControl.Event) {
        self.subscriber = subscriber
        self.control = control
        control.addTarget(self, action: #selector(handleEvent), for: event)
    }

    func request(_ demand: Subscribers.Demand) {
        // Don't need to do something.
        // When events about UIControl are called, call handleEvent().
    }

    func cancel() {
        subscriber = nil
    }

    @objc private func handleEvent() {
        _ = subscriber?.receive(control)
    }
}

struct UIControlPublisher<C: UIControl>: Publisher {
    typealias Output = C
    typealias Failure = Never

    private let control: C
    private let events: UIControl.Event

    init(control: C, events: UIControl.Event) {
        self.control = control
        self.events = events
    }

    func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        subscriber.receive(subscription: UIControlSubscription(subscriber: subscriber, control: control, event: events))
    }
}

extension CombineCompatible where Self: UIControl {
    func publisher(for events: UIControl.Event) -> UIControlPublisher<Self> {
        return UIControlPublisher(control: self, events: events)
    }
}

extension UIControl: CombineCompatible {}
