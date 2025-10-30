import Foundation
import SwiftUI

struct DiscoverDetailView: View {
    let detail: DiscoverBookDetail

    @ObservedObject private var viewModel: DiscoverViewModel

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @State private var isSaving = false
    @State private var showDescriptionSheet = false

    private let coverSize = CGSize(width: 180, height: 260)

    init(detail: DiscoverBookDetail, viewModel: DiscoverViewModel) {
        self.detail = detail
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpace._24) {
                coverSection
                titleSection

                if let ratingRow = ratingSection {
                    ratingRow
                }

                if let metaRow = metadataSection {
                    metaRow
                }

                if let categories = categoriesSection {
                    categories
                }

                if let description = detail.description, !description.isEmpty {
                    descriptionSection(description)
                }
            }
            .padding(.horizontal, AppSpace._16)
            .padding(.top, AppSpace._24)
            .padding(.bottom, AppSpace._32)
        }
        .background(AppColors.Semantic.bgPrimary)
        .navigationTitle(Text(LocalizedStringKey("discover.detail.title")))
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("discover.detail")
        .safeAreaInset(edge: .bottom) {
            ctaSection
        }
        .sheet(isPresented: $showDescriptionSheet) {
            descriptionSheet
        }
    }

    // MARK: - Sections

    private var coverSection: some View {
        VStack {
            coverImage
        }
        .frame(maxWidth: .infinity)
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: AppSpace._8) {
            Text(detail.title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(AppColors.Semantic.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            if let subtitle = detail.subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.headline)
                    .foregroundStyle(AppColors.Semantic.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel(
                        Text(
                            String(
                                format: "%@: %@",
                                String(localized: "detail.subtitle"),
                                subtitle
                            )
                        )
                    )
            }

            Text(detail.authorsDisplay)
                .font(.subheadline)
                .foregroundStyle(AppColors.Semantic.textSecondary)
                .accessibilityLabel(
                    Text(
                        String(
                            format: String(
                                localized: String.LocalizationValue("discover.detail.authors.accessibility")
                            ),
                            detail.authorsDisplay
                        )
                    )
                )
        }
    }

    private var ratingSection: some View? {
        guard let ratingValue = detail.averageRatingDisplay else { return nil }

        return VStack(alignment: .leading, spacing: AppSpace._8) {
            Text(LocalizedStringKey("detail.rating"))
                .font(.headline)
                .foregroundStyle(AppColors.Semantic.textPrimary)
                .accessibilityHeading(.h2)

            HStack(spacing: AppSpace._8) {
                Image(systemName: "star.fill")
                    .foregroundStyle(AppColors.Semantic.tintPrimary)
                Text(ratingValue)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.Semantic.textPrimary)
                if let count = detail.ratingsCountDisplay {
                    Text("(\(count))")
                        .font(.footnote)
                        .foregroundStyle(AppColors.Semantic.textSecondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(ratingAccessibilityLabel)
        .accessibilityIdentifier("detail.rating")
    }

    private var metadataSection: some View? {
        let entries = metadataEntries
        guard entries.isEmpty == false else { return nil }

        let displayText = entries.map(\.value).joined(separator: " · ")

        return VStack(alignment: .leading, spacing: AppSpace._8) {
            Text(LocalizedStringKey("discover.detail.metadata.heading"))
                .font(.headline)
                .foregroundStyle(AppColors.Semantic.textPrimary)
                .accessibilityHeading(.h2)

            Text(displayText)
                .font(.subheadline)
                .foregroundStyle(AppColors.Semantic.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(metadataAccessibilityLabel(entries)))
        .accessibilityIdentifier("detail.meta")
    }

    private var categoriesSection: some View? {
        var chipItems: [ChipItem] = detail.categories.map { .category($0) }
        if let language = detail.languageBadge {
            let display = detail.languageDisplay ?? language
            chipItems.append(.language(code: language, display: display))
        }

        guard chipItems.isEmpty == false else { return nil }

        return VStack(alignment: .leading, spacing: AppSpace._12) {
            Text(LocalizedStringKey("detail.categories"))
                .font(.headline)
                .foregroundStyle(AppColors.Semantic.textPrimary)
                .accessibilityHeading(.h2)

            WrappingChips(chipItems) { item in
                switch item {
                case .category(let name):
                    Text(name)
                        .font(.caption)
                        .padding(.vertical, 6)
                        .padding(.horizontal, AppSpace._12)
                        .background(AppColors.Semantic.bgElevated)
                        .clipShape(Capsule(style: .continuous))
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.75)
                        )
                case .language(let code, let display):
                    VStack(spacing: AppSpace._4) {
                        Text(code)
                            .font(.caption.weight(.semibold))
                        Text(display)
                            .font(.caption2)
                            .foregroundStyle(AppColors.Semantic.textSecondary)
                    }
                    .padding(.vertical, AppSpace._8)
                    .padding(.horizontal, AppSpace._12)
                    .background(AppColors.Semantic.bgElevated)
                    .clipShape(Capsule(style: .continuous))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.75)
                    )
                    .accessibilityLabel(
                        Text(
                            String(
                                format: "%@: %@",
                                String(localized: String.LocalizationValue("detail.language")),
                                display
                            )
                        )
                    )
                }
            }
        }
        .accessibilityIdentifier("detail.categories")
    }

    private func descriptionSection(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpace._8) {
            Text(LocalizedStringKey("discover.detail.about"))
                .font(.headline)
                .foregroundStyle(AppColors.Semantic.textPrimary)
                .accessibilityHeading(.h2)

            Text(text)
                .font(.body)
                .foregroundStyle(AppColors.Semantic.textSecondary)
                .lineLimit(3)

            Button {
                showDescriptionSheet = true
            } label: {
                Text(LocalizedStringKey("detail.readMore"))
                    .font(.footnote.weight(.semibold))
            }
            .buttonStyle(.plain)
        }
        .accessibilityIdentifier("detail.description")
    }

    private var ctaSection: some View {
        VStack(spacing: AppSpace._12) {
            Divider()
                .padding(.horizontal, -AppSpace._16)

            VStack(spacing: AppSpace._12) {
                Button(action: handleAddToLibrary) {
                    if isSaving {
                        ProgressView()
                            .tint(AppColors.Semantic.textInverse)
                    } else {
                        Text(LocalizedStringKey("detail.addToLibrary"))
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: AppRadius.m))
                .disabled(isSaving)
                .accessibilityIdentifier("detail.addToLibrary")

                if let external = detail.externalURL {
                    Button {
                        openURL(external)
                    } label: {
                        Text(LocalizedStringKey("detail.openInGoogleBooks"))
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.roundedRectangle(radius: AppRadius.m))
                    .accessibilityIdentifier("detail.openInGoogleBooks")
                }
            }
            .padding(.horizontal, AppSpace._16)
            .padding(.bottom, AppSpace._16)
        }
        .background(AppColors.Semantic.bgPrimary.opacity(0.98))
        .ignoresSafeArea(edges: .bottom)
    }

    private var descriptionSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpace._16) {
                    Text(detail.description ?? "")
                        .font(.body)
                        .foregroundStyle(AppColors.Semantic.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(AppSpace._16)
            }
            .background(AppColors.Semantic.bgPrimary)
            .navigationTitle(Text(LocalizedStringKey("discover.detail.about")))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(LocalizedStringKey("detail.readLess")) {
                        showDescriptionSheet = false
                    }
                }
            }
        }
    }

    // MARK: - Cover

    private var coverImage: some View {
        Group {
            if let url = detail.thumbnailURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholderCover
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: coverSize.width, height: coverSize.height)
                            .clipped()
                    case .failure:
                        placeholderCover
                    @unknown default:
                        placeholderCover
                    }
                }
            } else {
                placeholderCover
            }
        }
        .frame(width: coverSize.width, height: coverSize.height)
        .cornerRadius(AppRadius.l)
        .shadow(color: AppShadow.elevation1, radius: 4, x: 0, y: 2)
        .accessibilityHidden(true)
    }

    private var placeholderCover: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous)
                .fill(AppColors.Semantic.bgElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.l, style: .continuous)
                        .stroke(AppColors.Semantic.borderMuted, lineWidth: 1)
                )
            Text(initials(from: detail.title))
                .font(.largeTitle.weight(.semibold))
                .foregroundStyle(AppColors.Semantic.tintPrimary.opacity(0.8))
        }
        .frame(width: coverSize.width, height: coverSize.height)
    }

    private func initials(from text: String) -> String {
        let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        let initials = words.prefix(2).compactMap { $0.first }.map { String($0) }
        return initials.joined().uppercased()
    }

    // MARK: - Actions

    private func handleAddToLibrary() {
        guard isSaving == false else { return }
        isSaving = true

        let result = viewModel.addToLibrary(from: detail.remote)
        isSaving = false

        switch result {
        case .added, .alreadyExists:
            dismiss()
        case .failure:
            break
        }
    }

    // MARK: - Helpers

    private var metadataEntries: [MetaEntry] {
        var result: [MetaEntry] = []

        if let publisher = detail.publisher, !publisher.isEmpty {
            result.append(MetaEntry(labelKey: "detail.publisher", value: publisher))
        }
        if let year = detail.publishedYear, !year.isEmpty {
            result.append(MetaEntry(labelKey: "detail.year", value: year))
        }
        if let pagesValue = pagesDisplayValue {
            result.append(MetaEntry(labelKey: "detail.pages", value: pagesValue))
        }

        return result
    }

    private var pagesDisplayValue: String? {
        detail.pagesDisplay(unitKey: "detail.pages")
    }

    private var ratingAccessibilityLabel: Text {
        let prefix = String(localized: "detail.rating")
        if let formatted = detail.ratingAccessibilityLabel(baseKey: "detail.rating.accessibility") {
            return Text("\(prefix): \(formatted)")
        } else {
            return Text(prefix)
        }
    }

    private func metadataAccessibilityLabel(_ entries: [MetaEntry]) -> String {
        let heading = String(localized: "discover.detail.metadata.heading")
        let details = entries.accessibilityLabel
        return details.isEmpty ? heading : "\(heading): \(details)"
    }
}

