import 'package:nfc_manager/nfc_manager.dart';

class NFCProvider {

  void ReadData(void Function(String,int) callback) async {

    String hexIdentifier = '';
    try {
      NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        try {
          late var mifare;
          late var mifareIdentifier;
          if(tag.data['mifareultralight'] != null) {
              mifare = tag.data['mifareultralight'];
              mifareIdentifier = mifare['identifier'];
          }
          else if(tag.data['mifareclassic'] != null) {
              mifare = tag.data['mifareclassic'];
              mifareIdentifier = mifare['identifier'];
          }
          else if(tag.data['isodep'] != null) {
            mifare = tag.data['isodep'];
            mifareIdentifier = mifare['identifier'];
          }
          else {
            callback('',-4);
            return;
          }
          //Creating Hex identifier.
          String identifier = mifareIdentifier.map((e) =>
              e.toRadixString(16).padLeft(2, '0')).join('');
          for(var i =0; i < identifier.length; i+=2) {
            hexIdentifier += identifier.substring(i,i + 2) + ' ';
          }
          hexIdentifier = hexIdentifier.substring(0, hexIdentifier.length - 1);
          NfcManager.instance.stopSession();
        }
        catch(ex) {
          if(await NfcManager.instance.isAvailable()) {
            NfcManager.instance.stopSession();
          }
          callback('$ex',-2);
          return;
        }
        callback(hexIdentifier,1);
      });
    }
    catch(ex) {
      if(await NfcManager.instance.isAvailable()) {
        NfcManager.instance.stopSession();
      }
      callback('$ex', -3);
    }
    finally { }
  }

  void StopNFC() async {
    if (await NfcManager.instance.isAvailable()) {
      await NfcManager.instance.stopSession();
    }
  }


  //             //     formattable!.format(mes// void WriteData(void Function(String,int) callback) async {
//   //
//   //   try {
//   //     NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
//   //       try {
//   //           var mifare = tag.data['mifareultralight'];
//   //           var mifareIdentifier = mifare['identifier'];
//   //           var mifareType = mifare['type'];
//   //           String technology = '';
//   //           if(mifareType == 2) {
//   //             technology = ('''Technologies: NfcA, MifareUltralight, NdefFormatable''' + '''Mifare Ultralight type: Ultralight C''');
//   //           }
//   //           else {
//   //             callback('The card technology is not supported.',-1);
//   //             return;
//   //           }
//   //           //Creating Hex identifier.
//   //           String hexIdentifier = '';
//   //           String reversedHexIdentifier = '';
//   //           String identifier = mifareIdentifier.map((e) =>
//   //                                   e.toRadixString(16).padLeft(2, '0')).join('');
//   //           for(var i =0; i < identifier.length; i+=2) {
//   //             hexIdentifier += identifier.substring(i,i + 2) + ' ';
//   //           }
//   //           hexIdentifier = hexIdentifier.substring(0, hexIdentifier.length - 1);
//   //           //reversedHexIdentifier = hexIdentifier.split('').reversed.join().split('').reversed.join();
//   //
//   //
//   //
//   //           //Creating Decimal identifier.
//   //           // String decIdentifier = '';
//   //           // for (int i = 0; i <= hexIdentifier.length - 8; i += 8) {
//   //           //   final hex = hexIdentifier.substring(i, i + 8);
//   //           //   decIdentifier += int.parse(hex, radix: 16).toString();
//   //           // }
//   //           //String reversedDecIdentifier = decIdentifier.split('').reversed.join().split('').reversed.join();
//   //           //Creating the final text.
//   //           //hexIdentifier = 'ID (Hex): ' + hexIdentifier;
//   //           //reversedHexIdentifier = 'ID (reversed hex): ' + reversedHexIdentifier;
//   //           // decIdentifier = 'ID (dec): ' + decIdentifier;
//   //           // reversedDecIdentifier = 'ID (reversed dec): ' + reversedDecIdentifier;
//   //           //var text = '$hexIdentifier' + '\n$reversedHexIdentifier' /*+ '''$decIdentifier''' + '''$reversedDecIdentifier''' */+ '\n$technology';
//   //
//   //           //Write on the tag.
//   //           //var ndef = Ndef.from(tag);
//   //           //try {
//   //             // NdefMessage message = new NdefMessage([
//   //             //   NdefRecord.createText(text,languageCode: 'en'),
//   //             //   NdefRecord.createText('Ho',languageCode: 'en'),
//   //             //   NdefRecord.createText('HF',languageCode: 'en')
//   //             // ]);
//   //             // if(ndef != null) {
//   //             //     ndef.write(message);
//   //             // }
//   //             // else {
//   //             //   var formattable = NdefFormatable.from(tag);
//   //             //   if(formattable != null) {sage);
  //             //   }
  //             //   else {
  //             //     callback('Either Ndef or Formattable tags are not found.',-2);
  //             //     return;
  //             //   }
  //             //   // identifier = formattable!.identifier.map((e) =>
  //             //   //     e.toRadixString(16).padLeft(2, '0')).join('');
  //             // }
  //             NfcManager.instance.stopSession();
  //       }
  //       catch(ex) {
  //         if(await NfcManager.instance.isAvailable()) {
  //           NfcManager.instance.stopSession();
  //         }
  //         callback('An error: $ex',-2);
  //         return;
  //       }
  //       callback('Successfully restoring the NFC card.',1);
  //     });
  //   }
  //   catch(ex) {
  //     NfcManager.instance.stopSession();
  //     callback('An error: $ex', -3);
  //     return;
  //   }
  //   finally { }
  // }

}