import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:issuetracker/kasus/kasus_service.dart';

class Kasus {
  final database = Supabase.instance.client.from('KasusService');

//create

  Future createKasus(KasusService newKasus) async {
    await database.insert(newKasus.toMap());
  }

//read

  final stream = Supabase.instance.client.from('KasusService').stream(
    primaryKey: ['id_kasus']
    ).map((data) => data.map((kasusMap) => KasusService.fromMap(kasusMap)).toList());

//update

    Future updateKasus (KasusService oldKasus, String newContent) async {
      await database.update({'content' : newContent}).eq('id_kasus', oldKasus.idKasus!);
    }

    //Delete

    Future deleteKasus (KasusService kasus) async{
      await database.delete().eq('id_kasus', kasus.idKasus!);
    }
}
