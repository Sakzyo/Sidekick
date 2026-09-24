//
//  ConversationManagerView.swift
//  Sidekick
//
//  Created by Bean John on 10/8/24.
//

import Combine
import SwiftUI

struct ConversationManagerView: View {
    
    @Environment(\.appearsActive) private var appearsActive
    
    @StateObject private var model: Model = .shared
    @StateObject private var canvasController: CanvasController = .init()
    
    @Environment(AppState.self) private var appState
        @Environment(ConversationManager.self) private var conversationManager
    @Environment(ConversationState.self) private var conversationState
    
    var selectedExpert: Expert? {
        guard let selectedExpertId = conversationState.selectedExpertId else {
            return nil
        }
        return ExpertManager.getExpert(id: selectedExpertId)
    }
    
    var selectedConversation: Conversation? {
        return self.conversationState.selectedConversation
    }
    
    var body: some View {
        NavigationSplitView {
            conversationList
        } detail: {
            conversationView
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItemGroup(
                placement: .principal
            ) {
                ExpertSelectionMenu()
                    .onChange(
                        of: conversationState.selectedExpertId
                    ) {
                        guard var selectedConversation = self.selectedConversation else {
                            return
                        }
                        selectedConversation.expertId = self.conversationState.selectedExpertId
                        self.conversationManager.update(selectedConversation)
                    }
            }
            ToolbarItemGroup(
                placement: .primaryAction
            ) {
                Spacer()
                // Button to toggle canvas
                canvasToggle
                // Menu to share conversation
                MessageShareMenu()
            }
        }
        .onChange(of: selectedExpert) {
            self.refreshSystemPrompt()
        }
        .onChange(
            of: conversationState.selectedConversationId
        ) {
            withAnimation(.linear) {
                // Use most recently selected expert
                let expertId: UUID? = selectedConversation?.messages.last?.expertId ?? ExpertManager.default?.id
                self.conversationState.selectedExpertId = expertId
                // Turn off artifacts
                self.conversationState.useCanvas = false
            }
        }
        .onChange(
            of: self.selectedConversation?.messagesWithSnapshots
        ) {
            self.loadLatestSnapshot()
        }
        .onAppear {
            self.selectInitialConversationIfNeeded()
        }
        .onChange(of: conversationManager.isLoaded) {
            self.selectInitialConversationIfNeeded()
        }
        .onChange(of: conversationManager.conversations) {
            self.selectInitialConversationIfNeeded()
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: Notifications.systemPromptChanged.name
            )
        ) { output in
            self.refreshSystemPrompt()
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: Notifications.changedInferenceConfig.name
            )
        ) { output in
            self.refreshModel()
        }
        // ``ConversationState.newConversation`` now handles
        // expert reset + selection directly because the new chat
        // is an in-memory draft that isn't surfaced by
        // ``ConversationManager.recentConversation`` until the
        // user sends the first message. The previous listener
        // would have clobbered the draft selection with the
        // most-recent persisted conversation, so it's gone.
        .onReceive(
            NotificationCenter.default.publisher(
                for: Notifications.switchToConversation.name
            )
        ) { output in
            guard let targetId = output.object as? UUID else {
                return
            }
            withAnimation(.linear) {
                self.conversationState.selectedConversationId = targetId
            }
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: Notifications.didCommandSelectExpert.name
            )
        ) { output in
            // Update expert if needed
            if self.appearsActive {
                withAnimation(.linear) {
                    self.conversationState.selectedExpertId = self.appState.commandSelectedExpertId
                }
            }
        }
        .environmentObject(model)
        .environmentObject(canvasController)
    }
    
    var conversationList: some View {
        VStack(
            alignment: .leading,
            spacing: 0
        ) {
            Text("Sidekick")
                .font(.caption2.weight(.semibold))
                .tracking(1.2)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.top, 15)
                .padding(.bottom, 12)
            ConversationSidebarButtons()
                .padding(.horizontal, 10)
                .padding(.bottom, 16)
            Text("Conversations")
                .font(.caption2.weight(.semibold))
                .tracking(1)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.bottom, 6)
            ConversationNavigationListView()
        }
        .navigationSplitViewColumnWidth(
            min: 220,
            ideal: 260,
            max: 320
        )
    }
    
    var conversationView: some View {
        Group {
            if conversationState.selectedConversationId == nil || selectedConversation == nil {
                noSelectedConversation
            } else {
                HSplitView {
                    ConversationView()
                        .frame(minWidth: 450, minHeight: 500)
                    if self.conversationState.useCanvas {
                        CanvasView()
                            .frame(
                                minWidth: 500,
                                idealWidth: 700,
                                maxWidth: 800
                            )
                    }
                }
            }
        }
    }
    
    var noSelectedConversation: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.text.bubble.right")
                .font(.system(size: 30, weight: .light))
                .foregroundStyle(.secondary)
            Text("New Conversation")
                .font(.title2.weight(.semibold))
            Button("New Chat") {
                self.conversationState.newConversation()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var canvasToggle: some View {
        Button {
            self.toggleCanvas()
        } label: {
            Label("Canvas", systemImage: "cube")
                .foregroundStyle(.secondary)
                .symbolRenderingMode(.monochrome)
        }
        .disabled({
            let hasAssistantMessages = self.selectedConversation?.messages.contains {
                $0.getSender() == .assistant
            } ?? false
            let hasMessages = !(self.selectedConversation?.messages.isEmpty ?? true)
            return !hasAssistantMessages || !hasMessages
        }())
        .keyboardShortcut(.return, modifiers: [.command, .option])
    }
    
    /// Function to load latest snapshot
    private func loadLatestSnapshot() {
        // Get latest message message with snapshot
        guard let selectedConversation = self.selectedConversation else {
            return
        }
        guard let message = selectedConversation.messagesWithSnapshots.last else {
            return
        }
        // Show latest snapshot in canvas
        withAnimation(.linear) {
            self.canvasController.selectedMessageId = message.id
            self.conversationState.useCanvas = true
        }
    }

    private func selectInitialConversationIfNeeded() {
        guard self.conversationManager.isLoaded else {
            return
        }
        guard self.conversationState.selectedConversationId == nil else {
            return
        }
        guard let recentConversationId = self.conversationManager.recentConversation?.id else {
            return
        }
        withAnimation(.linear) {
            self.conversationState.selectedConversationId = recentConversationId
        }
    }
    
    private func toggleCanvas() {
        withAnimation(.linear) {
            // Select a version if possible
            if let message = self.selectedConversation?.messagesWithSnapshots.last {
                self.canvasController.selectedMessageId = message.id
            }
            // Confirm whether content should be extracted
            if self.selectedConversation?.messagesWithSnapshots.isEmpty ?? true {
                // If no snapshots, confirm extraction
                if !Dialogs.showConfirmation(
                    title: String(localized: "No Content Found"),
                    message: String(localized: "No content found. Would you like to extract content from your most recent message?")
                ) {
                    return // If no, exit
                }
            }
            // Toggle canvas
            self.conversationState.useCanvas.toggle()
            // Extract snapshot if needed
            if !self.canvasController.isExtractingSnapshot {
                Task { @MainActor in
                    try? await self.canvasController.extractSnapshot(
                        selectedConversation: selectedConversation
                    )
                }
            }
        }
    }
    
    private func refreshModel() {
        // Refresh model
        Task {
            await self.model.refreshModel()
        }
    }
    
    private func refreshSystemPrompt() {
        // Set new prompt
        var prompt: String = InferenceSettings.systemPrompt
        if let systemPrompt = self.selectedExpert?.systemPrompt {
            prompt = systemPrompt
        }
        Task {
            await self.model.setSystemPrompt(prompt)
        }
    }
    
}
