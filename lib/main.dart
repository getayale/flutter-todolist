import 'package:flutter/material.dart';

import 'task.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class Task {
  String title;
  bool isCompleted;

  Task({required this.title, this.isCompleted = false});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> tasks = [];

  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final filteredTasks = tasks.where((task) {
      if (selectedFilter == 'Pending') {
        return !task.isCompleted;
      }

      if (selectedFilter == 'Completed') {
        return task.isCompleted;
      }

      return true;
    }).toList();

    final allCount = tasks.length;

    final pendingCount = tasks.where((task) => !task.isCompleted).length;

    final completedCount = tasks.where((task) => task.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 68, 71, 71),
        foregroundColor: Colors.white,
        elevation: 4,
        title: Row(
          children: [
            Image.asset(
              'assets/th.webp',
              width: 32,
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            const Text(
              'TodoList',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () async {
                final newTask = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (context) => const TaskScreen()),
                );

                if (newTask != null && newTask.trim().isNotEmpty) {
                  setState(() {
                    tasks.add(Task(title: newTask.trim()));
                    selectedFilter = 'All';
                  });
                }
              },
              icon: const Icon(Icons.list_alt),
              label: const Text('My Task'),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  selectedFilter = 'Completed';
                });
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Completed'),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['All', 'Pending', 'Completed'].map((filter) {
                final isSelected = selectedFilter == filter;

                final count = filter == 'All'
                    ? allCount
                    : filter == 'Pending'
                    ? pendingCount
                    : completedCount;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedFilter = filter;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? Colors.teal
                            : Colors.grey.shade200,
                        foregroundColor: isSelected
                            ? Colors.white
                            : Colors.black87,
                        elevation: isSelected ? 3 : 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        '$filter ($count)',
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          selectedFilter == 'Completed'
                              ? Icons.task_alt
                              : Icons.checklist,
                          size: 60,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          selectedFilter == 'All'
                              ? 'No tasks yet'
                              : selectedFilter == 'Pending'
                              ? 'No pending tasks'
                              : 'No completed tasks',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];

                      return ListTile(
                        leading: Checkbox(
                          value: task.isCompleted,
                          activeColor: Colors.teal,
                          onChanged: (value) {
                            setState(() {
                              task.isCompleted = value ?? false;
                            });
                          },
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: Text(
                          task.isCompleted ? 'Completed' : 'Pending',
                          style: TextStyle(
                            color: task.isCompleted
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  height: 50,
                  color: const Color.fromARGB(255, 102, 156, 165),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  height: 50,
                  color: const Color.fromARGB(255, 62, 124, 103),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  height: 50,
                  color: const Color.fromARGB(255, 67, 88, 88),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
