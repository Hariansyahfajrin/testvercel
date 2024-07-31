import 'package:admin/screens/main/provider/main_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Image.asset("assets/images/logo.png"),
          ),
          DrawerListTile(
            title: "Dashboard",
            svgSrc: "assets/icons/menu_dashboard.svg",
            press: () {
              context.read<MainScreenProvider>().navigateToScreen('Dashboard');
            },
          ),
          DrawerListTile(
            title: "Category",
            svgSrc: "assets/icons/menu_tran.svg",
            press: () {
              context.read<MainScreenProvider>().navigateToScreen('Category');
            },
          ),
          DrawerListTile(
            title: "Sub Category",
            svgSrc: "assets/icons/menu_task.svg",
            press: () {
              context
                  .read<MainScreenProvider>()
                  .navigateToScreen('SubCategory');
            },
          ),
          DrawerListTile(
            title: "Brands",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {
              context.read<MainScreenProvider>().navigateToScreen('Brands');
            },
          ),
          DrawerListTile(
            title: "Variant Type",
            svgSrc: "assets/icons/menu_store.svg",
            press: () {
              context
                  .read<MainScreenProvider>()
                  .navigateToScreen('VariantType');
            },
          ),
          DrawerListTile(
            title: "Variants",
            svgSrc: "assets/icons/menu_notification.svg",
            press: () {
              context.read<MainScreenProvider>().navigateToScreen('Variants');
            },
          ),
          DrawerListTile(
            title: "Orders",
            svgSrc: "assets/icons/menu_profile.svg",
            press: () {
              context.read<MainScreenProvider>().navigateToScreen('Order');
            },
          ),
          DrawerListTile(
            title: "Coupons",
            svgSrc: "assets/icons/menu_setting.svg",
            press: () {
              context.read<MainScreenProvider>().navigateToScreen('Coupon');
            },
          ),
          DrawerListTile(
            title: "Posters",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {
              context.read<MainScreenProvider>().navigateToScreen('Poster');
            },
          ),
          DrawerListTile(
            title: "Notifications",
            svgSrc: "assets/icons/menu_notification.svg",
            press: () {
              context
                  .read<MainScreenProvider>()
                  .navigateToScreen('Notifications');
            },
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        colorFilter: ColorFilter.mode(Colors.white54, BlendMode.srcIn),
        height: 16,
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}
