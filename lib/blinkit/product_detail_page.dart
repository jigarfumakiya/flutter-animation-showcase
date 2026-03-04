import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animation_showcase/blinkit/blinkit_page.dart';

// ============================================================
// PRODUCT DETAIL PAGE
// ============================================================

class ProductDetailPage extends StatefulWidget {
  final List<BlinkitProduct> products;
  final int initialIndex;

  const ProductDetailPage({
    super.key,
    required this.products,
    required this.initialIndex,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _expansionCtrl;
  late final PageController _pageCtrl;
  late int _currentPage;
  bool _isExpanded = false;

  static const double _kCornerRadius = 20.0;
  static const double _kBottomGap = 24.0;
  static const double _kViewportFraction = 0.88;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _expansionCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _pageCtrl = PageController(
      initialPage: widget.initialIndex,
      viewportFraction: _kViewportFraction,
    );
  }

  @override
  void dispose() {
    _expansionCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  // ---- Expand: remove the top gap, go full screen ----
  void _expand() {
    if (!_isExpanded) {
      setState(() => _isExpanded = true);
      _expansionCtrl.animateTo(
        1.0,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  // ---- Collapse back to partial, or dismiss if already partial ----
  void _collapseOrDismiss() {
    if (_isExpanded) {
      setState(() => _isExpanded = false);
      _expansionCtrl.animateTo(
        0.0,
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeOutBack,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Top gap = status bar height + breathing room
    final statusBarH = MediaQuery.of(context).padding.top;
    final partialGap = statusBarH + 46.0;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _expansionCtrl,
        builder: (ctx, _) {
          final t = _expansionCtrl.value;
          final topGap = partialGap * (1.0 - t);
          final bottomGap = _kBottomGap * (1.0 - t);
          final cornerR = _kCornerRadius * (1.0 - t);
          final topSafePadding = statusBarH * t;
          // Animate card width: 95% of screen (peek) → 100% (full screen)
          final cardWidth =
              screenWidth * (_kViewportFraction + (1 - _kViewportFraction) * t);

          return Stack(
            children: [
              Column(
                children: [
                  // Animated top gap — black space above the card
                  SizedBox(height: topGap),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageCtrl,
                      clipBehavior: Clip.none,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemCount: widget.products.length,
                      itemBuilder: (ctx, i) {
                        final isActive = i == _currentPage;
                        if (isActive) {
                          // Active card: expands from 95% → 100% of screen width
                          return OverflowBox(
                            maxWidth: screenWidth,
                            child: SizedBox(
                              width: cardWidth,
                              child: _ProductDetailCard(
                                key: ValueKey(widget.products[i].id),
                                product: widget.products[i],
                                useHero: i == widget.initialIndex,
                                cornerRadius: cornerR,
                                isExpanded: _isExpanded,
                                topSafePadding: topSafePadding,
                                onScrolledIntoContent: _expand,
                                onOverscrollDown: _collapseOrDismiss,
                              ),
                            ),
                          );
                        }
                        // Adjacent cards: inset 10px on each side so the
                        // gap between active card and peek is clearly visible.
                        // Fade to invisible as the active card goes full screen.
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Opacity(
                            opacity: (1.0 - t).clamp(0.0, 1.0),
                            child: _ProductDetailCard(
                              key: ValueKey(widget.products[i].id),
                              product: widget.products[i],
                              useHero: false,
                              cornerRadius: _kCornerRadius,
                              isExpanded: false,
                              topSafePadding: 0,
                              onScrolledIntoContent: () {},
                              onOverscrollDown: () {},
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Animated bottom gap — black space below the card
                  SizedBox(height: bottomGap),
                ],
              ),

              // Transparent overlay covering the black gap at the top.
              // Tapping or dragging down on it dismisses the card.
              if (topGap > 0)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: topGap,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(),
                    onVerticalDragUpdate: (d) {
                      if (d.delta.dy > 3) Navigator.of(context).pop();
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// SINGLE PRODUCT DETAIL CARD
// ============================================================

class _ProductDetailCard extends StatefulWidget {
  final BlinkitProduct product;
  final bool useHero;
  final double cornerRadius;
  final bool isExpanded;
  final double topSafePadding;
  final VoidCallback onScrolledIntoContent; // scroll down → expand
  final VoidCallback onOverscrollDown;       // pull down past top → collapse/dismiss

  const _ProductDetailCard({
    super.key,
    required this.product,
    required this.useHero,
    required this.cornerRadius,
    required this.isExpanded,
    required this.topSafePadding,
    required this.onScrolledIntoContent,
    required this.onOverscrollDown,
  });

  @override
  State<_ProductDetailCard> createState() => _ProductDetailCardState();
}

class _ProductDetailCardState extends State<_ProductDetailCard> {
  late final ScrollController _scrollCtrl;
  bool _overscrollHandled = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final px = _scrollCtrl.position.pixels;

    // Scroll DOWN into content → expand to full screen
    if (px > 8 && !widget.isExpanded) {
      widget.onScrolledIntoContent();
    }

    // Pull DOWN past the top (overscroll) → collapse if expanded, dismiss if partial
    if (px < -20 && !_overscrollHandled) {
      _overscrollHandled = true;
      widget.onOverscrollDown();
    }

    if (px > -15) _overscrollHandled = false;
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.cornerRadius;
    return AnimatedBuilder(
      animation: _scrollCtrl,
      builder: (ctx, child) {
        final px = _scrollCtrl.hasClients ? _scrollCtrl.position.pixels : 0.0;
        // Translate card down proportional to overscroll (dampened by 0.5)
        final dy = px < 0 ? (-px * 0.5).clamp(0.0, 260.0) : 0.0;
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollCtrl,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
            slivers: [
              SliverToBoxAdapter(child: _buildHeroImage(context)),
              SliverToBoxAdapter(child: _buildProductInfo()),
              SliverToBoxAdapter(child: _buildBrandSection()),
              SliverToBoxAdapter(child: _buildSimilarProducts()),
              SliverToBoxAdapter(child: _buildSimilarProducts()),
              SliverToBoxAdapter(child: _buildSimilarProducts()),
              SliverToBoxAdapter(child: _buildSimilarProducts()),
              // Space so content is not hidden behind the floating bottom bar
              const SliverToBoxAdapter(child: SizedBox(height: 90)),
            ],
          ),
          // Floating blur "Add to cart" bar pinned to the bottom of the card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBlurBottomBar(),
          ),
          // Top bar: back + actions, always pinned at top
          Positioned(top: 0, left: 0, right: 0, child: _buildTopBar(context)),
        ],
      ),
    ),
  );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: widget.topSafePadding),
      child: SizedBox(
        height: kToolbarHeight,
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 4),
          Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 22,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Spacer(),
          _TopActionButton(icon: Icons.favorite_border),
          _TopActionButton(icon: Icons.search),
          _TopActionButton(icon: Icons.ios_share),
          const SizedBox(width: 8),
        ],
      ),
    ),
  );
  }

  // ---- Hero image (full-width, top of scroll) ----

  Widget _buildHeroImage(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final imageChild = Image.network(
      widget.product.imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: screenH * 0.48,
      errorBuilder: (_, __, ___) => Container(
        height: screenH * 0.48,
        color: Colors.grey.shade800,
        child: const Icon(Icons.image, color: Colors.grey, size: 60),
      ),
    );
    if (!widget.useHero) return imageChild;
    return Hero(
      tag: 'blinkit_product_${widget.product.id}',
      child: imageChild,
    );
  }

  // ---- Image sliver (custom pinned header) ----

  Widget _buildImageSliver(BuildContext context) {
    final expandedHeight = MediaQuery.of(context).size.height * 0.43;
    return SliverPersistentHeader(
      pinned: false,
      delegate: _ImageHeaderDelegate(
        product: widget.product,
        useHero: widget.useHero,
        expandedHeight: expandedHeight,
      ),
    );
  }

  // ---- Loaded product info ----

  Widget _buildProductInfo() {
    return Container(
      color: Colors.grey.shade900,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Delivery + dots row
          Row(
            children: [
              _DeliveryBadge(mins: widget.product.deliveryMins),
              const Spacer(),
              ...List.generate(4, (i) {
                return Container(
                  width: i == 0 ? 14 : 6,
                  height: 6,
                  margin: const EdgeInsets.only(left: 3),
                  decoration: BoxDecoration(
                    color: i == 0 ? Colors.white : Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 12),

          // Product name
          Text(
            widget.product.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),

          if (widget.product.isLowStock) ...[
            const SizedBox(height: 4),
            const Text(
              'Only 3 left',
              style: TextStyle(
                color: Colors.red,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 8),

          Text(
            widget.product.quantity,
            style: TextStyle(color: Colors.grey.shade300, fontSize: 14),
          ),
          const SizedBox(height: 6),

          // Price row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '₹${widget.product.price.toInt()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.product.mrp != null) ...[
                const SizedBox(width: 8),
                Text(
                  'MRP ₹${widget.product.mrp!.toInt()}',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Colors.grey.shade500,
                  ),
                ),
                if (widget.product.discountPercent != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${widget.product.discountPercent}% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade800, height: 1),
          const SizedBox(height: 14),

          // View product details
          Row(
            children: [
              const Text(
                'View product details',
                style: TextStyle(
                  color: Color(0xFF0C831F),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF0C831F),
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---- Brand section ----

  Widget _buildBrandSection() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: Colors.grey.shade900,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey.shade700,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.store, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product.brand,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Explore all products',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  // ---- Similar products horizontal list ----

  Widget _buildSimilarProducts() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: Colors.grey.shade900,
      padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Text(
              'Similar products',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 188,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _SimilarProductCard(index: i),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Floating blur "Add to cart" bar ----

  Widget _buildBlurBottomBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade900.withValues(alpha: 0.6),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
                width: 0.5,
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.product.quantity,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                  Row(
                    children: [
                      Text(
                        '₹${widget.product.price.toInt()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.product.mrp != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          'MRP ₹${widget.product.mrp!.toInt()}',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.grey.shade500,
                          ),
                        ),
                      ],
                      if (widget.product.discountPercent != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          '${widget.product.discountPercent}% OFF',
                          style: const TextStyle(
                            color: Color(0xFF4FC3F7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    'Inclusive of all taxes',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C831F),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Add to cart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtCount(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(0)}k' : n.toString();
}

// ============================================================
// SIMILAR PRODUCT CARD
// ============================================================

class _SimilarProductCard extends StatelessWidget {
  final int index;

  const _SimilarProductCard({required this.index});

  static const _kGreen = Color(0xFF0C831F);
  static const _names = [
    'NIC Choco Vanilla',
    'Amul Gold Classic',
    'King Alphonso Tub',
    'Mango Delight Bar',
    'Strawberry Swirl',
  ];
  static const _prices = [249, 195, 210, 89, 120];
  static const _quantities = ['500 ml', '1 ltr', '1 ltr', '60 ml', '100 ml'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 124,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    child: Image.network(
                      'https://picsum.photos/seed/sim${index + 20}/200/200',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade700,
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(
                    Icons.favorite_border,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 16,
                  ),
                ),
                if (index == 0)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade700,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '8% OFF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _kGreen,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'ADD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: _kGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _quantities[index % _quantities.length],
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _names[index % _names.length],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                const SizedBox(height: 2),
                Text(
                  '₹${_prices[index % _prices.length]}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// IMAGE HEADER DELEGATE
// Image fills the entire header at every scroll offset.
// When collapsed to toolbar height the image shows as background.
// ============================================================

class _ImageHeaderDelegate extends SliverPersistentHeaderDelegate {
  final BlinkitProduct product;
  final bool useHero;
  final double expandedHeight;

  const _ImageHeaderDelegate({
    required this.product,
    required this.useHero,
    required this.expandedHeight,
  });

  @override
  double get minExtent => kToolbarHeight;

  @override
  double get maxExtent => expandedHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // 0 = fully expanded, 1 = fully collapsed
    final t = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    final imageWidget = Image.network(
      product.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey.shade800,
        child: const Icon(Icons.image, color: Colors.grey, size: 60),
      ),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        // Base dark background
        Container(color: Colors.grey.shade900),

        // Product image — fills the entire header at all scroll positions
        Positioned.fill(
          child: useHero
              ? Hero(tag: 'blinkit_product_${product.id}', child: imageWidget)
              : imageWidget,
        ),

        // Top gradient — darkens image behind buttons; gets stronger when collapsed
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.5 + 0.35 * t),
                Colors.transparent,
              ],
              stops: const [0.0, 0.65],
            ),
          ),
        ),

        // Bottom gradient — bleeds into content section (only when expanded)
        if (t < 0.95)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 64,
            child: Opacity(
              opacity: (1.0 - t).clamp(0.0, 1.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.grey.shade900, Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  bool shouldRebuild(_ImageHeaderDelegate old) =>
      product != old.product || useHero != old.useHero;
}

// ============================================================
// TOP ACTION BUTTON (heart, search, share)
// ============================================================

class _TopActionButton extends StatelessWidget {
  final IconData icon;

  const _TopActionButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 17),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
        onPressed: () {},
      ),
    );
  }
}

// ============================================================
// DELIVERY BADGE
// ============================================================

class _DeliveryBadge extends StatelessWidget {
  final int mins;

  const _DeliveryBadge({required this.mins});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.brightness_3, color: Colors.white70, size: 13),
          const SizedBox(width: 5),
          Text(
            '$mins MINS',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
