import 'package:flutter/material.dart';
import 'package:webfeed/domain/rss_feed.dart';
import 'package:webfeed/domain/rss_item.dart';
import 'network.dart';

const color1 = Color(0xff91a1b4);
const color2 = Color(0xff545c6b);

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primaryColor: Color(0xff91a1b4),
          iconTheme: IconThemeData(color: Color(0xff545c6b))),
      home: MyHomePage(
        title: 'Latest news',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  State<StatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<RssFeed> future;
  @override
  void initState() {
    super.initState();

    future = getNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: color1.withOpacity(0.5),
          elevation: 0.0,
          title: Text(
            widget.title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 30.8,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 32.0),
              child: InkWell(
                child: Icon(
                  Icons.share,
                  color: color1,
                ),
              ),
            ),
          ],
        ),
        body: _body());
  }

  Widget _body() {
    return FutureBuilder(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<RssFeed> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.blue[200],
                ),
              );
            case ConnectionState.done:
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 5.0),
                  child: ListView.builder(
                    itemCount: snapshot.data.items.length + 2,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == 0) {
                        return Padding(
                          padding: EdgeInsets.only(top: 8.0, bottom: 16.0),
                          child: Text(snapshot.data.description),
                        );
                      }
                      if (index == 1) {
                        return _bigItem;
                      }
                      return _item(snapshot.data.items[index - 2]);
                    },
                  ));
            default:
              return Text('Result: ${snapshot.data}');
          }
        });
  }
}

Widget _bigItem = Stack(
  alignment: Alignment.center,
  children: [
    ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Image.asset('assets/big_item.png'),
    ),
    Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Icon(
        Icons.play_arrow,
        color: Colors.blueGrey[400],
      ),
    )
  ],
);

Widget _item(RssItem item) {
  var mediaUrl = _extractImage(item.content.value);
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Row(
                  children: [
                    Container(
                      width: 42.0,
                      height: 42.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(21.0),
                        color: Colors.blue[300],
                      ),
                      child: Center(
                        child: Text(item.categories.first.value[0],
                            style: TextStyle(
                              color: Colors.white,
                            )),
                      ),
                    ),
                    Text(
                      ' ' + item.categories.first.value, //por ahora
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Text(item.title),
              Text(item.dc.creator),
            ],
          ),
        ),
        // SizedBox(width: 16.0),
        // Container(
        //   width: 120,
        //   height: 120,
        //   child: Image.network(mediaUrl,
        //   fit: BoxFit.cover,),
        // ),
        Image(
            image: (mediaUrl != null)
                ? NetworkImage(mediaUrl)
                : (AssetImage('assets/item_1.jpg')),
            width: 150,
            height: 150,
            fit: BoxFit.cover),
      ],
    ),
  );
}

String _extractImage(String content) {
  RegExp regExp = RegExp('<img(^>)+src="([^">]+)"');

  Iterable<Match> matches = regExp.allMatches(content);

  if (matches.length > 0) return matches.first.group(1);

  return null;
}
