// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/yalo_sdk.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint(
      '${record.level.name}: ${record.time}: ${record.message} ${record.error ?? ''}',
    );
  });
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oris Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2207F1),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const HomeScreen(),
    );
  }
}

// ── Data model ──────────────────────────────────────────────────────────────

class Product {
  final String name;
  final String description;
  final String longDescription;
  final double price;
  final double? originalPrice;
  final IconData icon;
  final Color accentColor;
  final double rating;
  final int reviews;
  final List<String> features;
  final Map<String, String> specs;

  const Product({
    required this.name,
    required this.description,
    required this.longDescription,
    required this.price,
    this.originalPrice,
    required this.icon,
    required this.accentColor,
    required this.rating,
    required this.reviews,
    required this.features,
    required this.specs,
  });
}

const _products = [
  Product(
    name: 'Wireless Headphones',
    description: 'Active noise cancelling, 30h battery',
    longDescription:
        'Experience immersive sound with industry-leading active noise '
        'cancellation. These premium wireless headphones deliver rich, '
        'balanced audio with deep bass and crystal-clear highs. The '
        'lightweight, ergonomic design ensures all-day comfort, while '
        'the 30-hour battery life keeps the music going.',
    price: 79.99,
    originalPrice: 129.99,
    icon: Icons.headphones_rounded,
    accentColor: Color(0xFF6C5CE7),
    rating: 4.8,
    reviews: 1243,
    features: [
      'Active noise cancellation',
      '30-hour battery life',
      'Bluetooth 5.3',
      'Multipoint connection',
      'Built-in microphone',
    ],
    specs: {
      'Driver': '40mm dynamic',
      'Frequency': '20Hz – 20kHz',
      'Weight': '250g',
      'Charging': 'USB-C, 10min = 3h',
      'Codec': 'AAC, LDAC, SBC',
    },
  ),
  Product(
    name: 'Smart Watch',
    description: 'Heart rate, GPS, water resistant',
    longDescription:
        'Stay connected and track your health with this feature-packed '
        'smartwatch. Continuous heart rate monitoring, built-in GPS for '
        'outdoor workouts, and advanced sleep tracking help you understand '
        'your body better. The always-on AMOLED display is bright and '
        'readable even in direct sunlight.',
    price: 199.99,
    icon: Icons.watch_rounded,
    accentColor: Color(0xFF00B894),
    rating: 4.6,
    reviews: 876,
    features: [
      '1.4" AMOLED always-on display',
      'Heart rate & SpO2 monitoring',
      'Built-in GPS + GLONASS',
      '5 ATM water resistance',
      '7-day battery life',
    ],
    specs: {
      'Display': '1.4" AMOLED 454x454',
      'Sensors': 'HR, SpO2, Accel, Gyro',
      'Water': '5 ATM (50m)',
      'Battery': '7 days typical',
      'OS': 'Wear OS 4',
    },
  ),
  Product(
    name: 'Portable Speaker',
    description: '360° sound, IPX7 waterproof',
    longDescription:
        'Take the party anywhere with this rugged portable speaker. '
        'Delivering powerful 360-degree sound from a compact, cylindrical '
        'design, it fills any room — or outdoor space — with rich, detailed '
        'audio. The IPX7 waterproof rating means it can survive rain, '
        'splashes, and even a dunk in the pool.',
    price: 49.99,
    originalPrice: 69.99,
    icon: Icons.speaker_rounded,
    accentColor: Color(0xFFE17055),
    rating: 4.7,
    reviews: 2105,
    features: [
      '360° omnidirectional sound',
      'IPX7 waterproof',
      '12-hour playtime',
      'Stereo pairing support',
      'Built-in USB-C power bank',
    ],
    specs: {
      'Output': '20W RMS',
      'Drivers': '2x full-range + passive',
      'Bluetooth': '5.3, 30m range',
      'Battery': '5000mAh, 12h',
      'Weight': '540g',
    },
  ),
  Product(
    name: 'Mechanical Keyboard',
    description: 'RGB backlit, hot-swappable switches',
    longDescription:
        'Elevate your typing experience with this premium mechanical '
        'keyboard. Hot-swappable switches let you customize the feel '
        'without soldering, while per-key RGB backlighting creates '
        'stunning effects. The durable aluminum frame and PBT keycaps '
        'are built to last through millions of keystrokes.',
    price: 119.99,
    icon: Icons.keyboard_rounded,
    accentColor: Color(0xFF0984E3),
    rating: 4.9,
    reviews: 534,
    features: [
      'Hot-swappable mechanical switches',
      'Per-key RGB with 16M colors',
      'PBT double-shot keycaps',
      'Aluminum CNC frame',
      'USB-C + 2.4GHz wireless',
    ],
    specs: {
      'Layout': '75% (84 keys)',
      'Switches': 'Gateron Pro 3.0',
      'Keycaps': 'PBT double-shot',
      'Connection': 'USB-C / 2.4GHz / BT',
      'Battery': '4000mAh, 200h',
    },
  ),
];

