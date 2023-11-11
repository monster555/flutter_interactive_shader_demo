import 'package:flutter/material.dart';
import 'package:flutter_interactive_shader_demo/ui/widgets/shader_widget.dart';
import 'package:flutter_interactive_shader_demo/ui/widgets/title_widget.dart';

/// A page for displaying a shader effect using the [ShaderWidget].
///
/// The [ShaderPage] widget is used to display a shader effect in a full-screen view.
///
/// Parameters:
///
/// - [shaderName] The name of the shader to display on this page.
class ShaderPage extends StatelessWidget {
  /// Creates a [ShaderPage] widget.
  const ShaderPage(this.shaderName, {super.key});

  /// The name of the shader to display on this page.
  final String shaderName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Display the shader widget.
          ShaderWidget(shaderName),
          // Display the title widget.
          const TitleWidget()
        ],
      ),
    );
  }
}
