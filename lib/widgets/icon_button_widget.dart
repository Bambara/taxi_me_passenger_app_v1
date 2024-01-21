import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class IconButtonWidget extends StatelessWidget {
  const IconButtonWidget({Key? key, required this.imagePath, required this.function, required this.iconData, required this.isIcon, required this.iconSize}) : super(key: key);

  final String imagePath;
  final VoidCallback function;
  final IconData iconData;
  final bool isIcon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return IconButton(
      color: Theme.of(context).iconTheme.color,
      iconSize: iconSize,
      icon: isIcon
          ? Icon(iconData)
          : SvgPicture.asset(
              imagePath,
              fit: BoxFit.scaleDown,
              height: iconSize,
              width: iconSize,
            ),
      onPressed: () => function(),
    );
  }
}
