//
//  EventRecorder.swift
//  MacroRecorder
//

import Foundation
import CoreGraphics
import Combine
import ApplicationServices
import Carbon

class EventRecorder: ObservableObject {
    @Published var isRecording = false
    @Published var recordedEvents: [MacroEvent] = []

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var lastEventTime: TimeInterval = 0
    private var startTime: TimeInterval = 0

    // Store hotkeys to filter them out during recording
    var recordingHotkey: (keyCode: UInt32, modifiers: UInt32)?
    var playbackHotkey: (keyCode: UInt32, modifiers: UInt32)?

    // Event masks for what we want to capture
    private var eventMask: CGEventMask {
        let mask1 = CGEventMask(1 << CGEventType.leftMouseDown.rawValue)
        let mask2 = CGEventMask(1 << CGEventType.leftMouseUp.rawValue)
        let mask3 = CGEventMask(1 << CGEventType.rightMouseDown.rawValue)
        let mask4 = CGEventMask(1 << CGEventType.rightMouseUp.rawValue)
        let mask5 = CGEventMask(1 << CGEventType.mouseMoved.rawValue)
        let mask6 = CGEventMask(1 << CGEventType.leftMouseDragged.rawValue)
        let mask7 = CGEventMask(1 << CGEventType.rightMouseDragged.rawValue)
        let mask8 = CGEventMask(1 << CGEventType.keyDown.rawValue)
        let mask9 = CGEventMask(1 << CGEventType.keyUp.rawValue)
        let mask10 = CGEventMask(1 << CGEventType.scrollWheel.rawValue)

        var result = mask1
        result |= mask2
        result |= mask3
        result |= mask4
        result |= mask5
        result |= mask6
        result |= mask7
        result |= mask8
        result |= mask9
        result |= mask10
        return result
    }

    func startRecording() {
        guard !isRecording else { return }

        // Check for accessibility permissions
        guard checkAccessibilityPermissions() else {
            print("Accessibility permissions not granted")
            return
        }

        recordedEvents.removeAll()
        startTime = Date().timeIntervalSince1970
        lastEventTime = startTime

        // Create event tap callback
        let callback: CGEventTapCallBack = { proxy, type, event, refcon in
            guard let refcon = refcon else { return Unmanaged.passUnretained(event) }

            let recorder = Unmanaged<EventRecorder>.fromOpaque(refcon).takeUnretainedValue()
            recorder.handleEvent(event: event, type: type)

            return Unmanaged.passUnretained(event)
        }

        // Create event tap
        let selfPointer = Unmanaged.passUnretained(self).toOpaque()
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: eventMask,
            callback: callback,
            userInfo: selfPointer
        )

        guard let eventTap = eventTap else {
            print("Failed to create event tap")
            return
        }

        // Create run loop source
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)

        guard let runLoopSource = runLoopSource else {
            print("Failed to create run loop source")
            return
        }

        // Add to run loop
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)

        isRecording = true
        print("Recording started")
    }

    func stopRecording() {
        guard isRecording else { return }

        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }

        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        }

        eventTap = nil
        runLoopSource = nil
        isRecording = false

        print("Recording stopped. Captured \(recordedEvents.count) events")
    }

    private func handleEvent(event: CGEvent, type: CGEventType) {
        let currentTime = Date().timeIntervalSince1970
        let delay = recordedEvents.isEmpty ? 0 : currentTime - lastEventTime

        // Filter out hotkey events to prevent recording our own hotkeys
        if type == .keyDown || type == .keyUp {
            let keyCode = UInt32(event.getIntegerValueField(.keyboardEventKeycode))
            let flags = event.flags

            // Extract modifier flags
            let cmdPressed = flags.contains(.maskCommand)
            let shiftPressed = flags.contains(.maskShift)
            let optPressed = flags.contains(.maskAlternate)
            let ctrlPressed = flags.contains(.maskControl)

            // Check if this matches our recording hotkey
            if let recordingHotkey = recordingHotkey {
                if keyCode == recordingHotkey.keyCode {
                    let expectedCmd = (recordingHotkey.modifiers & UInt32(cmdKey)) != 0
                    let expectedShift = (recordingHotkey.modifiers & UInt32(shiftKey)) != 0
                    let expectedOpt = (recordingHotkey.modifiers & UInt32(optionKey)) != 0
                    let expectedCtrl = (recordingHotkey.modifiers & UInt32(controlKey)) != 0

                    if cmdPressed == expectedCmd && shiftPressed == expectedShift &&
                       optPressed == expectedOpt && ctrlPressed == expectedCtrl {
                        print("Filtered out recording hotkey event")
                        return
                    }
                }
            }

            // Check if this matches our playback hotkey
            if let playbackHotkey = playbackHotkey {
                if keyCode == playbackHotkey.keyCode {
                    let expectedCmd = (playbackHotkey.modifiers & UInt32(cmdKey)) != 0
                    let expectedShift = (playbackHotkey.modifiers & UInt32(shiftKey)) != 0
                    let expectedOpt = (playbackHotkey.modifiers & UInt32(optionKey)) != 0
                    let expectedCtrl = (playbackHotkey.modifiers & UInt32(controlKey)) != 0

                    if cmdPressed == expectedCmd && shiftPressed == expectedShift &&
                       optPressed == expectedOpt && ctrlPressed == expectedCtrl {
                        print("Filtered out playback hotkey event")
                        return
                    }
                }
            }
        }

        // Filter out excessive mouse move events to optimize recording
        if type == .mouseMoved {
            // Only record mouse moves if there's a significant delay (e.g., > 100ms)
            // or if it's been a while since last recorded move
            if delay < 0.1 {
                return
            }
        }

        if let macroEvent = MacroEvent.from(cgEvent: event, delay: delay) {
            recordedEvents.append(macroEvent)
            lastEventTime = currentTime
        }
    }

    func checkAccessibilityPermissions() -> Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        return AXIsProcessTrustedWithOptions(options)
    }

    func clearRecording() {
        recordedEvents.removeAll()
    }
}
