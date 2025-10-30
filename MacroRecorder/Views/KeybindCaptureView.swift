//
//  KeybindCaptureView.swift
//  MacroRecorder
//

import SwiftUI
import Carbon

struct HotkeyConfig: Codable, Equatable {
    var keyCode: UInt32
    var modifiers: UInt32

    var displayString: String {
        var parts: [String] = []

        if modifiers & UInt32(cmdKey) != 0 {
            parts.append("⌘")
        }
        if modifiers & UInt32(shiftKey) != 0 {
            parts.append("⇧")
        }
        if modifiers & UInt32(optionKey) != 0 {
            parts.append("⌥")
        }
        if modifiers & UInt32(controlKey) != 0 {
            parts.append("⌃")
        }

        parts.append(keyCodeToString(keyCode: UInt16(keyCode)))
        return parts.joined()
    }

    private func keyCodeToString(keyCode: UInt16) -> String {
        let keyCodes: [UInt16: String] = [
            0x00: "A", 0x01: "S", 0x02: "D", 0x03: "F", 0x04: "H", 0x05: "G",
            0x06: "Z", 0x07: "X", 0x08: "C", 0x09: "V", 0x0B: "B", 0x0C: "Q",
            0x0D: "W", 0x0E: "E", 0x0F: "R", 0x10: "Y", 0x11: "T", 0x12: "1",
            0x13: "2", 0x14: "3", 0x15: "4", 0x16: "6", 0x17: "5", 0x18: "=",
            0x19: "9", 0x1A: "7", 0x1B: "-", 0x1C: "8", 0x1D: "0", 0x1E: "]",
            0x1F: "O", 0x20: "U", 0x21: "[", 0x22: "I", 0x23: "P", 0x25: "L",
            0x26: "J", 0x27: "'", 0x28: "K", 0x29: ";", 0x2A: "\\", 0x2B: ",",
            0x2C: "/", 0x2D: "N", 0x2E: "M", 0x2F: ".", 0x32: "`",
            0x24: "↩", 0x30: "⇥", 0x31: "␣", 0x33: "⌫", 0x35: "⎋",
            0x7A: "F1", 0x78: "F2", 0x63: "F3", 0x76: "F4", 0x60: "F5",
            0x61: "F6", 0x62: "F7", 0x64: "F8", 0x65: "F9", 0x6D: "F10",
            0x67: "F11", 0x6F: "F12"
        ]

        return keyCodes[keyCode] ?? "?"
    }
}

struct KeybindCaptureView: View {
    @Binding var hotkeyConfig: HotkeyConfig
    @State private var isCapturing = false
    @State private var capturedKey: String = ""
    let label: String

    var body: some View {
        HStack {
            Text(label)
                .frame(width: 150, alignment: .leading)

            Button(action: {
                isCapturing = true
            }) {
                Text(isCapturing ? "Press keys..." : hotkeyConfig.displayString)
                    .font(.system(.body, design: .monospaced))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .frame(minWidth: 100)
                    .background(isCapturing ? Color.accentColor.opacity(0.2) : Color(NSColor.controlBackgroundColor))
                    .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isCapturing ? Color.accentColor : Color.clear, lineWidth: 2)
            )
            .background(KeybindCaptureHelper(isCapturing: $isCapturing, onCapture: { keyCode, modifiers in
                hotkeyConfig = HotkeyConfig(keyCode: UInt32(keyCode), modifiers: modifiers)
            }))

            if isCapturing {
                Button("Cancel") {
                    isCapturing = false
                }
                .buttonStyle(.borderless)
            }
        }
    }
}

struct KeybindCaptureHelper: NSViewRepresentable {
    @Binding var isCapturing: Bool
    let onCapture: (UInt16, UInt32) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = KeyCaptureNSView()
        view.onKeyCapture = { keyCode, modifiers in
            onCapture(keyCode, modifiers)
            isCapturing = false
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if let captureView = nsView as? KeyCaptureNSView {
            captureView.isCapturing = isCapturing
            if isCapturing {
                DispatchQueue.main.async {
                    nsView.window?.makeFirstResponder(nsView)
                }
            }
        }
    }
}

class KeyCaptureNSView: NSView {
    var isCapturing = false
    var onKeyCapture: ((UInt16, UInt32) -> Void)?

    override var acceptsFirstResponder: Bool {
        return isCapturing
    }

    override func keyDown(with event: NSEvent) {
        guard isCapturing else {
            super.keyDown(with: event)
            return
        }

        let keyCode = event.keyCode
        var modifiers: UInt32 = 0

        if event.modifierFlags.contains(.command) {
            modifiers |= UInt32(cmdKey)
        }
        if event.modifierFlags.contains(.shift) {
            modifiers |= UInt32(shiftKey)
        }
        if event.modifierFlags.contains(.option) {
            modifiers |= UInt32(optionKey)
        }
        if event.modifierFlags.contains(.control) {
            modifiers |= UInt32(controlKey)
        }

        // Require at least one modifier key
        if modifiers != 0 {
            onKeyCapture?(keyCode, modifiers)
        }
    }

    override func flagsChanged(with event: NSEvent) {
        // Ignore modifier-only key presses
    }
}
