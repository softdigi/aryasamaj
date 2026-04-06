class EventModel {
  final int id;
  final String title;
  final String? description;
  final DateTime? eventDate;
  final String? location;
  final String? imageUrl;
  final String status; // upcoming | past

  const EventModel({
    required this.id,
    required this.title,
    this.description,
    this.eventDate,
    this.location,
    this.imageUrl,
    this.status = 'upcoming',
  });

  factory EventModel.fromJson(Map<String, dynamic> j) => EventModel(
        id: j['id'] as int,
        title: j['title'] as String? ?? '',
        description: j['description'] as String?,
        eventDate: j['event_date'] != null
            ? DateTime.tryParse(j['event_date'] as String)
            : null,
        location: j['location'] as String?,
        imageUrl: j['image_url'] as String?,
        status: j['status'] as String? ?? 'upcoming',
      );
}
