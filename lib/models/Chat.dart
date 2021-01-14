import 'package:elfchat/models/Message.dart';
import 'package:elfchat/models/User.dart';

class ElfChat {
  String chatID;
  final ElfUser user;
  List<ElfMessage> messages;

  ElfChat(this.user, this.chatID);
}
