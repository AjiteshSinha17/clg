class PostFilter {
  final String? category;
  final String? searchQuery;
  final bool onlyFollowing;

  PostFilter({this.category, this.searchQuery, this.onlyFollowing = false});

  PostFilter copyWith({
    String? category,
    String? searchQuery,
    bool? onlyFollowing,
  }) {
    return PostFilter(
      category: category ?? this.category,
      searchQuery: searchQuery ?? this.searchQuery,
      onlyFollowing: onlyFollowing ?? this.onlyFollowing,
    );
  }
}
