import 'dart:async';
import 'dart:convert';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GooglePlaceSearchResult {
  final String fullAddress;
  final String city;
  final String country;
  final double latitude;
  final double longitude;

  const GooglePlaceSearchResult({required this.fullAddress, required this.city, required this.country, required this.latitude, required this.longitude});

  Map<String, dynamic> toLocationData() {
    return {
      "fullAddress": fullAddress,
      "country": country,
      "city": city,
      "geoLocation": {
        "type": "Point",
        "coordinates": [longitude, latitude],
        "timestamp": DateTime.now().toUtc().toIso8601String(),
      },
    };
  }
}

class _Prediction {
  final String description;
  final String placeId;
  final String mainText;
  final String secondaryText;

  const _Prediction({required this.description, required this.placeId, required this.mainText, required this.secondaryText});

  factory _Prediction.fromJson(Map<String, dynamic> j) => _Prediction(
    description: j['description'] ?? '',
    placeId: j['place_id'] ?? '',
    mainText: j['structured_formatting']?['main_text'] ?? '',
    secondaryText: j['structured_formatting']?['secondary_text'] ?? '',
  );
}

class GooglePlaceSearchTextField extends StatefulWidget {
  final String placeholder;
  final TextEditingController controller;
  final void Function(GooglePlaceSearchResult) onPlaceSelected;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Color? borderColor;
  final TextStyle? inputTextStyle;
  final TextStyle? hintTextStyle;
  final List<String> countries;

  const GooglePlaceSearchTextField({
    Key? key,
    required this.placeholder,
    required this.controller,
    required this.onPlaceSelected,
    this.height,
    this.width,
    this.backgroundColor,
    this.borderColor,
    this.inputTextStyle,
    this.hintTextStyle,
    this.countries = const ['bd'],
  }) : super(key: key);

  @override
  State<GooglePlaceSearchTextField> createState() => _GooglePlaceSearchTextFieldState();
}

class _GooglePlaceSearchTextFieldState extends State<GooglePlaceSearchTextField> {
  List<_Prediction> _predictions = [];
  Timer? _debounce;
  bool _isPlaceSelected = false;
  String _lastSelectedText = '';
  bool _showSuggestions = false;
  bool _isUserInput = false;

  String get _apiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  final Map<String, bool> _serviceabilityCache = {};


  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _debounce?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    if (!_isUserInput) return;
    _isUserInput = false;

