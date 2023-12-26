import 'package:dandani/models/detailMitraModel.dart';
import 'package:dandani/pages/search.dart';
import 'package:dandani/providers/mitraProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dandani/util/colors.dart';

class kategoriWidget extends StatelessWidget {
  final String text;
  final String keyword;
  final icon;
  final TextEditingController searchController;

  const kategoriWidget({
    required this.text,
    required this.keyword,
    required this.icon,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: grey, padding: EdgeInsets.all(0)),
      onPressed: () {
        (keyword == 'search')
            ? showDialog(
                context: context,
                barrierColor: Colors.black.withOpacity(0.7),
                builder: (context) {
                  return AlertDialog(
                    title: Text('Cari'),
                    content: TextField(
                      controller: searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Cari jasa servis ...',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 10),
                        child: ElevatedButton(
                          onPressed: () {
                            String search = searchController.text;
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchPage(
                                  search: search,
                                  city: "",
                                  district: "",
                                ),
                              ),
                            );
                          },
                          child: Text(
                            'Cari',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: purplePrimary,
                            shadowColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              )
            : Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchPage(
                    search: text,
                    city: "",
                    district: "",
                  ),
                ),
              );
      },
      child: Container(
          width: MediaQuery.of(context).size.width * 0.29,
          height: MediaQuery.of(context).size.width * 0.3 * 0.9,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: white,
              ),
              Container(
                margin: EdgeInsets.only(top: 8),
                child: Text(
                  text,
                  style: TextStyle(
                    color: white,
                  ),
                ),
              )
            ],
          )),
    );
  }
}

class jasaListWidget extends StatelessWidget {
  final String account;
  final String name;
  final String desc;
  final String specialist;
  final String whatsapp;
  final String province;
  final String city;
  final String district;
  final String maps;
  final String photo;

  const jasaListWidget(
      {required this.account,
      required this.name,
      required this.desc,
      required this.specialist,
      required this.whatsapp,
      required this.province,
      required this.city,
      required this.district,
      required this.maps,
      required this.photo});

  @override
  Widget build(BuildContext context) {
    final Mitra mitra = Mitra(
      account,
      name,
      desc,
      specialist,
      whatsapp,
      province,
      city,
      district,
      maps,
      photo,
    );

    return InkWell(
      onTap: () {
        Provider.of<MitraProvider>(context, listen: false).setMitra(mitra);
        Navigator.pushNamed(context, '/detail');
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
                left: BorderSide(color: Colors.grey.shade300),
                right: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Stack(
              children: [
                FadeInImage(
                  width: double.infinity,
                  height: 180,
                  placeholder: AssetImage('assets/grayload.gif'),
                  image: (photo.contains('default.jpg'))
                      ? AssetImage('assets/images/default.jpg')
                      : NetworkImage(photo.split(',')[0]) as ImageProvider,
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.only(bottomRight: Radius.circular(10.0)),
                    color: purplePrimaryTrans,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      district,
                      style: TextStyle(color: white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5)),
              color: white,
              border: Border.all(color: Colors.grey.shade300),
            ),
            // color: white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 5),
                    child: Text(
                      name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text(
                      city,
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  BadgeWidget(specialist: specialist)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class BadgeWidget extends StatelessWidget {
  final String specialist;

  BadgeWidget({required this.specialist});

  @override
  Widget build(BuildContext context) {
    List<String> badgeTexts = specialist.replaceAll(', ', ',').split(',');

    return Wrap(
      spacing: 2.0,
      children: badgeTexts.map((text) => buildBadge(text)).toList(),
    );
  }

  Widget buildBadge(String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: Colors.indigo),
      child: Padding(
        padding: EdgeInsets.all(3),
        child: Text(
          text,
          style: TextStyle(fontSize: 10, color: white),
        ),
      ),
    );
  }
}

class BadgeWidget2 extends StatelessWidget {
  final String specialist;
  BadgeWidget2({required this.specialist});

  @override
  Widget build(BuildContext context) {
    List<String> badgeTexts = specialist.replaceAll(', ', ',').split(',');

    return Wrap(
      spacing: 2.0,
      children: badgeTexts.map((text) => buildBadge(text)).toList(),
    );
  }

  Widget buildBadge(String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: Colors.indigo),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
        child: Text(
          text,
          style: TextStyle(fontSize: 15, color: white),
        ),
      ),
    );
  }
}
