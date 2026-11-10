//
//  ServiceLinkFormView.swift
//  BrewServicesManager
//

import SwiftUI

/// Form for adding a new service link or editing an existing one.
struct ServiceLinkFormView: View {
    let title: Text
    let confirmTitle: LocalizedStringKey
    let onSave: (URL, String?) -> Void
    let onCancel: () -> Void

    @State private var urlString: String
    @State private var label: String
    @FocusState private var isURLFieldFocused: Bool

    /// Creates the form. `link` seeds the fields once; pass `nil` to add a new link.
    init(
        title: Text,
        confirmTitle: LocalizedStringKey,
        link: ServiceLink? = nil,
        onSave: @escaping (URL, String?) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.title = title
        self.confirmTitle = confirmTitle
        self.onSave = onSave
        self.onCancel = onCancel
        _urlString = State(initialValue: link?.url.absoluteString ?? "")
        _label = State(initialValue: link?.label ?? "")
    }

    private var validatedURL: URL? {
        ServiceLink.validatedURL(from: urlString)
    }

    var body: some View {
        VStack(spacing: .zero) {
            PanelHeaderView(title: title, onBack: onCancel)

            Divider()

            Form {
                TextField("URL", text: $urlString, prompt: Text(verbatim: "http://localhost:8080"))
                    .focused($isURLFieldFocused)

                TextField("Label", text: $label, prompt: Text("Optional"))
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            .scrollDisabled(true)

            HStack {
                Spacer()

                Button("Cancel", action: onCancel)
                    .keyboardShortcut(.cancelAction)

                Button(confirmTitle, action: save)
                    .disabled(validatedURL == nil)
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
            }
            .padding([.horizontal, .bottom])
        }
        .onAppear {
            isURLFieldFocused = true
        }
    }

    private func save() {
        guard let url = validatedURL else { return }
        onSave(url, ServiceLink.normalizedLabel(label))
    }
}

#Preview {
    ServiceLinkFormView(title: Text("Add Link"), confirmTitle: "Add", onSave: { _, _ in }, onCancel: { })
        .frame(width: LayoutConstants.serviceInfoMenuWidth, height: 240)
}
