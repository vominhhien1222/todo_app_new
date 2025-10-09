import 'package:flutter/material.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  // Mock dữ liệu bản tin: có title, subtitle, tag để lên màu chip.
  final List<Map<String, String>> _news = [
    {
      "title": "Cập nhật Todos: Hoàn thành 3 task trước 17:00",
      "subtitle": "Check lại ưu tiên High/Medium để kịp deadline hôm nay.",
      "tag": "Todos",
    },
    {
      "title": "Thông báo: Bảo trì hệ thống 23:00–23:30",
      "subtitle": "Ứng dụng có thể thoát ra trong thời gian cập nhật.",
      "tag": "Announcement",
    },
    {
      "title": "Mẹo năng suất: Quy tắc 2 phút",
      "subtitle": "Việc nào < 2 phút, làm ngay để đỡ tồn đọng.",
      "tag": "Tips",
    },
  ];

  // Giả lập refresh 800ms cho mượt (thay bằng load API/Firestore sau)
  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _news.shuffle(); // chỉ đổi thứ tự , sau dùng dữ liệu thật
    });
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return "Chào buổi sáng ☀️";
    if (hour < 14) return "Buổi trưa vui vẻ 🥗";
    if (hour < 19) return "Buổi chiều năng suất ⚡";
    return "Buổi tối thư giãn 🌙";
    // Bạn có thể thay bằng tên user: "Xin chào, Thảo 👋"
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Màu chủ đạo nhẹ nhàng, pha trộn để "tươi tươi" (tránh 1 màu).
    // - Teal (màu thương hiệu)
    // - Indigo/Cyan để tạo chiều sâu
    final Color accent = isDark ? Colors.tealAccent : Colors.teal;
    final Color subtle = isDark ? Colors.indigo.shade300 : Colors.indigo;
    final Color cyanish = isDark ? Colors.cyanAccent : Colors.cyan.shade400;

    return Scaffold(
      // AppBar nhẹ, bạn có thể bỏ nếu dùng BottomNav có tiêu đề riêng
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.background,
        title: const Text("Trang chính"),
        centerTitle: false,
      ),

      // Kéo xuống refresh list
      body: RefreshIndicator(
        color: accent,
        onRefresh: _onRefresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // -----------------------
            // 1) Banner JPG + overlay
            // -----------------------
            _BannerWithOverlay(
              isDark: isDark,
              accent: accent,
              cyanish: cyanish,
              subtle: subtle,
              // Nếu thiếu asset => fallback bằng gradient
              assetPath: "assets/images/news_banner.jpg",
            ),
            const SizedBox(height: 16),

            // -----------------------
            // 2) Lời chào (greeting)
            // -----------------------
            Text(
              _greeting(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Cùng mình điểm qua một số cập nhật mới nhất nhé.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),

            // -----------------------
            // 3) Dòng “nhanh tay” (quick chips)
            //    => tạo điểm nhấn màu mè hơn 1 chút cho tươi
            // -----------------------
            _QuickActionChips(accent: accent, cyanish: cyanish, subtle: subtle),
            const SizedBox(height: 16),

            // -----------------------
            // 4) Danh sách BẢN TIN (Cards)
            // -----------------------
            Text(
              "Bản tin gần đây",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),

            // List card tin tức
            ..._news.map(
              (item) => _NewsCard(
                title: item["title"]!,
                subtitle: item["subtitle"]!,
                tag: item["tag"]!,
                accent: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Banner có:
/// - Ảnh PNG (assetPath)
/// - Gradient mờ overlay (teal + cyan + indigo) cho "tươi tươi"
/// - Fallback: nếu lỗi asset => hiển thị gradient thay thế (không crash)
class _BannerWithOverlay extends StatelessWidget {
  const _BannerWithOverlay({
    required this.isDark,
    required this.accent,
    required this.cyanish,
    required this.subtle,
    required this.assetPath,
  });

  final bool isDark;
  final Color accent;
  final Color cyanish;
  final Color subtle;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Ảnh PNG làm nền (errorBuilder => fallback)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(
              assetPath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                // Nếu thiếu ảnh, dùng gradient thay thế
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [Colors.teal.shade900, Colors.indigo.shade900]
                          : [Colors.teal.shade400, Colors.cyan.shade300],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                );
              },
            ),
          ),

          // Overlay gradient mờ (tạo chiều sâu + dễ đọc chữ)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    // trộn nhẹ teal + indigo + transparent
                    accent.withOpacity(isDark ? 0.30 : 0.20),
                    subtle.withOpacity(isDark ? 0.25 : 0.12),
                    Colors.transparent,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),

          // Text giới thiệu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                children: const [
                  TextSpan(text: "Bản tin hôm nay\n"),
                  TextSpan(
                    text: "Cập nhật mới, tips hay, và thông báo hệ thống",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dải chip hành động nhanh cho cảm giác "tươi" & “app-like”
/// - Màu sắc phối: teal/cyan/indigo nhạt (có thay đổi light/dark)
class _QuickActionChips extends StatelessWidget {
  const _QuickActionChips({
    required this.accent,
    required this.cyanish,
    required this.subtle,
  });

  final Color accent;
  final Color cyanish;
  final Color subtle;

  @override
  Widget build(BuildContext context) {
    final chipStyle = Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _ChipPill(
          text: "Lộ trình hôm nay",
          color: accent,
          textStyle: chipStyle,
        ),
        _ChipPill(text: "Ưu tiên cao", color: cyanish, textStyle: chipStyle),
        _ChipPill(text: "Thông báo mới", color: subtle, textStyle: chipStyle),
      ],
    );
  }
}

class _ChipPill extends StatelessWidget {
  const _ChipPill({required this.text, required this.color, this.textStyle});

  final String text;
  final Color color;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Text(
        text,
        style: (textStyle ?? const TextStyle()).copyWith(color: color),
      ),
    );
  }
}

/// Card hiển thị 1 bản tin:
/// - Tag chip (màu theo accent)
/// - Title + subtitle
/// - Nền pastel nhạt tùy theme
class _NewsCard extends StatelessWidget {
  const _NewsCard({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final String tag;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.blueGrey.shade900 : Colors.teal.shade50,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.25)
                : Colors.teal.shade200.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.teal.shade100,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        leading: CircleAvatar(
          backgroundColor: accent.withOpacity(0.18),
          foregroundColor: accent,
          child: const Icon(Icons.article_outlined),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(subtitle, style: theme.textTheme.bodySmall),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.14),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: accent.withOpacity(0.25)),
          ),
          child: Text(
            tag,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0.2,
            ),
          ),
        ),
        onTap: () {
          // TODO: sau này điều hướng sang user_detail_screen.dart (Hero + slide)
          // Navigator.push(context, MaterialPageRoute(builder: (_) => const UserDetailScreen(...)));
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Đang mở: $tag")));
        },
      ),
    );
  }
}
