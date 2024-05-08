import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_tourism/forms/tourist_centre_form.dart';
import 'package:eco_tourism/screens/destination_detail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

void _confirmDeleteTouristCentre(
    BuildContext context, String documentId, String? imageUrl) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Delete'),
        content:
            const Text('Are you sure you want to delete this tourist_centre?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteTouristCentre(documentId, imageUrl);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}

void _deleteTouristCentre(String documentId, String? imageUrl) async {
  await FirebaseFirestore.instance
      .collection('tourist_centres')
      .doc(documentId)
      .delete();

  if (imageUrl != null) {
    await FirebaseStorage.instance.refFromURL(imageUrl).delete();
  }
}

class TouristCentres extends StatefulWidget {
  const TouristCentres({super.key});

  @override
  State<TouristCentres> createState() => _TouristCentresState();
}

class _TouristCentresState extends State<TouristCentres> {
  late TextEditingController _searchController;
  late User? _currentUser;
  late String _userType = '';

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _fetchUserType();
    _searchController = TextEditingController();
  }

  Future<void> _fetchUserType() async {
    if (_currentUser != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();
      setState(() {
        _userType = doc['userType'];
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showAddButton = _currentUser != null && _userType == 'admin';
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 1,

        backgroundColor: const Color.fromRGBO(1, 142, 1, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back when pressed
          },
          color: Colors.white, // Set the color of the arrow to white
        ),

        // titleSpacing: 1,
        title: const Text(
          "Tourist Centres",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(
                  context: context, delegate: _TouristCentreSearchDelegate());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          if (showAddButton)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      // Navigate to the screen where hotels can be added
                      // Replace 'DestinationDetailPage' with the appropriate screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TouristCentresForm(),
                        ),
                      );
                    },
                    child: const Text(
                      'Add Tourist Centre',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('tourist_centres')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                        'Error fetching data. Please check your network connection.'),
                  );
                }

                final touristCentres = snapshot.data!.docs;

                if (touristCentres.isEmpty) {
                  return const Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Text('No TouristCentre Posted Yet'),
                    ],
                  );
                }

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: touristCentres.length,
                  itemBuilder: (context, index) {
                    final touristCentre = touristCentres[index];
                    final name = touristCentre['name'];
                    final email = touristCentre['email'];
                    final phoneNumber = touristCentre['phoneNumber'];
                    final location = touristCentre['location'];
                    final price = touristCentre['price'];
                    final description = touristCentre['description'];
                    final datePosted =
                        (touristCentre['datePosted'] as Timestamp).toDate();
                    final imageUrl = touristCentre['imageUrl'];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DestinationDetailPage(
                              name: name,
                              email: email,
                              phoneNumber: phoneNumber,
                              location: location,
                              price: price,
                              description: description,
                              datePosted: datePosted,
                              imageUrl: imageUrl,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 2 - 20,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.4),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            if (showAddButton)
                                              IconButton(
                                                tooltip: 'Delete TouristCentre',
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  _confirmDeleteTouristCentre(
                                                      context,
                                                      touristCentre.id,
                                                      touristCentre[
                                                          'imageUrl']);
                                                },
                                              ),
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            RatingBar.builder(
                                              initialRating: 2,
                                              minRating: 1,
                                              direction: Axis.horizontal,
                                              allowHalfRating: true,
                                              itemCount: 5,
                                              itemSize: 20,
                                              itemPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4),
                                              itemBuilder: (context, _) =>
                                                  const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              ),
                                              unratedColor: Colors.white,
                                              onRatingUpdate: (rating) {},
                                            ),
                                            Text(
                                              name,
                                              style: const TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String formattedDate(DateTime date) {
    return DateFormat('HH:mm, d MMM y').format(date);
  }
}

class _TouristCentreSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      // Show all tourist_centres if query is empty
      return _buildAllTouristCentres(context);
    } else {
      // Show search results based on the query
      return _buildSearchResults(context);
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      // Show all tourist_centres if query is empty
      return _buildAllTouristCentres(context);
    } else {
      // Show search suggestions based on the query
      return _buildSearchResults(context);
    }
  }

  Widget _buildAllTouristCentres(BuildContext context) {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection('tourist_centres').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
                'Error fetching data. Please check your network connection.'),
          );
        }

        final touristCentres = snapshot.data!.docs;

        if (touristCentres.isEmpty) {
          return const Center(
            child: Text('No TouristCentre Posted Yet'),
          );
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: touristCentres.length,
          itemBuilder: (context, index) {
            final touristCentre = touristCentres[index];
            final name = touristCentre['name'];
            final email = touristCentre['email'];
            final phoneNumber = touristCentre['phoneNumber'];
            final location = touristCentre['location'];
            final price = touristCentre['price'];
            final description = touristCentre['description'];
            final datePosted =
                (touristCentre['datePosted'] as Timestamp).toDate();
            final imageUrl = touristCentre['imageUrl'];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DestinationDetailPage(
                      name: name,
                      email: email,
                      phoneNumber: phoneNumber,
                      location: location,
                      price: price,
                      description: description,
                      datePosted: datePosted,
                      imageUrl: imageUrl,
                    ),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 20,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      tooltip: 'Delete TouristCentre',
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        _confirmDeleteTouristCentre(
                                            context,
                                            touristCentre.id,
                                            touristCentre['imageUrl']);
                                      },
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RatingBar.builder(
                                      initialRating: 2,
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemSize: 20,
                                      itemPadding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      itemBuilder: (context, _) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      unratedColor: Colors.white,
                                      onRatingUpdate: (rating) {},
                                    ),
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection('tourist_centres').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
                'Error fetching data. Please check your network connection.'),
          );
        }

        final touristCentres = snapshot.data!.docs;

        if (touristCentres.isEmpty) {
          return const Center(
            child: Text('No results found'),
          );
        }

        final filteredTouristCentres = touristCentres.where((touristCentre) {
          final name = touristCentre['name'].toString().toLowerCase();
          return name.contains(query.toLowerCase());
        }).toList();

        if (filteredTouristCentres.isEmpty) {
          return const Center(
            child: Text('No results found'),
          );
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: filteredTouristCentres.length,
          itemBuilder: (context, index) {
            final touristCentre = filteredTouristCentres[index];
            final name = touristCentre['name'];
            final email = touristCentre['email'];
            final phoneNumber = touristCentre['phoneNumber'];
            final location = touristCentre['location'];
            final price = touristCentre['price'];
            final description = touristCentre['description'];
            final datePosted =
                (touristCentre['datePosted'] as Timestamp).toDate();
            final imageUrl = touristCentre['imageUrl'];

            return GestureDetector(
              onTap: () {
                // Navigate to tourist_centre detail page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DestinationDetailPage(
                      name: name,
                      email: email,
                      phoneNumber: phoneNumber,
                      location: location,
                      price: price,
                      description: description,
                      datePosted: datePosted,
                      imageUrl: imageUrl,
                    ),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 20,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      tooltip: 'Delete TouristCentre',
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        _confirmDeleteTouristCentre(
                                            context,
                                            touristCentre.id,
                                            touristCentre['imageUrl']);
                                      },
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RatingBar.builder(
                                      initialRating: 2,
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemSize: 20,
                                      itemPadding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      itemBuilder: (context, _) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      unratedColor: Colors.white,
                                      onRatingUpdate: (rating) {},
                                    ),
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
