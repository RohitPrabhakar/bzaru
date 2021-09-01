import 'package:flutter/material.dart';
import 'package:flutter_bzaru/providers/customer/c_order_state.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class PhoneCheckoutTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<COrderState>(
      builder: (context, state, child) => Padding(
        padding: EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              fit: FlexFit.loose,
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.mobile_friendly,
                    size: 30,
                    color: KColors.customerPrimaryColor,
                  ),
                  SizedBox(width: 10),
                  Flexible(
                      child: BText(
                    state.selectedAddress?.mobileNumber != null &&
                            state.selectedAddress.mobileNumber.isNotEmpty
                        ? "(+91) ${state.selectedAddress.mobileNumber}"
                        : state.contactNumber != null &&
                                state.contactNumber.isNotEmpty
                            ? "(+91) ${state.contactNumber}"
                            : "N.A",
                    variant: TypographyVariant.h1,
                    maxLines: 2,
                    style: TextStyle(fontWeight: FontWeight.w400),
                  )),
                  Flexible(
                    child: SizedBox(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
