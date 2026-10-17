import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/theme_provider.dart';
import 'task.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TodoList',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeProvider.themeMode,
      home: const HomeScreen(),
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
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = themeProvider.isDarkMode;

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
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  selectedFilter = 'Completed';
                });
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Completed'),
            ),
            IconButton(
              onPressed: () {
                context.read<ThemeProvider>().toggleTheme();
              },
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              tooltip: isDarkMode
                  ? 'Switch to light mode'
                  : 'Switch to dark mode',
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
                            : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                        foregroundColor: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
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
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          selectedFilter == 'All'
                              ? 'No tasks yet'
                              : selectedFilter == 'Pending'
                              ? 'No pending tasks'
                              : 'No completed tasks',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
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
                  color: isDarkMode
                      ? const Color(0xFF34565B)
                      : const Color.fromARGB(255, 102, 156, 165),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  height: 50,
                  color: isDarkMode
                      ? const Color(0xFF285846)
                      : const Color.fromARGB(255, 62, 124, 103),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  height: 50,
                  color: isDarkMode
                      ? const Color(0xFF374747)
                      : const Color.fromARGB(255, 67, 88, 88),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
