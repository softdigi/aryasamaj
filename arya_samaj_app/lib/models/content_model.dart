class ContentModel {
  final int id;
  final String title;
  final String type; // pdf, audio, video, image, text
  final String? fileUrl;
  final String? imageUrl;
  final String? description;
  final String? author;
  final int? downloadCount;

  ContentModel({
    required this.id, required this.title, required this.type,
    this.fileUrl, this.imageUrl, this.description, this.author, this.downloadCount,
  });

  factory ContentModel.fromJson(Map j) => ContentModel(
    id: j['id'], title: j['title'], type: j['type'],
    fileUrl: j['file_url'], imageUrl: j['image_url'],
    description: j['description'], author: j['author'],
    downloadCount: j['download_count'],
  );
}
