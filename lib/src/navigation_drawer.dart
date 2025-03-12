import 'package:flutter/material.dart';

const double _kCircularIndicatorDiameter = 56;
const double _kIndicatorHeight = 32;

const _defaultDrawerWidth = 304.0;
const _defaultRailWidth = 80.0;

/// A Material 3 [NavigationDrawer] item.
///
/// Displays an icon, a label and an indicator.
/// Use with [NavigationDrawer.items].
class NavigationDrawerItem {
  /// Creates a navigation drawer item with an icon and a label, to be used
  /// in the [NavigationDrawer.items].
  NavigationDrawerItem({
    required this.label,
    required this.icon,
    this.shortLabel,
    this.selectedIcon,
    this.indicator,
  });

  /// The text label that appears next to or below the icon of this
  /// [NavigationDrawerItem].
  final String label;

  /// The [Widget] (usually an [Icon]) that's displayed for this
  /// [NavigationDrawerItem].
  final Widget icon;

  /// The short text label that appears in the rail.
  ///
  /// If not provided, [label] is used.
  final String? shortLabel;

  /// The [Widget] (usually an [Icon]) that's displayed for this
  /// [NavigationDrawerItem] when it's selected collapsed state.
  ///
  /// For expanded state always [icon] is used.
  ///
  /// If not provided, [icon] is used.
  final Widget? selectedIcon;

  /// The indicator that appears on the top right corner of
  /// the collapsed item or next to label of the expanded item.
  final String? indicator;
}

/// State for a [NavigationDrawer].
enum DrawerState {
  /// The drawer displays as a Material 3 navigation rail.
  collapsed,

  /// The drawer displays as a Material 3 navigation drawer.
  expanded,
}

/// Signature for a function that creates a widget that can animate.
typedef AnimatedWidgetBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
);

/// Material 3 Navigation Drawer component.
///
/// When drawer state is [DrawerState.collapsed], the drawer displays
/// as a Material 3 navigation rail.
/// When drawer state is [DrawerState.expanded], the drawer displays
/// as a Material 3 navigation drawer.
///
/// See also:
///  * <https://m3.material.io/components/navigation-rail>
///  * <https://m3.material.io/components/navigation-drawer>
class NavigationDrawer extends StatefulWidget {
  /// Creates a Material 3 Navigation Drawer component.
  const NavigationDrawer({
    required this.items,
    super.key,
    this.initialState = DrawerState.expanded,
    this.collapsible = false,
    this.selectedIndex,
    this.onItemTap,
    this.headerBuilder,
    this.footerBuilder,
    this.itemBorderRadius = const BorderRadius.all(Radius.circular(32)),
    this.mainAnimationDuration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOutCubic,
    this.showRailLabel = true,
    this.elevation = 3,
    this.color,
    this.expandedWidth = _defaultDrawerWidth,
    this.collapsedWidth = _defaultRailWidth,
  }) : shortDuration = mainAnimationDuration ~/ 3;

  /// The initial state of the drawer.
  ///
  /// Defaults to [DrawerState.expanded].
  final DrawerState initialState;

  /// Whether the drawer can be collapse.
  ///
  /// When true, the menu icon is displayed in the header.
  ///
  /// Defaults to false.
  final bool collapsible;

  /// Determines which one of the [items] is currently selected.
  ///
  /// When this is updated, the destination (from [items]) at
  /// [selectedIndex] goes from unselected to selected.
  final int? selectedIndex;

  /// Called when one of the [items] is tapped.
  ///
  /// This callback usually updates the int passed to [selectedIndex].
  final ValueChanged<int>? onItemTap;

  /// A builder that's called to build the header of the drawer.
  final AnimatedWidgetBuilder? headerBuilder;

  /// A builder that's called to build the footer of the drawer.
  final AnimatedWidgetBuilder? footerBuilder;

  /// The list of items in this [NavigationDrawer].
  ///
  /// When [selectedIndex] is updated, the destination from this list at
  /// [selectedIndex] will change to selected.
  final List<NavigationDrawerItem> items;

