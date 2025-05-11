import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtubeclone/data.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

final isLikedProvider = StateProvider<bool>((ref) => false);
final isDislikedProvider = StateProvider<bool>((ref) => false);
final isSubscribedProvider = StateProvider<bool>((ref) => false);

class VideoScreen extends ConsumerStatefulWidget {
  final Video video;

  const VideoScreen({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  ConsumerState<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends ConsumerState<VideoScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.video.videoUrl),
      );
      
      await controller.initialize();
      
      if (!mounted) return;

      _videoPlayerController = controller;
      
      _chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: false,
        aspectRatio: controller.value.aspectRatio,
        placeholder: Image.network(
          widget.video.thumbnailUrl,
          fit: BoxFit.cover,
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 42),
                const SizedBox(height: 16),
                Text(
                  'Video yüklenirken bir hata oluştu: $errorMessage',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _initializePlayer();
                  },
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          );
        },
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        showOptions: true,
        customControls: const MaterialControls(),
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.red,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.white,
        ),
      );
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Video yüklenirken hata oluştu: $e');
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = ref.watch(isLikedProvider);
    final isDisliked = ref.watch(isDislikedProvider);
    final isSubscribed = ref.watch(isSubscribedProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _isInitialized && _chewieController != null
                  ? GestureDetector(
                      onTap: () {
                        if (_chewieController!.isPlaying) {
                          _chewieController!.pause();
                        } else {
                          _chewieController!.play();
                        }
                      },
                      child: Chewie(controller: _chewieController!),
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          widget.video.thumbnailUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        const CircularProgressIndicator(),
                      ],
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.video.title,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Text(
                        '${widget.video.viewCount} views • ${timeago.format(widget.video.timestamp)}',
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.thumb_up,
                              color: isLiked ? Colors.blue : Colors.grey,
                            ),
                            onPressed: () {
                              ref.read(isLikedProvider.notifier).state = !isLiked;
                              if (isDisliked) {
                                ref.read(isDislikedProvider.notifier).state = false;
                              }
                            },
                          ),
                          Text(widget.video.likes),
                          IconButton(
                            icon: Icon(
                              Icons.thumb_down,
                              color: isDisliked ? Colors.blue : Colors.grey,
                            ),
                            onPressed: () {
                              ref.read(isDislikedProvider.notifier).state = !isDisliked;
                              if (isLiked) {
                                ref.read(isLikedProvider.notifier).state = false;
                              }
                            },
                          ),
                          Text(widget.video.dislikes),
                        ],
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      CircleAvatar(
                        foregroundImage: NetworkImage(widget.video.author.profileImageUrl),
                        radius: 20.0,
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.video.author.username,
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${widget.video.author.subscribers} subscribers',
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(isSubscribedProvider.notifier).state = !isSubscribed;
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: isSubscribed ? Colors.grey : Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          isSubscribed ? 'ABONE OLUNDU' : 'ABONE OL',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final suggestedVideo = suggestedVideos[index];
                return ListTile(
                  leading: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        suggestedVideo.thumbnailUrl,
                        width: 120.0,
                        height: 68.0,
                        fit: BoxFit.cover,
                      ),
                      const Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  title: Text(
                    suggestedVideo.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${suggestedVideo.author.username} • ${suggestedVideo.viewCount} views • ${timeago.format(suggestedVideo.timestamp)}',
                  ),
                );
              },
              childCount: suggestedVideos.length,
            ),
          ),
        ],
      ),
    );
  }
}