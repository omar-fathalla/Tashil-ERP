import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

/// Layout that follows m3.material.io/foundations/layout (overview, parts of
/// layout, adaptive design, breakpoints).
///
/// * **Breakpoints** (previously window size classes): five widths at which
///   the layout changes. Design for breakpoints, not devices: the window
///   changes with rotation, split screen and resizing.
/// * **Layout scaffold**: bars frame the page, rails hold navigation and
///   primary controls, and all content sits in 1 to 3 **panes**.
/// * **Adaptive strategies**: reveal, divide, resize, reposition, swap.
///   Swap only components that do the same job (bar and rail, FAB and
///   extended FAB), never a button for a chip or a menu.
/// * RTL: the first pane and the navigation are on the right in Arabic,
///   because everything here uses the reading direction.
enum TashilBreakpoint {
  /// Under 600dp: phone in portrait, SUNMI V3 (360dp).
  compact(0),

  /// 600 to 839dp: tablet or unfolded foldable in portrait.
  medium(600),

  /// 840 to 1199dp: tablet or phone in landscape, small desktop window.
  expanded(840),

  /// 1200 to 1599dp: desktop, the admin panel.
  large(1200),

  /// 1600dp and wider: desktop, ultra-wide monitors.
  extraLarge(1600);

  const TashilBreakpoint(this.minWidth);

  /// Smallest window width (dp) in this breakpoint.
  final double minWidth;

  static TashilBreakpoint fromWidth(double width) {
    for (final b in values.reversed) {
      if (width >= b.minWidth) return b;
    }
    return compact;
  }

  /// The breakpoint of the window.
  static TashilBreakpoint of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);

  bool operator >=(TashilBreakpoint other) => index >= other.index;
  bool operator <(TashilBreakpoint other) => index < other.index;

  /// Leading and trailing margin: 16dp on compact, 24dp from medium.
  double get margin => this == compact ? 16 : 24;

  /// Space between two panes: 24dp at every breakpoint that has two.
  double get spacer => 24;

  /// Highest number of panes M3 allows here (never more than three).
  int get maxPanes => switch (this) {
    compact => 1,
    medium || expanded || large => 2,
    extraLarge => 3,
  };

  /// Panes M3 recommends: one up to medium (two only for low-density
  /// content like settings), two from expanded, up to three on extra-large.
  int get recommendedPanes => switch (this) {
    compact || medium => 1,
    expanded || large => 2,
    extraLarge => 3,
  };

  /// Default width of the fixed pane in a fixed-and-flexible layout:
  /// 360dp on expanded, 412dp on large and extra-large. Medium splits 50/50.
  double? get fixedPaneWidth => switch (this) {
    compact || medium => null,
    expanded => 360,
    large || extraLarge => 412,
  };

  /// Arabic name for the playground and debug labels.
  String get label => switch (this) {
    compact => 'مضغوط',
    medium => 'متوسط',
    expanded => 'موسّع',
    large => 'كبير',
    extraLarge => 'كبير جداً',
  };
}

/// How a two-pane layout shares the width.
enum PaneSplit {
  /// First pane has a fixed width ([TashilBreakpoint.fixedPaneWidth]), the
  /// second takes the rest. List-detail: invoices + the open invoice.
  fixedFlexible,

  /// Both panes flexible, spacer visually centred (50/50).
  split,
}

/// The layout scaffold's content area: 1 to 3 panes with the breakpoint's
/// margins and 24dp spacers, a drag handle between the first two panes,
/// and the "show and hide" strategy when only one pane fits.
///
/// Flutter has no pane scaffold (Compose has `ListDetailPaneScaffold`,
/// and the `flutter_adaptive_scaffold` package is discontinued), so this
/// one is ours.
///
/// * One pane fits (compact, and medium unless [twoPanesOnMedium]): shows
///   [second] when [showSecond] is true (an item is open), else [first].
///   The caller handles back (close the item) on compact.
/// * Two panes: [first] and [second] side by side. With no [second] the
///   first pane gets the whole width ([placeholder] can fill the space
///   instead, like "pick an invoice").
/// * [third] (extra-large only) is a supplementary pane, like a standard
///   side sheet with filters; max 400dp.
/// * The drag handle resizes the first pane, and dragging it to an edge
///   collapses to one pane. Also works with the keyboard (arrow keys) and
///   screen readers (increase / decrease).
class PaneLayout extends StatefulWidget {
  const PaneLayout({
    super.key,
    required this.first,
    this.second,
    this.third,
    this.placeholder,
    this.showSecond = false,
    this.split = PaneSplit.fixedFlexible,
    this.twoPanesOnMedium = false,
    this.resizable = true,
    this.contained = false,
    this.breakpoint,
  });