// MARK: - Supporting Types

private struct MetaEntry: Hashable {
    let labelKey: String
    let value: String
}

private enum ChipItem: Hashable {
    case category(String)
    case language(code: String, display: String)
}

private struct WrappingChips<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    private let data: Data
    private let spacing: CGFloat
    private let content: (Data.Element) -> Content

    @State private var totalHeight: CGFloat = .zero

    init(_ data: Data, spacing: CGFloat = AppSpace._8, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            generateContent(in: geometry)
        }
        .frame(minHeight: totalHeight)
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width: CGFloat = 0
        var height: CGFloat = 0
        let items = Array(data)

        return ZStack(alignment: .topLeading) {
            ForEach(items, id: \.self) { element in
                content(element)
                    .alignmentGuide(.leading) { dimension in
                        if width + dimension.width > geometry.size.width {
                            width = 0
                            height -= dimension.height + spacing
                        }
                        let result = width
                        width += dimension.width + spacing
                        return result
                    }
                    .alignmentGuide(.top) { dimension in
                        let result = height
                        if element == items.last {
                            DispatchQueue.main.async {
                                totalHeight = abs(height) + dimension.height
                            }
                        }
                        return result
                    }
            }
        }
    }
}

private extension Array where Element == MetaEntry {
    var accessibilityLabel: String {
        map { entry in
            let label = String(localized: String.LocalizationValue(entry.labelKey))
            return "\(label): \(entry.value)"
        }.joined(separator: ", ")
    }
}
