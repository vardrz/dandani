import 'package:flutter/material.dart';
import 'package:dandani/util/colors.dart';

class kategoriWidget extends StatelessWidget {
  final String text;
  final icon;

  const kategoriWidget({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style:
          ElevatedButton.styleFrom(primary: grey, padding: EdgeInsets.all(0)),
      onPressed: () {},
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
  final String nama;
  final String specialist;
  final String alamat;
  final String foto;

  const jasaListWidget(
      {required this.nama,
      required this.specialist,
      required this.alamat,
      required this.foto});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print('pressed jasa service');
      },
      child: Card(
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: Image.asset(foto),
                ),
                Column(
                  children: [
                    Text(nama),
                    Text(specialist),
                    Text(alamat),
                  ],
                )
              ],
            )),
      ),
    );
  }
}
