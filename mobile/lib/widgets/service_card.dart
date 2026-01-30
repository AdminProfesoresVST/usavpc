import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_theme.dart';

class ServiceCard extends StatelessWidget {
  final String title;
  final String price;
  final String description;
  final VoidCallback onTap;
  final bool isPopular;

  const ServiceCard({
    super.key,
    required this.title,
    required this.price,
    required this.description,
    required this.onTap,
    this.isPopular = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTheme.elevacionMedia,
      shape: RoundedRectangleBorder(borderRadius: AppTheme.inputRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTheme.inputRadius,
        child: Stack(
          children: [
            Padding(
              padding: AppTheme.paddingEstandar,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.labelBold,
                  ),
                  SizedBox(height: AppTheme.espacioEntreCampos),
                  Text(
                    price,
                    style: AppTheme.h2NavyBold.copyWith(color: AppTheme.actionBlue),
                  ),
                  SizedBox(height: AppTheme.espacioEntreCampos),
                  Text(
                    description,
                    style: AppTheme.captionGreyRegular,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isPopular)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: AppTheme.paddingBadge,
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen,
                    borderRadius: BorderRadius.only(
                      topRight: AppTheme.radiusBotonEsquina,
                      bottomLeft: AppTheme.radiusBotonEsquina,
                    ),
                  ),
                  child: Text(
                    'Popular',
                    style: AppTheme.captionWhiteBold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
