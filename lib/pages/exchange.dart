import 'package:exchange_currancy_app/pages/rate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: camel_case_types
class exchangepage extends StatefulWidget {
  const exchangepage({super.key});

  @override
  State<exchangepage> createState() => _exchangepageState();
}

double result = 0;

class _exchangepageState extends State<exchangepage> {
  TextEditingController texteditor = TextEditingController();
  double exchangeRate = 80000; // مقدار اولیه پیش‌فرض

  @override
  void initState() {
    super.initState();
    loadRate();
  }

  void loadRate() async {
    try {
      CurrencyRate rate = await fetchCurrencyRate("youan");
      setState(() {
        exchangeRate = rate.valueInIrr as double;
      });
    } catch (e) {
      exchangeRate = 0;
      print("خطا در گرفتن نرخ: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Exchange Convertor"),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.only(bottom: 10),
              color: Colors.black45,
              child: Text(
                exchangeRate == 0 ? exchangeRate.toString():"${result.toStringAsFixed(2)}\$",
                style: TextStyle(color: Colors.white, fontSize: 33),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 20, right: 20),
              child: TextField(
                controller: texteditor,
                style: TextStyle(color: Colors.black),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[MoneyInputFormatter()],
                decoration: InputDecoration(
                  label: Text("Please Enter the amount"),
                  labelStyle: TextStyle(color: Colors.grey),
                  suffixIcon: Icon(Icons.monetization_on, color: Colors.white),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 15, left: 20, right: 20),
              child: ElevatedButton(
                style: TextButton.styleFrom(
                  elevation: 10,
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.black38,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                onPressed: () {
                  
                  final enteredValue = double.parse(
                    texteditor.text.replaceAll(",", ""),
                  );
                  result = enteredValue / exchangeRate;
                  print(result);
                  setState(() {});
                },
                child: Text("Convert"),
              ),
            ),
            Container(height: 10,),
            exchangeRate == 0
                ? Text(
                    "There is a problem with the initialization or communication with the API.",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

class MoneyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. کاراکترهای غیر عددی (به جز نقطه) رو حذف کن
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');

    // 2. اگر خالی بود یا فقط یک نقطه بود، خالی برگردون (تا از ".." جلوگیری شه)
    if (newText.isEmpty || newText == '.') {
      return TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // 3. پیدا کردن نقطه اعشار (اگر وجود داشت)
    int decimalPointIndex = newText.indexOf('.');
    String integerPart;
    String decimalPart = '';

    if (decimalPointIndex != -1) {
      integerPart = newText.substring(0, decimalPointIndex);
      decimalPart = newText.substring(decimalPointIndex + 1);
    } else {
      integerPart = newText;
    }

    // 4. قسمت صحیح رو فرمت کن (اضافه کردن کاما)
    String formattedIntegerPart = '';
    for (int i = integerPart.length - 1; i >= 0; i--) {
      formattedIntegerPart = integerPart[i] + formattedIntegerPart;
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        formattedIntegerPart = ',$formattedIntegerPart';
      }
    }

    // 5. ساخت متن نهایی
    String finalFormattedText = formattedIntegerPart;
    if (decimalPart.isNotEmpty) {
      finalFormattedText += '.$decimalPart';
    }

    // 6. تنظیم موقعیت نشانگر (cursor)
    // این قسمت کمی پیچیده‌تر هست تا نشانگر در جای صحیح قرار بگیره
    int newOffset = newValue.selection.end;
    int oldLength = oldValue.text.length;
    int newLength = finalFormattedText.length;

    // اگر طول متن جدید بیشتر از قدیم شد (یعنی کاما اضافه شده)
    if (newLength > oldLength) {
      int commaCount = 0;
      for (int i = 0; i < newValue.selection.end; i++) {
        if (finalFormattedText.substring(0, i).replaceAll(',', '').length !=
            newValue.text.substring(0, i).replaceAll(',', '').length) {
          commaCount++;
        }
      }
      newOffset += commaCount;
    } else if (newLength < oldLength) {
      // اگر طول متن جدید کمتر شد (یعنی کاما حذف شده یا عدد کم شده)
      int oldCommaCount = 0;
      for (int i = 0; i < oldValue.selection.end; i++) {
        if (oldValue.text[i] == ',') {
          oldCommaCount++;
        }
      }
      int newCommaCount = 0;
      for (
        int i = 0;
        i < finalFormattedText.length && i < newValue.selection.end;
        i++
      ) {
        if (finalFormattedText[i] == ',') {
          newCommaCount++;
        }
      }
      newOffset = newValue.selection.end - (oldCommaCount - newCommaCount);
    }

    return TextEditingValue(
      text: finalFormattedText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}
