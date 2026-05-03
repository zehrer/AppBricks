//
//  Copyright (c) 2026 zehrer.xyz
//  Author: Stephan Zehrer
//
//  This file is part of AppBricks.
//
//  AppBricks is dual-licensed:
//  - GPLv3 for open-source use
//  - Commercial license required for proprietary use
//
// SPDX-License-Identifier: GPL-3.0-only
//
//  See the LICENSE file for details.
//
//  SwiftUIView.swift
//

import SwiftUI
import SwiftData

// MARK: - TagListView

struct TagListView: View {
    // External selection binding for multi-select usage
    @Binding var selection: Set<Tag>

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Tag.name, order: .forward)])
    private var tags: [Tag]

    @State private var draftName: String = ""
    @State private var draftColor: SimpleColor = .red
    @State private var isAddingNewTag: Bool = false
    @FocusState private var isDraftFocused: Bool
    @State private var pendingScrollID: String? = nil

    var allowsMultipleSelection: Bool = true

    init(selection: Binding<Set<Tag>> = .constant([]), allowsMultipleSelection: Bool = true) {
        self._selection = selection
        self.allowsMultipleSelection = allowsMultipleSelection
    }

    var body: some View {
        ScrollViewReader { proxy in
            List {
                Section(header: Text("tags.header", bundle: .module)) {
                    ForEach(tags) { tag in
                        Button(action: { toggleSelection(for: tag) }) {
                            HStack(spacing: 12) {
                                selectionIndicator(isSelected: isSelected(tag))
                                Text(tag.name)
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                Spacer()
                                Menu {
                                    ForEach(SimpleColor.allCases) { color in
                                        Button {
                                            // Update the tag's color
                                            tag.simpleColor = color
                                            // Selecting a color should not toggle selection, so do nothing else
                                        } label: {
                                            Label(SimpleColor.labelName(color), systemImage: (tag.simpleColor == color) ? "checkmark.circle.fill" : "circle")
                                        }
                                    }
                                } label: {
                                    colorDot(fill: tag.simpleColor?.color)
                                }
                                .menuStyle(.borderlessButton)
                                .accessibilityLabel(Text("tags.accessibility.change_color", bundle: .module))
                            }
                        }
                        .buttonStyle(.plain)
                        .contentShape(Rectangle())
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(Text(tag.name))
                        .accessibilityValue(Text(isSelected(tag) ? "tags.accessibility.selected" : "tags.accessibility.not_selected", bundle: .module))
                        .id(tag.persistentModelID)
                    }
                }

                if isAddingNewTag {
                    Section {
                        HStack(spacing: 12) {
                            selectionIndicator(isSelected: true)
                            TextField(String(localized: "tags.placeholder.name", bundle: .module), text: $draftName)
                                .focused($isDraftFocused)
                                .submitLabel(.done)
                                .onSubmit {
                                    finalizeDraftIfPossible()
                                }
                            Spacer()
                            colorPickerButton()
                        }
                        .contentShape(Rectangle())
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(Text(String(localized: "tags.placeholder.name", bundle: .module)))
                        .id(draftRowID)
                    }
                }

                Section {
                    Button(action: addInlineNewTag) {
                        HStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.green)
                            Text("tags.button.add_new", bundle: .module)
                                .foregroundStyle(.primary)
                            Spacer()
                        }
                        .padding(.vertical, 6)
                        .contentShape(Rectangle())
                        .accessibilityHint(Text("tags.accessibility.hint.create", bundle: .module))
                    }
                    .buttonStyle(.plain)
                }
            }
            .onChange(of: pendingScrollID) { _, newValue in
                if let id = newValue {
                    withAnimation {
                        proxy.scrollTo(id, anchor: .center)
                    }
                    // reset after scrolling
                    pendingScrollID = nil
                }
            }
        }
        .navigationTitle(Text("tags.title", bundle: .module))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(role: .cancel) {
                    discardDraft()
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    finalizeDraftIfPossible()
                    dismiss()
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                }
                .disabled(isAddingNewTag && draftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    // MARK: - Selection helpers

    private func isSelected(_ tag: Tag) -> Bool {
        selection.contains(where: { $0.persistentModelID == tag.persistentModelID })
    }

    private func toggleSelection(for tag: Tag) {
        if allowsMultipleSelection {
            if let existing = selection.first(where: { $0.persistentModelID == tag.persistentModelID }) {
                selection.remove(existing)
            } else {
                selection.insert(tag)
            }
        } else {
            selection.removeAll()
            selection.insert(tag)
        }
    }

    // MARK: - Inline creation helpers

    private func addInlineNewTag() {
        guard !isAddingNewTag else {
            isDraftFocused = true
            pendingScrollID = draftRowID
            return
        }

        draftName = ""
        draftColor = .red
        isAddingNewTag = true
        isDraftFocused = true
        pendingScrollID = draftRowID
    }

    private func finalizeDraftIfPossible() {
        guard isAddingNewTag else { return }
        let trimmed = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let normalized = Tag.normalizedTagName(from: trimmed) else { return }
        guard let tag = Tag(normalized) else { return }
        tag.simpleColor = draftColor
        modelContext.insert(tag)
        selection.insert(tag)
        isAddingNewTag = false
        draftName = ""
    }

    private func discardDraft() {
        isAddingNewTag = false
        draftName = ""
    }

    // MARK: - UI bits

    @ViewBuilder
    private func selectionIndicator(isSelected: Bool) -> some View {
        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            .foregroundStyle(isSelected ? Color.accentColor : .secondary)
    }

    @ViewBuilder
    private func colorDot(fill: Color?) -> some View {
        let resolvedFill: Color = fill ?? Color.secondary.opacity(0.3)
        Circle()
            .fill(resolvedFill)
            .frame(width: 16, height: 16)
    }

    @ViewBuilder
    private func colorPickerButton() -> some View {
        Menu {
            ForEach(SimpleColor.allCases) { color in
                Button {
                    draftColor = color
                } label: {
                    Label(SimpleColor.labelName(color), systemImage: color == draftColor ? "checkmark.circle.fill" : "circle")
                }
            }
        } label: {
            colorDot(fill: draftColor.color)
        }
        .menuStyle(.borderlessButton)
    }

    private var draftRowID: String { "draft-row" }
}

// MARK: - Preview

#Preview("With sample tags") {
    // Create an in-memory container and seed some tags
    let container = try! ModelContainer(for: Tag.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = container.mainContext

    let samples: [(String, SimpleColor)] = [
        ("Home", .blue),
        ("Work", .red),
        ("Important", .yellow),
        ("Finance", .green),
        ("Ideas", .purple),
        ("GrayTag", .gray)
    ]

    for (name, color) in samples {
        if let tag = Tag(name) {
            tag.simpleColor = color
            context.insert(tag)
        }
    }

    return NavigationStack {
        TagListView()
    }
    .modelContainer(container)
    .environment(\.locale, Locale(identifier: "en"))
}
