import SwiftUI

struct SidebarView: View {
    @Binding var selectedCategory: AppCategory
    @ObservedObject var viewModel: AppListViewModel
    
    var body: some View {
        List(selection: $selectedCategory) {
            Section {
                ForEach(AppCategory.allCases, id: \.self) { category in
                    HStack(spacing: 10) {
                        Image(systemName: category.iconName)
                            .font(.system(size: 14))
                            .foregroundStyle(selectedCategory == category ? .white : Color.accentColor)
                            .frame(width: 22)
                        
                        Text(category.rawValue)
                            .font(.system(size: 13, weight: .medium))
                        
                        Spacer()
                        
                        Text("\(count(for: category))")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.quaternary.opacity(0.5))
                            )
                    }
                    .padding(.vertical, 2)
                    .tag(category)
                }
            } header: {
                Label("分类", systemImage: "folder")
                    .font(.system(size: 11, weight: .semibold))
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 180, idealWidth: 200)
        .scrollContentBackground(.hidden)
        .background(Color(.windowBackgroundColor).opacity(0.5))
        .onChange(of: selectedCategory) { _ in
            viewModel.filterApps()
        }
    }
    
    private func count(for category: AppCategory) -> Int {
        switch category {
        case .all: return viewModel.allApps.count
        default:
            return viewModel.allApps.filter { $0.category == category }.count
        }
    }
}