  final Widget first;
  final Widget? second;
  final Widget? third;

  /// Fills the second pane when there is room for it but no [second].
  final Widget? placeholder;

  /// On one-pane breakpoints: show [second] instead of [first].
  final bool showSecond;
  final PaneSplit split;

  /// Medium allows two 50/50 panes for low-density content (settings).
  final bool twoPanesOnMedium;

  /// Shows the drag handle between the first two panes.
  final bool resizable;

  /// Explicit grouping: panes get a container colour and rounded corners.
  /// Off (implicit grouping) the panes blend with the background.
  final bool contained;

  /// Override for previews; defaults to the width this widget gets.
  final TashilBreakpoint? breakpoint;

  @override
  State<PaneLayout> createState() => _PaneLayoutState();
}

class _PaneLayoutState extends State<PaneLayout> {
  /// First pane width chosen with the drag handle; null = the default.
  double? _firstWidth;

  /// Collapsed to one pane with the drag handle: which pane stays.
  bool? _onlyFirst;

  static const _minPane = 240.0;
  static const _thirdWidth = 400.0;
  static const _keyStep = 24.0;

  int _panes(TashilBreakpoint b) {
    final w = widget;
    if (b == TashilBreakpoint.compact) return 1;
    if (b == TashilBreakpoint.medium && !w.twoPanesOnMedium) return 1;
    if (w.second == null && w.placeholder == null) return 1;
    if (b == TashilBreakpoint.extraLarge && w.third != null) return 3;
    return 2;
  }

  Widget _pane(Widget child) {
    if (!widget.contained) return child;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(TashilRadius.large),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = widget;
        final b = w.breakpoint ?? TashilBreakpoint.fromWidth(c.maxWidth);
        final panes = _panes(b);
        final margin = EdgeInsets.symmetric(horizontal: b.margin);

        if (panes == 1) {
          final showSecond = w.showSecond && w.second != null;
          return Padding(
            padding: margin,
            child: _pane(
              KeyedSubtree(
                key: ValueKey(showSecond),
                child: showSecond ? w.second! : w.first,
              ),
            ),
          );
        }

        // Collapsed with the drag handle: one pane, the handle stays at its
        // edge so the person can drag the other pane back.
        if (_onlyFirst != null) {
          final onlyFirst = _onlyFirst!;
          final handle = SizedBox(
            width: b.spacer,
            child: PaneDragHandle(
              onDrag: (d) {
                if (onlyFirst ? d < 0 : d > 0) _restore();
              },
              onReset: _restore,
            ),
          );
          final pane = Expanded(
            child: _pane(onlyFirst ? w.first : (w.second ?? w.placeholder!)),
          );
          return Padding(
            padding: margin,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: onlyFirst ? [pane, handle] : [handle, pane],
            ),
          );
        }

        final third = panes == 3 ? w.third : null;
        final inner =
            c.maxWidth -
            2 * b.margin -
            b.spacer -
            (third == null ? 0 : _thirdWidth + b.spacer);
        final defaultFirst = switch (w.split) {
          PaneSplit.fixedFlexible => b.fixedPaneWidth ?? inner / 2,
          PaneSplit.split => inner / 2,
        };
        final maxFirst = (inner - _minPane).clamp(_minPane, double.infinity);
        final first = (_firstWidth ?? defaultFirst).clamp(_minPane, maxFirst);

        void resize(double delta) {
          final next = first + delta;
          setState(() {
            if (next < _minPane - 48) {
              _onlyFirst = false;
            } else if (next > maxFirst + 48) {
              _onlyFirst = true;
            } else {
              _firstWidth = next.clamp(_minPane, maxFirst);
            }
          });
        }

        return Padding(
          padding: margin,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(width: first, child: _pane(w.first)),
              SizedBox(
                width: b.spacer,
                child: w.resizable
                    ? PaneDragHandle(
                        onDrag: resize,
                        step: _keyStep,
                        onReset: () => setState(() => _firstWidth = null),
                      )
                    : null,
              ),
              Expanded(child: _pane(w.second ?? w.placeholder!)),
              if (third != null) ...[
                SizedBox(width: b.spacer),
                SizedBox(width: _thirdWidth, child: _pane(third)),
              ],
            ],
          ),
        );
      },
    );
  }

  void _restore() => setState(() {
    _onlyFirst = null;
    _firstWidth = null;
  });
}

