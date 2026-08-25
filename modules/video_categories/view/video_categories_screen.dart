import 'package:adgo_mobile/modules/video_feed/view/controllers/video_controller.dart';
import 'package:adgo_mobile/modules/video_feed/view/widgets/video_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../themes/utils.dart';

class VideoCategoriesScreen extends ConsumerStatefulWidget {
  const VideoCategoriesScreen({super.key});

  @override
  _VideoCategoriesScreenState createState() => _VideoCategoriesScreenState();
}

class _VideoCategoriesScreenState extends ConsumerState<VideoCategoriesScreen> {
  bool isLoadingMore = false;
  
  final List<String> categories = [
    "Electronics",
    "Beauty & Health",
    "Home & Kitchen",
    "Women's Clothing",
    "Toys & Games",
    "Sports & Outdoors",
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialVideos();
  }

  Future<void> _loadInitialVideos() async {
    final currentAddsCount = ref.watch(addsCountProvider).value ?? 0;
    if (currentAddsCount < 30) {
      await fetchMore(currentAddsCount);
    }
  }

  Future<void> fetchMore(int currentAddsCount) async {
    if (isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      await ref.read(fetchMoreVideosProvider(currentAddsCount).future);
      ref.invalidate(videoGridSuggestionProvider);
      ref.invalidate(addsCountProvider);
    } finally {
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final videos = ref.watch(videoGridSuggestionProvider);
    
    return Scaffold(
      body: SafeArea(
        child: videos.when(
          data: (allVideos) {
            
            if (allVideos.isEmpty) {
              return const Center(child: Text("No videos available"));
            }
            
            final int videosPerCategory = (allVideos.length / 6).ceil();
            final electronics = allVideos.take(videosPerCategory).toList();
            final beauty = allVideos.length > videosPerCategory 
                ? allVideos.skip(videosPerCategory).take(videosPerCategory).toList() 
                : [];
            final home = allVideos.length > (videosPerCategory * 2) 
                ? allVideos.skip(videosPerCategory * 2).take(videosPerCategory).toList() 
                : [];
            final clothing = allVideos.length > (videosPerCategory * 3) 
                ? allVideos.skip(videosPerCategory * 3).take(videosPerCategory).toList() 
                : [];
            final toys = allVideos.length > (videosPerCategory * 4) 
                ? allVideos.skip(videosPerCategory * 4).take(videosPerCategory).toList() 
                : [];
            final sports = allVideos.length > (videosPerCategory * 4) 
                ? allVideos.skip(videosPerCategory * 4).toList() 
                : [];
            
            final categoryVideos = [electronics, beauty, home, clothing, toys, sports];
            
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(videoGridSuggestionProvider);
                await _loadInitialVideos();
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                      child: Text(
                        "Discover Items",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= categoryVideos.length || categoryVideos[index].isEmpty) {
                          return const SizedBox.shrink();
                        }
                        
                        return CategoryRow(
                          title: categories[index],
                          videos: categoryVideos[index],
                          onEndReached: () {
                            
                            if (index == categories.length - 1) {
                              final currentAddsCount = ref.read(addsCountProvider).value ?? 0;
                              if (currentAddsCount < 30) {
                                fetchMore(currentAddsCount);
                              }
                            }
                          },
                        );
                      },
                      childCount: categories.length,
                    ),
                  ),
                  if (isLoadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                ],
              ),
            );
          },
          loading: () => Center(child: CircularProgressIndicator(color: primaryLightColor)),
          error: (err, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Error: $err"),
                ElevatedButton(
                  onPressed: () => _loadInitialVideos(),
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryRow extends StatefulWidget {
  final String title;
  final List<dynamic> videos;
  final VoidCallback onEndReached;

  const CategoryRow({
    Key? key,
    required this.title,
    required this.videos,
    required this.onEndReached,
  }) : super(key: key);

  @override
  State<CategoryRow> createState() => _CategoryRowState();
}

class _CategoryRowState extends State<CategoryRow> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }
  
  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      widget.onEndReached();
    }
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double aspectRatio = 9 / 16;
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth * 0.28;
    final itemHeight = itemWidth / aspectRatio;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 24.0, bottom: 12.0),
          child: Text(
            widget.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: itemHeight,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            itemCount: widget.videos.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: GestureDetector(
                  onTap: () {},
                  child: SizedBox(
                    width: itemWidth,
                    child: VideoCard(video: widget.videos[index]),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}