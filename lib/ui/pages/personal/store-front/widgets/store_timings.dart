import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/model/timing_model.dart';
import 'package:flutter_bzaru/providers/customer/c_store_state.dart';
import 'package:flutter/src/painting/text_style.dart' as text;
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' show DateFormat;

class StoreTimings extends StatelessWidget {
  Widget build(BuildContext context) {
    return Consumer<CStoreState>(
      builder: (context, state, child) => state.isBusy
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,

              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: state.storeTimings
                      .map((model) => _buildDays(model, context))
                      .toList(),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: state.storeTimings
                      .map((model) => _buildTimings(model, context))
                      .toList(),
                ),
              ],

              // state.storeTimings
              //     .map((timingModel) =>
              //         _buildBusinessHourTile(timingModel, context))
              //     .toList(),
            ),
    );
  }

  Widget _buildDays(TimingModel model, BuildContext context) {
    final locale = AppLocalizations.of(context);
    return BText(
      locale.getTranslatedValue(model.day.toLowerCase()).substring(0, 3),
      variant: TypographyVariant.h4,
      style: text.TextStyle(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildTimings(TimingModel model, BuildContext context) {
    return model.isClosed
        ? BText(
            "Closed",
            variant: TypographyVariant.h4,
          )
        : BText(
            "${model.startTime.toLowerCase()}-${model.endTime.toLowerCase()}",
            variant: TypographyVariant.h4,
          );
  }
}
