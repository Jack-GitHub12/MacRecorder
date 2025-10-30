//
//  MacroEvent.swift
//  MacroRecorder
//

import Foundation
import CoreGraphics

enum EventType: String, Codable {
    case mouseLeftDown
    case mouseLeftUp
    case mouseRightDown
    case mouseRightUp
    case mouseMove
    case mouseDrag
    case keyDown
    case keyUp
    case scroll
}

struct MacroEvent: Codable, Identifiable {
    let id: UUID
    let type: EventType
    let timestamp: TimeInterval
    let position: CGPoint?
    let keyCode: UInt16?
    let flags: UInt64?
    let scrollDeltaX: Double?
    let scrollDeltaY: Double?
    var delay: TimeInterval // Time since previous event

    init(
        id: UUID = UUID(),
        type: EventType,
        timestamp: TimeInterval,
        position: CGPoint? = nil,
        keyCode: UInt16? = nil,
        flags: UInt64? = nil,
        scrollDeltaX: Double? = nil,
        scrollDeltaY: Double? = nil,
        delay: TimeInterval = 0
    ) {
        self.id = id
        self.type = type
        self.timestamp = timestamp
        self.position = position
        self.keyCode = keyCode
        self.flags = flags
        self.scrollDeltaX = scrollDeltaX
        self.scrollDeltaY = scrollDeltaY
        self.delay = delay
    }

    // Create from CGEvent
    static func from(cgEvent: CGEvent, delay: TimeInterval = 0) -> MacroEvent? {
        let timestamp = Date().timeIntervalSince1970
        let eventType = cgEvent.type

        let type: EventType?
        switch eventType {
        case .leftMouseDown:
            type = .mouseLeftDown
        case .leftMouseUp:
            type = .mouseLeftUp
        case .rightMouseDown:
            type = .mouseRightDown
        case .rightMouseUp:
            type = .mouseRightUp
        case .mouseMoved:
            type = .mouseMove
        case .leftMouseDragged, .rightMouseDragged:
            type = .mouseDrag
        case .keyDown:
            type = .keyDown
        case .keyUp:
            type = .keyUp
        case .scrollWheel:
            type = .scroll
        default:
            return nil
        }

        guard let eventType = type else { return nil }

        let position = cgEvent.location
        let keyCode = eventType == .keyDown || eventType == .keyUp
            ? UInt16(cgEvent.getIntegerValueField(.keyboardEventKeycode))
            : nil
        let flags = cgEvent.flags.rawValue

        let scrollDeltaX = eventType == .scroll
            ? Double(cgEvent.getIntegerValueField(.scrollWheelEventDeltaAxis2))
            : nil
        let scrollDeltaY = eventType == .scroll
            ? Double(cgEvent.getIntegerValueField(.scrollWheelEventDeltaAxis1))
            : nil

        return MacroEvent(
            type: eventType,
            timestamp: timestamp,
            position: position,
            keyCode: keyCode,
            flags: flags,
            scrollDeltaX: scrollDeltaX,
            scrollDeltaY: scrollDeltaY,
            delay: delay
        )
    }

    // Create CGEvent for playback
    func toCGEvent() -> CGEvent? {
        let eventType: CGEventType

        switch type {
        case .mouseLeftDown:
            eventType = .leftMouseDown
        case .mouseLeftUp:
            eventType = .leftMouseUp
        case .mouseRightDown:
            eventType = .rightMouseDown
        case .mouseRightUp:
            eventType = .rightMouseUp
        case .mouseMove:
            eventType = .mouseMoved
        case .mouseDrag:
            eventType = .leftMouseDragged
        case .keyDown:
            eventType = .keyDown
        case .keyUp:
            eventType = .keyUp
        case .scroll:
            eventType = .scrollWheel
        }

        var event: CGEvent?

        switch type {
        case .mouseLeftDown, .mouseLeftUp, .mouseRightDown, .mouseRightUp, .mouseMove, .mouseDrag:
            guard let position = position else { return nil }
            let mouseButton: CGMouseButton = type == .mouseRightDown || type == .mouseRightUp ? .right : .left
            event = CGEvent(mouseEventSource: nil, mouseType: eventType, mouseCursorPosition: position, mouseButton: mouseButton)

        case .keyDown, .keyUp:
            guard let keyCode = keyCode else { return nil }
            event = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: type == .keyDown)

        case .scroll:
            event = CGEvent(scrollWheelEvent2Source: nil,
                          units: .pixel,
                          wheelCount: 2,
                          wheel1: Int32(scrollDeltaY ?? 0),
                          wheel2: Int32(scrollDeltaX ?? 0),
                          wheel3: 0)
        }

        if let flags = flags {
            event?.flags = CGEventFlags(rawValue: flags)
        }

        return event
    }
}

struct Macro: Codable, Identifiable {
    let id: UUID
    var name: String
    var events: [MacroEvent]
    let createdAt: Date
    var modifiedAt: Date

    init(id: UUID = UUID(), name: String, events: [MacroEvent] = []) {
        self.id = id
        self.name = name
        self.events = events
        self.createdAt = Date()
        self.modifiedAt = Date()
    }

    mutating func updateDelays() {
        guard events.count > 1 else { return }

        for i in 1..<events.count {
            events[i].delay = events[i].timestamp - events[i-1].timestamp
        }

        if !events.isEmpty {
            events[0].delay = 0
        }
    }
}
