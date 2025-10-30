//
//  EventListView.swift
//  MacroRecorder
//

import SwiftUI
import UniformTypeIdentifiers

struct EventListView: View {
    let macro: Macro
    @ObservedObject var session: MacroSession
    let currentEventIndex: Int

    @State private var selectedEvent: MacroEvent?
    @State private var showingEventEditor = false
    @State private var showingEventCreator = false
    @State private var draggedEventIndex: Int?

    var body: some View {
        VStack(spacing: 0) {
            // Timeline visualization
            TimelineView(
                events: macro.events,
                currentEventIndex: currentEventIndex,
                isPlaying: session.isPlaying
            )
            .frame(height: 100)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Event list header
            HStack {
                Text("Event")
                    .frame(width: 150, alignment: .leading)

                Text("Type")
                    .frame(width: 120, alignment: .leading)

                Text("Position")
                    .frame(width: 120, alignment: .leading)

                Text("Delay (s)")
                    .frame(width: 100, alignment: .leading)

                Spacer()

                Button(action: {
                    showingEventCreator = true
                }) {
                    Image(systemName: "plus.circle.fill")
                }
                .buttonStyle(.borderless)
                .help("Add New Event")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Event list
            ScrollViewReader { proxy in
                List(Array(macro.events.enumerated()), id: \.element.id) { index, event in
                    EventRow(
                        event: event,
                        index: index,
                        isSelected: selectedEvent?.id == event.id,
                        isCurrent: currentEventIndex == index && session.isPlaying,
                        onEdit: {
                            selectedEvent = event
                            showingEventEditor = true
                        },
                        onDelete: {
                            session.removeEvent(eventId: event.id)
                        }
                    )
                    .id(event.id)
                    .onTapGesture {
                        selectedEvent = event
                    }
                    .onDrag {
                        self.draggedEventIndex = index
                        return NSItemProvider(object: String(index) as NSString)
                    }
                    .onDrop(of: [.text], delegate: EventDropDelegate(
                        destinationIndex: index,
                        draggedIndex: $draggedEventIndex,
                        session: session
                    ))
                }
                .onChange(of: currentEventIndex) { newIndex in
                    if newIndex < macro.events.count {
                        withAnimation {
                            proxy.scrollTo(macro.events[newIndex].id, anchor: .center)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingEventEditor) {
            if let event = selectedEvent {
                EventEditorView(
                    event: event,
                    onSave: { updatedEvent in
                        session.updateEvent(updatedEvent)
                        showingEventEditor = false
                    },
                    onCancel: {
                        showingEventEditor = false
                    }
                )
            }
        }
        .sheet(isPresented: $showingEventCreator) {
            EventCreatorView(
                onSave: { newEvent in
                    session.insertEvent(newEvent, at: macro.events.count)
                    showingEventCreator = false
                },
                onCancel: {
                    showingEventCreator = false
                }
            )
        }
    }
}

struct EventRow: View {
    let event: MacroEvent
    let index: Int
    let isSelected: Bool
    let isCurrent: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 10) {
            // Index
            Text("\(index + 1)")
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .leading)

            // Type icon
            Image(systemName: eventIcon)
                .foregroundColor(eventColor)
                .frame(width: 30)

            // Type name
            Text(eventTypeName)
                .frame(width: 120, alignment: .leading)

            // Position or key
            Text(eventDetails)
                .font(.system(.caption, design: .monospaced))
                .frame(width: 120, alignment: .leading)

            // Delay
            Text(String(format: "%.3f", event.delay))
                .font(.system(.body, design: .monospaced))
                .frame(width: 100, alignment: .leading)

            Spacer()

            if isHovering {
                HStack(spacing: 5) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                    }
                    .buttonStyle(.borderless)

                    Button(action: onDelete) {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
        .padding(.vertical, 4)
        .background(backgroundColor)
        .cornerRadius(4)
        .onHover { hovering in
            isHovering = hovering
        }
        .contextMenu {
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }

            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private var backgroundColor: Color {
        if isCurrent {
            return Color.green.opacity(0.2)
        } else if isSelected {
            return Color.accentColor.opacity(0.1)
        } else {
            return Color.clear
        }
    }

    private var eventIcon: String {
        switch event.type {
        case .mouseLeftDown, .mouseLeftUp:
            return "cursorarrow.click"
        case .mouseRightDown, .mouseRightUp:
            return "cursorarrow.click.2"
        case .mouseMove:
            return "cursorarrow.rays"
        case .mouseDrag:
            return "cursorarrow.and.square.on.square.dashed"
        case .keyDown, .keyUp:
            return "keyboard"
        case .scroll:
            return "scroll"
        }
    }

    private var eventColor: Color {
        switch event.type {
        case .mouseLeftDown, .mouseRightDown:
            return .blue
        case .mouseLeftUp, .mouseRightUp:
            return .cyan
        case .mouseMove:
            return .purple
        case .mouseDrag:
            return .orange
        case .keyDown:
            return .green
        case .keyUp:
            return .mint
        case .scroll:
            return .indigo
        }
    }

    private var eventTypeName: String {
        switch event.type {
        case .mouseLeftDown:
            return "Left Click"
        case .mouseLeftUp:
            return "Left Release"
        case .mouseRightDown:
            return "Right Click"
        case .mouseRightUp:
            return "Right Release"
        case .mouseMove:
            return "Mouse Move"
        case .mouseDrag:
            return "Mouse Drag"
        case .keyDown:
            return "Key Down"
        case .keyUp:
            return "Key Up"
        case .scroll:
            return "Scroll"
        }
    }

    private var eventDetails: String {
        switch event.type {
        case .mouseLeftDown, .mouseLeftUp, .mouseRightDown, .mouseRightUp, .mouseMove, .mouseDrag:
            if let pos = event.position {
                return "(\(Int(pos.x)), \(Int(pos.y)))"
            }
        case .keyDown, .keyUp:
            if let keyCode = event.keyCode {
                return "Key: \(keyCode)"
            }
        case .scroll:
            if let dx = event.scrollDeltaX, let dy = event.scrollDeltaY {
                return "(\(Int(dx)), \(Int(dy)))"
            }
        }
        return "-"
    }
}

struct TimelineView: View {
    let events: [MacroEvent]
    let currentEventIndex: Int
    let isPlaying: Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                Rectangle()
                    .fill(Color(NSColor.controlBackgroundColor))

                // Timeline track
                Rectangle()
                    .fill(Color.secondary.opacity(0.1))
                    .frame(height: 4)
                    .padding(.horizontal, 20)

                // Events on timeline
                ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                    let position = calculatePosition(for: index, in: geometry.size.width)

                    Circle()
                        .fill(index == currentEventIndex && isPlaying ? Color.green : eventColor(for: event))
                        .frame(width: 8, height: 8)
                        .offset(x: position)
                }

                // Playhead
                if isPlaying && currentEventIndex < events.count {
                    let position = calculatePosition(for: currentEventIndex, in: geometry.size.width)

                    Rectangle()
                        .fill(Color.green)
                        .frame(width: 2)
                        .offset(x: position)
                }
            }
        }
    }

    private func calculatePosition(for index: Int, in width: CGFloat) -> CGFloat {
        let padding: CGFloat = 20
        let usableWidth = width - (padding * 2)

        guard events.count > 1 else {
            return padding + usableWidth / 2
        }

        let percentage = CGFloat(index) / CGFloat(events.count - 1)
        return padding + (usableWidth * percentage)
    }

    private func eventColor(for event: MacroEvent) -> Color {
        switch event.type {
        case .mouseLeftDown, .mouseLeftUp, .mouseRightDown, .mouseRightUp:
            return .blue
        case .mouseMove, .mouseDrag:
            return .purple
        case .keyDown, .keyUp:
            return .green
        case .scroll:
            return .orange
        }
    }
}

struct EventDropDelegate: DropDelegate {
    let destinationIndex: Int
    @Binding var draggedIndex: Int?
    let session: MacroSession

    func performDrop(info: DropInfo) -> Bool {
        guard let draggedIndex = draggedIndex else { return false }

        if draggedIndex != destinationIndex {
            session.moveEvent(from: draggedIndex, to: destinationIndex)
        }

        self.draggedIndex = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let draggedIndex = draggedIndex else { return }

        if draggedIndex != destinationIndex {
            withAnimation(.default) {
                // Visual feedback could be added here
            }
        }
    }
}
