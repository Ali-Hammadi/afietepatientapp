import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:afiete/core/routes/app_route.dart';
import 'package:afiete/feature/articles/domain/entities/article_entities.dart';
import 'package:afiete/feature/articles/presentation/cubits/articles_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ArticleCardWidget extends StatefulWidget {
  final ArticleEntity article;
  final VoidCallback? onReadMore;
  final VoidCallback? onDoctorTap;
  final bool isExpanded;
  final bool compactMode;
  final bool flatMode;

  const ArticleCardWidget({
    super.key,
    required this.article,
    this.onReadMore,
    this.onDoctorTap,
    this.isExpanded = false,
    this.compactMode = false,
    this.flatMode = false,
  });

  @override
  State<ArticleCardWidget> createState() => _ArticleCardWidgetState();
}

class _ArticleCardWidgetState extends State<ArticleCardWidget> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final formattedDate = DateFormat(
      'd MMM yyyy',
      Localizations.localeOf(context).toLanguageTag(),
    ).format(widget.article.createdAt);
    final doctorImage = widget.article.doctor.imageUrl ?? '';
    final isNetworkImage = doctorImage.startsWith('http');
    final cardPadding =
        widget.compactMode ? AppStyles.padding * 0.8 : AppStyles.padding;
    final avatarSize = widget.compactMode ? 44.0 : 50.0;

    final content = Padding(
      padding: EdgeInsets.symmetric(
        vertical: widget.flatMode ? 10 : cardPadding,
        horizontal: widget.flatMode ? 0 : cardPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _buildDoctorHeader(
            colorScheme: colorScheme,
            doctorImage: doctorImage,
            isNetworkImage: isNetworkImage,
            formattedDate: formattedDate,
            avatarSize: avatarSize,
          ),
          if (widget.article.imageUrl.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildArticleImage(
              colorScheme: colorScheme,
              imageUrl: widget.article.imageUrl,
            ),
          ],
          Text(
            widget.article.title,
            style: (widget.compactMode
                    ? AppStyles.bodyLarge
                    : AppStyles.headingSmall)
                .copyWith(fontWeight: FontWeight.w700),
            maxLines: widget.compactMode ? 2 : 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Text(
            widget.article.content,
            style:
                widget.compactMode ? AppStyles.bodySmall : AppStyles.bodyMedium,
            maxLines: widget.compactMode
                ? 4
                : _isExpanded
                    ? null
                    : 4,
            overflow:
                _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Builder(builder: (context) {
            return Row(
              children: [
                IconButton(
                  onPressed: () {
                    context.read<ArticlesCubit>().reactToArticle(
                          widget.article.id,
                          'like',
                        );
                  },
                  icon: Icon(
                    Icons.thumb_up_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Text('${widget.article.likesCount}'),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    context.read<ArticlesCubit>().reactToArticle(
                          widget.article.id,
                          'dislike',
                        );
                  },
                  icon: Icon(
                    Icons.thumb_down_outlined,
                    size: 18,
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(width: 4),
                Text('${widget.article.dislikesCount}'),
              ],
            );
          }),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
              // navigate to details when user taps read more
              if (widget.onReadMore == null) {
                Navigator.pushNamed(
                  context,
                  MyRoutes.articleDetailsScreen,
                  arguments: widget.article,
                );
              } else {
                widget.onReadMore?.call();
              }
            },
            child: Text(
              _isExpanded ? SettingsStrings.readLess : SettingsStrings.readMore,
              style: AppStyles.bodyMedium.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.flatMode) {
      return content;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppStyles.borderRadius * 1.5),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 10,
            spreadRadius: -4,
            offset: const Offset(-2, 0),
          ),
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 10,
            spreadRadius: -4,
            offset: const Offset(2, 0),
          ),
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 10,
            spreadRadius: -5,
            offset: const Offset(0, -2),
          ),
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 10,
            spreadRadius: -5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppStyles.borderRadius * 1.5),
        child: content,
      ),
    );
  }

  Widget _buildDoctorHeader({
    required ColorScheme colorScheme,
    required String doctorImage,
    required bool isNetworkImage,
    required String formattedDate,
    required double avatarSize,
  }) {
    final avatar = ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: avatarSize,
        height: avatarSize,
        color: colorScheme.primary.withValues(alpha: 0.14),
        child: doctorImage.isEmpty
            ? Icon(Icons.person_outline, color: colorScheme.primary)
            : isNetworkImage
                ? Image.network(
                    doctorImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.person_outline,
                          color: colorScheme.primary);
                    },
                  )
                : Image.asset(
                    doctorImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.person_outline,
                          color: colorScheme.primary);
                    },
                  ),
      ),
    );

    final nameWidget = Text(
      widget.article.doctor.name!,
      style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
    );

    final metaWidget = Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: SettingsStrings.specialtyLabel(
              widget.article.doctor.specialization,
            ),
            style: AppStyles.bodySmall.copyWith(
              color: colorScheme.outlineVariant,
            ),
          ),
          TextSpan(
            text: ' · ',
            style: AppStyles.bodySmall.copyWith(
              color: colorScheme.outlineVariant,
            ),
          ),
          TextSpan(
            text: formattedDate,
            style: AppStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );

    return Row(
      children: [
        if (widget.onDoctorTap != null)
          GestureDetector(onTap: widget.onDoctorTap, child: avatar)
        else
          avatar,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.onDoctorTap != null)
                GestureDetector(onTap: widget.onDoctorTap, child: nameWidget)
              else
                nameWidget,
              const SizedBox(height: 4),
              metaWidget,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArticleImage({
    required ColorScheme colorScheme,
    required String imageUrl,
  }) {
    final isNetworkImage = imageUrl.startsWith('http');

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppStyles.borderRadius),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          child: imageUrl.isNotEmpty
              ? (isNetworkImage
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image_outlined,
                          color: colorScheme.primary,
                        );
                      },
                    )
                  : Image.asset(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image_outlined,
                          color: colorScheme.primary,
                        );
                      },
                    ))
              : Icon(Icons.image_outlined, color: colorScheme.primary),
        ),
      ),
    );
  }
}
