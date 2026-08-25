// reel_item.dart
import 'dart:async';
import 'dart:ui';

import 'package:adgo_mobile/modules/seller_gallery/view/screens/seller_gallery_screen.dart';
import 'package:adgo_mobile/modules/reel_screen/model/reel.dart';
import 'package:adgo_mobile/modules/reel_screen/view/widgets/floating_button.dart';
import 'package:adgo_mobile/themes/utils.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/providers/cdn_rovider.dart';
import '../../../../services/providers/like_provider.dart';
import '../controllers/video_player_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReelItem extends ConsumerStatefulWidget {
  final Reel reel;
  final int pageIndex;
  const ReelItem({super.key, required this.reel, required this.pageIndex});

  @override
  _ReelItemState createState() => _ReelItemState();
}

class _ReelItemState extends ConsumerState<ReelItem>
    with WidgetsBindingObserver {
  BetterPlayerController? _betterPlayerController;

  bool _isLoading = true;
  bool _hasError = false;
  bool _showControls = false;
  bool _initInProgress = false;
  bool _isVisible = false;
  bool _isInitialized = false;

  Timer? _cookieRefreshTimer;

  String? cookieHeaders;
  String? domainName;

  bool _isLiked = false;
  int _likeCount = 0; // initial like count

  // TODO: replace with widget.reel path if you have it
  //static const String _clipPath = "/output/388e3f0c-60ce-463f-8a51-9c7075598408/clip.mpd";

  // If your Reel stores just the path like "output/.../clip.mpd":
  String? get _clipPath {
    final path = widget.reel.videoUrl;
    debugPrint("🔗 Video path from reel: $path");
    // Ensure path starts with / for URL construction
    return path.startsWith('/') ? path : '/$path';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
    _checkIfLiked();
    _fetchLikeCount();
    
    // Check if this video should be visible initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
  }

  void _checkIfLiked() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) return;

      final likeRepo = ref.read(likeRepoProvider);

      final res = await likeRepo.isLiked(
        videoId: widget.reel.id,
        userId: userId,
      );

      print("LIKED ====================");
      print(res.data); // should print true or false

      setState(() {
        _isLiked = res.data as bool; // ← cast to bool
      });
    } catch (e) {
      debugPrint("Error checking isLiked: $e");
    }
  }

  void _fetchLikeCount() async {
    try {
      final likeRepo = ref.read(likeRepoProvider);

      final res = await likeRepo.getLikeCount(
        videoId: widget.reel.id,
      );

      // Assuming backend returns integer directly
      setState(() {
        _likeCount = res.data as int;
      });
    } catch (e) {
      debugPrint("Error fetching like count: $e");
    }
  }

  void _checkVisibility() {
    final currentIndex = ref.read(videoPlayerManagerProvider);
    final shouldBeVisible = currentIndex == widget.pageIndex;

    if (_isVisible != shouldBeVisible) {
      setState(() {
        _isVisible = shouldBeVisible;
      });
      debugPrint(
          "🎬 Video ${widget.pageIndex} visibility changed to: $_isVisible");

      if (mounted && _isInitialized && _betterPlayerController != null) {
        if (_isVisible) {
          debugPrint("▶️ Auto-playing video ${widget.pageIndex}");
          _betterPlayerController!.play();
        } else {
          debugPrint("⏸️ Pausing video ${widget.pageIndex}");
          _betterPlayerController!.pause();
        }
      }
    }
  }

  Future<void> _bootstrap() async {
    try {
      // 1) Fetch cookies first
      await _refreshCookies();

      // 2) Init player once we have the cookies/domain (but don't auto-play yet)
      await _initializeBetterPlayer();

      // 3) Start periodic refresh (and re-init data source when cookies rotate)
      _startCookieRefresh();

      // Mark as initialized
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Bootstrap failed: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  void _startCookieRefresh() {
    // already refreshed once in bootstrap; schedule periodic
    _cookieRefreshTimer?.cancel();
    _cookieRefreshTimer =
        Timer.periodic(const Duration(minutes: 15), (_) async {
      await _refreshCookies();
      // Re-apply data source so new cookies are used
      await _reinitializeDataSource();
    });
  }

  Future<void> _refreshCookies() async {
    try {
      final cdnRepo = ref.read(cdnRepoProvider);
      final response = await cdnRepo.getCdnCookies();

      final data = response.data;
      if (data is Map) {
        cookieHeaders = data['cookieHeaders'] as String?;
        domainName = data['domainName'] as String?;

        debugPrint("CDN cookies refreshed.");
        debugPrint("cookieHeaders: $cookieHeaders");
        debugPrint("domainName: $domainName");

        // Optional: log setCookies map if present
        final setCookies = data['setCookies'];
        if (setCookies is Map) {
          for (final entry in setCookies.entries) {
            debugPrint(" ${entry.key} = ${entry.value}");
          }
        }
      } else {
        debugPrint("Unexpected response format: ${response.data}");
      }

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Failed to refresh CDN cookies: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ctrl = _betterPlayerController;
    if (ctrl == null) return;

    if (state == AppLifecycleState.paused) {
      ctrl.pause();
    } else if (state == AppLifecycleState.resumed) {
      ctrl.play();
    }
    super.didChangeAppLifecycleState(state);
  }

  String? get _videoUrl {
    if (domainName == null || domainName!.isEmpty) {
      debugPrint("❌ Cannot build video URL: domainName is null/empty");
      return null;
    }
    final url = "https://$domainName$_clipPath";
    debugPrint("✅ Constructed video URL: $url");
    return url;
  }

  Future<void> _initializeBetterPlayer() async {
    if (_initInProgress) return;
    _initInProgress = true;

    try {
      final url = _videoUrl;
      if (url == null) {
        throw StateError("Cannot initialize player: domainName is null/empty.");
      }

      debugPrint("🎥 Initializing player for: $url");
      debugPrint("🍪 Cookie headers available: ${cookieHeaders != null && cookieHeaders!.isNotEmpty}");

      debugPrint("🎥 Initializing player for: $url");
      debugPrint(
          "🍪 Cookie headers available: ${cookieHeaders != null && cookieHeaders!.isNotEmpty}");

      final Map<String, String>? headers =
          (cookieHeaders != null && cookieHeaders!.isNotEmpty)
              ? {'Cookie': cookieHeaders!}
              : null;

      if (headers != null) {
        debugPrint("🔑 Using signed cookies for video request");
      }

      final dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        url,
        videoFormat: BetterPlayerVideoFormat.dash,
        headers: headers,
      );

      debugPrint("📦 DASH manifest URL: $url");

      _betterPlayerController?.dispose();

      _betterPlayerController = BetterPlayerController(
        const BetterPlayerConfiguration(
          autoPlay: false, // Don't auto-play, wait for visibility
          looping: true,
          fit: BoxFit.contain,
          expandToFill: false,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            showControls: false,
          ),
          allowedScreenSleep: false,
        ),
      );

      await _betterPlayerController!.setupDataSource(dataSource);

      _betterPlayerController!.addEventsListener((event) {
        if (event.betterPlayerEventType == BetterPlayerEventType.exception) {
          if (mounted) {
            setState(() {
              _hasError = true;
            });
          }
        }
      });

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      debugPrint("BetterPlayer initialization error: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } finally {
      _initInProgress = false;
    }
  }

  Future<void> _reinitializeDataSource() async {
    final ctrl = _betterPlayerController;
    if (ctrl == null) return;

    try {
      final wasPlaying = await ctrl.isPlaying() ?? false;

      final url = _videoUrl;
      if (url == null) return;

      final Map<String, String>? headers =
          (cookieHeaders != null && cookieHeaders!.isNotEmpty)
              ? {'Cookie': cookieHeaders!}
              : null;

      final dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        url,
        videoFormat: BetterPlayerVideoFormat.dash,
        headers: headers,
      );

      await ctrl.setupDataSource(dataSource);
      if (wasPlaying) {
        ctrl.play();
      }
    } catch (e) {
      debugPrint("Failed to reinitialize data source with new cookies: $e");
    }
  }

  void _togglePlayPause() async {
    final ctrl = _betterPlayerController;
    if (ctrl == null) return;

    // Only allow play/pause if this video is currently visible
    if (!_isVisible) return;

    final isPlaying = await ctrl.isPlaying() ?? false;
    if (isPlaying) {
      debugPrint("⏸️ User paused video ${widget.pageIndex}");
      ctrl.pause();
      if (mounted) {
        setState(() {
          _showControls = true;
        });
      }
    } else {
      debugPrint("▶️ User resumed video ${widget.pageIndex}");
      ctrl.play();
      _hideControlsWithDelay();
    }
  }

  void _handleScreenTap() {
    _togglePlayPause();
  }

  void _hideControlsWithDelay() {
    final ctrl = _betterPlayerController;
    if (ctrl == null) return;

    final isPlaying = ctrl.isPlaying(); // returns bool
    if (isPlaying! && mounted) {
      setState(() {
        _showControls = false;
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    debugPrint("🗑️ Disposing video ${widget.pageIndex}");
    WidgetsBinding.instance.removeObserver(this);
    _betterPlayerController?.dispose();
    _cookieRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the video player manager to control playback
    ref.listen<int>(videoPlayerManagerProvider, (previous, next) {
      _checkVisibility();
    });

    return Scaffold(
      body: GestureDetector(
          onTap: _handleScreenTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_hasError)
                Center(
                  child: Text("Error loading video",
                      style: TextStyle(color: errorColor)),
                )
              else if (_betterPlayerController != null)
                Container(
                  color: Colors.black,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: BetterPlayer(controller: _betterPlayerController!),
                  ),
                ),
                )
              else
                const Center(child: Text("No video available")),
              if (_betterPlayerController != null)
                Center(
                  child: AnimatedOpacity(
                    opacity: _showControls ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryDarkColor.withAlpha((0.3 * 255).toInt()),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        (_betterPlayerController?.isPlaying() ?? false)
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: whiteColor,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 0,
                right: 0,
              bottom: 0,
                child: Center(child: _buildSideActionButtons()),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 80,
              child: Center(
                child: ClipRect(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          const Color.fromARGB(24, 0, 0, 0).withOpacity(0.1),
                          const Color.fromARGB(0, 0, 0, 0).withOpacity(0.01),
                        ],
                      ),
                    ),
                    width: MediaQuery.of(context).size.width * 0.95,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SellerGalleryScreen()),
                            );
                          },
                          child: Text(
                            "@${widget.reel.shopHandle}",
                            style: TextStyle(
                                color: whiteColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                                
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.reel.title,
                          style: TextStyle(
                              color: whiteColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.purple.withAlpha((0.7 * 255).toInt()),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.reel.description ?? '',
                            style: TextStyle(color: whiteColor, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
              if (_showControls &&
                  !(_betterPlayerController == null)) // keep the area guarded
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ValueListenableBuilder<VideoPlayerValue>(
                    valueListenable:
                        _betterPlayerController!.videoPlayerController!,
                    builder: (context, value, child) {
                      final positionMs =
                          value.position.inMilliseconds.toDouble();
                      final durationMs = (value.duration ?? Duration.zero)
                          .inMilliseconds
                          .toDouble();

                      final clampedValue = durationMs <= 0
                          ? 0.0
                          : positionMs.clamp(0.0, durationMs);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(
                              "${_formatDuration(value.position)} / ${_formatDuration(value.duration ?? Duration.zero)}",
                              style: TextStyle(color: whiteColor, fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 5),
                          SliderTheme(
                            data: SliderThemeData(
                              thumbColor: whiteColor,
                              activeTrackColor: whiteColor,
                              inactiveTrackColor:
                                  whiteColor.withAlpha((0.3 * 255).toInt()),
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6),
                              trackHeight: 2,
                              overlayShape: SliderComponentShape.noOverlay,
                              trackShape: const RoundedRectSliderTrackShape(),
                            ),
                            child: Slider(
                              value: clampedValue,
                              min: 0.0,
                              max: durationMs <= 0 ? 1.0 : durationMs,
                              onChanged: (newPosition) {
                                final ms =
                                    durationMs <= 0 ? 0 : newPosition.toInt();
                                _betterPlayerController!.seekTo(
                                  Duration(milliseconds: ms),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }

  void _handleLikeEx() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID not found')),
        );
        return;
      }

      final likeRepo = ref.read(likeRepoProvider);

      await likeRepo.likeVideo(
        videoId: widget.reel.id, // make sure this matches your model
        userId: userId,
      );

      debugPrint("❤️ Liked video successfully");
    } catch (e) {
      debugPrint("❌ Failed to like video: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error liking video: $e')),
      );
    }
  }

  void _handleLike() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID not found')),
        );
        return;
      }

      final likeRepo = ref.read(likeRepoProvider);

      if (_isLiked) {
        await likeRepo.unlikeVideo(
          videoId: widget.reel.id,
          userId: userId,
        );
      } else {
        await likeRepo.likeVideo(
          videoId: widget.reel.id,
          userId: userId,
        );
      }

      // Refresh like status
      _checkIfLiked();
      _fetchLikeCount();
    } catch (e) {
      debugPrint("❌ Failed to like video: $e");
    }
  }

  Widget likeButton({
    required bool isLiked,
    required VoidCallback onTap,
  }) {
    return IconButton(
      icon: Icon(
        isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
        color: isLiked ? Colors.red : whiteColor,
        size: 32,
        shadows: [
          Shadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildSideActionButtons() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              likeButton(
                isLiked: _isLiked,
                onTap: _handleLike,
              ),
              const SizedBox(height: 4),
          Text(
            '$_likeCount',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
            ],
          ),
          
          floatingButton(Icons.shopping_bag_outlined, () {}),
          floatingButton(Icons.share, () {}),
        ],
      ),
    );
  }
}
