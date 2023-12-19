import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

import 'package:dandani/widgets/widget.dart';
import 'package:dandani/util/colors.dart';

import 'package:dandani/models/detailMitraModel.dart';

import 'package:dandani/providers/mitraProvider.dart';
import 'package:dandani/providers/listChatProvider.dart';

class DetailPage extends StatelessWidget {
  // const DetailPage({super.key});

  Future<void> _openWhatsapp(String url) async {
    var wa = url.replaceFirst('6208', '628');
    final _url = Uri.parse('https://wa.me/$wa');
    if (!await launchUrl(
      _url,
      // mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $_url');
    }
  }

  Future<void> _openMap(String latlong) async {
    final _url = Uri.parse('https://maps.google.com/?q=$latlong');
    if (!await launchUrl(
      _url,
      // mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    Mitra? mitra = Provider.of<MitraProvider>(context).mitra;
    var userLoggedEmail =
        Provider.of<ConversationProvider>(context).userLoggedEmail;
    double widthButtonWA = (mitra?.account == userLoggedEmail) ? 0.88 : 0.67;

    List<Widget> photoList = mitra!.photo
        .split(',')
        .where((link) => link.isNotEmpty)
        .map((link) => Image(
              image: NetworkImage(link),
              fit: BoxFit.fill,
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(mitra.name),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // main info
                Container(
                  width: double.maxFinite,
                  height: 250,
                  child: FlutterCarousel(
                    options: CarouselOptions(
                      viewportFraction: 1.0,
                      showIndicator: true,
                      slideIndicator: const CircularSlideIndicator(),
                    ),
                    items: photoList,
                  ),
                ),
                // title
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  width: double.infinity,
                  color: purplePrimaryTrans,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mitra.name,
                              style: TextStyle(
                                  color: white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              mitra.district + ', ' + mitra.city,
                              style: TextStyle(color: white),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => _openMap(mitra.maps),
                        child: Container(
                          margin: EdgeInsets.only(right: 10),
                          child: Image.asset(
                            'assets/icons/icon-google-maps.png',
                            scale: 1.8,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                // desc
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          "Deskripsi",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        mitra.desc,
                        style: TextStyle(fontSize: 15),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: MediaQuery.of(context).size.width * 0.65,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          "Spesialis",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      BadgeWidget2(specialist: mitra.specialist),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (mitra.account != userLoggedEmail) ...[
                  InkWell(
                    onTap: () {
                      Provider.of<ConversationProvider>(context, listen: false)
                          .getConversationsByMitra(mitra.name, mitra.account);

                      Navigator.pushNamed(context, '/chat');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: purplePrimary),
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.message,
                            color: white,
                          ),
                          Text(
                            "Chat",
                            style: TextStyle(color: white, fontSize: 10),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
                InkWell(
                  onTap: () => _openWhatsapp(mitra.whatsapp),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Color(0xFF128C7E)),
                    width: MediaQuery.of(context).size.width * widthButtonWA,
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 10),
                          child: Image.asset(
                            "assets/icons/icon-whatsapp.png",
                            scale: 4,
                          ),
                        ),
                        Text(
                          "Whatsapp",
                          style: TextStyle(color: white, fontSize: 20),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
