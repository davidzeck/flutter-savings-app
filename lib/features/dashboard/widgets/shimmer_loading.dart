import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Shimmer loading placeholder for the dashboard
///
/// Shows skeleton cards while data is being loaded.
class DashboardShimmerLoading extends StatefulWidget {
  const DashboardShimmerLoading({super.key});

  @override
  State<DashboardShimmerLoading> createState() =>
      _DashboardShimmerLoadingState();
}

class _DashboardShimmerLoadingState extends State<DashboardShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          children: [
            // Stats shimmer row
            _buildStatsShimmer(),
            const SizedBox(height: AppDimensions.md),

            // Card shimmer list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingScreen,
                ),
                itemCount: 4,
                itemBuilder: (context, index) => _buildCardShimmer(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsShimmer() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingScreen,
        ),
        itemCount: 5,
        itemBuilder: (context, index) => Container(
          width: 120,
          margin: const EdgeInsets.only(right: AppDimensions.sm),
          decoration: BoxDecoration(
            color: AppColors.shimmerBase,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            gradient: _buildShimmerGradient(),
          ),
        ),
      ),
    );
  }

  Widget _buildCardShimmer() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      padding: const EdgeInsets.all(AppDimensions.paddingCard),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row placeholders
          Row(
            children: [
              _shimmerBox(width: 70, height: 20),
              const SizedBox(width: AppDimensions.sm),
              _shimmerBox(width: 60, height: 20),
              const Spacer(),
              _shimmerBox(width: 70, height: 20),
            ],
          ),
          const SizedBox(height: AppDimensions.md),

          // Title placeholder
          _shimmerBox(width: double.infinity, height: 18),
          const SizedBox(height: AppDimensions.sm),

          // Description placeholder
          _shimmerBox(width: double.infinity, height: 14),
          const SizedBox(height: AppDimensions.xs),
          _shimmerBox(width: 200, height: 14),
          const SizedBox(height: AppDimensions.md),

          // Progress bar placeholder
          _shimmerBox(width: double.infinity, height: 6),
          const SizedBox(height: AppDimensions.sm),

          // Bottom row placeholders
          Row(
            children: [
              _shimmerBox(width: 100, height: 14),
              const Spacer(),
              _shimmerBox(width: 80, height: 14),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        gradient: _buildShimmerGradient(),
      ),
    );
  }

  LinearGradient _buildShimmerGradient() {
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: const [
        AppColors.shimmerBase,
        AppColors.shimmerHighlight,
        AppColors.shimmerBase,
      ],
      stops: [
        _animation.value - 0.3,
        _animation.value,
        _animation.value + 0.3,
      ].map((s) => s.clamp(0.0, 1.0)).toList(),
    );
  }
}
