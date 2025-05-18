import 'package:flutter/material.dart';
import '../../models/tip.dart';
import '../../data/tips_data.dart';
import 'tip_detail_screen.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  String _selectedCategory = 'Sexualidad';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filtered =
        tipsList.where((tip) {
          final matchesCategory = tip.category == _selectedCategory;
          final matchesSearch = tip.title.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
          return matchesCategory && matchesSearch;
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Consejos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.pink[50],
        foregroundColor: Colors.pink[800],
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Barra de búsqueda
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar consejos...',
                    hintStyle: TextStyle(color: Colors.pink[300]),
                    prefixIcon: Icon(Icons.search, color: Colors.pink[400]),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.pink[100]!,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.pink[300]!,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: TextStyle(color: Colors.pink[800]),
                ),
                const SizedBox(height: 16),

                // Filtros de categoría (horizontal scrollable para responsive)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        ['Sexualidad', 'Salud Mental', 'Salud Íntima'].map((
                          cat,
                        ) {
                          final isSelected = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: ElevatedButton(
                                onPressed:
                                    () =>
                                        setState(() => _selectedCategory = cat),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isSelected ? Colors.pink : Colors.white,
                                  elevation: isSelected ? 5 : 1,
                                  shadowColor:
                                      isSelected
                                          ? Colors.pink[300]
                                          : Colors.grey[300],
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side: BorderSide(
                                      color:
                                          isSelected
                                              ? Colors.pink
                                              : Colors.pink[100]!,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.pink[700],
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // Título de resultados
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Resultados: ${filtered.length}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.pink[800],
                        ),
                      ),
                      Icon(Icons.tune, color: Colors.pink[400], size: 20),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Lista de cards
                Expanded(
                  child:
                      filtered.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 48,
                                  color: Colors.pink[200],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No se encontraron consejos',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final tip = filtered[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  color: Colors.white,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap:
                                        () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) =>
                                                    TipDetailScreen(tip: tip),
                                          ),
                                        ),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        // Para hacerlo responsive
                                        final isSmallScreen =
                                            constraints.maxWidth < 300;

                                        return Row(
                                          children: [
                                            Hero(
                                              tag: 'tip_image_${tip.title}',
                                              child: ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.horizontal(
                                                      left: Radius.circular(20),
                                                    ),
                                                child: Image.asset(
                                                  tip.imageUrl,
                                                  width:
                                                      isSmallScreen ? 80 : 110,
                                                  height: 110,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                  isSmallScreen ? 8.0 : 16.0,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      tip.title,
                                                      style: TextStyle(
                                                        fontSize:
                                                            isSmallScreen
                                                                ? 14
                                                                : 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.pink[800],
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      tip.category,
                                                      style: TextStyle(
                                                        fontSize:
                                                            isSmallScreen
                                                                ? 12
                                                                : 13,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: CircleAvatar(
                                                backgroundColor:
                                                    Colors.pink[50],
                                                radius: 16,
                                                child: Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 12,
                                                  color: Colors.pink[400],
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
