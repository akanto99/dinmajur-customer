import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/circle_network_image/circle_network_image.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// ─────────────────────────────────────────────────────────
/// ✅ STATIC MODEL
/// ─────────────────────────────────────────────────────────
class StaticFreelancer {
  final String name;
  final String image;
  final String address;
  final List<String> skills;
  final int experience;
  final int salary;
  final String salaryType;
  final String phone;

  StaticFreelancer({
    required this.name,
    required this.image,
    required this.address,
    required this.skills,
    required this.experience,
    required this.salary,
    required this.salaryType,
    required this.phone,
  });
}

/// ✅ STATIC DATA
final staticFreelancer = StaticFreelancer(
  name: "Akanto",
  image: "",
  address: "Dhaka, Bangladesh",
  skills: ["Electrician", "AC Repair", "Wiring"],
  experience: 3,
  salary: 500,
  salaryType: "hour",
  phone: "01700000000",
);

class FreelancerProfileScreen extends StatelessWidget {
  const FreelancerProfileScreen({super.key});

  // ─── Helpers ─────────────────────────────────────────────
  String get _displayName => staticFreelancer.name;
  String get _workingAddress => staticFreelancer.address;

  int get _totalOrders => 120;
  int get _completed => 95;
  int get _cancelled => 12;
  int get _running => 8;
  int get _pending => 5;
  double get _completion => _totalOrders == 0 ? 0 : (_completed / _totalOrders) * 100;
  double get _avgRating => 4.2;
  int get _totalReviews => 52;

  // ─── Build ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, sw),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: sw * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHero(context),
                    SizedboxSpaccing.height02(context),
                    _divider(context),
                    SizedboxSpaccing.height02(context),
                    _buildSection(context, 'ORDER STATISTICS', _buildStatsGrid(context)),
                    SizedboxSpaccing.height02(context),
                    _buildSection(context, 'DETAILS', _buildDetails(context)),
                    SizedboxSpaccing.height02(context),
                    _buildSection(context, 'SKILLS', _buildSkills(context)),
                    SizedboxSpaccing.height02(context),
                    _buildSection(context, 'REVIEWS', _buildReviews(context)),
                    SizedboxSpaccing.height025(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── AppBar ───────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context, double sw) {
    return Container(
      height: 56,
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        border: Border(bottom: BorderSide(color: AppColors.border(context), width: 1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Icon(FontAwesomeIcons.arrowLeft, size: 13, color: AppColors.textPrimary(context)),
            ),
          ),
          SizedboxSpaccing.width03(context),
          Text('Freelancer Profile', style: AppTextStyles.textSize16(context, weight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ── Hero ────────────────────────────────────────────────
  Widget _buildHero(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatarNetwork(imageUrl: staticFreelancer.image.isEmpty ? null : staticFreelancer.image, name: _displayName, size: 68, borderWidth: 1, borderColor: AppColors.border(context)),
        SizedboxSpaccing.width03(context),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_displayName, style: AppTextStyles.textSize16(context, weight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(
                '${staticFreelancer.skills.join(' · ')} · $_workingAddress',
                style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  ...List.generate(
                    5,
                    (i) => Icon(i < _avgRating.floor() ? Icons.star_rounded : (i < _avgRating ? Icons.star_half_rounded : Icons.star_outline_rounded), size: 14, color: const Color(0xFFF59E0B)),
                  ),
                  const SizedBox(width: 4),
                  Text('${_avgRating.toStringAsFixed(1)} · $_totalReviews reviews', style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Stats ───────────────────────────────────────────────
  Widget _buildStatsGrid(BuildContext context) {
    final cells = [
      ('$_totalOrders', 'Total orders'),
      ('$_completed', 'Completed'),
      ('$_cancelled', 'Cancelled'),
      ('$_running', 'Running'),
      ('$_pending', 'Pending'),
      ('${_completion.toStringAsFixed(0)}%', 'Completion'),
    ];

    return Column(
      children: [
        Table(
          border: TableBorder(
            horizontalInside: BorderSide(color: AppColors.border(context), width: 0.5),
            verticalInside: BorderSide(color: AppColors.border(context), width: 0.5),
          ),
          children: [
            TableRow(children: [_statCell(context, cells[0].$1, cells[0].$2), _statCell(context, cells[1].$1, cells[1].$2), _statCell(context, cells[2].$1, cells[2].$2)]),
            TableRow(children: [_statCell(context, cells[3].$1, cells[3].$2), _statCell(context, cells[4].$1, cells[4].$2), _statCell(context, cells[5].$1, cells[5].$2)]),
          ],
        ),
        Divider(height: 1, color: AppColors.border(context)),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Completion rate', style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))),
                  Text('${_completion.toStringAsFixed(0)}%', style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(value: _completion / 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statCell(BuildContext context, String val, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Text(val, style: AppTextStyles.textSize20(context, weight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))),
        ],
      ),
    );
  }

  // ── Details ─────────────────────────────────────────────
  Widget _buildDetails(BuildContext context) {
    final rows = [
      {'icon': FontAwesomeIcons.locationDot, 'text': _workingAddress},
      {'icon': FontAwesomeIcons.clock, 'text': '${staticFreelancer.experience} years experience'},
      {'icon': FontAwesomeIcons.bangladeshiTakaSign, 'text': '${staticFreelancer.salary} / ${staticFreelancer.salaryType}'},
      {'icon': FontAwesomeIcons.phone, 'text': staticFreelancer.phone},
    ];

    return Column(
      children: rows.map((e) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Icon(e['icon'] as IconData, size: 13),
              const SizedBox(width: 10),
              Expanded(child: Text(e['text'] as String)),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Skills ──────────────────────────────────────────────
  Widget _buildSkills(BuildContext context) {
    final skills = staticFreelancer.skills;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: skills
            .map(
              (item) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: Text(item, style: AppTextStyles.textSize12(context)),
              ),
            )
            .toList(),
      ),
    );
  }

  // ── Reviews (UNCHANGED) ────────────────────────────────
  Widget _buildReviews(BuildContext context) {
    final reviews = [_Review(initials: 'MN', name: 'Nahid', time: '3:10 PM', stars: 4, comment: 'Great service!', service: 'Service')];

    return Column(
      children: reviews.map((r) {
        return ListTile(
          leading: CircleAvatar(child: Text(r.initials)),
          title: Text(r.name),
          subtitle: Text(r.comment),
        );
      }).toList(),
    );
  }

  // ── Section ────────────────────────────────────────────
  Widget _buildSection(BuildContext context, String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.containerBackground(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _divider(BuildContext context) => Divider(height: 1, color: AppColors.border(context));
}

class _Review {
  final String initials, name, time, comment, service;
  final int stars;

  const _Review({required this.initials, required this.name, required this.time, required this.stars, required this.comment, required this.service});
}
