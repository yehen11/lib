import 'package:adgo_mobile/themes/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TagSelectionScreen extends ConsumerStatefulWidget {
  const TagSelectionScreen({super.key});

  @override
  _TagSelectionScreenState createState() => _TagSelectionScreenState();
}

class _TagSelectionScreenState extends ConsumerState<TagSelectionScreen> {

  final Set<String> _selectedTags = {};
  
  final int _minSelection = 3;
  final int _maxSelection = 25;

  final Map<String, List<TagData>> _tagCategories = {
    'Primary': [
      TagData('Business', '💼'),
      TagData('Science & Tech', '🔬'),
      TagData('Arts', '🎭'),
      TagData('Music', '🎵'),
      TagData('Film & Media', '🎬'),
      TagData('TV', '📺'),
    ],
    'Media': [
      TagData('Film', '🎞️'),
      TagData('Anime', '🌸'),
      TagData('Gaming', '🎮'),
      TagData('Adult', '🔞'),
      TagData('Comics', '📚'),
      TagData('Comedy', '😂'),
      TagData('Other', '📌'),
    ],
    'Lifestyle': [
      TagData('Fashion', '👗'),
      TagData('Health', '❤️'),
      TagData('Sports & Fitness', '🏃'),
      TagData('Travel & Outdoor', '🌲'),
      TagData('Food & Drink', '🍔'),
      TagData('Home & Lifestyle', '🏠'),
    ],
    'Community': [
      TagData('Charities & Causes', '🙌'),
      TagData('Community', '👪'),
      TagData('Government', '🏛️'),
      TagData('Seasonal', '🍂'),
      TagData('Hobbies', '🎨'),
      TagData('Auto, Boat & Air', '🚗'),
      TagData('School Activities', '🎓'),
    ],
  };

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        if (_selectedTags.length < _maxSelection) {
          _selectedTags.add(tag);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You can select maximum $_maxSelection tags'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 24),
                    onPressed: () {
                      Navigator.maybePop(context);
                    },
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tell us what you love',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose between $_minSelection and $_maxSelection interests, and we\'ll curate the best events for your feed.',
                    style: TextStyle(
                      fontSize: 15,
                      color: primaryDarkColor.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _tagCategories.length,
                itemBuilder: (context, index) {
                  final category = _tagCategories.keys.elementAt(index);
                  final tags = _tagCategories[category]!;
                  
                  if (category == 'Media') {
                    return _buildMediaSection(tags);
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildTagGrid(tags),
                    );
                  }
                },
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _selectedTags.length >= _minSelection
                    ? () {
                        Navigator.pop(context, _selectedTags.toList());
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedTags.length >= _minSelection
                      ? primaryLightColor
                      : whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                    side: BorderSide(
                      color: primaryLightColor
                    ),
                  ),
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _selectedTags.length >= _minSelection
                      ? whiteColor
                      : primaryDarkColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMediaSection(List<TagData> tags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TagChip(
          label: 'Film & Media',
          emoji: '🎬',
          isSelected: _selectedTags.contains('Film & Media'),
          onTap: () => _toggleTag('Film & Media'),
          elevation: 0,
          selectedColor: primaryLightColor,
        ),
        
        const SizedBox(height: 12),
        
        _buildTagGrid(tags),
        
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTagGrid(List<TagData> tags) {
    return Wrap(
      spacing: 8,
      runSpacing: 12,
      children: tags.map((tag) {
        return TagChip(
          label: tag.name,
          emoji: tag.emoji,
          isSelected: _selectedTags.contains(tag.name),
          onTap: () => _toggleTag(tag.name),
          elevation: 0,
          selectedColor: primaryLightColor,
        );
      }).toList(),
    );
  }
}

class TagChip extends StatelessWidget {
  final String label;
  final String? emoji;
  final bool isSelected;
  final VoidCallback onTap;
  final double elevation;
  final Color selectedColor;
  final Color unselectedColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  
  const TagChip({
    Key? key,
    required this.label,
    this.emoji,
    required this.isSelected,
    required this.onTap,
    this.elevation = 0.5,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.white,
    this.selectedTextColor = Colors.white,
    this.unselectedTextColor = Colors.black87,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : unselectedColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? selectedColor : Colors.grey[300]!,
              width: 1,
            ),
            boxShadow: elevation > 0 
                ? [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 0,
                      blurRadius: elevation,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (emoji != null) ...[
                Text(
                  emoji!,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? selectedTextColor : unselectedTextColor,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TagData {
  final String name;
  final String emoji;
  
  TagData(this.name, this.emoji);
}