class EventFilter {
  final String category; // "" = all
  final bool? isGlobal; // null = all
  final bool onlyTickets;
  final bool nearMe; // filter by city (client-side)
  final int minPrice;
  final int maxPrice;

  const EventFilter({
    this.category = '',
    this.isGlobal,
    this.onlyTickets = false,
    this.nearMe = false,
    this.minPrice = 0,
    this.maxPrice = 999999999,
  });

  EventFilter copyWith({
    String? category,
    bool? isGlobal,
    bool? onlyTickets,
    bool? nearMe,
    int? minPrice,
    int? maxPrice,
  }) {
    return EventFilter(
      category: category ?? this.category,
      isGlobal: isGlobal,
      onlyTickets: onlyTickets ?? this.onlyTickets,
      nearMe: nearMe ?? this.nearMe,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }
}
