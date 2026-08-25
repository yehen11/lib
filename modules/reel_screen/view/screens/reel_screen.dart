// ignore_for_file: library_private_types_in_public_api

/*
@Author - Anuruddha
@Date - 2025/03/01
*/

import 'package:adgo_mobile/modules/reel_screen/model/reel.dart';
import 'package:adgo_mobile/modules/reel_screen/view/controllers/reel_controller.dart';
import 'package:adgo_mobile/modules/reel_screen/view/controllers/video_player_manager.dart';
import 'package:adgo_mobile/modules/reel_screen/view/widgets/reel_item.dart';
import 'package:adgo_mobile/modules/video_feed/model/video_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart'; // for debugPrint

class ReelScreen extends ConsumerStatefulWidget {
  final VideoModel? initialVideo;
  
  const ReelScreen({super.key, this.initialVideo});

  @override
  _ReelScreenState createState() => _ReelScreenState();
}

class _ReelScreenState extends ConsumerState<ReelScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Set initial index to 0 when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(videoPlayerManagerProvider.notifier).setCurrentIndex(0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reels = ref.watch(reelsProvider);

    debugPrint("================ REELS COUNT ================");
    debugPrint((reels.valueOrNull?.length ?? 0).toString());

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: reels.when(
        data: (List<Reel> reelsList) {
          // Build final reel list: initial video (if provided) + recommendations
          final List<Reel> finalReelsList = [];
          
          // Add initial video first if provided
          if (widget.initialVideo != null) {
            finalReelsList.add(Reel(
              id: widget.initialVideo!.id,
              videoUrl: widget.initialVideo!.videoUrl,
              title: widget.initialVideo!.title,
              shopId: widget.initialVideo!.shopId ?? '',
              shopHandle: widget.initialVideo!.shopHandle ?? '',
              description: widget.initialVideo!.description ?? '',
            ));
            debugPrint("Added initial video: ${widget.initialVideo!.id}");
          }
          
          // Add recommendation videos (exclude initial video if already added)
          for (var reel in reelsList) {
            if (widget.initialVideo == null || reel.id != widget.initialVideo!.id) {
              finalReelsList.add(reel);
            }
          }
          
          debugPrint("Final reels count: ${finalReelsList.length}");
          
          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            itemCount: finalReelsList.length,
            // Keep only adjacent pages cached (current + 1 before + 1 after)
            // This optimizes memory usage like TikTok/YT Shorts
            allowImplicitScrolling: true,
            pageSnapping: true,
            onPageChanged: (index) {
              debugPrint("📄 Page changed to index: $index");
              // Update video player manager to play only the current video
              ref.read(videoPlayerManagerProvider.notifier).setCurrentIndex(index);
            },
            itemBuilder: (context, index) {
              final reel = finalReelsList[index];
              return KeyedSubtree(
                key: PageStorageKey("reel_${reel.id}"),
                child: ReelItem(
                  reel: reel,
                  pageIndex: index,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}