import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dandani/widgets/widget.dart';
import 'package:dandani/util/colors.dart';

import 'package:dandani/models/detailMitraModel.dart';

import 'package:dandani/providers/mitraProvider.dart';
import 'package:dandani/providers/listChatProvider.dart';

class DetailPage extends StatelessWidget {
  // const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    Mitra? mitra = Provider.of<MitraProvider>(context).mitra;
    var userLoggedEmail =
        Provider.of<ConversationProvider>(context).userLoggedEmail;
    double widthButtonWA = (mitra?.account == userLoggedEmail) ? 0.88 : 0.67;

    return Scaffold(
      appBar: AppBar(
        title: Text(mitra!.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // main info
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover, image: NetworkImage(mitra.photo))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    width: double.infinity,
                    color: purplePrimaryTrans,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
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
                        InkWell(
                          onTap: () {
                            print('press maps');
                          },
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    '''Lorem ipsum dolor, sit amet consectetur adipisicing elit. Aut velit iusto in earum dolorem nemo alias a distinctio vitae! Non accusantium impedit harum necessitatibus distinctio velit consequatur quidem corrupti vel.
      
Blanditiis doloribus perferendis ipsam sed consequatur aliquam possimus cumque laborum quis? Provident reiciendis, ea optio tempore nobis adipisci est ipsa maxime nulla beatae totam ad aliquid molestias similique vero ipsam!''',
                    style: TextStyle(fontSize: 15),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      "Spesialis",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  BadgeWidget2(specialist: mitra.specialist),
                ],
              ),
            ),
            // contact
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (mitra.account != userLoggedEmail) ...[
                    InkWell(
                      onTap: () {
                        Provider.of<ConversationProvider>(context,
                                listen: false)
                            .getConversationsByEmail(mitra.name, mitra.account);

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
                  Container(
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
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
