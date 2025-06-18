import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Model Company
class Company {
  final String name;
  final String country;
  final String industry;
  final String locality;
  final String region;
  final String size;
  final String linkedinUrl;
  final String website;

  Company({
    required this.name,
    required this.country,
    required this.industry,
    required this.locality,
    required this.region,
    required this.size,
    required this.linkedinUrl,
    required this.website,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      industry: json['industry'] ?? '',
      locality: json['locality'] ?? '',
      region: json['region'] ?? '',
      size: json['size'] ?? '',
      linkedinUrl: json['linkedin_url'] ?? '',
      website: json['website'] ?? '',
    );
  }
}

// ฟังก์ชันดึงข้อมูลบริษัท
Future<List<Company>> fetchCompanies() async {
  final url = Uri.https(
    'get-list-of-companies.p.rapidapi.com',
    '/',
    {
      'database': 'us',
      'size': '51-200',
      'locality': 'San Francisco',
      'region': 'California',
      'country': 'United States',
      'industry': 'computer software',
      'page': '1',
    },
  );

  final response = await http.get(
    url,
    headers: {
      'X-RapidAPI-Key': 'e02856a639msh0b7aaf7fbc23208p1db95ejsnfa807ce59621', // <-- แก้เป็น API Key ของคุณ
      'X-RapidAPI-Host': 'get-list-of-companies.p.rapidapi.com',
    },
  );

  if (response.statusCode == 200) {
    final jsonBody = jsonDecode(response.body);
    final companiesJson = jsonBody['results'] as List<dynamic>;
    return companiesJson.map((json) => Company.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load companies');
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Company List',
      home: CompanyListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CompanyListPage extends StatefulWidget {
  @override
  _CompanyListPageState createState() => _CompanyListPageState();
}

class _CompanyListPageState extends State<CompanyListPage> {
  late Future<List<Company>> _futureCompanies;

  @override
  void initState() {
    super.initState();
    _futureCompanies = fetchCompanies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('บริษัทซอฟต์แวร์ใน SF, CA, US'),
      ),
      body: FutureBuilder<List<Company>>(
        future: _futureCompanies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // กำลังโหลด
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // เกิดข้อผิดพลาด
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // ไม่มีข้อมูล
            return Center(child: Text('ไม่พบบริษัท'));
          }

          // แสดงรายชื่อบริษัท
          final companies = snapshot.data!;
          return ListView.builder(
            itemCount: companies.length,
            itemBuilder: (context, index) {
              final company = companies[index];
              return ListTile(
                title: Text(company.name),
                subtitle: Text('${company.locality}, ${company.region}'),
                trailing: Text(company.size),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Website: ${company.website}')),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
