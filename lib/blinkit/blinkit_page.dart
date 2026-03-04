import 'package:flutter/material.dart';
import 'package:flutter_animation_showcase/blinkit/blinkit_product.dart';
import 'package:flutter_animation_showcase/blinkit/product_detail_page.dart';


class BlinkitPage extends StatefulWidget {
  const BlinkitPage({super.key});

  @override
  State<BlinkitPage> createState() => _BlinkitPageState();
}

class _BlinkitPageState extends State<BlinkitPage> {
  late final Future<List<BlinkitProduct>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = BlinkitProductRepository.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: FutureBuilder<List<BlinkitProduct>>(
          future: _productsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF0C831F)),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to load products',
                  style: TextStyle(color: Colors.grey.shade400),
                ),
              );
            }
            return _ProductGrid(products: snapshot.data!);
          },
        ),
      ),
    );
  }
}


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

    // RepaintBoundary lets the compositor move the grid layer without repainting
    // every card on each frame of the secondary animation.
    return AnimatedBuilder(
      animation: secondaryAnim,
      builder: (ctx, child) {
        final t = Curves.easeInCubic.transform(secondaryAnim.value);
        return Transform.translate(
          offset: Offset(0, -screenH * t),
          child: child,
        );
      },
      child: RepaintBoundary(child: grid),
    );
  }
}

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
    precacheImage(NetworkImage(product.imageUrl), context);
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
          final page = RepaintBoundary(child: child);
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.5),
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.10),
                end: Offset.zero,
              ).animate(curved),
              child: page,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 420),
      ),
    );
  }
}