  /// The border radius of items.
  ///
  /// Defaults to [BorderRadius.circular(32)].
  final BorderRadius itemBorderRadius;

  /// The expand/collapse main animation duration.
  ///
  /// Defaults to 300 ms.
  final Duration mainAnimationDuration;

  /// The duration of internal item animation.
  final Duration shortDuration;

  /// Determines the curve of the expand/collapse animation.
  ///
  /// Defaults to [Curves.easeInOutCubic].
  final Curve curve;

  /// When true, items labels is shown under the icon
  /// when the drawer is collapsed.
  ///
  /// Defaults to true.
  final bool showRailLabel;

  /// The elevation of the drawer.
  ///
  /// Defaults to 3.
  final double elevation;

  /// The color of the drawer.
  ///
  /// Defaults to [MaterialType.canvas] color.
  final Color? color;

  /// The width of the expanded drawer.
  ///
  /// Defaults to [_defaultDrawerWidth].
  final double expandedWidth;

  /// The width of the collapsed drawer.
  ///
  /// Defaults to [_defaultRailWidth].
  final double collapsedWidth;

  @override
  State<NavigationDrawer> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  late Animation<double> _mainAnimation;
  late Animation<double> _secondaryAnimation;
  late Animation<AlignmentGeometry> _alignAnimation;
  late Animation<double> _reversedAnimation;
  late Animation<double> _reversedSecondaryAnimation;

  @override
  void didUpdateWidget(covariant NavigationDrawer oldWidget) {
    if (widget.initialState != oldWidget.initialState) {
      if (widget.initialState == DrawerState.expanded) {
        expand();
      } else {
        collapse();
      }
    }

    if (widget.expandedWidth != oldWidget.expandedWidth ||
        widget.collapsedWidth != oldWidget.collapsedWidth) {
      _widthAnimation = Tween<double>(
        begin: widget.collapsedWidth,
        end: widget.expandedWidth,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: widget.curve,
        ),
      );
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.mainAnimationDuration,
      value: widget.initialState == DrawerState.expanded ? 1 : 0,
    );

