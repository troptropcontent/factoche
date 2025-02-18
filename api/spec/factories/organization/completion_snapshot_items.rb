FactoryBot.define do
  factory :completion_snapshot_item, class: 'Organization::CompletionSnapshotItem' do
    item { nil }
    completion_snapshot { nil }
    completion_percentage { "0.15" }
  end
end
