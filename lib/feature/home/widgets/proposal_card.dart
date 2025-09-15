
import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:flutter/cupertino.dart';

class ProposalCard extends StatelessWidget {
  const ProposalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
      color: AppColors.fieldColor,
      ),
      
    );
  }
}
