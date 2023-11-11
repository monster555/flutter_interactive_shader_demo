import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

part 'shader_painter.dart';

/// A widget that displays a shader with dynamic parameters.
///
/// This widget uses a [FragmentShader] to render dynamic visual effects. The shader
/// parameters are updated during the widget's build and animation process.
///
/// Shader parameters are set using the `setFloat` method, and the numbers passed to
/// this method correspond to specific properties of the shader. The correspondence is
/// based on the order in which the variables are declared in the fragment program code:
///
/// Mapping Shader Parameters to Fragment Program Variables:
/// - `iTime` (0): Elapsed time since widget initialization.
/// - `iResolution` (1, 2): Width and height of the widget.
/// - `iMouse` (4, 5): X and Y Offset for panning gestures.
///
/// This mapping helps understand how the shader parameters set with `setFloat`
/// correspond to the variables declared in the fragment program code.
///
/// The `xOffset` and `yOffset` are updated when the user pans on the widget, affecting
/// the visual output of the shader. The elapsed time is automatically calculated
/// to create dynamic effects over time.
///
/// The `iResolution` variable in the fragment program is a `vec3` (vector of 3
/// floats), hence it's set using indices 1 and 2. Similarly, the `iMouse` variable is
/// a `vec4`, and its X and Y components are set using indices 4 and 5.
class ShaderWidget extends StatefulWidget {
  /// A widget that displays a shader with dynamic parameters.
  ///
  /// This widget uses a [FragmentShader] to render dynamic visual effects. The shader
  /// parameters are updated during the widget's build and animation process.
  ///
  /// Shader parameters are set using the `setFloat` method, and the numbers passed to
  /// this method correspond to specific properties of the shader.
  ///
  /// The `xOffset` and `yOffset` are updated when the user pans on the widget, affecting
  /// the visual output of the shader. The elapsed time is automatically calculated
  /// to create dynamic effects over time.
  ///
  /// The [shaderName] parameter is required, specifying the name of the shader to be used.
  /// Optional parameters:
  /// - [width] The width of the widget, if specified.
  /// - [height] The height of the widget, if specified.
  const ShaderWidget(
    this.shaderName, {
    super.key,
    this.width,
    this.height,
  });

  /// The name of the fragment shader to be applied.
  final String shaderName;

  /// The width of the shader view. If not specified, it defaults to the width
  /// of the parent widget.
  final double? width;

  /// The height of the shader view. If not specified, it defaults to the height
  /// of the parent widget.
  final double? height;

  @override
  State<ShaderWidget> createState() => _ShaderWidgetState();
}

/// The state for the [ShaderWidget] widget.
///
/// This state class manages the animation controller for the shader and
/// calculates the elapsed time since the widget's initialization.
class _ShaderWidgetState extends State<ShaderWidget>
    with SingleTickerProviderStateMixin {
  /// The animation controller responsible for animating the shader.
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  )..repeat();

  @override
  void dispose() {
    // Dispose the animation controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  /// The horizontal offset for user interaction.
  double xOffset = 0;

  /// The vertical offset for user interaction.
  double yOffset = 0;

  /// The time when the widget was initialized.
  int _startTime = 0;

  /// Returns the elapsed time since the widget was initialized.
  double get _elapsedTimeInSeconds =>
      (DateTime.now().millisecondsSinceEpoch - _startTime) / 1000;

  /// Builds the widget tree for the [ShaderWidget].
  @override
  Widget build(BuildContext context) {
    // Initialize the start time when the widget is first built.
    _startTime = DateTime.now().millisecondsSinceEpoch;

    // Use the specified width and height if provided, otherwise use the
    // MediaQuery size.
    final width = widget.width ?? MediaQuery.sizeOf(context).width;
    final height = widget.height ?? MediaQuery.sizeOf(context).height;

    return SizedBox(
      width: width,
      height: height,
      child: FutureBuilder<FragmentShader>(
        // Load the shader from the shaders folder.
        future: _loadShader(widget.shaderName),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final shader = snapshot.data!;

            // Set the shader's width and height parameters.
            shader
              // Set width: Corresponds to shader's `iResolution.x`
              ..setFloat(1, width)
              // Set height: Corresponds to shader's `iResolution.y`
              ..setFloat(2, height);

            return GestureDetector(
              onPanUpdate: (details) {
                // Update the xOffset based on the horizontal movement of the pan gesture.
                xOffset += details.delta.dx;

                // Update the yOffset based on the vertical movement of the pan gesture.
                yOffset += details.delta.dy;
              },
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  // Set shader parameters including elapsed time, xOffset, and yOffset.
                  shader
                    // Set elapsed time: Corresponds to shader's `iTime`
                    ..setFloat(0, _elapsedTimeInSeconds)

                    // Set X Offset: Corresponds to shader's `iMouse.x`.
                    // Applying -1 * xOffset to adjust for potential coordinate system differences.
                    // This inversion is used for demo/educational purposes and may vary from shader to shader.
                    ..setFloat(4, -1 * xOffset)

                    // Set Y Offset: Corresponds to shader's `iMouse.y`.
                    // Applying -1 * yOffset for potential coordinate system adjustments.
                    // This inversion is used for demo/educational purposes and may vary from shader to shader.
                    ..setFloat(5, -1 * yOffset);
                  return CustomPaint(
                    painter: ShaderPainter(shader),
                  );
                },
              ),
            );
          } else {
            // Display a CircularProgressIndicator while loading the shader.
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

/// Loads and returns a [FragmentShader] from an asset using the specified [shaderName].
///
/// This method loads a shader program from the assets folder with the given [shaderName]
/// and returns the corresponding [FragmentShader].
///
/// Parameters:
///
/// - [shaderName] The name of the shader file to load.
Future<FragmentShader> _loadShader(String shaderName) async {
  // Load the shader program from the assets folder.
  FragmentProgram program =
      await FragmentProgram.fromAsset('shaders/$shaderName');

  // Return the fragment shader from the program.
  return program.fragmentShader();
}
