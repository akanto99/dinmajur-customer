import 'package:flutter/material.dart';

/// A widget that displays a sticky header showing the current visible category/service
class StickyServiceHeader extends StatelessWidget {
  final String currentServiceName;
  final bool isVisible;
  final Color backgroundColor;
  final TextStyle textStyle;
  final double height;
  final EdgeInsetsGeometry? padding;
  final bool showBorder;
  final Color? borderColor;

  const StickyServiceHeader({
    Key? key,
    required this.currentServiceName,
    required this.isVisible,
    required this.backgroundColor,
    required this.textStyle,
    this.height = 45,
    this.padding,
    this.showBorder = true,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // No animation - instant show/hide
    return SizedBox(
      height: isVisible && currentServiceName.isNotEmpty ? height : 0,
      child: isVisible && currentServiceName.isNotEmpty
          ? Container(
        width: double.infinity,
        padding: padding ?? EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: showBorder
              ? Border(
            bottom: BorderSide(
              color: borderColor ?? Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.label,
              size: 16,
              color: textStyle.color ?? Colors.grey,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                currentServiceName,
                style: textStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      )
          : SizedBox.shrink(),
    );
  }
}

/// Mixin to handle scroll-based sticky header logic
mixin StickyHeaderScrollMixin<T extends StatefulWidget> on State<T> {
  late ScrollController scrollController;
  final Map<int, GlobalKey> categoryKeys = {};
  String currentVisibleService = '';
  bool showStickyHeader = false;
  int _currentVisibleIndex = -1;

  // AppBar height + any offset (adjust based on your layout)
  double get appBarHeight => 60.0;
  double get stickyHeaderHeight => 45.0;

  // The threshold where sticky header should appear
  double get headerThreshold => appBarHeight;

  void initializeStickyHeader(ScrollController controller) {
    scrollController = controller;
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    int newVisibleIndex = -1;
    String newVisibleService = '';

    // Iterate through all categories to find which one is currently "active"
    for (var entry in categoryKeys.entries) {
      final index = entry.key;
      final key = entry.value;
      final context = key.currentContext;

      if (context != null) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero);
        final itemTop = position.dy;
        final itemBottom = position.dy + box.size.height;

        // Check if this item's top has crossed the threshold
        // The key logic: when scrolling down, show the header when item top <= threshold
        // When scrolling up, keep showing until the NEXT item's top crosses threshold
        if (itemTop <= headerThreshold && itemBottom > headerThreshold) {
          // This item is currently at the sticky position
          newVisibleIndex = index;
          newVisibleService = getServiceNameByIndex(index);
          break;
        }
      }
    }

    // Determine if sticky header should be visible
    bool shouldShow = newVisibleIndex >= 0;

    // Only update if there's a change to avoid unnecessary rebuilds
    if (_currentVisibleIndex != newVisibleIndex ||
        showStickyHeader != shouldShow ||
        currentVisibleService != newVisibleService) {
      setState(() {
        _currentVisibleIndex = newVisibleIndex;
        showStickyHeader = shouldShow;
        currentVisibleService = newVisibleService;
      });
    }
  }

  // Override this in your screen to return the service name
  String getServiceNameByIndex(int index);

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    super.dispose();
  }
}