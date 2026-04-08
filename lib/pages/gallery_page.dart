import 'dart:ui';
import 'package:flutter/material.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> imagePaths = List.generate(
      40,
      (index) => 'assets/nos${index + 1}.jpg',
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: imagePaths.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final path = imagePaths[index];
          return GestureDetector(
            onTap: () {
              showGeneralDialog(
                context: context,
                barrierLabel: 'Photo',
                barrierDismissible: true,
                barrierColor: Colors.black.withOpacity(0.35),
                transitionDuration: const Duration(milliseconds: 220),
                pageBuilder: (_, __, ___) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                          child: Material(
                            color: Colors.white,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Hero(
                                  tag: path,
                                  child: _AssetImageWithLoader(
                                    path: path,
                                    aspectRatio: 16 / 9,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                    isFull: true,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    'Um momento especial nosso 💖',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.pink.shade700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                transitionBuilder: (context, anim, __, child) {
                  return FadeTransition(opacity: anim, child: child);
                },
              );
            },
            child: Hero(
              tag: path,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _AssetImageWithLoader(
                  path: path,
                  aspectRatio: 1, // quadradinho no grid
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Widget reutilizável: mostra loader até a imagem estar disponível,
/// depois faz um fade-in suave.
class _AssetImageWithLoader extends StatefulWidget {
  final String path;
  final double aspectRatio;
  final BorderRadius? borderRadius;
  final bool isFull;

  const _AssetImageWithLoader({
    required this.path,
    required this.aspectRatio,
    this.borderRadius,
    this.isFull = false,
  });

  @override
  State<_AssetImageWithLoader> createState() => _AssetImageWithLoaderState();
}

class _AssetImageWithLoaderState extends State<_AssetImageWithLoader> {
  late final ImageProvider _provider;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _provider = AssetImage(widget.path);

    // Observa o stream de carregamento do ImageProvider
    final stream = _provider.resolve(const ImageConfiguration());
    ImageStreamListener? listener;
    listener = ImageStreamListener(
      (ImageInfo _, bool __) {
        if (mounted) {
          setState(() => _loaded = true);
        }
        stream.removeListener(listener!);
      },
      onError: (dynamic _, __) {
        if (mounted) {
          setState(() => _loaded = true); // evita loader infinito em erro
        }
        stream.removeListener(listener!);
      },
    );
    stream.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(16);

    final img = ClipRRect(
      borderRadius: radius,
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Plano de fundo suave (enquanto carrega)
            Container(color: const Color(0xFFE1BEE7).withOpacity(0.25)),
            // Loader
            if (!_loaded)
              const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2.4),
                ),
              ),
            // Imagem com fade-in quando disponível
            AnimatedOpacity(
              opacity: _loaded ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: Image(
                image: _provider,
                fit: widget.isFull ? BoxFit.cover : BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );

    return img;
  }
}
