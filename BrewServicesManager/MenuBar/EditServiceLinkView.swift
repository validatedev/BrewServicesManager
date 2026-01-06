//
//  EditServiceLinkView.swift
//  BrewServicesManager
//

import SwiftUI

struct EditServiceLinkView: View {
    let link: ServiceLink
    let onSave: (URL, String?) -> Void
    let onCancel: () -> Void

    @State private var urlString: String
    @State private var label: String
    @FocusState private var urlFieldFocused: Bool

    private var isValid: Bool {
        guard let url = URL(string: urlString),
              let scheme = url.scheme?.lowercased() else {
            return false
        }

        // Block potentially malicious schemes - allow everything else
        let blockedSchemes = ["javascript", "data", "file"]

        return !blockedSchemes.contains(scheme)
    }

    init(link: ServiceLink, onSave: @escaping (URL, String?) -> Void, onCancel: @escaping () -> Void) {
        self.link = link
        self.onSave = onSave
        self.onCancel = onCancel
        _urlString = State(initialValue: link.url.absoluteString)
        _label = State(initialValue: link.label ?? "")
    }

    var body: some View {
        VStack(spacing: .zero) {
            PanelHeaderView(title: "Edit Link", onBack: onCancel)

            Divider()

            VStack(alignment: .leading, spacing: LayoutConstants.compactPadding) {
                VStack(alignment: .leading, spacing: LayoutConstants.tightSpacing) {
                    Text("URL")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TextField("http://localhost:8080", text: $urlString)
                        .textFieldStyle(.roundedBorder)
                        .focused($urlFieldFocused)
                }

                VStack(alignment: .leading, spacing: LayoutConstants.tightSpacing) {
                    Text("Label (optional)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TextField("My Service", text: $label)
                        .textFieldStyle(.roundedBorder)
                }

                HStack {
                    Spacer()

                    Button("Cancel") {
                        onCancel()
                    }
                    .keyboardShortcut(.cancelAction)

                    Button("Save") {
                        if let url = URL(string: urlString) {
                            let trimmedLabel = label.trimmingCharacters(in: .whitespaces)
                            onSave(url, trimmedLabel.isEmpty ? nil : trimmedLabel)
                        }
                    }
                    .disabled(!isValid)
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
                }
                .padding(.top, LayoutConstants.compactPadding)
            }
            .padding()

            Spacer()
        }
        .onAppear {
            urlFieldFocused = true
        }
    }
}
