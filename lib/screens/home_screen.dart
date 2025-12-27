import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';
import 'order_history_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductRepository _productRepo = ProductRepository();

  // Các biến quản lý bộ lọc
  String _searchQuery = "";
  String _selectedCategory = "All";
  final List<String> _categories = ["All", "Electronics", "Clothing", "Food", "Books", "Toys"];

  // 👇 THÊM 2 BIẾN NÀY ĐỂ LỌC GIÁ
  double? _minPrice;
  double? _maxPrice;

  // 👇 HÀM HIỆN HỘP THOẠI LỌC GIÁ
  void _showFilterDialog() {
    final minController = TextEditingController(text: _minPrice?.toString() ?? '');
    final maxController = TextEditingController(text: _maxPrice?.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Lọc theo giá"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: minController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Giá thấp nhất (\$)", prefixIcon: Icon(Icons.attach_money)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: maxController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Giá cao nhất (\$)", prefixIcon: Icon(Icons.attach_money)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Xóa bộ lọc giá
              setState(() {
                _minPrice = null;
                _maxPrice = null;
              });
              Navigator.pop(ctx);
            },
            child: const Text("Xóa lọc", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              // Áp dụng bộ lọc
              setState(() {
                _minPrice = double.tryParse(minController.text);
                _maxPrice = double.tryParse(maxController.text);
              });
              Navigator.pop(ctx);
            },
            child: const Text("Áp dụng"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shop - 2351060455"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryScreen())),
          ),
          Consumer<CartProvider>(
            builder: (_, cart, ch) => Badge(
              label: Text(cart.itemCount.toString()),
              child: IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Thanh tìm kiếm & Nút Lọc Giá
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "Tìm sản phẩm...",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: 10),
                // 👇 NÚT BẤM ĐỂ MỞ DIALOG LỌC GIÁ
                IconButton.filledTonal(
                  icon: Icon(Icons.filter_list,
                      color: (_minPrice != null || _maxPrice != null) ? Colors.blue : Colors.black
                  ),
                  onPressed: _showFilterDialog,
                ),
              ],
            ),
          ),

          // 2. Hiển thị thông tin đang lọc (User Experience)
          if (_minPrice != null || _maxPrice != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Text(
                    "Đang lọc giá: \$${_minPrice ?? 0} - \$${_maxPrice ?? '∞'}",
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() { _minPrice = null; _maxPrice = null; }),
                    child: const Text("Xóa lọc"),
                  )
                ],
              ),
            ),

          // 3. Bộ lọc Category (Danh mục)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: _categories.map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: _selectedCategory == cat,
                    onSelected: (bool selected) {
                      setState(() => _selectedCategory = cat);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // 4. Danh sách sản phẩm
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: _productRepo.getProductsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Lỗi tải dữ liệu"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var products = snapshot.data ?? [];

                // --- BẮT ĐẦU LOGIC LỌC (QUAN TRỌNG) ---

                // 1. Lọc theo Category
                if (_selectedCategory != "All") {
                  products = products.where((p) => p.category == _selectedCategory).toList();
                }

                // 2. Lọc theo Tên (Search)
                if (_searchQuery.isNotEmpty) {
                  products = products.where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
                }

                // 3. Lọc theo Giá (Min - Max)
                if (_minPrice != null) {
                  products = products.where((p) => p.price >= _minPrice!).toList();
                }
                if (_maxPrice != null) {
                  products = products.where((p) => p.price <= _maxPrice!).toList();
                }
                // ----------------------------------------

                if (products.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 50, color: Colors.grey),
                        Text("Không tìm thấy sản phẩm nào phù hợp"),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: products.length,
                  itemBuilder: (ctx, i) => _buildProductItem(products[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(ProductModel product) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
      child: Card(
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.grey[200],
                child: Image.network(product.imageUrl, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.image)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("\$${product.price}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  if (product.stock == 0)
                    const Text("Hết hàng", style: TextStyle(color: Colors.red, fontSize: 12)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}