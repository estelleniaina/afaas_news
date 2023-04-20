import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:afaas_news/PostDataModel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/dom.dart' as dom;
class PostDetail extends StatelessWidget {
  final PostDataModel postDataModel;
  const PostDetail({Key? key, required this.postDataModel}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset : true,
      appBar: AppBar(
        title: Html(data: postDataModel.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child:  Column(
          children: [
            //postDataModel.image == '' ? Text("") :
            // Padding(
            //   padding: EdgeInsets.only(top: 10),
            //   child: Image.network(postDataModel.image, alignment: Alignment.center,),
            // ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Html(
                  data: postDataModel.content,
                  onLinkTap: (String? link, RenderContext context, Map<String, String> attributes, dom.Element? element) async {
                    await launch(link!);
                  }
              ),
            ),
          ],
        ),
      ),
    );
  }
}
