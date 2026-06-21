import 'package:flutter/material.dart';

import 'brand_service_icon.dart';

class BrandIcon extends StatelessWidget {
  final String? serviceId;
  final String? serviceName;
  final String? category;
  final String? iconKey;
  final double size;

  const BrandIcon({
    super.key,
    this.serviceId,
    this.serviceName,
    this.category,
    this.iconKey,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return BrandServiceIcon(
      serviceId: serviceId,
      serviceName: serviceName,
      category: category,
      iconKey: iconKey,
      size: size,
    );
  }
}
