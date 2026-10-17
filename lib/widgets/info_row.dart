import 'package:flutter/material.dart';

Widget row(String k, String v, {bool last = false}) => Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          border: last
              ? null
              : Border(
                  bottom: BorderSide(color: Colors.grey.withOpacity(.25)))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(k, style: TextStyle(color: Colors.grey.shade600)),
        Flexible(
            child: Text(v,
                style: const TextStyle(fontWeight: FontWeight.w700),
                textAlign: TextAlign.left)),
      ]),
    );