/// The drag handle that resizes panes (M3 "Drag handle"): a 4 x 48dp pill
/// in the spacer, 24dp wide hit area, resize cursor on hover. Drags follow
/// the reading direction (in Arabic, dragging left grows the first pane).
/// Arrow keys move it, Home resets it, and screen readers get increase and
/// decrease actions.
class PaneDragHandle extends StatefulWidget {
  const PaneDragHandle({
    super.key,
    required this.onDrag,
    this.onReset,
    this.step = 24,
  });

  /// Change in the first pane's width, in dp, positive = wider.
  final ValueChanged<double> onDrag;
  final VoidCallback? onReset;
  final double step;

  @override
  State<PaneDragHandle> createState() => _PaneDragHandleState();
}

class _PaneDragHandleState extends State<PaneDragHandle> {
  bool _hover = false;
  bool _dragging = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final active = _dragging || _hover || _focused;
    double sign(double dx) => rtl ? -dx : dx;
    return Semantics(
      label: 'تغيير عرض الأجزاء',
      onIncrease: () => widget.onDrag(widget.step),
      onDecrease: () => widget.onDrag(-widget.step),
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.resizeColumn,
        onShowHoverHighlight: (v) => setState(() => _hover = v),
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        shortcuts: {
          SingleActivator(
            rtl ? LogicalKeyboardKey.arrowLeft : LogicalKeyboardKey.arrowRight,
          ): const _GrowIntent(
            1,
          ),
          SingleActivator(
            rtl ? LogicalKeyboardKey.arrowRight : LogicalKeyboardKey.arrowLeft,
          ): const _GrowIntent(
            -1,
          ),
          const SingleActivator(LogicalKeyboardKey.home): const _ResetIntent(),
        },
        actions: {
          _GrowIntent: CallbackAction<_GrowIntent>(
            onInvoke: (i) => widget.onDrag(i.sign * widget.step),
          ),
          _ResetIntent: CallbackAction<_ResetIntent>(
            onInvoke: (_) => widget.onReset?.call(),
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (_) => setState(() => _dragging = true),
          onHorizontalDragUpdate: (d) => widget.onDrag(sign(d.delta.dx)),
          onHorizontalDragEnd: (_) => setState(() => _dragging = false),
          onDoubleTap: widget.onReset,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: active ? 12 : 4,
              height: _dragging ? 52 : 48,
              decoration: BoxDecoration(
                color: _dragging ? scheme.onSurface : scheme.outline,
                borderRadius: BorderRadius.circular(TashilRadius.full),
                border: _focused
                    ? Border.all(color: scheme.secondary, width: 2)
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GrowIntent extends Intent {
  const _GrowIntent(this.sign);
  final int sign;
}

class _ResetIntent extends Intent {
  const _ResetIntent();
}

/// Keeps long text at a readable line length (M3: 40 to 60 characters per
/// line at every breakpoint) and at the start edge.
class ReadingWidth extends StatelessWidget {
  const ReadingWidth({super.key, required this.child, this.characters = 60});

  final Widget child;
  final int characters;

  /// About half an em per character for Cairo body text.
  static double maxWidthFor(BuildContext context, {int characters = 60}) {
    final size =
        Theme.of(context).textTheme.bodyLarge?.fontSize ?? 16; // dp, unscaled
    final scaled = MediaQuery.textScalerOf(context).scale(size);
    return characters * scaled * 0.55;
  }

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.topStart,
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidthFor(context, characters: characters),
      ),
      child: child,
    ),
  );
}

/// A FAB that changes presentation with the window (M3 adaptive
/// components): standard FAB on compact and medium, extended FAB with its
/// label from expanded. Same action either way.
class AdaptiveFab extends StatelessWidget {
  const AdaptiveFab({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.breakpoint,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final TashilBreakpoint? breakpoint;

  @override
  Widget build(BuildContext context) {
    final b = breakpoint ?? TashilBreakpoint.of(context);
    if (b >= TashilBreakpoint.expanded) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      );
    }
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: label,
      child: Icon(icon),
    );
  }
}
