import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ShowImageScreen extends StatefulWidget {
  const ShowImageScreen({
    Key? key,
    required this.url,
  }) : super(key: key);
  final String url;
  @override
  State<ShowImageScreen> createState() => _ShowImageScreenState();
}

class _ShowImageScreenState extends State<ShowImageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: InteractiveViewer(
        child: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Center(
            child: CachedNetworkImage(
              imageUrl: widget.url,
              placeholder: (context, url) {
                return const Center(child: CircularProgressIndicator());
              },
              imageBuilder: (context, imageProvider) {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