    if (_isPlaceSelected && widget.controller.text == _lastSelectedText) return;
    if (widget.controller.text != _lastSelectedText) _isPlaceSelected = false;

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (widget.controller.text.isNotEmpty && !_isPlaceSelected) {
        _fetchPredictions(widget.controller.text);
      } else {
        setState(() => _showSuggestions = false);
      }
    });
  }

  Future<void> _fetchPredictions(String query) async {
    if (query.isEmpty || _isPlaceSelected) return;
    try {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(query)}'
        '&components=country:${widget.countries.join('|country:')}'
        '&key=$_apiKey',
      );
      final res = await http.get(uri);
      if (!mounted) return;
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['status'] == 'OK') {
          final list = (data['predictions'] as List).map((p) => _Prediction.fromJson(p)).toList();
          setState(() {
            _predictions = list;
            _showSuggestions = list.isNotEmpty && !_isPlaceSelected;
          });
          return;
        }
      }
    } catch (e) {
    }
    if (mounted) setState(() => _showSuggestions = false);
  }

  bool _isPredictionServiceable(_Prediction prediction) {
    final text = prediction.description.toLowerCase();
    const serviceableKeywords = ['chittagong', 'chattogram', 'chottogram', 'chattagam', 'ctg', 'চট্টগ্রাম', 'চিটাগাং', 'dhaka', 'ঢাকা'];
    return serviceableKeywords.any((kw) => text.contains(kw));
  }


  Future<bool> _isPredictionServiceableAsync(_Prediction prediction) async {
    // Return cached result if available
    if (_serviceabilityCache.containsKey(prediction.placeId)) {
      return _serviceabilityCache[prediction.placeId]!;
    }

    try {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
            '?place_id=${prediction.placeId}'
            '&fields=address_components'
            '&key=$_apiKey',
      );
      final res = await http.get(uri);
      if (res.statusCode != 200) return false;

      final data = json.decode(res.body);
      if (data['status'] != 'OK') return false;

      final components = data['result']['address_components'] as List<dynamic>;

      String level2 = '';
      String level1 = '';

      for (final c in components) {
        final types = List<String>.from(c['types'] as List);
        final name = (c['long_name'] as String? ?? '').toLowerCase().trim();

        if (types.contains('administrative_area_level_2') && level2.isEmpty) {
          level2 = name;
        }
        if (types.contains('administrative_area_level_1') && level1.isEmpty) {
          level1 = name;
        }
      }


      const serviceableKeywords = [
        'chittagong', 'chattogram', 'chottogram', 'chattagam', 'ctg',
        'চট্টগ্রাম', 'চিটাগাং',
        'dhaka', 'ঢাকা',
      ];

      // ✅ Check administrative_area_level_2 first, then level_1 as fallback
      final checkText = level2.isNotEmpty ? level2 : level1;
      final result = serviceableKeywords.any((kw) => checkText.contains(kw));


      _serviceabilityCache[prediction.placeId] = result;
      return result;

    } catch (e) {
      return false;
    }
  }

  Future<void> _onPredictionTapped(_Prediction prediction) async {
    final isServiceable = await _isPredictionServiceableAsync(prediction);

    if (!isServiceable) {
      if (mounted) {
        Utils.flushBarErrorMessage("Service is not available in this area", context);
      }
      return;
    }

    _isPlaceSelected = true;
    _lastSelectedText = prediction.description;
    widget.controller.text = prediction.description;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: prediction.description.length),
    );
    setState(() => _showSuggestions = false);
    FocusScope.of(context).unfocus();
    await _fetchPlaceDetails(prediction.placeId, prediction.description);
  }

  Future<void> _fetchPlaceDetails(String placeId, String predictionDescription) async {
    try {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&fields=geometry,formatted_address,address_components'
        '&key=$_apiKey',
      );
      final res = await http.get(uri);
      if (!mounted || res.statusCode != 200) return;

      final data = json.decode(res.body);
      if (data['status'] != 'OK') return;

      final result = data['result'];
      final loc = result['geometry']['location'];
      final double lat = (loc['lat'] as num).toDouble();
      final double lng = (loc['lng'] as num).toDouble();

      // ✅ Use prediction description as fullAddress (human-friendly name)
      //    NOT formatted_address (which gives street/postal address like
      //    "4 Zakir Hossain Road..." instead of "Khulshi Town Center...")
      //    formatted_address is only used to extract city/country components
      final components = result['address_components'] as List<dynamic>;

      String level2 = '';
      String level1 = '';
      String country = '';

      for (final c in components) {
        final types = List<String>.from(c['types'] as List);
        final name = c['long_name'] as String? ?? '';
        if (types.contains('administrative_area_level_2') && level2.isEmpty) {
          level2 = _normalizeCity(_stripSuffix(name));
        }
        if (types.contains('administrative_area_level_1') && level1.isEmpty) {
          level1 = _normalizeCity(_stripSuffix(name));
        }
        if (types.contains('country') && country.isEmpty) {
          country = name;
        }
      }

      final String city = level2.isNotEmpty ? level2 : level1;

      // ✅ Controller already shows predictionDescription (set in _onPredictionTapped)
      //    No need to update it again — just keep it as is
      widget.onPlaceSelected(
        GooglePlaceSearchResult(
          fullAddress: predictionDescription, // ✅ human-friendly description
          city: city,
          country: country,
          latitude: lat,
          longitude: lng,
        ),
      );
    } catch (e) {
    }
  }

  String _stripSuffix(String raw) => raw.replaceAll(RegExp(r'\s*(District|Division|Zila|Upazila|Sadar|জেলা|বিভাগ|উপজেলা|সদর)\s*$', caseSensitive: false), '').trim();

  String _normalizeCity(String city) {
    const variants = {'chittagong', 'chattogram', 'chottogram', 'chattagam', 'চট্টগ্রাম', 'চট্টগ্রাম জেলা', 'চট্টগ্রাম বিভাগ'};
    if (variants.contains(city.toLowerCase().trim())) return 'Chittagong';
    return city;
  }

  @override
  Widget build(BuildContext context) {
    final double actualHeight = widget.height ?? 50;
    final double actualWidth = widget.width ?? MediaQuery.of(context).size.width * 0.9;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Search field ──────────────────────────────────────────────
        Container(
          height: actualHeight,
          width: actualWidth,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? AppColors.containerBackground(context),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(width: 1, color: widget.borderColor ?? AppColors.border(context)),
          ),
          child: TextFormField(
            controller: widget.controller,
            keyboardType: TextInputType.streetAddress,
            style: widget.inputTextStyle ?? AppTextStyles.textSize14(context, weight: FontWeight.w400),
            onChanged: (_) => _isUserInput = true,
            onTap: () {
              if (widget.controller.text.isNotEmpty && !_isPlaceSelected) {
                _isUserInput = true;
                _fetchPredictions(widget.controller.text);
              }
            },
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: widget.hintTextStyle ?? AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
              border: const OutlineInputBorder(borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            ),
          ),
        ),

        // ── Suggestions dropdown ──────────────────────────────────────
        if (_showSuggestions && _predictions.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 220),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: AppColors.containerBackground(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(width: 1, color: AppColors.border(context)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _predictions.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.border(context)),
                itemBuilder: (context, i) {
                  final p = _predictions[i];

                  return FutureBuilder<bool>(
                    future: _isPredictionServiceableAsync(p),
                    initialData: true, // show as available while loading
                    builder: (context, snapshot) {
                      final bool serviceable = snapshot.data ?? true;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _onPredictionTapped(p),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: serviceable
                                      ? AppColors.button(context)
                                      : AppColors.subtitle(context),
                                  size: 18,
                                ),
                                SizedboxSpaccing.width03(context),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              p.mainText,
                                              style: AppTextStyles.textSize14(
                                                context,
                                                weight: FontWeight.w500,
                                                color: serviceable
                                                    ? AppColors.textPrimary(context)
                                                    : AppColors.subtitle(context),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (!serviceable)
                                            Container(
                                              margin: const EdgeInsets.only(left: 6),
                                              padding: const EdgeInsets.symmetric(horizontal: 6),
                                              child: Text(
                                                'Not Available',
                                                style: AppTextStyles.textSize10(
                                                  context,
                                                  color: Colors.orange,
                                                  weight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      if (p.secondaryText.isNotEmpty)
                                        Text(
                                          p.secondaryText,
                                          style: AppTextStyles.textSize12(
                                            context,
                                            weight: FontWeight.w400,
                                            color: AppColors.subtitle(context),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
