import 'package:flutter/material.dart';

class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Analytics', 'icon': Icons.insights, 'color': Colors.blue},
      {'name': 'Products', 'icon': Icons.inventory_2, 'color': Colors.orange},
      {'name': 'Finance', 'icon': Icons.account_balance_wallet, 'color': Colors.green},
      {'name': 'Marketing', 'icon': Icons.campaign, 'color': Colors.purple},
      {'name': 'Support', 'icon': Icons.headset_mic, 'color': Colors.teal},
      {'name': 'Settings', 'icon': Icons.tune, 'color': Colors.indigo},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Services'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search field
            TextField(
              decoration: InputDecoration(
                hintText: 'Search services, reports, items...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Categories',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            // Grid of categories
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final color = cat['color'] as Color;
                final icon = cat['icon'] as IconData;
                final name = cat['name'] as String;

                return InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Selected category: $name')),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: color.withValues(alpha: 0.2),
                          radius: 22,
                          child: Icon(icon, color: color, size: 24),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            Text(
              'Featured Items',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.star, color: Colors.amber),
                    title: const Text('Q3 Sales Summary'),
                    subtitle: const Text('Updated yesterday • 1.2 MB PDF'),
                    trailing: const Icon(Icons.download),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.trending_up, color: Colors.green),
                    title: const Text('Customer Growth Rate'),
                    subtitle: const Text('Live metrics • 24% increase'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () {},
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
