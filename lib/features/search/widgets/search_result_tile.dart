import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/search_event_model.dart';

class SearchResultTile extends StatefulWidget {
  final SearchEventModel event;

  const SearchResultTile({super.key, required this.event});

  @override
  State<SearchResultTile> createState() => _SearchResultTileState();
}

class _SearchResultTileState extends State<SearchResultTile> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: border),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Row(
        children: [
          // thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: widget.event.imageAsset.isNotEmpty
                ? Image.asset(
                    widget.event.imageAsset,
                    width: 62,
                    height: 62,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? AppColors.darkGradient
                          : AppColors.lightGradient,
                    ),
                  ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // title + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.event.dateLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // heart
          IconButton(
            onPressed: () => setState(() => _liked = !_liked),
            icon: Icon(
              _liked ? Icons.favorite : Icons.favorite_border,
              color: _liked
                  ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                  : textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
