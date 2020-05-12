import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:math';
import 'package:dio/dio.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
            title: TabBar(tabs: [
              Tab(text: 'Example 1: Navigation'),
              Tab(text: 'Example 2: Form'),
              Tab(text: 'Example 3: Scroll')
            ]),
          ),
          body: TabBarView(children: [
            NavigationExample(),
            FormExample(),
            ScrollExample(),
          ])),
    );
  }
}

class NavigationExample extends StatelessWidget {
  String url = "https://dev-tasks.crossroads-group.com/api/user/projects";
  String token =
      "_fbp=fb.1.1585952795850.569407500; jwt-doSsoCookie=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzODI5NTc1Mzc3MTM5ODEyNTEiLCJ1c2VySWQiOiIzODI5NTc1Mzc3MTM5ODEyNTEiLCJleHBpcmVzSW4iOjI1OTIwMDAsImlhdCI6MTU4ODU5OTA5NCwiZXhwIjoxNTkxMTkxMDk0fQ.XTmOMq1_tFnD-dmkv3nAOWkTm6I-inwnWLrVH6v8yx4; crgSsoSessionId=Rp0tahRP3Hw3JbLGbodZ2kf4d2yjgLPy; crgSsoSessionId_expiration=1589327714674";

  Future<dynamic> searchByQuery(String query) async {
    var response = await Dio(BaseOptions(headers: {"cookie": token})).get(
        "https://dev-tasks.crossroads-group.com/api/user/projects",
        queryParameters: {"query": query});
    print(response.data);
    return response.data;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 10.0,
                ),
                TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    autofocus: true,
                    style: DefaultTextStyle.of(context)
                        .style
                        .copyWith(fontStyle: FontStyle.italic),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'What are you looking for?'),
                  ),
                  suggestionsCallback: (pattern) async {
                    return await searchByQuery(pattern);
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      leading: Icon(Icons.shopping_cart),
                      title: Text(suggestion['project']['name'] ?? ""),
                      subtitle: Text('${suggestion['project']['description']}'),
                    );
                  },
                  hideOnLoading: true,
                  onSuggestionSelected: (suggestion) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            ProductPage(product: suggestion)));
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}

class FormExample extends StatefulWidget {
  @override
  _FormExampleState createState() => _FormExampleState();
}

class _FormExampleState extends State<FormExample> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _typeAheadController = TextEditingController();

  String _selectedCity;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: this._formKey,
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          children: <Widget>[
            Text('What is your favorite city?'),
            TypeAheadFormField(
              textFieldConfiguration: TextFieldConfiguration(
                decoration: InputDecoration(labelText: 'City'),
                controller: this._typeAheadController,
              ),
              suggestionsCallback: (pattern) {
                return CitiesService.getSuggestions(pattern);
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion),
                );
              },
              transitionBuilder: (context, suggestionsBox, controller) {
                return suggestionsBox;
              },
              onSuggestionSelected: (suggestion) {
                this._typeAheadController.text = suggestion;
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please select a city';
                }
              },
              onSaved: (value) => this._selectedCity = value,
            ),
            SizedBox(
              height: 10.0,
            ),
            RaisedButton(
              child: Text('Submit'),
              onPressed: () {
                if (this._formKey.currentState.validate()) {
                  this._formKey.currentState.save();
                  Scaffold.of(context).showSnackBar(SnackBar(
                      content:
                          Text('Your Favorite City is ${this._selectedCity}')));
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

class ScrollExample extends StatelessWidget {
  final List<String> items = List.generate(5, (index) => "Item $index");

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      Center(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Suggestion box will resize when scrolling"),
      )),
      SizedBox(height: 200),
      TypeAheadField<String>(
        getImmediateSuggestions: true,
        textFieldConfiguration: TextFieldConfiguration(
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'What are you looking for?'),
        ),
        suggestionsCallback: (String pattern) async {
          return items
              .where((item) =>
                  item.toLowerCase().startsWith(pattern.toLowerCase()))
              .toList();
        },
        itemBuilder: (context, String suggestion) {
          return ListTile(
            title: Text(suggestion),
          );
        },
        onSuggestionSelected: (String suggestion) {
          print("Suggestion selected");
        },
      ),
      SizedBox(height: 500),
    ]);
  }
}

class ProductPage extends StatelessWidget {
  final Map<String, dynamic> product;

  ProductPage({this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          children: [
            Text(
              this.product['name'],
              style: Theme.of(context).textTheme.headline,
            ),
            Text(
              this.product['price'].toString() + ' USD',
              style: Theme.of(context).textTheme.subhead,
            )
          ],
        ),
      ),
    );
  }
}

class BackendService {
  static Future<List> getSuggestions(String query) async {
    await Future.delayed(Duration(seconds: 1));

    return List.generate(3, (index) {
      return {'name': query + index.toString(), 'price': Random().nextInt(100)};
    });
  }
}

class CitiesService {
  static final List<String> cities = [
    'Beirut',
    'Damascus',
    'San Fransisco',
    'Rome',
    'Los Angeles',
    'Madrid',
    'Bali',
    'Barcelona',
    'Paris',
    'Bucharest',
    'New York City',
    'Philadelphia',
    'Sydney',
  ];

  static List<String> getSuggestions(String query) {
    List<String> matches = List();
    matches.addAll(cities);

    matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }
}
