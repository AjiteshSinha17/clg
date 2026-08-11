import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/theme.dart';
import '../../state/theme_provider.dart';

class HackathonEvent {
  final String id;
  final String title;
  final String organizer;
  final String state;
  final String mode;
  final String status;
  final String startDate;
  final String endDate;
  final String regDeadline;
  final String prizePool;
  final String themeTopic;
  final List<String> tags;
  final String location;
  final String teamSize;
  final String contactEmail;
  final String contactPhone;
  final String websiteUrl;
  final String description;

  const HackathonEvent({
    required this.id,
    required this.title,
    required this.organizer,
    required this.state,
    required this.mode,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.regDeadline,
    required this.prizePool,
    required this.themeTopic,
    required this.tags,
    required this.location,
    required this.teamSize,
    required this.contactEmail,
    required this.contactPhone,
    required this.websiteUrl,
    required this.description,
  });
}

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  String _selectedStatus = 'ALL';
  String _selectedState = 'All India';

  static const List<String> _indianStates = [
    'All India',
    'Maharashtra',
    'Karnataka',
    'Delhi NCR',
    'Tamil Nadu',
    'Telangana',
    'West Bengal',
    'Uttar Pradesh',
    'Remote / Online',
  ];

  static const List<HackathonEvent> _sampleEvents = [
    HackathonEvent(
      id: 'h1',
      title: 'Smart India Hackathon 2026',
      organizer: 'Ministry of Education & AICTE',
      state: 'Delhi NCR',
      mode: 'In-Person & Online',
      status: 'UPCOMING',
      startDate: 'Aug 25, 2026 - 09:00 AM',
      endDate: 'Aug 27, 2026 - 06:00 PM',
      regDeadline: 'Aug 18, 2026',
      prizePool: '₹1,50,00,000',
      themeTopic: 'Smart Governance, AgriTech & Clean Energy',
      tags: ['#Government', '#AgriTech', '#SmartCities'],
      location: 'New Delhi / Pan-India Nodal Centers',
      teamSize: '6 Members (1 Female mandatory)',
      contactEmail: 'sih2026@gov.in',
      contactPhone: '+91 11 2958 1000',
      websiteUrl: 'https://sih.gov.in',
      description:
          'World’s largest open innovation model nationwide initiative to provide students a platform to solve pressing problems of everyday life.',
    ),
    HackathonEvent(
      id: 'h2',
      title: 'Bengaluru AI Innovation Sprint',
      organizer: 'NASSCOM & Karnataka Innovation Council',
      state: 'Karnataka',
      mode: 'In-Person',
      status: 'ONGOING',
      startDate: 'Aug 10, 2026 - 10:00 AM',
      endDate: 'Aug 13, 2026 - 08:00 PM',
      regDeadline: 'Aug 08, 2026',
      prizePool: '₹5,00,000 + Incubation Support',
      themeTopic: 'Generative AI & Autonomous Agent Workflows',
      tags: ['#AI/ML', '#GenAI', '#StartupSupport'],
      location: 'KTech Innovation Hub, Electronic City, Bengaluru',
      teamSize: '2 - 4 Members',
      contactEmail: 'connect@karnatakaai.org',
      contactPhone: '+91 80 2345 6789',
      websiteUrl: 'https://karnatakatech.gov.in',
      description:
          'Build next-gen LLM agents and web apps targeting public healthcare and urban transit challenges in Karnataka state.',
    ),
    HackathonEvent(
      id: 'h3',
      title: 'MH-Hackathon 2026 Tech Summit',
      organizer: 'Government of Maharashtra & IIT Bombay',
      state: 'Maharashtra',
      mode: 'In-Person',
      status: 'UPCOMING',
      startDate: 'Sep 02, 2026 - 09:30 AM',
      endDate: 'Sep 04, 2026 - 05:00 PM',
      regDeadline: 'Aug 28, 2026',
      prizePool: '₹10,00,000',
      themeTopic: 'FinTech, Cyber Security & Smart Supply Chains',
      tags: ['#FinTech', '#CyberSecurity', '#IITBombay'],
      location: 'Victor Menezes Convention Centre, IIT Bombay, Mumbai',
      teamSize: '3 - 5 Members',
      contactEmail: 'hackathon@iitb.ac.in',
      contactPhone: '+91 22 2576 7000',
      websiteUrl: 'https://iitb.ac.in',
      description:
          '48-hour continuous hackathon targeting financial inclusion, blockchain verification, and cyber resilience for Maharashtra SMEs.',
    ),
    HackathonEvent(
      id: 'h4',
      title: 'DevFest India Cloud & Web3 Hackathon',
      organizer: 'Google Developer Student Clubs India',
      state: 'Remote / Online',
      mode: 'Remote / Online',
      status: 'ONGOING',
      startDate: 'Aug 05, 2026 - 12:00 PM',
      endDate: 'Aug 18, 2026 - 11:59 PM',
      regDeadline: 'Aug 04, 2026',
      prizePool: '\$10,000 USD + Google Cloud Credits',
      themeTopic: 'Cloud Native, Firebase & Cross-Platform Mobile Apps',
      tags: ['#Flutter', '#Firebase', '#GoogleCloud'],
      location: 'Discord / Devpost Online Platform',
      teamSize: '1 - 4 Members',
      contactEmail: 'support@gdscindia.dev',
      contactPhone: '+91 99000 11223',
      websiteUrl: 'https://devfest.withgoogle.com',
      description:
          'Build high-performance Flutter and Firebase web/mobile apps addressing real community needs across Indian colleges.',
    ),
    HackathonEvent(
      id: 'h5',
      title: 'TN Smart City Mobility Hackathon',
      organizer: 'Anna University & Guidance Tamil Nadu',
      state: 'Tamil Nadu',
      mode: 'In-Person',
      status: 'UPCOMING',
      startDate: 'Sep 12, 2026 - 08:30 AM',
      endDate: 'Sep 14, 2026 - 06:00 PM',
      regDeadline: 'Sep 05, 2026',
      prizePool: '₹3,50,00,000 + Govt Grants',
      themeTopic: 'Electric Mobility & Smart Traffic Management',
      tags: ['#EV', '#SmartCities', '#AnnaUniversity'],
      location: 'Anna University Campus, Guindy, Chennai',
      teamSize: '2 - 4 Members',
      contactEmail: 'hack@annauniv.edu',
      contactPhone: '+91 44 2235 7004',
      websiteUrl: 'https://annauniv.edu',
      description:
          'Solving transit bottlenecks and battery swapping logistics for urban municipal corporations in Chennai and Coimbatore.',
    ),
    HackathonEvent(
      id: 'h6',
      title: 'Telangana T-Hub CyberShield 2026',
      organizer: 'T-Hub & Telangana Academy for Skill & Knowledge',
      state: 'Telangana',
      mode: 'In-Person',
      status: 'UPCOMING',
      startDate: 'Sep 20, 2026 - 10:00 AM',
      endDate: 'Sep 22, 2026 - 07:00 PM',
      regDeadline: 'Sep 15, 2026',
      prizePool: '₹7,50,000 + T-Hub Residency',
      themeTopic: 'Zero Trust Security & AI Threat Detection',
      tags: ['#CyberSecurity', '#THub', '#Hyderabad'],
      location: 'T-Hub 2.0, HITEC City, Hyderabad',
      teamSize: '3 - 4 Members',
      contactEmail: 'events@t-hub.co',
      contactPhone: '+91 40 6789 0000',
      websiteUrl: 'https://t-hub.co',
      description:
          'Design AI-driven threat monitoring tools and secure vault architectures for digital health and governance networks.',
    ),
  ];

  List<HackathonEvent> get _filteredEvents {
    return _sampleEvents.where((e) {
      if (_selectedStatus != 'ALL' && e.status != _selectedStatus) {
        return false;
      }
      if (_selectedState != 'All India') {
        if (e.state != _selectedState && e.mode != _selectedState) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void _showEventDetailModal(HackathonEvent event, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: AppTheme.liquidGlassDecoration(
            isDark: isDark,
            radius: 32,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: (isDark
                                  ? AppTheme.darkPrimary
                                  : (event.status == 'ONGOING'
                                      ? const Color(0xFF00E676)
                                      : const Color(0xFF18D8D0)))
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? AppTheme.darkPrimary
                                : (event.status == 'ONGOING'
                                    ? const Color(0xFF00E676)
                                    : const Color(0xFF18D8D0)),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          event.status,
                          style: TextStyle(
                            color: isDark
                                ? AppTheme.darkPrimary
                                : (event.status == 'ONGOING'
                                    ? const Color(0xFF00E676)
                                    : AppTheme.lightPrimary),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: isDark
                              ? AppTheme.darkOnSurface
                              : AppTheme.lightOnSurface,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppTheme.darkOnSurface
                          : AppTheme.lightOnSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.corporate_fare_rounded,
                        size: 16,
                        color: isDark
                            ? AppTheme.darkPrimary
                            : AppTheme.lightPrimary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.organizer,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppTheme.darkOnSurfaceVariant
                                : AppTheme.lightOnSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailTile(
                          isDark,
                          Icons.emoji_events_rounded,
                          'Prize Pool',
                          event.prizePool,
                          const Color(0xFFFFD700),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailTile(
                          isDark,
                          Icons.groups_rounded,
                          'Team Size',
                          event.teamSize,
                          isDark
                              ? AppTheme.darkPrimary
                              : AppTheme.lightPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailTile(
                          isDark,
                          Icons.location_on_rounded,
                          'State / Mode',
                          '${event.state} (${event.mode})',
                          const Color(0xFF1769D5),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailTile(
                          isDark,
                          Icons.hourglass_bottom_rounded,
                          'Deadline',
                          event.regDeadline,
                          const Color(0xFFFF5252),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Dates & Timeline',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppTheme.darkOnSurface
                          : AppTheme.lightOnSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0E2036)
                          : const Color(0xFFE6F5F3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF4EF5EC).withValues(alpha: 0.15)
                            : const Color(0xFF18D8D0).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.play_circle_fill_rounded,
                              color: Color(0xFF00E676),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Start: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isDark
                                    ? AppTheme.darkOnSurface
                                    : AppTheme.lightOnSurface,
                              ),
                            ),
                            Text(
                              event.startDate,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppTheme.darkOnSurfaceVariant
                                    : AppTheme.lightOnSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.stop_circle_rounded,
                              color: Color(0xFFFF5252),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'End: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isDark
                                    ? AppTheme.darkOnSurface
                                    : AppTheme.lightOnSurface,
                              ),
                            ),
                            Text(
                              event.endDate,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppTheme.darkOnSurfaceVariant
                                    : AppTheme.lightOnSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Topic & Themes',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppTheme.darkOnSurface
                          : AppTheme.lightOnSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    event.themeTopic,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: isDark
                          ? AppTheme.darkOnSurfaceVariant
                          : AppTheme.lightOnSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: event.tags
                        .map(
                          (t) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: (isDark
                                      ? AppTheme.darkPrimary
                                      : (event.status == 'ONGOING'
                                          ? const Color(0xFF00E676)
                                          : const Color(0xFF18D8D0)))
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? AppTheme.darkPrimary
                                    : (event.status == 'ONGOING'
                                        ? const Color(0xFF00E676)
                                        : const Color(0xFF18D8D0)),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              t,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppTheme.darkPrimary
                                    : AppTheme.lightPrimary,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppTheme.darkOnSurface
                          : AppTheme.lightOnSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: isDark
                          ? AppTheme.darkOnSurfaceVariant
                          : AppTheme.lightOnSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Contact & Support',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppTheme.darkOnSurface
                          : AppTheme.lightOnSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 16,
                        color: isDark
                            ? AppTheme.darkPrimary
                            : AppTheme.lightPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        event.contactEmail,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppTheme.darkOnSurface
                              : AppTheme.lightOnSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 16,
                        color: isDark
                            ? AppTheme.darkPrimary
                            : AppTheme.lightPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        event.contactPhone,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppTheme.darkOnSurface
                              : AppTheme.lightOnSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  GestureDetector(
                    onTap: () async {
                      final uri = Uri.parse(event.websiteUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Could not open ${event.websiteUrl}'),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient(isDark),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.aquaGlow.withValues(
                              alpha: isDark ? 0.4 : 0.25,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.launch_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Visit Official Website & Register',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailTile(
    bool isDark,
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0E2036) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF4EF5EC).withValues(alpha: 0.12)
              : const Color(0xFF18D8D0).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppTheme.darkOnSurfaceVariant
                        : AppTheme.lightOnSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final events = _filteredEvents;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (context.canPop()) ...[
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF0E2036)
                                  : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF4EF5EC).withValues(alpha: 0.2)
                                    : const Color(0xFF18D8D0).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: isDark
                                  ? AppTheme.darkOnSurface
                                  : AppTheme.lightOnSurface,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Events & Hackathons',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppTheme.darkOnSurface
                                  : AppTheme.lightOnSurface,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Container(
                            width: 60,
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient(isDark),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: ['ALL', 'ONGOING', 'UPCOMING'].map((status) {
                      final isSelected = _selectedStatus == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedStatus = status),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? AppTheme.primaryGradient(isDark)
                                  : null,
                              color: isSelected
                                  ? null
                                  : (isDark
                                        ? const Color(0xFF0E2036)
                                        : Colors.white),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : (isDark
                                          ? const Color(0xFF4EF5EC).withValues(alpha: 0.15)
                                          : const Color(0xFF18D8D0).withValues(alpha: 0.2)),
                              ),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                          ? AppTheme.darkOnSurfaceVariant
                                          : AppTheme.lightOnSurfaceVariant),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _indianStates.length,
                      itemBuilder: (context, index) {
                        final stateName = _indianStates[index];
                        final isSelected = _selectedState == stateName;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedState = stateName),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark
                                          ? const Color(0xFF18D8D0).withValues(alpha: 0.25)
                                          : const Color(0xFF006A66).withValues(alpha: 0.15))
                                    : (isDark
                                          ? const Color(0xFF0E2036).withValues(alpha: 0.5)
                                          : Colors.white.withValues(alpha: 0.7)),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? (isDark
                                            ? const Color(0xFF4EF5EC)
                                            : const Color(0xFF18D8D0))
                                      : Colors.transparent,
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                stateName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? (isDark
                                            ? AppTheme.darkPrimary
                                            : AppTheme.lightPrimary)
                                      : (isDark
                                            ? AppTheme.darkOnSurfaceVariant
                                            : AppTheme.lightOnSurfaceVariant),
                                ),
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

            Expanded(
              child: events.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy_rounded,
                            size: 48,
                            color: isDark
                                ? AppTheme.darkPrimary.withValues(alpha: 0.5)
                                : AppTheme.lightPrimary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No hackathons found in $_selectedState',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppTheme.darkOnSurface
                                  : AppTheme.lightOnSurface,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return _buildHackathonCard(event, isDark);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHackathonCard(HackathonEvent event, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.liquidGlassDecoration(
        isDark: isDark,
        radius: 24,
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badge Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: event.status == 'ONGOING'
                        ? const Color(0xFF00E676).withValues(alpha: 0.15)
                        : const Color(0xFF18D8D0).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: event.status == 'ONGOING'
                          ? const Color(0xFF00E676)
                          : const Color(0xFF18D8D0),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    event.status,
                    style: TextStyle(
                      color: event.status == 'ONGOING'
                          ? const Color(0xFF00E676)
                          : (isDark
                                ? AppTheme.darkPrimary
                                : AppTheme.lightPrimary),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.place_rounded,
                        size: 14,
                        color: isDark
                            ? AppTheme.darkOutline
                            : AppTheme.lightOutline,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${event.state} (${event.mode})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppTheme.darkOutline
                                : AppTheme.lightOutline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              event.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppTheme.darkOnSurface
                    : AppTheme.lightOnSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              event.organizer,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppTheme.darkOnSurfaceVariant
                    : AppTheme.lightOnSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.trophy,
                        size: 14,
                        color: Color(0xFFFFD700),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.prizePool,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppTheme.darkOnSurface
                                : AppTheme.lightOnSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 14,
                      color: isDark
                          ? AppTheme.darkPrimary
                          : AppTheme.lightPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event.startDate.split(' - ')[0],
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppTheme.darkOnSurfaceVariant
                            : AppTheme.lightOnSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    children: event.tags
                        .take(2)
                        .map(
                          (t) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.darkContainerHigh
                                  : const Color(0xFFE6F5F3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              t,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppTheme.darkPrimary
                                    : AppTheme.lightPrimary,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showEventDetailModal(event, isDark),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient(isDark),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.aquaGlow.withValues(
                            alpha: isDark ? 0.35 : 0.2,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
