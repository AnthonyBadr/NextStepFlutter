import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPrefsDebugScreen extends StatefulWidget {
  const SharedPrefsDebugScreen({super.key});

  @override
  State<SharedPrefsDebugScreen> createState() => _SharedPrefsDebugScreenState();
}

class _SharedPrefsDebugScreenState extends State<SharedPrefsDebugScreen> {
  Map<String, dynamic> _prefsData = {};
  Map<String, dynamic> _filteredData = {};
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterData(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredData = Map.from(_prefsData);
      } else {
        _filteredData = Map.fromEntries(
          _prefsData.entries.where((entry) => 
            entry.key.toLowerCase().contains(query.toLowerCase()) ||
            entry.value.toString().toLowerCase().contains(query.toLowerCase())
          ),
        );
      }
    });
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    setState(() {
      _prefsData = {
        for (String key in keys) 
          key: prefs.get(key)
      };
      _filteredData = Map.from(_prefsData);
      _isLoading = false;
    });
  }

  Future<void> _clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _loadPrefs();
  }

  Future<void> _removeItem(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    await _loadPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SharedPreferences Debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPrefs,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearAll,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Search by key or value',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterData('');
                        },
                      )
                    : null,
              ),
              onChanged: _filterData,
            ),
          ),
          
          // Data List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredData.isEmpty
                    ? const Center(
                        child: Text(
                          'No matching data found',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredData.length,
                        itemBuilder: (context, index) {
                          final key = _filteredData.keys.elementAt(index);
                          final value = _filteredData[key];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ListTile(
                              title: Text(
                                key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                value is String && value.startsWith('{')
                                    ? const JsonEncoder.withIndent('  ').convert(
                                        jsonDecode(value)
                                      )
                                    : value.toString(),
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _removeItem(key),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}