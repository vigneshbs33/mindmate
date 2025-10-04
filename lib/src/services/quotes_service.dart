import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'dart:math';

class QuotesService {
  List<String> _quotes = const [];
  final Random _rng = Random();

  Future<void> init() async {
    final data = await rootBundle.loadString('assets/quotes.json');
    final list = (jsonDecode(data) as List).cast<String>();
    _quotes = list;
  }

  String randomQuote() {
    if (_quotes.isEmpty) return 'Be kind to your mind.';
    return _quotes[_rng.nextInt(_quotes.length)];
  }
}


