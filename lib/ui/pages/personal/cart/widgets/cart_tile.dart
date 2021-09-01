import 'package:flutter/material.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/ui/pages/personal/cart/widgets/cart_order_item.dart';
import 'package:flutter_bzaru/ui/pages/personal/cart/widgets/cart_store_tile.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';

class CartTile extends StatefulWidget {
  final OrdersModel ordersModel;

  const CartTile({Key key, this.ordersModel}) : super(key: key);

  @override
  _CartTileState createState() => _CartTileState();
}

class _CartTileState extends State<CartTile> {
  ValueNotifier<bool> _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _isExpanded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _isExpanded,
      builder: (context, expanded, child) => AnimatedContainer(
        color: KColors.bgColor,
        padding: EdgeInsets.symmetric(horizontal: 10),
        duration: Duration(milliseconds: 100),
        curve: Curves.fastOutSlowIn,
        margin: EdgeInsets.symmetric(vertical: 10),
        child: AnimatedCrossFade(
          firstChild: _buildFirstChild(widget.ordersModel, expanded),
          secondChild: _buildSecondChild(widget.ordersModel, expanded),
          crossFadeState:
              expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: Duration(milliseconds: 100),
        ),
      ).pH(10),
    );
  }

  Widget _buildFirstChild(OrdersModel ordersModel, bool isExpanded) {
    return CartStoreTile(
      ordersModel: ordersModel,
      isFirst: true,
      onExpanded: (value) {
        _isExpanded.value = true;
      },
    );
  }

  Widget _buildSecondChild(OrdersModel ordersModel, bool isExpanded) {
    return Column(
      children: [
        CartStoreTile(
          ordersModel: ordersModel,
          isFirst: false,
          onExpanded: (value) {
            _isExpanded.value = false;
          },
        ),
        SizedBox(height: 10),
        Column(
          children: ordersModel.items
              .map((item) => CartOrderItem(productModel: item))
              .toList(),
        ),
        // Divider(thickness: 2.0),
        SizedBox(height: 10),
      ],
    );
  }
}
