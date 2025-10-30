//
//  MacroListView.swift
//  MacroRecorder
//

import SwiftUI

struct MacroListView: View {
    let macros: [Macro]
    @Binding var selectedMacro: Macro?
    let onLoad: (Macro) -> Void
    let onDelete: (Macro) -> Void
    let onExport: (Macro) -> Void
    let onImport: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Saved Macros")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top)

                Spacer()

                Menu {
                    Button(action: onImport) {
                        Label("Import Macro", systemImage: "square.and.arrow.down")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .padding(.trailing)
                        .padding(.top)
                }
            }

            Divider()
                .padding(.top, 8)

            // Macro list
            if macros.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "tray")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)

                    Text("No saved macros")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(macros) { macro in
                    MacroListItem(
                        macro: macro,
                        isSelected: selectedMacro?.id == macro.id,
                        onLoad: { onLoad(macro) },
                        onDelete: { onDelete(macro) },
                        onExport: { onExport(macro) }
                    )
                    .onTapGesture {
                        selectedMacro = macro
                    }
                }
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct MacroListItem: View {
    let macro: Macro
    let isSelected: Bool
    let onLoad: () -> Void
    let onDelete: () -> Void
    let onExport: () -> Void

    @State private var isHovering = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(macro.name)
                        .font(.body)
                        .fontWeight(isSelected ? .semibold : .regular)

                    Text("\(macro.events.count) events")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(macro.modifiedAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isHovering {
                    Menu {
                        Button(action: onLoad) {
                            Label("Load", systemImage: "arrow.down.doc")
                        }

                        Button(action: onExport) {
                            Label("Export", systemImage: "square.and.arrow.up")
                        }

                        Divider()

                        Button(role: .destructive, action: onDelete) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .menuStyle(.borderlessButton)
                    .frame(width: 30, height: 30)
                }
            }
        }
        .padding(.vertical, 4)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(4)
        .onHover { hovering in
            isHovering = hovering
        }
        .contextMenu {
            Button(action: onLoad) {
                Label("Load", systemImage: "arrow.down.doc")
            }

            Button(action: onExport) {
                Label("Export", systemImage: "square.and.arrow.up")
            }

            Divider()

            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
