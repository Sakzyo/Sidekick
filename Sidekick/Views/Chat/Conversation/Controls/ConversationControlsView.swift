//
//  ConversationControlsView.swift
//  Sidekick
//
//  Created by Bean John on 10/8/24.
//

import ImagePlayground
import MarkdownUI
import SwiftUI

struct ConversationControlsView: View {
    
    @Environment(PromptController.self) private var promptController
    @Environment(ConversationManager.self) private var conversationManager
        @Environment(ConversationState.self) private var conversationState
    
    @Namespace private var textFieldMoveAnimation
    
    var selectedConversation: Conversation? {
        return self.conversationState.selectedConversation
    }
    
    var selectedExpert: Expert? {
        guard let selectedExpertId = conversationState.selectedExpertId else {
            return nil
        }
        return ExpertManager.getExpert(id: selectedExpertId)
    }
    
    var messages: [Message] {
        return selectedConversation?.messages ?? []
    }
    
    var showQuickPrompts: Bool {
        let noPrompt: Bool = promptController.prompt.isEmpty
        let noMessages: Bool = messages.isEmpty
        let noResources: Bool = !promptController.hasResources
        return noPrompt && noMessages && noResources
    }

    var isCenteredLayout: Bool {
        self.promptController.prompt.isEmpty && self.messages.isEmpty
    }
    
    var maxHeight: CGFloat {
        return self.isCenteredLayout ? .infinity : 0
    }
    
    var body: some View {
        VStack {
            Spacer()
                .frame(maxHeight: maxHeight)
            controls
            Spacer()
                .frame(maxHeight: maxHeight)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 28)
        .padding(.bottom, isCenteredLayout ? 0 : 18)
        .animation(
            .easeInOut(duration: 0.22),
            value: self.isCenteredLayout
        )
    }
    
    var controls: some View {
        @Bindable var promptController = self.promptController
        return VStack {
            if promptController.hasResources && !self.promptController.prompt.isEmpty {
                resources
                    .matchedGeometryEffect(
                        id: "resources",
                        in: textFieldMoveAnimation
                    )
            }
            if messages.isEmpty {
                Group {
                    if promptController.prompt.isEmpty {
                        typedText
                            .transition(
                                .asymmetric(
                                    insertion: .push(from: .bottom),
                                    removal: .move(edge: .bottom)
                                )
                                .combined(with: .opacity)
                            )
                    }
                    inputField
                }
            }
            if showQuickPrompts {
                ConversationQuickPromptsView(
                    input: $promptController.prompt
                )
                .transition(
                    .asymmetric(
                        insertion: .push(from: .top),
                        removal: .move(edge: .top)
                    )
                    .combined(with: .opacity)
                )
            }
            if promptController.hasResources && self.promptController.prompt.isEmpty {
                resources
                    .matchedGeometryEffect(
                        id: "resources",
                        in: textFieldMoveAnimation
                    )
            }
            if !messages.isEmpty {
                inputField
            }
        }
        .frame(maxWidth: 780)
        .animation(
            .easeInOut(duration: 0.22),
            value: self.showQuickPrompts
        )
        .onDrop(
            of: ["public.file-url"],
            delegate: promptController
        )
    }
    
    var resources: some View {
        @Bindable var promptController = self.promptController
        return TemporaryResourcesView(
            tempResources: $promptController.tempResources
        )
        .transition(
            .opacity
        )
    }
    
    var typedText: some View {
        Text("How can I help you?")
            .font(.system(size: 26, weight: .semibold))
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 12)
    }
    
    var inputField: some View {
        HStack {
            PromptInputField()
        }
    }
    
}