    _widthAnimation = Tween<double>(
      begin: widget.collapsedWidth,
      end: widget.expandedWidth,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );
    _mainAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );
    _secondaryAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0, 0.01, curve: widget.curve),
      ),
    );
    _alignAnimation = Tween<AlignmentGeometry>(
      begin: Alignment.center,
      end: Alignment.topLeft,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );
    _reversedAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );
    _reversedSecondaryAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0, 0.5, curve: widget.curve),
      ),
    );

    _controller.addListener(() {
      setState(() {});
    });
  }

  bool get isExpanded => _controller.isCompleted;

  void expand() {
    _controller.forward();
  }

  void collapse() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _widthAnimation.value,
      child: Material(
        elevation: widget.elevation,
        color: widget.color,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: _buildItems(context),
              ),
            ),
            if (widget.footerBuilder != null)
              widget.footerBuilder!.call(context, _controller),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildItems(BuildContext context) {
    final list = <Widget>[
      Stack(
        children: [
          Container(),
          if (widget.headerBuilder != null)
            widget.headerBuilder!.call(context, _controller),
          if (widget.collapsible)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  width: widget.collapsedWidth,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.color ??
                            Theme.of(context).colorScheme.surface,
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        if (isExpanded) {
                          collapse();
                        } else {
                          expand();
                        }
                      },
                      icon: const Icon(Icons.menu),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ];

    for (var i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      final selected = i == widget.selectedIndex;
      list.add(
        _Item(
          selected: selected,
          item: item,
          onTap: () => widget.onItemTap?.call(i),
          mainAnimation: _mainAnimation,
          secondaryAnimation: _secondaryAnimation,
          alignAnimation: _alignAnimation,
          reversedAnimation: _reversedAnimation,
          reversedSecondaryAnimation: _reversedSecondaryAnimation,
          borderRadius: widget.itemBorderRadius,
          duration: widget.shortDuration,
          showRailLabel: widget.showRailLabel,
          expandedWidth: widget.expandedWidth,
          collapsedWidth: widget.collapsedWidth,
        ),
      );
    }
    return list;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.selected,
    required this.item,
    required this.onTap,
    required this.mainAnimation,
    required this.secondaryAnimation,
    required this.alignAnimation,
    required this.reversedAnimation,
    required this.reversedSecondaryAnimation,
    required this.borderRadius,
    required this.duration,
    required this.showRailLabel,
    required this.expandedWidth,
    required this.collapsedWidth,
  });

  final bool selected;
  final NavigationDrawerItem item;
  final VoidCallback onTap;
  final Animation<double> mainAnimation;
  final Animation<double> secondaryAnimation;
  final Animation<AlignmentGeometry> alignAnimation;
  final Animation<double> reversedAnimation;
  final Animation<double> reversedSecondaryAnimation;
  final BorderRadius borderRadius;
  final Duration duration;
  final bool showRailLabel;
  final double expandedWidth;
  final double collapsedWidth;

  @override
  Widget build(BuildContext context) {
    final activeColor = Theme.of(context).colorScheme.secondaryContainer;
    final collapsed = mainAnimation.isDismissed;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: showRailLabel ? 4 + mainAnimation.value * 8 : 12,
        vertical: showRailLabel
            ? 4 + reversedAnimation.value * 4
            : mainAnimation.value * 4,
      ),
      child: _IndicatorInkWell(
        railLabelVisible: showRailLabel && collapsed,
        onTap: onTap,
        borderRadius: borderRadius,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: showRailLabel ? reversedAnimation.value * 8 : 0,
              ),
              child: AlignTransition(
                alignment: alignAnimation,
                child: AnimatedContainer(
                  duration: duration,
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    color: selected ? activeColor : null,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: showRailLabel
                          ? 4 + mainAnimation.value * 8
                          : 12 +
                              reversedAnimation.value *
                                  4, // 4 -> 12 or 16 -> 12
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Badge(
                          isLabelVisible: item.indicator != null && collapsed,
                          label: Text(
                            item.indicator ?? '',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w200,
                                ),
                          ),
                          child:
                              selected && collapsed && item.selectedIcon != null
                                  ? item.selectedIcon
                                  : item.icon,
                        ),
                        Flexible(
                          child: SizeTransition(
                            axis: Axis.horizontal,
                            sizeFactor: secondaryAnimation,
                            child: SizedBox(
                              width: expandedWidth,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  item.label,
                                  style: Theme.of(context).textTheme.labelLarge,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (item.indicator != null && mainAnimation.isCompleted)
                          Padding(
                            padding: const EdgeInsets.only(left: 12, right: 4),
                            child: Text(
                              item.indicator!,
                              style: Theme.of(context).textTheme.labelLarge,
                              maxLines: 1,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (showRailLabel)
              SizeTransition(
                sizeFactor: reversedAnimation,
                child: SizedBox(
                  width: collapsedWidth - 8,
                  child: FadeTransition(
                    opacity: reversedSecondaryAnimation,
                    child: Column(
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          item.shortLabel ?? item.label,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                fontWeight: selected ? FontWeight.w700 : null,
                              ),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _IndicatorInkWell extends InkResponse {
  const _IndicatorInkWell({
    required this.railLabelVisible,
    super.child,
    super.onTap,
    super.borderRadius,
  }) : super(
          containedInkWell: true,
          highlightShape: BoxShape.rectangle,
        );

  /// Whether the rail label is visible.
  ///
  /// If true, the ink effect will be applied to icon only.
  /// Otherwise, the ink effect will be applied to the whole item.
  final bool railLabelVisible;

  @override
  RectCallback? getRectCallback(RenderBox referenceBox) {
    if (!railLabelVisible) {
      // The default rect callback for Ink highlight.
      return super.getRectCallback(referenceBox);
    }

    final indicatorHorizontalCenter = referenceBox.size.width / 2;

    return () {
      return Rect.fromLTWH(
        indicatorHorizontalCenter - (_kCircularIndicatorDiameter / 2),
        0,
        _kCircularIndicatorDiameter,
        _kIndicatorHeight,
      );
    };
  }
}
