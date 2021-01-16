import 'package:elfchat/models/ChatSnippet.dart';
import 'package:elfchat/screens/UserPage.dart';
import 'package:elfchat/services/FireStoreServices.dart';
import 'package:elfchat/services/auth.dart';
import 'package:elfchat/widgets/LoadingWidget.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final AuthServices auth;
  final FireStoreServices db;

  const SearchPage(this.auth, this.db);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var _searchController = TextEditingController();
  bool isSearching = false;
  bool didSearchFail = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  _submuit(String value, List<ElfChatSnippet> chatList) async {
    value = value.trim();
    if (value.isEmpty || value == widget.auth.user.email) return;

    setState(() => isSearching = true);
    var user = await widget.db.searchForUser(value);
    if (user == null) {
      setState(() {
        isSearching = false;
        didSearchFail = true;
      });
    } else {
      Navigator.pushReplacementNamed(
        context,
        '/user',
        arguments: UserPageArguments(chatList: chatList, elfUser: user, form: UserDetailsForm.Search),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onSubmitted: (value) => _submuit(value, ModalRoute.of(context).settings.arguments),
          autofocus: true,
          controller: _searchController,
          cursorColor: Colors.white,
          style: TextStyle(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: 'Search by email address',
            border: InputBorder.none,
          ),
          maxLines: 1,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Icon(Icons.search),
          )
        ],
      ),
      body: Center(
        child: isSearching
            ? LoadingWidget(text: 'Searching')
            : SearchFiller(
                text: didSearchFail ? 'No Results' : 'Find your friends',
                isBroke: didSearchFail,
              ),
      ),
    );
  }
}

class SearchFiller extends StatelessWidget {
  const SearchFiller({
    Key key,
    this.isBroke = false,
    @required this.text,
  }) : super(key: key);

  final bool isBroke;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isBroke ? Icons.search_off : Icons.search,
          size: 150,
          color: Colors.grey,
        ),
        Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            fontSize: 25,
          ),
        )
      ],
    );
  }
}
