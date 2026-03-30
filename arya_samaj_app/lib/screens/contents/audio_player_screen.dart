import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/constants/app_colors.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../models/content_model.dart';

final audioListProvider = FutureProvider.family<List<ContentModel>, int>((ref, catId) async {
  final api = ref.read(apiClientProvider);
  final res = await api.get(ApiEndpoints.contents, params: {'category_id': catId, 'type': 'audio'});
  return (res.data['data'] as List).map((e) => ContentModel.fromJson(e)).toList();
});

final _player = AudioPlayer();
final currentIndexProvider = StateProvider<int>((ref) => -1);
final isPlayingProvider = StateProvider<bool>((ref) => false);

class AudioPlayerScreen extends ConsumerStatefulWidget {
  final int categoryId;
  const AudioPlayerScreen({super.key, required this.categoryId});
  @override
  ConsumerState<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends ConsumerState<AudioPlayerScreen> {
  @override
  void dispose() {
    _player.stop();
    super.dispose();
  }

  Future<void> _play(ContentModel item, int index) async {
    ref.read(currentIndexProvider.notifier).state = index;
    if (item.fileUrl == null) return;
    await _player.setUrl(item.fileUrl!);
    await _player.play();
    ref.read(isPlayingProvider.notifier).state = true;
  }

  String _fmt(Duration d) => '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(audioListProvider(widget.categoryId));
    final current = ref.watch(currentIndexProvider);
    final playing = ref.watch(isPlayingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(title: const Text('भजन'), backgroundColor: const Color(0xFF0A1628)),
      body: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppColors.categoryBar,
          child: const Row(children: [
            Expanded(child: Text('गीत भजन ऑडियो अपलोड करें', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
            Icon(Icons.lock, color: Colors.white, size: 16),
          ]),
        ),
        if (current >= 0) StreamBuilder<Duration>(
          stream: _player.positionStream,
          builder: (ctx, snap) {
            final pos = snap.data ?? Duration.zero;
            final dur = _player.duration ?? const Duration(minutes: 1);
            return Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF1A2A4A),
              child: Column(children: [
                Slider(
                  value: pos.inSeconds.toDouble().clamp(0, dur.inSeconds.toDouble()),
                  max: dur.inSeconds.toDouble(),
                  activeColor: AppColors.saffron,
                  onChanged: (v) => _player.seek(Duration(seconds: v.toInt())),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(_fmt(pos), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  Row(children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous, color: Colors.white),
                      onPressed: current > 0 ? () { listAsync.whenData((l) => _play(l[current - 1], current - 1)); } : null,
                    ),
                    Container(
                      width: 48, height: 48,
                      decoration: const BoxDecoration(color: AppColors.saffron, shape: BoxShape.circle),
                      child: IconButton(
                        icon: Icon(playing ? Icons.pause : Icons.play_arrow, color: Colors.white),
                        onPressed: () async {
                          if (playing) {
                            await _player.pause();
                            ref.read(isPlayingProvider.notifier).state = false;
                          } else {
                            await _player.play();
                            ref.read(isPlayingProvider.notifier).state = true;
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, color: Colors.white),
                      onPressed: () { listAsync.whenData((l) { if (current < l.length - 1) _play(l[current + 1], current + 1); }); },
                    ),
                  ]),
                  Text(_fmt(dur), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
              ]),
            );
          },
        ),
        Expanded(
          child: listAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.saffron)),
            error: (e, _) => const Center(child: Text('लोड नहीं हो सका', style: TextStyle(color: Colors.white))),
            data: (list) => ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: list.length,
              itemBuilder: (ctx, i) {
                final item = list[i];
                final isCurrent = current == i;
                return GestureDetector(
                  onTap: () => _play(item, i),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isCurrent ? AppColors.saffron : AppColors.audioCardBg,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(children: [
                      Expanded(child: Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600))),
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(color: Colors.black.withOpacity(.3), shape: BoxShape.circle),
                        child: Icon(isCurrent && playing ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 18),
                      ),
                    ]),
                  ),
                );
              },
            ),
          ),
        ),
      ]),
    );
  }
}
