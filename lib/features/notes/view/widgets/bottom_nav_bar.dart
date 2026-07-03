import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:notebook_ai/core/res/color_manager.dart';
import 'package:notebook_ai/core/res/fonts_manager.dart';
import 'package:notebook_ai/features/notes/data/providers/navigation_provider.dart';

/// Bottom navigation bar matching the Figma design.
///
/// 3 tabs: Notes, Folders, Search. Has gradient background fading to
/// transparent at top, and active state highlighting.
class NotesBottomNavBar extends StatelessWidget {
  final NotesView currentView;
  final ValueChanged<NotesView> onNav;

  const NotesBottomNavBar({
    super.key,
    required this.currentView,
    required this.onNav,
  });

  @override
  Widget build(BuildContext context) {
    context.locale;
    final items = <_NavItem>[
      _NavItem(
        icon: LucideIcons.fileText,
        activeIcon: LucideIcons.fileText,
        label: 'nav.notes'.tr(),
        target: NotesView.list,
      ),
      _NavItem(
        icon: LucideIcons.folderOpen,
        activeIcon: LucideIcons.folder,
        label: 'nav.folders'.tr(),
        target: NotesView.folders,
      ),
      _NavItem(
        icon: LucideIcons.search,
        activeIcon: LucideIcons.search,
        label: 'nav.search'.tr(),
        target: NotesView.search,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            ColorM.background,
            ColorM.background,
            ColorM.background.withValues(alpha: 0.95),
            ColorM.background.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.5, 0.8, 1.0],
        ),
        border: Border(
          top: BorderSide(color: ColorM.border, width: 1),
        ),
      ),
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 12.h,
        bottom: 24.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) {
          final isActive = _isActive(item.target);
          return _NavButton(
            item: item,
            isActive: isActive,
            onTap: () {
              HapticFeedback.selectionClick();
              onNav(item.target);
            },
          );
        }).toList(),
      ),
    );
  }

  bool _isActive(NotesView target) {
    if (target == NotesView.list &&
        (currentView == NotesView.list || currentView == NotesView.editor)) {
      return true;
    }
    if (target == NotesView.folders &&
        (currentView == NotesView.folders ||
            currentView == NotesView.folderDetail)) {
      return true;
    }
    if (target == NotesView.search && currentView == NotesView.search) {
      return true;
    }
    return false;
  }
}

// ─── Private Helpers ──────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final NotesView target;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.target,
  });
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? ColorM.primaryAccent : ColorM.mutedForeground;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? item.activeIcon : item.icon,
              size: 22.sp,
              color: color,
            ),
            SizedBox(height: 4.h),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10.sp,
                fontFamily: FontsM.dmSans.name,
                fontWeight:
                    isActive ? FontWeightM.semiBold : FontWeightM.regular,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
