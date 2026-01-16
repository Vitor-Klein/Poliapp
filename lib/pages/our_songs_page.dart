import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OurSongsPage extends StatefulWidget {
  const OurSongsPage({super.key});

  @override
  State<OurSongsPage> createState() => _OurSongsPageState();
}

class _OurSongsPageState extends State<OurSongsPage> {
  static const _embedUrl =
      'https://open.spotify.com/embed/playlist/3wrMIV2LSiLzts6BICX0PX?utm_source=generator';
  static const _openUrl =
      'https://open.spotify.com/playlist/3wrMIV2LSiLzts6BICX0PX';

  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
        ),
      )
      ..loadRequest(Uri.parse(_embedUrl));
  }

  Future<void> _openInSpotify() async {
    await launchUrl(Uri.parse(_openUrl), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nossas músicas'),
        actions: [
          IconButton(
            tooltip: 'Abrir no Spotify',
            icon: const Icon(Icons.open_in_new),
            onPressed: _openInSpotify,
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
