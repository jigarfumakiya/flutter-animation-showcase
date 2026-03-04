import 'package:flutter/material.dart';
import 'package:flutter_animation_showcase/blinkit/product_detail_page.dart';

// ============================================================
// MODEL
// ============================================================

class BlinkitProduct {
  final String id;
  final String name;
  final String brand;
  final String imageUrl;
  final String quantity;
  final double price;
  final double? mrp;
  final double rating;
  final int ratingCount;
  final int deliveryMins;
  final int? discountPercent;
  final bool isLowStock;

  const BlinkitProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.quantity,
    required this.price,
    this.mrp,
    required this.rating,
    required this.ratingCount,
    required this.deliveryMins,
    this.discountPercent,
    this.isLowStock = false,
  });
}

// ============================================================
// DATA
// ============================================================

final kBlinkitProducts = <BlinkitProduct>[
  const BlinkitProduct(
    id: '1',
    name: 'Amul Vanilla Magic Ice Cream Tub',
    brand: 'Amul',
    imageUrl: 'https://picsum.photos/seed/icecream-amul/400/400',
    quantity: '1 ltr',
    price: 180,
    rating: 4.4,
    ratingCount: 64077,
    deliveryMins: 11,
  ),
  const BlinkitProduct(
    id: '2',
    name: 'The Dairy Factory by Kwality Walls Vanilla Ice Cream Tub',
    brand: 'Kwality Walls',
    imageUrl: 'https://picsum.photos/seed/icecream-kwality/400/400',
    quantity: '700 ml',
    price: 131,
    mrp: 145,
    rating: 4.4,
    ratingCount: 47360,
    deliveryMins: 11,
    discountPercent: 9,
    isLowStock: true,
  ),
  const BlinkitProduct(
    id: '3',
    name: 'Kwality Walls Choco Vanilla Frozen Dessert',
    brand: 'Kwality Walls',
    imageUrl: 'https://picsum.photos/seed/icecream-choco/400/400',
    quantity: '80 ml',
    price: 30,
    rating: 4.4,
    ratingCount: 24482,
    deliveryMins: 11,
  ),
  const BlinkitProduct(
    id: '4',
    name: 'Amul Gold Vanilla Magic Ice Cream Tub',
    brand: 'Amul',
    imageUrl: 'https://picsum.photos/seed/icecream-gold/400/400',
    quantity: '1 ltr',
    price: 210,
    rating: 4.3,
    ratingCount: 14053,
    deliveryMins: 11,
  ),
  const BlinkitProduct(
    id: '5',
    name: 'Cream Bell Vanilla Frozen Dessert Sandwich',
    brand: 'Cream Bell',
    imageUrl: 'https://picsum.photos/seed/icecream-creambell/400/400',
    quantity: '80 ml',
    price: 30,
    rating: 4.3,
    ratingCount: 34267,
    deliveryMins: 11,
  ),
  const BlinkitProduct(
    id: '6',
    name: 'Amul Vanilla Ice Cream Cup (No Added Sugar)',
    brand: 'Amul',
    imageUrl: 'https://picsum.photos/seed/icecream-cup/400/400',
    quantity: '2 x 125 ml',
    price: 69,
    mrp: 70,
    rating: 4.4,
    ratingCount: 411,
    deliveryMins: 11,
  ),
  const BlinkitProduct(
    id: '7',
    name: 'NIC Premium Vanilla Ice Cream',
    brand: 'NIC',
    imageUrl: 'https://picsum.photos/seed/icecream-nic/400/400',
    quantity: '500 ml',
    price: 249,
    rating: 4.5,
    ratingCount: 2341,
    deliveryMins: 11,
  ),
  const BlinkitProduct(
    id: '8',
    name: 'Mother Dairy Vanilla Frozen Dessert',
    brand: 'Mother Dairy',
    imageUrl: 'https://picsum.photos/seed/icecream-mother/400/400',
    quantity: '750 ml',
    price: 165,
    mrp: 180,
    rating: 4.1,
    ratingCount: 5678,
    deliveryMins: 11,
    discountPercent: 8,
  ),
  const BlinkitProduct(
    id: '9',
    name: 'Baskin Robbins Vanilla Flavour Ice Cream',
    brand: 'Baskin Robbins',
    imageUrl: 'https://picsum.photos/seed/icecream-baskin/400/400',
    quantity: '500 ml',
    price: 399,
    rating: 4.6,
    ratingCount: 9823,
    deliveryMins: 11,
  ),
];

// ============================================================
// PAGE
// ============================================================

class BlinkitPage extends StatelessWidget {
  const BlinkitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _ProductGrid(products: kBlinkitProducts),
      ),
    );
  }
}

// ============================================================
// PRODUCT GRID
// ============================================================

class _ProductGrid extends StatelessWidget {
  final List<BlinkitProduct> products;

  const _ProductGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    final secondaryAnim = ModalRoute.of(context)?.secondaryAnimation;
    final screenH = MediaQuery.of(context).size.height;

    final grid = GridView.builder(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.58,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _ProductCard(
          product: products[index],
          allProducts: products,
          index: index,
        );
      },
    );

    if (secondaryAnim == null) return grid;

    return AnimatedBuilder(
      animation: secondaryAnim,
      builder: (ctx, child) {
        // easeInCubic forward  = cards accelerate away upward
        // reversed naturally becomes easeOutCubic = cards decelerate settling back
        final t = Curves.easeInCubic.transform(secondaryAnim.value);
        return Transform.translate(
          offset: Offset(0, -screenH * t),
          child: child,
        );
      },
      child: grid,
    );
  }
}

// ============================================================
// PRODUCT CARD
// ============================================================

class _ProductCard extends StatelessWidget {
  final BlinkitProduct product;
  final List<BlinkitProduct> allProducts;
  final int index;

  const _ProductCard({
    required this.product,
    required this.allProducts,
    required this.index,
  });

  static const _kGreen = Color(0xFF0C831F);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _buildImage()),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 4, 6, 6),
              child: _buildInfo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      children: [
        Positioned.fill(
          child: Hero(
            tag: 'blinkit_product_${product.id}',
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade800,
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
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
            size: 18,
          ),
        ),
        if (product.discountPercent != null)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.shade700,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${product.discountPercent}% OFF',
                style: const TextStyle(
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _kGreen,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'ADD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                border: Border.all(color: _kGreen, width: 1),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Center(
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: _kGreen,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              product.quantity,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 10),
            const SizedBox(width: 2),
            Text(
              '${product.rating}',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 9),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: _kGreen,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 3),
            Text(
              '${product.deliveryMins} MINS',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 9),
            ),
          ],
        ),
        if (product.isLowStock) ...[
          const SizedBox(height: 2),
          const Text(
            'Only 3 left',
            style: TextStyle(color: Colors.red, fontSize: 9),
          ),
        ],
        const SizedBox(height: 2),
        Row(
          children: [
            Text(
              '₹${product.price.toInt()}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (product.mrp != null) ...[
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'MRP ₹${product.mrp!.toInt()}',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 9,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Colors.grey.shade500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ProductDetailPage(
          products: allProducts,
          initialIndex: index,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: const Interval(0.0, 0.5)),
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.18),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 380),
      ),
    );
  }
}
