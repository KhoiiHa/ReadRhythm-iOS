import SwiftUI

struct DiscoverDetailView: View {
    let detail: DiscoverBookDetail

    @ObservedObject private var viewModel: DiscoverViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var isDescriptionExpanded = false
    @State private var isSaving = false

    private let coverSize = CGSize(width: 180, height: 260)

    init(detail: DiscoverBookDetail, viewModel: DiscoverViewModel) {
        self.detail = detail
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpace._24) {
                coverSection
                contentSection
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
    }

    // MARK: - Sections

    private var coverSection: some View {
        VStack {
            coverImage
        }
        .frame(maxWidth: .infinity)
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: AppSpace._20) {
            titleSection

            if let rating = detail.averageRatingDisplay {
                ratingSection(rating: rating)
            }

            metadataSection

            categoriesSection

            if let description = detail.description, !description.isEmpty {
                descriptionSection(description)
            }

            if let external = detail.externalURL {
                googleBooksLink(external)
            }
        }
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
            }

            if !detail.authorsDisplay.isEmpty {
                Text(detail.authorsDisplay)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.Semantic.textSecondary)
                    .accessibilityLabel(Text(String(format: String(localized: "discover.detail.authors.accessibility"), detail.authorsDisplay)))
            }
        }
    }

    private func ratingSection(rating: String) -> some View {
        HStack(spacing: AppSpace._8) {
            Image(systemName: "star.fill")
                .foregroundStyle(AppColors.Semantic.tintPrimary)
            Text(rating)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.Semantic.textPrimary)
            if let ratingCount = detail.ratingsCountDisplay(oneKey: "discover.detail.rating.count.one",
                                                            manyKey: "discover.detail.rating.count") {
                Text(ratingCount)
                    .font(.footnote)
                    .foregroundStyle(AppColors.Semantic.textSecondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(String(format: String(localized: "discover.detail.rating.accessibility"), rating, detail.ratingsCount ?? 0)))
    }

    private var metadataSection: some View {
        let unknown = String(localized: "discover.detail.metadata.unknown")
        let pagesFormat = String(localized: "discover.detail.pages")

        let items: [MetadataItem] = [
            MetadataItem(
                id: "publisher",
                titleKey: "discover.detail.publisher",
                value: detail.publisher?.nilIfEmpty ?? unknown
            ),
            MetadataItem(
                id: "year",
                titleKey: "discover.detail.year",
                value: detail.publishedYear ?? unknown
            ),
            MetadataItem(
                id: "pages",
                titleKey: "discover.detail.pageCount",
                value: detail.pagesDisplay(localizedFormat: pagesFormat) ?? unknown
            ),
            MetadataItem(
                id: "language",
                titleKey: "discover.detail.language",
                value: detail.languageDisplay ?? unknown
            )
        ]

        return VStack(alignment: .leading, spacing: AppSpace._12) {
            Text(LocalizedStringKey("discover.detail.metadata.heading"))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.Semantic.textPrimary)

            WrappingChips(items) { item in
                MetadataChip(titleKey: item.titleKey, value: item.value)
            }
        }
    }

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: AppSpace._12) {
            Text(LocalizedStringKey("discover.detail.categories"))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.Semantic.textPrimary)

            if detail.categories.isEmpty {
                MetadataChip(titleKey: "discover.detail.categories",
                             value: String(localized: "discover.detail.metadata.unknown"))
            } else {
                WrappingChips(detail.categories) { category in
                    Text(category)
                        .font(.caption)
                        .padding(.vertical, 6)
                        .padding(.horizontal, AppSpace._12)
                        .background(AppColors.Semantic.bgElevated)
                        .clipShape(Capsule(style: .continuous))
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.75)
                        )
                }
            }
        }
    }

    private func descriptionSection(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpace._8) {
            Text(LocalizedStringKey("discover.detail.about"))
                .font(.headline)
                .foregroundStyle(AppColors.Semantic.textPrimary)

            Text(text)
                .font(.body)
                .foregroundStyle(AppColors.Semantic.textSecondary)
                .lineLimit(isDescriptionExpanded ? nil : 6)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isDescriptionExpanded.toggle()
                }
            } label: {
                Text(LocalizedStringKey(isDescriptionExpanded ? "discover.detail.description.less" : "discover.detail.description.more"))
                    .font(.footnote.weight(.semibold))
            }
            .buttonStyle(.plain)
        }
    }

    private func googleBooksLink(_ url: URL) -> some View {
        Link(destination: url) {
            HStack {
                Image(systemName: "safari")
                Text(LocalizedStringKey("discover.detail.openGoogleBooks"))
                Spacer()
                Image(systemName: "arrow.up.right")
            }
            .font(.subheadline.weight(.semibold))
            .padding(.vertical, AppSpace._12)
            .padding(.horizontal, AppSpace._16)
            .frame(maxWidth: .infinity)
            .background(AppColors.Semantic.bgElevated)
            .foregroundStyle(AppColors.Semantic.textPrimary)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.m, style: .continuous))
        }
        .accessibilityIdentifier("book.external.googlebooks")
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
                        Text(LocalizedStringKey("cta.addToLibrary"))
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(isSaving)
                .accessibilityIdentifier("discover.detail.cta.add")
                .accessibilityLabel(Text(LocalizedStringKey("cta.addToLibrary")))

                Button(action: dismiss.callAsFunction) {
                    Text(LocalizedStringKey("cta.cancel"))
                }
                .buttonStyle(SecondaryButtonStyle())
                .accessibilityIdentifier("discover.detail.cta.cancel")
                .accessibilityLabel(Text(LocalizedStringKey("cta.cancel")))
            }
            .padding(.horizontal, AppSpace._16)
            .padding(.bottom, AppSpace._16)
        }
        .background(AppColors.Semantic.bgPrimary.opacity(0.98))
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Subviews

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
}

// MARK: - Helpers

private extension DiscoverDetailView {
    struct MetadataItem: Identifiable, Hashable {
        let id: String
        let titleKey: String
        let value: String
    }

    struct MetadataChip: View {
        let titleKey: String
        let value: String

        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedStringKey(titleKey))
                    .font(.caption)
                    .foregroundStyle(AppColors.Semantic.textSecondary)
                Text(value)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AppColors.Semantic.textPrimary)
            }
            .padding(.horizontal, AppSpace._12)
            .padding(.vertical, AppSpace._8)
            .background(AppColors.Semantic.bgElevated)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.m, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.m, style: .continuous)
                    .stroke(AppColors.Semantic.borderMuted, lineWidth: 0.75)
            )
        }
    }
}

// MARK: - Wrapping Chips Helper

private struct WrappingChips<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    private let data: Data
    private let content: (Data.Element) -> Content
    private let spacing: CGFloat

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

    private func heightReader(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { geometry -> Color in
            DispatchQueue.main.async {
                binding.wrappedValue = geometry.size.height
            }
            return Color.clear
        }
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
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if element == items.last {
                            width = 0
                        }
                        return result
                    }
            }
        }
        .background(heightReader($totalHeight))
    }
}

private extension Optional where Wrapped == String {
    var nilIfEmpty: String? {
        guard let value = self else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
