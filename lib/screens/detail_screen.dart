import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/phases.dart';
import '../data/recommendations.dart';
import '../models/history_entry.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class DetailScreen extends StatefulWidget {
  final Recommendation recommendation;
  final String phase;

  const DetailScreen({
    super.key,
    required this.recommendation,
    required this.phase,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _messageController = TextEditingController();
  bool _messageSent = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _saveToHistory(String method) async {
    final entry = HistoryEntry(
      date: DateTime.now(),
      phase: widget.phase,
      category: widget.recommendation.category,
      prompt: widget.recommendation.prompt,
      message: _messageController.text.isNotEmpty
          ? _messageController.text
          : null,
      shareMethod: method,
    );

    await StorageService.addHistoryEntry(entry);

    setState(() {
      _messageSent = true;
    });
  }

  Future<void> _copyToClipboard() async {
    final text = _messageController.text;
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe un mensaje primero'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    await Clipboard.setData(ClipboardData(text: text));
    await _saveToHistory('copy');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check, color: Colors.white),
              SizedBox(width: 8),
              Text('Copiado al portapapeles'),
            ],
          ),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  Future<void> _shareWhatsApp() async {
    final text = _messageController.text;
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe un mensaje primero'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final encoded = Uri.encodeComponent(text);
    final url = Uri.parse('https://wa.me/?text=$encoded');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      await _saveToHistory('whatsapp');
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir WhatsApp'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _shareTelegram() async {
    final text = _messageController.text;
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe un mensaje primero'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final encoded = Uri.encodeComponent(text);
    final url = Uri.parse('https://t.me/share/url?text=$encoded');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      await _saveToHistory('telegram');
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir Telegram'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final phaseData = phases[widget.phase]!;
    final rec = widget.recommendation;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Sticky header
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppTheme.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.headerGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(56, 8, 20, 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                rec.category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              rec.icon,
                              color: Colors.white.withOpacity(0.9),
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Main prompt card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: phaseData.bgColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    border: Border.all(color: phaseData.color.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        rec.icon,
                        color: phaseData.color,
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        rec.prompt,
                        style: TextStyle(
                          color: phaseData.color,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // "Por qué funciona" card
                _buildInfoCard(
                  title: 'Por qué funciona',
                  icon: Icons.psychology,
                  iconColor: AppTheme.primary,
                  content: rec.porQue,
                ),

                const SizedBox(height: 16),

                // "Evitar decir" card
                _buildListCard(
                  title: 'Evita decir',
                  icon: Icons.not_interested,
                  iconColor: AppTheme.error,
                  items: rec.evitar,
                  isWarning: true,
                ),

                const SizedBox(height: 16),

                // "Inspiración" card
                _buildListCard(
                  title: 'Inspiración',
                  icon: Icons.lightbulb,
                  iconColor: AppTheme.warning,
                  items: rec.inspiracion,
                  isItalic: true,
                ),

                const SizedBox(height: 24),

                // Message input card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    border: Border.all(color: AppTheme.border),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.edit_note,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Tu mensaje',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _messageController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText:
                              'Escribe tu mensaje inspirado en las sugerencias...',
                          hintStyle: TextStyle(
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Share buttons
                      Row(
                        children: [
                          // Copy button
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _copyToClipboard,
                              icon: const Icon(Icons.copy, size: 18),
                              label: const Text('Copiar'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.textSecondary,
                                side: const BorderSide(color: AppTheme.border),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // WhatsApp button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _shareWhatsApp,
                              icon: const Icon(Icons.send, size: 18),
                              label: const Text('WhatsApp'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Telegram button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _shareTelegram,
                              icon: const Icon(Icons.send, size: 18),
                              label: const Text('Telegram'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0088CC),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Sent confirmation
                      if (_messageSent) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSmall),
                            border: Border.all(
                              color: AppTheme.success.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: AppTheme.success,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  '¡Mensaje enviado! Se ha guardado en tu historial.',
                                  style: TextStyle(
                                    color: AppTheme.success,
                                    fontSize: 13,
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

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<String> items,
    bool isWarning = false,
    bool isItalic = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWarning ? AppTheme.error.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isWarning ? AppTheme.error.withOpacity(0.2) : AppTheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isWarning ? AppTheme.error : AppTheme.textMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        color: isWarning
                            ? AppTheme.error
                            : AppTheme.textSecondary,
                        fontSize: 14,
                        fontStyle:
                            isItalic ? FontStyle.italic : FontStyle.normal,
                        height: 1.4,
                      ),
                    ),
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
