import 'package:flutter/material.dart';
import 'package:flutter_bzaru/model/dashboard_tiles_model.dart';
import 'package:flutter_bzaru/ui/widgets/custom_list_tile.dart';

class DashBoardTiles extends StatelessWidget {
  final List<DashboardTilesModel> dashboardTiles;

  const DashBoardTiles({Key key, @required this.dashboardTiles})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: dashboardTiles
            .map(
              (model) => Column(
                children: [
                  Container(
                    color: Colors.grey[100],
                    child: BListTile(
                      leadingIcon: model.icon,
                      title: model.title,
                      nextScreen: model.nextScreen,
                    ),
                  ),
                  SizedBox(height: 2.0),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

///!COULD BE USED INSTEAD OF COLUMN
// height: 600,
// child: ListView.builder(
//   itemCount: tiles.length,
//   itemBuilder: (context, index) => Column(
//     children: [
//       ListTile(
//         leading: Image.asset(
//           tiles[index]["icon"],
//           height: 23,
//           width: 23,
//         ),
//         title: KText(
//           tiles[index]["title"],
//           variant: TypographyVariant.title,
//           style: TextStyle(color: Colors.black),
//         ),
//         trailing: Image.asset(
//           KImages.nextArrow,
//           height: 23,
//           width: 23,
//         ),
//       ),
//       Divider(
//         height: 2,
//         thickness: 1.0,
//       )
//     ],
//   ),
// ),
