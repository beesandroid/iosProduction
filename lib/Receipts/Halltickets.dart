import 'package:flutter/material.dart';

import 'Internal.dart';
import 'external.dart';

class HallTickets extends StatefulWidget {
  const HallTickets({Key? key}) : super(key: key);

  @override
  State<HallTickets> createState() => _HallTicketsState();
}

class _HallTicketsState extends State<HallTickets>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text(
          'Hall Tickets',
          style: TextStyle(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Text(
                'Internal',
                style:
                    TextStyle(color: Colors.white), // Set text color to white
              ),
            ),
            Tab(
              child: Text(
                'External',
                style:
                    TextStyle(color: Colors.white), // Set text color to white
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          InternalView(),
          ExternalView(),
        ],
      ),
    );
  }
}
