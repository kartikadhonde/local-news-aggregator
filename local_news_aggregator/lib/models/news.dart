class News {
  final String title;
  final String? description;
  final String? urlToImage;
  final String? source;
  final String? url;

  News({
    required this.title,
    this.description,
    this.urlToImage,
    this.source,
    this.url,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      title: json['title'] ?? 'No title',
      description: json['description'],
      urlToImage: json['urlToImage'],
      source: json['source']?['name'],
      url: json['url'],
    );
  }
}