// ── Home screen ─────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isChatOpen = false;
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleChat() {
    setState(() {
      _isChatOpen = !_isChatOpen;
    });
    if (_isChatOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _openProduct(BuildContext context, Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Oris Store',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
          IconButton(
            onPressed: () {},
            icon: Badge(
              label: const Text('2'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          _buildStoreContent(context, theme, colorScheme),
          if (_isChatOpen) _buildChatOverlay(context, theme),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleChat,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Icon(
            _isChatOpen ? Icons.close : Icons.chat_rounded,
            key: ValueKey(_isChatOpen),
          ),
        ),
      ),
    );
  }

  // ── Store content ───────────────────────────────────────────────────────

  Widget _buildStoreContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 88),
      children: [
        _buildHeroBanner(theme, colorScheme),
        const SizedBox(height: 24),
        _buildCategoryRow(colorScheme),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Products',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('See all')),
            ],
          ),
        ),
        const SizedBox(height: 4),
        _buildProductGrid(context, theme, colorScheme),
        const SizedBox(height: 24),
        _buildPromoBanner(theme, colorScheme),
      ],
    );
  }

  Widget _buildHeroBanner(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'NEW ARRIVALS',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Summer\nCollection',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Up to 40% off',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Shop Now'),
                ),
              ],
            ),
          ),
          Icon(
            Icons.shopping_bag_rounded,
            size: 80,
            color: Colors.white.withValues(alpha: 0.25),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(ColorScheme colorScheme) {
    const categories = [
      (Icons.devices_rounded, 'All'),
      (Icons.headphones_rounded, 'Audio'),
      (Icons.watch_rounded, 'Wearables'),
      (Icons.keyboard_rounded, 'Accessories'),
      (Icons.phone_iphone_rounded, 'Phones'),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final (icon, label) = categories[index];
          final isSelected = index == 0;
          return FilterChip(
            selected: isSelected,
            label: Text(label),
            avatar: Icon(icon, size: 18),
            onSelected: (_) {},
            showCheckmark: false,
            selectedColor: colorScheme.primaryContainer,
            backgroundColor: colorScheme.surfaceContainerLow,
            side: BorderSide.none,
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return _ProductCard(
          product: product,
          onTap: () => _openProduct(context, product),
        );
      },
    );
  }

  Widget _buildPromoBanner(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.support_agent_rounded,
            size: 36,
            color: colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need help choosing?',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Chat with our assistant for personalized recommendations.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSecondaryContainer.withValues(
                      alpha: 0.75,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Chat overlay ────────────────────────────────────────────────────────

  Widget _buildChatOverlay(BuildContext context, ThemeData theme) {
    final screenWidth = MediaQuery.of(context).size.width;
    final chatWidth = screenWidth * 0.5;

    final YaloChatClient client = YaloChatClient(
      name: 'Chat test',
      flowKey: '',
      userToken: '',
      authToken: '',
    );

    client.registerAction('test-action', () {
      final product = _products[0];
      _openProduct(context, product);
    });

    return Positioned(
      right: 16,
      width: chatWidth,
      top: 8,
      bottom: 80,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          alignment: Alignment.bottomRight,
          child: Material(
            elevation: 8,
            shadowColor: Colors.black26,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: Chat(
              client: client,
              theme: ChatTheme.fromThemeData(
                theme,
                ChatTheme(
                  chatIconImage: const AssetImage(
                    'assets/images/oris-icon.png',
                  ),
                ),
              ),
              onShopPressed: () {},
              onCartPressed: () {},
            ),
          ),
        ),
      ),
    );
  }
}

// ── Product card ────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasDiscount = product.originalPrice != null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image placeholder
            Expanded(
              child: Hero(
                tag: 'product-${product.name}',
                child: Container(
                  width: double.infinity,
                  color: product.accentColor.withValues(alpha: 0.08),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          product.icon,
                          size: 56,
                          color: product.accentColor.withValues(alpha: 0.6),
                        ),
                      ),
                      if (hasDiscount)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.error,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '-${((1 - product.price / product.originalPrice!) * 100).round()}%',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onError,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.favorite_border_rounded,
                            size: 18,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Product info
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: Colors.amber.shade700,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${product.rating}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ' (${product.reviews})',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          '\$${product.originalPrice!.toStringAsFixed(2)}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Product detail screen ───────────────────────────────────────────────────

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasDiscount = product.originalPrice != null;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // ── Collapsing image header ──
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: colorScheme.surface,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: colorScheme.surface,
                  child: IconButton(
                    icon: const Icon(Icons.favorite_border_rounded),
                    onPressed: () {},
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                child: CircleAvatar(
                  backgroundColor: colorScheme.surface,
                  child: IconButton(
                    icon: const Icon(Icons.share_rounded),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product-${product.name}',
                child: Container(
                  color: product.accentColor.withValues(alpha: 0.08),
                  child: Center(
                    child: Icon(
                      product.icon,
                      size: 120,
                      color: product.accentColor.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Body content ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Discount badge
                  if (hasDiscount)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${((1 - product.price / product.originalPrice!) * 100).round()}% OFF',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  // Name
                  Text(
                    product.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Rating row
                  Row(
                    children: [
                      ...List.generate(5, (i) {
                        final filled = i < product.rating.floor();
                        final half =
                            !filled &&
                            i < product.rating.ceil() &&
                            product.rating % 1 >= 0.5;
                        return Icon(
                          half
                              ? Icons.star_half_rounded
                              : (filled
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded),
                          size: 20,
                          color: Colors.amber.shade700,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        '${product.rating}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.reviews} reviews)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '\$${product.originalPrice!.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.longDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Features
                  Text(
                    'Features',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...product.features.map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: product.accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: product.accentColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(f, style: theme.textTheme.bodyMedium),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Specs table
                  Text(
                    'Specifications',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        for (
                          var i = 0;
                          i < product.specs.entries.length;
                          i++
                        ) ...[
                          if (i > 0)
                            Divider(
                              height: 1,
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    product.specs.keys.elementAt(i),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    product.specs.values.elementAt(i),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Bottom spacing for the button bar
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom action bar ──
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Price column
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total price',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              // Add to cart button
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} added to cart'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.shopping_cart_rounded, size: 20),
                label: const Text(
                  'Add to Cart',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
