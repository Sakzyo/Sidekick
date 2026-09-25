//
//  ChatPromptEditor.swift
//  Sidekick
//
//  Created by John Bean on 4/20/25.
//

import SwiftUI

struct ChatPromptEditor<Options: View>: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(PromptController.self) private var promptController
    
    @AppStorage("useCommandReturn") private var useCommandReturn: Bool = Settings.useCommandReturn
    var sendDescription: String {
        return String(localized: "Enter a message. Press ") + Settings.SendShortcut(self.useCommandReturn).rawValue + String(localized: " to send.")
    }
    
    @FocusState var isFocused: Bool
    @Binding var isRecording: Bool
    
    /// Store a debouncing work item that we can cancel
    @State private var debouncedTask: DispatchWorkItem?
    
    var useAttachments: Bool = true
    var useDictation: Bool = true
    
    var cornerRadius = InterfaceStyle.cornerRadius
    @ViewBuilder var options: () -> Options
    var rect: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }
    
    var outlineColor: Color {
        if isRecording {
            return .red
        } else if isFocused {
            return .primary.opacity(0.28)
        }
        return .primary.opacity(0.13)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            editor
            options()
                .padding(.horizontal, 12)
        }
        .padding(.vertical, 10)
        .background(Color(nsColor: .textBackgroundColor))
        .clipShape(rect)
        .overlay(
            rect
                .strokeBorder(outlineColor, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 12, y: 3)
        .animation(isFocused ? .easeIn(duration: 0.2) : .easeOut(duration: 0.0), value: isFocused)
    }

    private var editor: some View {
        @Bindable var promptController = self.promptController
        return MultilineTextField(
            text: $promptController.prompt,
            insertionPoint: $promptController.insertionPoint,
            prompt: sendDescription,
            onImageDrop: { url in
                Task {
                    await self.promptController.addFile(url)
                }
            }
        )
        .textFieldStyle(.plain)
        .frame(maxWidth: .infinity)
        .if(self.useAttachments) { view in
            view
                .padding(.leading, 24)
        }
        .if(self.useDictation) { view in
            view
                .padding(.trailing, 21)
        }
        .if(!self.useAttachments) { view in
            view
                .padding(.leading, 4)
        }
        .if(!self.useDictation) { view in
            view
                .padding(.trailing, 4)
        }
    }
    
}
