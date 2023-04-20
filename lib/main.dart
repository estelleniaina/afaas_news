import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:afaas_news/DatabaseHelper.dart';
import 'package:afaas_news/PostDataModel.dart';
import 'package:afaas_news/PostDetail.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Afaas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        useMaterial3: true,
      ),
      // home: const MyHomePage(title: ' Afaas news'),
      home: DefaultTabController(
        length: 2,
        child: const MyHomePage(title: ' Afaas news'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var jsonList, postSavedList;
  List categorieList = [];
  var colHover = Colors.amberAccent;
  var _selectedVadlue, _taxonomie;
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getData();
    getCategories();
  }

  void getData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var path = 'https://afaas-africa.org/wp-json/wl/v1/posts';
      var response = await Dio().get(path, queryParameters: {'category': _selectedVadlue, 'taxonomy' : _taxonomie});
      if (response.statusCode == 200) {
        setState(() {
          jsonList = response.data as List;
        });
      } else {
        print(response.statusCode);
      }
    } catch(e) {
      print(e);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void getCategories() async {
    try {
      var path = 'https://afaas-africa.org/wp-json/wl/v1/categories';
      var response = await Dio().get(path);
      if (response.statusCode == 200) {
        setState(() {
          categorieList = response.data?['lists'] as List;
          _taxonomie = response.data?['taxonomie'];
        });
      } else {
        print(response.statusCode);
      }
    } catch(e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(
        bottom: const TabBar(
          tabs: [
            Tab(text : "Actualités"),
            Tab(text : "Sauvegarde"),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: <Widget>[
            Image.asset(
                'assets/icons/AFAAS.png',
                width: 30,
                height: 30,
            ),
            Text(widget.title),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          Center(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: buildSearch()
                ),
                _isLoading ? CircularProgressIndicator() :  Expanded(
                  child:ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    final PostDataModel Postdata = PostDataModel(jsonList[index]['id'], jsonList[index]['title'], jsonList[index]['content'], jsonList[index]['slug'], jsonList[index]['image']);
                    return Card(
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: jsonList[index]['image'] == '' ?
                            Image.asset(
                                'assets/images/no-image.jpg',
                                width: 50,
                                height: 50,
                                fit: BoxFit.fill
                            ) :
                            Image.network(
                              jsonList[index]['image'],
                              fit: BoxFit.fill,
                              width: 50,
                              height: 50,
                            ),
                          ),
                          title: Html(data: jsonList[index]['title']),
                          // subtitle: Text("Item Sub title"),
                          trailing: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    DatabaseHelper.instance.add(Postdata);
                                    Fluttertoast.showToast(msg: "Post saved on local");
                                  });
                                },
                                child: Icon(Icons.download_for_offline, color: Colors.green,)
                              ),
                            ],
                          ),
                          onTap: () {
                            print("tapped");
                            Navigator.of(context).push(MaterialPageRoute(builder: (context)=> PostDetail(postDataModel: Postdata,)));
                          },
                        ));
                  },
                  itemCount: jsonList == null ? 0 : jsonList.length,
                ),)
              ],
            )

          ),
          FutureBuilder<List<PostDataModel>>(
            future: DatabaseHelper.instance.getPosts(),
            builder: (BuildContext context, AsyncSnapshot<List<PostDataModel>> snapshot) {
              if (!snapshot.hasData) {
                CircularProgressIndicator();
              }

              return snapshot!.data!.isEmpty ?
              Center(child: Text('No posts saved')) :
              ListView(
                children: snapshot.data!.map((post) {
                  return Card(
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: post.image == '' ?
                        Image.asset(
                            'assets/images/no-image.jpg',
                            width: 50,
                            height: 50,
                            fit: BoxFit.fill
                        ) :
                        Image.network(
                          post.image,
                          fit: BoxFit.fill,
                          width: 50,
                          height: 50,
                        ),
                      ),
                      title: Html(data: post.title),
                      // subtitle: Text("Item Sub title"),
                      trailing: Column(
                        children: [
                          InkWell(
                              onTap: () {
                                setState(() {
                                  DatabaseHelper.instance.remove(post.id);
                                  Fluttertoast.showToast(msg: "Post deleted from local data");
                                });
                              },
                              child: Icon(Icons.remove_circle, color: Colors.red, )
                          ),
                        ],
                      ),
                      onTap: () {
                        print("tapped");
                        Navigator.of(context).push(MaterialPageRoute(builder: (context)=> PostDetail(postDataModel: PostDataModel(post.id, post.title, post.content, post.slug, post.image)
                          ,)));
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildSearch() => DropdownButton(
    value: _selectedVadlue,
    hint: Text('Select item'),
    isExpanded: true,
    onChanged: (newValue) {
      setState(() {
        _selectedVadlue = newValue != null ? newValue : 0;
        getData();
      });
    },

    items: categorieList?.map((item) {
      print(categorieList);
      return new DropdownMenuItem(child: Text(item['name']) , value: item['id'].toString());
    })?.toList() ?? [],
  );
}



