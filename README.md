<h1 align="center">
  <p align="center">
    <img src="Docs%20Images/appIcon.png" alt="Logo" width = "200" height = "200">
  </p>
  <br />
  Sidekick
</h1>

<p align="center">
<img alt="Downloads" src="https://img.shields.io/github/downloads/Sakzyo/Sidekick/total?label=Downloads" height=22.5>
<img alt="License" src="https://img.shields.io/github/license/Sakzyo/Sidekick?label=License" height=22.5>
</p>

Sidekick is a native macOS app for chatting with local models, working with your files, and connecting to remote AI providers. It is a <strong>local first</strong> application with a built-in `llama.cpp` inference engine, so local GGUF models do not require a separate model server. Conversations and saved memories are stored on your Mac. Local inference can work offline after the required models are downloaded; remote APIs, web search, and online tools use the network and may send relevant conversation or resource content to those services.

This fork of [the original Sidekick](https://github.com/johnbean393/Sidekick) adds a **Codex-inspired chat interface**: a wider conversation sidebar, centered messages, a quieter toolbar, and model selection inside the chat box alongside Search, Functions, and supported reasoning controls. Press **Command-K** to choose a model or **Command-N** to start a chat. The current source includes more subtle button corners scaled to the larger chat box.

The latest prerelease is [**v1.0.0-rc.2, build 40**](https://github.com/Sakzyo/Sidekick/releases/tag/v1.0.0-rc.2) for Apple Silicon and macOS 15.0 or later, including the latest button-radius refinements. The existing [**v1.0.0, build 39**](https://github.com/Sakzyo/Sidekick/releases/tag/v1.0.0) remains available. Sidekick supports GGUF model families such as Qwen3.5 through its bundled backend; model size and compatibility determine what can run on your Mac.

![Current Sidekick chat interface with the model selector inside the composer](Docs%20Images/Current/chat.jpg)

*Screenshots show a local build captured on 25 September 2026. RC2 includes these button-corner refinements; the original v1.0.0 DMG predates them.*

## Example Use

Suppose you are collecting evidence for a History paper about interactions between Aztecs and Spanish troops, and want to find passages about captured Spanish weapons.

Create an expert with your research papers, select it from the expert menu, and ask, “Did the Aztecs use captured Spanish weapons?” Sidekick can retrieve relevant passages and use them to answer, with source references where available. Ask for quotations and page numbers, then check them against the original document.

Open a reference below the answer to inspect the source in your viewer. Retrieval helps ground the response in your materials, but quotations, page numbers, and conclusions still depend on the document extraction and the selected model.

## Features

The sections below describe the current app. The [original project's feature guides](Markdown/Features/) provide additional background, while [this fork's RC2 release notes](docs/releases/1.0.0-rc.2.md) describe the current prerelease and its known limitations.

### Resource Use

Organize files, folders, and websites into **experts** with their own resources and instructions. Selecting an expert makes its indexed material available to the conversation.

Sidekick uses retrieval-augmented generation (RAG) to find relevant passages instead of placing every document into each prompt. The amount of material you can use depends on available memory, storage, indexing time, and the model's context window.

For example, a student might create experts named `English Literature`, `Mathematics`, `Geography`, `Computer Science`, and `Physics`, then select the one relevant to the current task.

**Settings → Retrieval** controls the number of retrieved passages, surrounding context, and experimental knowledge-graph retrieval.

![Current resource retrieval settings](Docs%20Images/Current/resources.jpg)

You can also attach files using the paperclip button or drag them into the chat box for the current conversation.

The **Search** control inside the composer enables web-assisted responses. Online search requires an internet connection; provider settings may require an API key.

![Current web-search provider settings](Docs%20Images/Current/search.jpg)

### Bring Your Own API Key

Use the bundled engine for local inference, or configure a server that exposes an **OpenAI-compatible API**. Choose the model from the selector inside the chat box, which lists local and remote options and supports searching model names.

The settings include presets for **OpenAI**, **DeepSeek**, **Google AI Studio**, **Groq**, **MiniMax**, **Mistral**, **OpenRouter**, **xAI**, **Aliyun Bailian**, **Zhipu**, **Anthropic**, and local servers such as **LM Studio** and **Ollama**. A preset supplies an endpoint; successful requests still depend on that endpoint's API compatibility and the selected model. Remote inference sends the prompt and included context to the configured server.

### Function Calling

Enable **Functions** in the composer and choose the tool categories the model can use. Available tools cover files, shell commands, web access, contacts, calendars, reminders, task lists, expert resources, and Mermaid diagrams. Tool use depends on the selected model's capabilities and any required macOS permissions.

The agent loop can perform multiple rounds of tool calls and run supported calls concurrently. The chat displays tool activity, results, and reasoning when the model supplies it. For example, a model can gather financial data and write a CSV file; the exact sequence and number of calls vary by task.

![Current function-calling settings and approval controls](Docs%20Images/Current/functions.jpg)

With the relevant tools and permissions enabled, Sidekick can look up a contact and open an email draft in the default mail application.

These workflows can use a local model. Tools that access websites or external services still require network access.

### Deep Research

Deep Research handles multi-step research tasks by clarifying the request, planning sections, gathering information, drafting a report, and preparing supporting diagrams.

Provide a topic and the scope you want covered. Sidekick shows progress as it works through the report. The number of sources and completion time depend on the task, model, and search configuration; web research requires an internet connection.

### Memory

Optional memory lets Sidekick save useful details and retrieve relevant ones in later conversations. Memory is disabled by default. Enable it in settings, and use the memory manager to review or remove saved entries. Memories are stored locally; recalled information can be included in requests to a remote model if you choose one.

For example, you might tell Sidekick that you are learning Python while building Tetris.

![Current memory settings and memory-manager control](Docs%20Images/Current/memory.jpg)

In a later conversation about `pygame` alternatives, a relevant saved memory can provide context about that project.

### Canvas

Use Canvas to edit and preview websites, code, and other text alongside the conversation. It keeps snapshots so you can inspect versions and copy or export content.

Select part of the text and ask the model for a focused revision, then review the result in the editor or preview.

### Image Generation

Sidekick integrates Apple's **Image Playground** for image requests on supported Macs.

A built-in Core ML classifier routes prompts toward text or image generation. When the request is ambiguous or a possible image prompt is very short, Sidekick asks which response type you want before opening the image-generation flow.

This feature requires macOS 15.2 or later and Image Playground availability, including the necessary Apple Intelligence setup. It is separate from the selected local or remote chat model.

### Advanced Markdown Rendering

Chat responses use an embedded WebKit Markdown renderer with streaming updates, selectable text, tables, images, syntax highlighting, and mathematical notation. Long code blocks can be expanded or collapsed. Conversation sharing includes text and HTML, with image and PDF capture available through the chat capture actions.

#### LaTeX

Inline and display equations are rendered with bundled **KaTeX** in the chat renderer.

#### Data Visualization

The current chat renderer displays Markdown tables directly and supports generated images. Enable the **Diagram** function category to let the model create Mermaid diagrams, or use Canvas to work on a visualization's code and preview.

Diagram tools save their output as SVG files for use outside Sidekick.

#### Code

Fenced code blocks show a language label, syntax highlighting, a copy action, and expand/collapse controls for longer snippets. Use Canvas when you want to edit or export a code artifact.

### Fast Generation

Sidekick runs local GGUF models through its bundled `llama.cpp` backend on Apple Silicon. Settings support speculative decoding with a compatible draft model. Generation speed and memory use depend on the model, quantization, context size, and hardware.

![Current local model and speculative decoding settings](Docs%20Images/Current/local-models.jpg)

When adding a local model, the configuration sheet shows its estimated memory use and lets you choose a context length.

![Current local model configuration and context-length controls](Docs%20Images/Current/model-configuration.jpg)

You can also route inference to a local server or remote provider. The app tracks generation per conversation, allowing work in separate chats to continue independently.

![Current remote endpoint settings with the API key concealed](Docs%20Images/Current/remote-models.jpg)

## Installation

### Requirements

- A Mac with Apple Silicon (arm64)
- macOS 15.0 or later
- At least 8 GB of RAM; larger models and context windows require more memory
- Enough free disk space for the app and any downloaded model files

### Via Homebrew

This repository does not provide a Homebrew cask for its builds. Install this fork using the GitHub release DMG below.

### Download and Setup

- Download `Sidekick-1.0.0-rc.2-arm64.dmg` from [the RC2 prerelease](https://github.com/Sakzyo/Sidekick/releases/tag/v1.0.0-rc.2). The release also includes a SHA-256 checksum file; the [original v1.0.0 download](https://github.com/Sakzyo/Sidekick/releases/tag/v1.0.0) remains available.
- Open the DMG and drag **Sidekick** to **Applications**, quitting any running copy before replacing it. This build is **ad hoc signed and not notarized**, so macOS Gatekeeper may block a downloaded copy. See the [RC2 release notes](docs/releases/1.0.0-rc.2.md) for the distribution details.
- Launch Sidekick and download a recommended model, select **Use GGUF model**, or choose **Use model server** to configure an API endpoint.
- Click **New Chat** in the sidebar, choose a model inside the chat box, and enter a message. Use the adjacent Search and Functions controls to enable those features.
- Get updates to this fork from its GitHub releases; the inherited in-app updater uses the original project's feed.

## Goals

Sidekick aims to make local AI practical for everyday work: chat with models on your own Mac, bring relevant documents into the conversation, and choose remote services when you need them. This fork focuses on a clear native desktop interface with controls close to the message composer.

The [original project's mission](Markdown/About/mission.md) provides the background for this work.

## Developer Setup

### Requirements

- A Mac with Apple Silicon
- Enough RAM and disk space for Xcode, dependencies, and any local models you plan to use
- Xcode and its Command Line Tools; the current source was built with **Xcode 26.6**
- Internet access for the initial Swift Package Manager dependency resolution

### Developer Setup Instructions

1. Clone this repository: `git clone https://github.com/Sakzyo/Sidekick.git`, then `cd Sidekick`.
1. Open `Sidekick.xcodeproj`, let Xcode resolve the Swift packages, and select the **Sidekick** scheme with **My Mac** as the destination.
1. For a signed development build, set your team in **Signing & Capabilities** and update the team prefix in `Sidekick/Sidekick.entitlements`'s `com.apple.application-identifier` to match. The optional helper updates the Xcode project's team settings: `(cd scripts && ./setup-team.sh YOUR_TEAM_ID)`.
1. Build and run in Xcode. The project includes the local inference executables and libraries; a separate inference-server installation is not required.
1. To create an ad hoc signed DMG from the current source, build Release and run the packaging script:

   ```bash
   xcodebuild -project Sidekick.xcodeproj -scheme Sidekick \
     -configuration Release -destination 'platform=macOS,arch=arm64' \
     -derivedDataPath /private/tmp/SidekickDerived \
     CODE_SIGNING_ALLOWED=NO build
   ./scripts/package-dmg.sh /private/tmp/SidekickDerived/Build/Products/Release/Sidekick.app
   ```

   The script verifies nested signatures, creates the DMG and checksum under `dist/`, and verifies the disk image. Its output is ad hoc signed and unnotarized.

The SwiftUI interface lives under `Sidekick/Views`. Shared surface and chat-button shapes are defined in `Sidekick/Views/Styles/InterfaceStyle.swift`; the Markdown renderer and export styles are under `Sidekick/Resources/ChatMarkdownWebView`.

## Contributing

Issues and pull requests are welcome at [Sakzyo/Sidekick](https://github.com/Sakzyo/Sidekick). For UI changes, describe the affected flow, include before-and-after screenshots, and check the native app after building. For model or tool issues, include the model name, provider or local setup, macOS version, and reproducible steps without sharing API keys.

## Contact

For questions and bug reports about this fork, [open an issue](https://github.com/Sakzyo/Sidekick/issues). For the original project, visit [johnbean393/Sidekick](https://github.com/johnbean393/Sidekick).

## Credits

This project builds on the work of:

- John Bean and the contributors to [the original Sidekick](https://github.com/johnbean393/Sidekick)
- psugihara and contributors to [FreeChat](https://github.com/psugihara/FreeChat), an inspiration for Sidekick
- Georgi Gerganov and contributors to [llama.cpp](https://github.com/ggml-org/llama.cpp)
- The teams behind Qwen, Llama, Gemma, and other compatible open models
- The maintainers of the Swift packages and bundled Markdown, highlighting, and mathematics libraries used by the app

## Star History

<a href="https://star-history.com/#Sakzyo/Sidekick&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=Sakzyo/Sidekick&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=Sakzyo/Sidekick&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=Sakzyo/Sidekick&type=Date" />
 </picture>
</a>
