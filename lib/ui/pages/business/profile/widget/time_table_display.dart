import 'package:flutter/material.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/model/timing_model.dart';
import 'package:flutter_bzaru/providers/profile_state.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class TimeTableDisplay extends StatefulWidget {
  @override
  _TimeTableDisplayState createState() => _TimeTableDisplayState();
}

class _TimeTableDisplayState extends State<TimeTableDisplay> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileState>(
      builder: (context, state, child) => Column(
        children: state.timingsList
            .map(
              (timingModel) => !timingModel.isClosed
                  ? _buildBusinessHourTile(timingModel)
                  : SizedBox(),
            )
            .toList(),
      ),
    );
  }

  Widget _buildBusinessHourTile(TimingModel timingModel) {
    final locale = AppLocalizations.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BText(
              locale.getTranslatedValue(timingModel.day.toLowerCase()),
              variant: TypographyVariant.h2,
            ),
            Row(
              children: [
                BText(
                  timingModel.startTime.toLowerCase(),
                  variant: TypographyVariant.h2,
                  style: timingModel.isClosed
                      ? TextStyle(color: Colors.grey)
                      : null,
                ),
                SizedBox(width: 5.0),
                BText(
                  "-",
                  variant: TypographyVariant.h2,
                  style: timingModel.isClosed
                      ? TextStyle(color: Colors.grey)
                      : null,
                ),
                SizedBox(width: 5.0),
                BText(
                  timingModel.endTime.toLowerCase(),
                  variant: TypographyVariant.h2,
                  style: timingModel.isClosed
                      ? TextStyle(color: Colors.grey)
                      : null,
                )
              ],
            )
          ],
        ),
        SizedBox(height: 5),
      ],
    );
  }
}
