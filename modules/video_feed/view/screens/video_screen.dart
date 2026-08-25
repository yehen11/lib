// video_grid_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../themes/utils.dart';
import '../../../../services/core/api_client.dart';
import '../../model/video_model.dart';
import '../widgets/video_card.dart';
import 'package:adgo_mobile/modules/video_feed/view/controllers/video_controller.dart';

class VideoGridScreen extends ConsumerStatefulWidget {
  const VideoGridScreen({super.key});

  @override
  _VideoGridScreenState createState() => _VideoGridScreenState();
}

class _VideoGridScreenState extends ConsumerState<VideoGridScreen> {
  final PageController _pageController = PageController();
  bool isLoadingMore = false;
  Timer? _cookieRefreshTimer;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_pageScrollListener);

    _cookieRefreshTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      _refreshCookies();
    });

    _refreshCookies();
  }

  Future<void> _refreshCookies() async {
    try {
      // Add your cookie refresh logic here
    } catch (e) {
      print("Failed to refresh cookies: $e");
    }
  }

  void _pageScrollListener() async {
    final videoGrid = ref.read(paginatedVideoGridProvider);
    final hasMore = ref.read(paginatedVideoGridProvider.notifier).hasMore;

    if (_pageController.position.pixels >=
        _pageController.position.maxScrollExtent - 200 &&
        videoGrid is AsyncData<List<VideoModel>> &&
        !isLoadingMore &&
        hasMore) {
      setState(() {
        isLoadingMore = true;
      });

      await ref.read(paginatedVideoGridProvider.notifier).loadMore();

      if (mounted) {
        setState(() {
          isLoadingMore = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _cookieRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoGrid = ref.watch(paginatedVideoGridProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomNavHeight = screenHeight / 15;
    final availableHeight = screenHeight - bottomNavHeight;
    final hasMore = ref.read(paginatedVideoGridProvider.notifier).hasMore;
    
    // Calculate grid with nice, consistent spacing
    const crossAxisCount = 3;
    const itemAspectRatio = 9 / 16; // width / height (portrait)

    // Use minimal, clean spacing - 1.5% of screen width
    final spacing = screenWidth * 0.015;
    final horizontalPadding = spacing * 1.5;
    final verticalPadding = spacing * 1.5;

    // Calculate item width: (screenWidth - padding - gaps) / 3
    final itemWidth =
        (screenWidth - (horizontalPadding * 2) - (spacing * 2)) / 3;
    final itemHeight = itemWidth / itemAspectRatio;

    // Calculate grid height: items + gaps + padding
    final gridHeight = (itemHeight * 3) + (spacing * 2) + (verticalPadding * 2);

    // Use consistent spacing for both axes
    final crossAxisSpacing = spacing;
    final mainAxisSpacing = spacing;

    return Scaffold(
      body: Stack(
        children: [
          videoGrid.when(
        data: (videos) {
          final pageCount = (videos.length / 9).ceil();

          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            itemCount: pageCount + ((hasMore && isLoadingMore) ? 1 : 0),
            itemBuilder: (context, pageIndex) {
              final startIndex = pageIndex * 9;
              final endIndex = (startIndex + 9).clamp(0, videos.length);

              if (pageIndex == pageCount) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text("Loading more videos..."),
                    ],
                  ),
                );
              }

              final pageVideos = videos.sublist(startIndex, endIndex);

                  return SizedBox(
                    width: screenWidth,
                    height: gridHeight,
                    child: GridView.builder(
                      // padding: EdgeInsets.symmetric(
                      //   horizontal: horizontalPadding,
                      //   vertical: verticalPadding,
                      // ),
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: crossAxisSpacing,
                        mainAxisSpacing: mainAxisSpacing,
                        childAspectRatio: 9 / 16,
                      ),
                      itemCount: pageVideos.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // Handle video tap
                          },
                          child: SizedBox(
                            width: itemWidth,
                            height: itemHeight,
                            child: VideoCard(video: pageVideos[index]),
                          ),
                        );
                      },
                ),
              );
            },
          );
        },
            loading: () => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: crossAxisSpacing,
                  mainAxisSpacing: mainAxisSpacing,
                  childAspectRatio: 9 / 16,
                ),
                itemCount: 9,
                itemBuilder: (context, index) => Container(
                  color: Colors.white,
                ),
              ),
            ),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Error: $err"),
              ElevatedButton(
                onPressed: () => ref.refresh(paginatedVideoGridProvider),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      ),
          // Page indicator at the bottom in available space
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: videoGrid.when(
                data: (videos) {
                  final pageCount = (videos.length / 9).ceil();
                  return SmoothPageIndicator(
                    controller: _pageController,
                    count: pageCount,
                    effect: ExpandingDotsEffect(
                      dotHeight: 10,
                      dotWidth: 10,
                      spacing: 8,
                      activeDotColor: primaryLightColor,
                      dotColor: Colors.deepPurple.shade100,
                    ),
                  );
                },
                loading: () => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
