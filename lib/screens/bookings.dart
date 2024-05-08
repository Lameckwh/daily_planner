import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  late TextEditingController _searchController;
  late Stream<QuerySnapshot> _bookingsStream;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _bookingsStream =
        FirebaseFirestore.instance.collection('bookings').snapshots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      appBar: AppBar(
        title: const Text('Bookings'),
        elevation: 1,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _searchController.clear();
                _bookingsStream = FirebaseFirestore.instance
                    .collection('bookings')
                    .snapshots();
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12), // Add border radius
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search by place name...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    _bookingsStream = FirebaseFirestore.instance
                        .collection('bookings')
                        .where('placeName', isGreaterThanOrEqualTo: value)
                        .snapshots();
                  });
                },
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: _bookingsStream,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var booking = snapshot.data!.docs[index];
                return GestureDetector(
                  onTap: () => _showBookingDetails(context, booking),
                  child: Card(
                    child: ListTile(
                      title: Text(booking['placeName']),
                      subtitle: Text('Arrival Date: ${booking['arrivalDate']}'),
                    ),
                  ),
                );
              },
            );
          }

          return const Center(
            child: Text('No bookings found.'),
          );
        },
      ),
    );
  }

  void _showBookingDetails(BuildContext context, DocumentSnapshot booking) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Booking Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Place Name: ${booking['placeName']}'),
              Text('Booker Name: ${booking['userName']}'),
              Text('Booker Email: ${booking['userEmail']}'),
              Text('Arrival Date: ${booking['arrivalDate']}'),
              Text('Departure Date: ${booking['departureDate']}'),
              Text('Number of Days/Nights: ${booking['numberOfDaysNights']}'),
              Text('Number of Guests: ${booking['numberOfGuests']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
