class SearchEventModel {
  final String title;
  final String dateLabel;
  final String imageAsset; // isi asset nanti, boleh kosong untuk placeholder

  const SearchEventModel({
    required this.title,
    required this.dateLabel,
    required this.imageAsset,
  });
}
