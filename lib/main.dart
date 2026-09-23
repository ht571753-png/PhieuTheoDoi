import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// ==================== 1. CƠ SỞ DỮ LIỆU SQLITE ====================
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('phieu_pt78bh.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final fullPath = p.join(dbPath, filePath);
    return await openDatabase(fullPath, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shspn TEXT,
        full_name TEXT NOT NULL,
        alias_name TEXT,
        dob TEXT,
        hometown TEXT,
        residence TEXT,
        cccd TEXT,
        cccd_date TEXT,
        cccd_place TEXT,
        ethnicity TEXT,
        nationality TEXT,
        religion TEXT,
        education TEXT,
        crime TEXT,
        arrest_date TEXT,
        sentence TEXT,
        arrival_date TEXT,
        judgment_no TEXT,
        judgment_court TEXT,
        detention_time TEXT,
        prior_conviction TEXT,
        prior_offense TEXT,
        drug_history TEXT,
        medical_history TEXT,
        fine_penalty TEXT,
        fine_status TEXT,
        compensation TEXT,
        compensation_status TEXT,
        crime_summary TEXT,
        father_info TEXT,
        mother_info TEXT,
        spouse_info TEXT,
        children_info TEXT,
        siblings_info TEXT,
        officer_note TEXT
      )
    ''');
  }

  Future<int> insertProfile(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('profiles', row);
  }

  Future<int> updateProfile(int id, Map<String, dynamic> row) async {
    final db = await database;
    return await db.update('profiles', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteProfile(int id) async {
    final db = await database;
    return await db.delete('profiles', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllProfiles() async {
    final db = await database;
    return await db.query('profiles', orderBy: 'id DESC');
  }
}

// ==================== 2. MÀN HÌNH CHÍNH ====================
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    title: 'Phiếu Theo Dõi Phạm Nhân PT78BH',
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
  ));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _profiles = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearch);
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.getAllProfiles();
    setState(() {
      _profiles = data;
      _filtered = data;
      _isLoading = false;
    });
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase().trim();
    setState(() {
      if (q.isEmpty) {
        _filtered = _profiles;
      } else {
        _filtered = _profiles.where((p) {
          final name = (p['full_name'] ?? '').toString().toLowerCase();
          final shspn = (p['shspn'] ?? '').toString().toLowerCase();
          final cccd = (p['cccd'] ?? '').toString().toLowerCase();
          final crime = (p['crime'] ?? '').toString().toLowerCase();
          return name.contains(q) || shspn.contains(q) || cccd.contains(q) || crime.contains(q);
        }).toList();
      }
    });
  }

  void _openEditScreen(Map<String, dynamic>? item) async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileEditScreen(profile: item)),
    );
    if (res == true) _loadData();
  }

  Future<void> _exportHtmlPrint(Map<String, dynamic> item) async {
    final buffer = StringBuffer();
    buffer.write('''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>PHIẾU THEO DÕI QUÁ TRÌNH CHẤP HÀNH ÁN PHẠT TÙ</title>
<style>
  @page { size: portrait; margin: 15mm; }
  body { font-family: "Times New Roman", Times, serif; font-size: 13px; line-height: 1.5; }
  .center { text-align: center; }
  .bold { font-weight: bold; }
  .header-tbl { width: 100%; border-collapse: collapse; margin-bottom: 15px; }
  .header-tbl td { border: none; padding: 2px; }
  .title { font-size: 16px; font-weight: bold; text-align: center; margin: 15px 0 5px 0; }
  .section { font-weight: bold; margin-top: 15px; text-transform: uppercase; }
</style>
</head>
<body onload="window.print()">
  <table class="header-tbl">
    <tr>
      <td style="width: 50%;" class="center">
        CỤC C10<br><b>TRẠI GIAM THỦ ĐỨC</b>
      </td>
      <td style="width: 50%;" class="center">
        <b>Mẫu PT78BH theo TT số 74/2026/TT-BCA</b><br>Ngày 01/06/2026
      </td>
    </tr>
  </table>

  <div class="title">PHIẾU THEO DÕI<br>QUÁ TRÌNH CHẤP HÀNH ÁN PHẠT TÙ CỦA PHẠM NHÂN</div>
  <div class="center" style="margin-bottom: 20px;">SHSPN: <b>\${item['shspn'] ?? ''}</b></div>

  <div class="section">I. SƠ LƯỢC LÝ LỊCH:</div>
  <div>- Họ và tên: <b>\${(item['full_name'] ?? '').toUpperCase()}</b>; Tên gọi khác: \${item['alias_name'] ?? ''}</div>
  <div>- Ngày sinh: \${item['dob'] ?? ''}; Quê quán: \${item['hometown'] ?? ''}</div>
  <div>- Nơi thường trú: \${item['residence'] ?? ''}</div>
  <div>- Số CCCD/CC/Hộ chiếu: \${item['cccd'] ?? ''}; Ngày cấp: \${item['cccd_date'] ?? ''}; Nơi cấp: \${item['cccd_place'] ?? ''}</div>
  <div>- Dân tộc: \${item['ethnicity'] ?? ''}; Quốc tịch: \${item['nationality'] ?? 'Việt Nam'}; Tôn giáo: \${item['religion'] ?? 'Không'}; Trình độ: \${item['education'] ?? ''}</div>
  <div>- Tội danh: <b>\${item['crime'] ?? ''}</b></div>
  <div>- Ngày bắt: \${item['arrest_date'] ?? ''}; Án phạt: <b>\${item['sentence'] ?? ''}</b>; Ngày đến trại: \${item['arrival_date'] ?? ''}</div>
  <div>- Bản án/QĐ số: \${item['judgment_no'] ?? ''} của TAND \${item['judgment_court'] ?? ''}</div>
  <div>- Thời gian tạm giữ, tạm giam: \${item['detention_time'] ?? ''}</div>
  <div>- Tiền án: \${item['prior_conviction'] ?? 'Không'}</div>
  <div>- Tiền sự: \${item['prior_offense'] ?? 'Không'}</div>
  <div>- Tiền sử nghiện ma túy: \${item['drug_history'] ?? 'Không'}</div>
  <div>- Tiền sử bệnh tật: \${item['medical_history'] ?? 'Bình thường'}</div>
  <div>- Hình phạt tiền: \${item['fine_penalty'] ?? ''} (Tình trạng: \${item['fine_status'] ?? ''})</div>
  <div>- Bồi thường dân sự: \${item['compensation'] ?? ''} (Tình trạng: \${item['compensation_status'] ?? ''})</div>

  <div class="section">II. TÓM TẮT HÀNH VI PHẠM TỘI:</div>
  <div style="text-align: justify;">\${item['crime_summary'] ?? 'Đang cập nhật...'}</div>

  <div class="section">III. QUAN HỆ GIA ĐÌNH:</div>
  <div>- Bố: \${item['father_info'] ?? ''}</div>
  <div>- Mẹ: \${item['mother_info'] ?? ''}</div>
  <div>- Vợ/Chồng: \${item['spouse_info'] ?? ''}</div>
  <div>- Con cái: \${item['children_info'] ?? ''}</div>
  <div>- Anh chị em ruột: \${item['siblings_info'] ?? ''}</div>

  <div class="section">IV. NHẬN XÉT CỦA CÁN BỘ QUẢN GIÁO:</div>
  <div style="text-align: justify;">\${item['officer_note'] ?? 'Chấp hành tốt nội quy cơ sở giam giữ.'}</div>
</body>
</html>
''');

    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('\${tempDir.path}/Phieu_PT78BH_\${item['shspn'] ?? item['id']}.html');
      await file.writeAsString(buffer.toString());

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/html')],
        text: 'Phiếu theo dõi phạm nhân \${item['full_name']} (Mở bằng Chrome để In hoặc Lưu PDF)',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi xuất bản in: \$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PHIẾU THEO DÕI PHẠM NHÂN (PT78BH)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo Tên, SHSPN, CCCD, Can tội...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const Center(child: Text('Chưa có hồ sơ phạm nhân nào.'))
                    : ListView.builder(
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final item = _filtered[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blueGrey[800],
                                child: Text('\${index + 1}', style: const TextStyle(color: Colors.white)),
                              ),
                              title: Text((item['full_name'] ?? '').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                              subtitle: Text(
                                'SHSPN: \${item['shspn'] ?? '-'} | Năm sinh: \${item['dob'] ?? '-'}\nTội danh: \${item['crime'] ?? '-'}\nÁn phạt: \${item['sentence'] ?? '-'}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.print, color: Colors.indigo),
                                    tooltip: 'In phiếu PT78BH',
                                    onPressed: () => _exportHtmlPrint(item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _openEditScreen(item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      await DatabaseHelper.instance.deleteProfile(item['id']);
                                      _loadData();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueGrey[900],
        onPressed: () => _openEditScreen(null),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Lập Phiếu Mới', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

// ==================== 3. BIỂU MẪU CẬP NHẬT THEO MẪU PT78BH ====================
class ProfileEditScreen extends StatefulWidget {
  final Map<String, dynamic>? profile;
  const ProfileEditScreen({Key? key, this.profile}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  final _shspnCtl = TextEditingController();
  final _nameCtl = TextEditingController();
  final _aliasCtl = TextEditingController();
  final _dobCtl = TextEditingController();
  final _hometownCtl = TextEditingController();
  final _residenceCtl = TextEditingController();
  final _cccdCtl = TextEditingController();
  final _cccdDateCtl = TextEditingController();
  final _cccdPlaceCtl = TextEditingController();
  final _ethnicityCtl = TextEditingController(text: 'Kinh');
  final _nationalityCtl = TextEditingController(text: 'Việt Nam');
  final _religionCtl = TextEditingController(text: 'Không');
  final _educationCtl = TextEditingController();
  final _crimeCtl = TextEditingController();
  final _arrestDateCtl = TextEditingController();
  final _sentenceCtl = TextEditingController();
  final _arrivalDateCtl = TextEditingController();
  final _judgmentNoCtl = TextEditingController();
  final _judgmentCourtCtl = TextEditingController();
  final _detentionTimeCtl = TextEditingController();
  final _priorConvictionCtl = TextEditingController();
  final _priorOffenseCtl = TextEditingController();
  final _drugHistoryCtl = TextEditingController();
  final _medicalHistoryCtl = TextEditingController();
  final _finePenaltyCtl = TextEditingController();
  final _fineStatusCtl = TextEditingController();
  final _compensationCtl = TextEditingController();
  final _compensationStatusCtl = TextEditingController();

  final _crimeSummaryCtl = TextEditingController();

  final _fatherCtl = TextEditingController();
  final _motherCtl = TextEditingController();
  final _spouseCtl = TextEditingController();
  final _childrenCtl = TextEditingController();
  final _siblingsCtl = TextEditingController();

  final _officerNoteCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    if (p != null) {
      _shspnCtl.text = p['shspn'] ?? '';
      _nameCtl.text = p['full_name'] ?? '';
      _aliasCtl.text = p['alias_name'] ?? '';
      _dobCtl.text = p['dob'] ?? '';
      _hometownCtl.text = p['hometown'] ?? '';
      _residenceCtl.text = p['residence'] ?? '';
      _cccdCtl.text = p['cccd'] ?? '';
      _cccdDateCtl.text = p['cccd_date'] ?? '';
      _cccdPlaceCtl.text = p['cccd_place'] ?? '';
      _ethnicityCtl.text = p['ethnicity'] ?? 'Kinh';
      _nationalityCtl.text = p['nationality'] ?? 'Việt Nam';
      _religionCtl.text = p['religion'] ?? 'Không';
      _educationCtl.text = p['education'] ?? '';
      _crimeCtl.text = p['crime'] ?? '';
      _arrestDateCtl.text = p['arrest_date'] ?? '';
      _sentenceCtl.text = p['sentence'] ?? '';
      _arrivalDateCtl.text = p['arrival_date'] ?? '';
      _judgmentNoCtl.text = p['judgment_no'] ?? '';
      _judgmentCourtCtl.text = p['judgment_court'] ?? '';
      _detentionTimeCtl.text = p['detention_time'] ?? '';
      _priorConvictionCtl.text = p['prior_conviction'] ?? '';
      _priorOffenseCtl.text = p['prior_offense'] ?? '';
      _drugHistoryCtl.text = p['drug_history'] ?? '';
      _medicalHistoryCtl.text = p['medical_history'] ?? '';
      _finePenaltyCtl.text = p['fine_penalty'] ?? '';
      _fineStatusCtl.text = p['fine_status'] ?? '';
      _compensationCtl.text = p['compensation'] ?? '';
      _compensationStatusCtl.text = p['compensation_status'] ?? '';
      _crimeSummaryCtl.text = p['crime_summary'] ?? '';
      _fatherCtl.text = p['father_info'] ?? '';
      _motherCtl.text = p['mother_info'] ?? '';
      _spouseCtl.text = p['spouse_info'] ?? '';
      _childrenCtl.text = p['children_info'] ?? '';
      _siblingsCtl.text = p['siblings_info'] ?? '';
      _officerNoteCtl.text = p['officer_note'] ?? '';
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final row = {
        'shspn': _shspnCtl.text.trim(),
        'full_name': _nameCtl.text.trim(),
        'alias_name': _aliasCtl.text.trim(),
        'dob': _dobCtl.text.trim(),
        'hometown': _hometownCtl.text.trim(),
        'residence': _residenceCtl.text.trim(),
        'cccd': _cccdCtl.text.trim(),
        'cccd_date': _cccdDateCtl.text.trim(),
        'cccd_place': _cccdPlaceCtl.text.trim(),
        'ethnicity': _ethnicityCtl.text.trim(),
        'nationality': _nationalityCtl.text.trim(),
        'religion': _religionCtl.text.trim(),
        'education': _educationCtl.text.trim(),
        'crime': _crimeCtl.text.trim(),
        'arrest_date': _arrestDateCtl.text.trim(),
        'sentence': _sentenceCtl.text.trim(),
        'arrival_date': _arrivalDateCtl.text.trim(),
        'judgment_no': _judgmentNoCtl.text.trim(),
        'judgment_court': _judgmentCourtCtl.text.trim(),
        'detention_time': _detentionTimeCtl.text.trim(),
        'prior_conviction': _priorConvictionCtl.text.trim(),
        'prior_offense': _priorOffenseCtl.text.trim(),
        'drug_history': _drugHistoryCtl.text.trim(),
        'medical_history': _medicalHistoryCtl.text.trim(),
        'fine_penalty': _finePenaltyCtl.text.trim(),
        'fine_status': _fineStatusCtl.text.trim(),
        'compensation': _compensationCtl.text.trim(),
        'compensation_status': _compensationStatusCtl.text.trim(),
        'crime_summary': _crimeSummaryCtl.text.trim(),
        'father_info': _fatherCtl.text.trim(),
        'mother_info': _motherCtl.text.trim(),
        'spouse_info': _spouseCtl.text.trim(),
        'children_info': _childrenCtl.text.trim(),
        'siblings_info': _siblingsCtl.text.trim(),
        'officer_note': _officerNoteCtl.text.trim(),
      };

      if (widget.profile == null) {
        await DatabaseHelper.instance.insertProfile(row);
      } else {
        await DatabaseHelper.instance.updateProfile(widget.profile!['id'], row);
      }

      if (mounted) Navigator.pop(context, true);
    }
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueGrey[900])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.profile == null ? 'Lập Phiếu PT78BH Mới' : 'Cập Nhật Phiếu PT78BH'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection('I. SƠ LƯỢC LÝ LỊCH'),
            Row(
              children: [
                Expanded(child: TextFormField(controller: _shspnCtl, decoration: const InputDecoration(labelText: 'Số HSPN (SHSPN)', border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                Expanded(child: TextFormField(controller: _dobCtl, decoration: const InputDecoration(labelText: 'Ngày sinh (dd/MM/yyyy)', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(controller: _nameCtl, decoration: const InputDecoration(labelText: 'Họ và tên phạm nhân *', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Bắt buộc' : null),
            const SizedBox(height: 8),
            TextFormField(controller: _aliasCtl, decoration: const InputDecoration(labelText: 'Tên gọi khác (nếu có)', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextFormField(controller: _hometownCtl, decoration: const InputDecoration(labelText: 'Quê quán', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextFormField(controller: _residenceCtl, decoration: const InputDecoration(labelText: 'Nơi thường trú', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(flex: 2, child: TextFormField(controller: _cccdCtl, decoration: const InputDecoration(labelText: 'Số CCCD/CC/Hộ chiếu', border: OutlineInputBorder()))),
                const SizedBox(width: 6),
                Expanded(child: TextFormField(controller: _cccdDateCtl, decoration: const InputDecoration(labelText: 'Ngày cấp', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(controller: _cccdPlaceCtl, decoration: const InputDecoration(labelText: 'Nơi cấp CCCD', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: TextFormField(controller: _ethnicityCtl, decoration: const InputDecoration(labelText: 'Dân tộc', border: OutlineInputBorder()))),
                const SizedBox(width: 6),
                Expanded(child: TextFormField(controller: _nationalityCtl, decoration: const InputDecoration(labelText: 'Quốc tịch', border: OutlineInputBorder()))),
                const SizedBox(width: 6),
                Expanded(child: TextFormField(controller: _religionCtl, decoration: const InputDecoration(labelText: 'Tôn giáo', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(controller: _crimeCtl, decoration: const InputDecoration(labelText: 'Tội danh', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: TextFormField(controller: _arrestDateCtl, decoration: const InputDecoration(labelText: 'Ngày bắt', border: OutlineInputBorder()))),
                const SizedBox(width: 6),
                Expanded(child: TextFormField(controller: _sentenceCtl, decoration: const InputDecoration(labelText: 'Án phạt', border: OutlineInputBorder()))),
                const SizedBox(width: 6),
                Expanded(child: TextFormField(controller: _arrivalDateCtl, decoration: const InputDecoration(labelText: 'Ngày đến trại', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: TextFormField(controller: _judgmentNoCtl, decoration: const InputDecoration(labelText: 'Bản án số', border: OutlineInputBorder()))),
                const SizedBox(width: 6),
                Expanded(child: TextFormField(controller: _judgmentCourtCtl, decoration: const InputDecoration(labelText: 'TAND ra bản án', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(controller: _priorConvictionCtl, decoration: const InputDecoration(labelText: 'Tiền án (ghi rõ từng lần)', border: OutlineInputBorder()), maxLines: 2),
            const SizedBox(height: 8),
            TextFormField(controller: _priorOffenseCtl, decoration: const InputDecoration(labelText: 'Tiền sự (ghi rõ từng lần)', border: OutlineInputBorder()), maxLines: 2),
            const SizedBox(height: 8),
            TextFormField(controller: _drugHistoryCtl, decoration: const InputDecoration(labelText: 'Tiền sử nghiện ma túy', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextFormField(controller: _medicalHistoryCtl, decoration: const InputDecoration(labelText: 'Tiền sử bệnh tật', border: OutlineInputBorder())),

            _buildSection('II. HÌNH PHẠT BỔ SUNG & BỒI THƯỜNG'),
            Row(
              children: [
                Expanded(child: TextFormField(controller: _finePenaltyCtl, decoration: const InputDecoration(labelText: 'Phạt tiền', border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                Expanded(child: TextFormField(controller: _fineStatusCtl, decoration: const InputDecoration(labelText: 'Tình trạng thực hiện', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: TextFormField(controller: _compensationCtl, decoration: const InputDecoration(labelText: 'Bồi thường thiệt hại', border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                Expanded(child: TextFormField(controller: _compensationStatusCtl, decoration: const InputDecoration(labelText: 'Tình trạng thực hiện', border: OutlineInputBorder()))),
              ],
            ),

            _buildSection('III. TÓM TẮT HÀNH VI PHẠM TỘI'),
            TextFormField(controller: _crimeSummaryCtl, decoration: const InputDecoration(labelText: 'Nội dung tóm tắt hành vi phạm tội', border: OutlineInputBorder()), maxLines: 4),

            _buildSection('IV. QUAN HỆ GIA ĐÌNH'),
            TextFormField(controller: _fatherCtl, decoration: const InputDecoration(labelText: 'Thông tin Bố', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextFormField(controller: _motherCtl, decoration: const InputDecoration(labelText: 'Thông tin Mẹ', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextFormField(controller: _spouseCtl, decoration: const InputDecoration(labelText: 'Thông tin Vợ / Chồng', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextFormField(controller: _childrenCtl, decoration: const InputDecoration(labelText: 'Thông tin các con', border: OutlineInputBorder()), maxLines: 2),
            const SizedBox(height: 8),
            TextFormField(controller: _siblingsCtl, decoration: const InputDecoration(labelText: 'Anh chị em ruột', border: OutlineInputBorder()), maxLines: 2),

            _buildSection('V. NHẬN XÉT CỦA CÁN BỘ QUẢN GIÁO'),
            TextFormField(controller: _officerNoteCtl, decoration: const InputDecoration(labelText: 'Ý thức, thái độ chấp hành của phạm nhân', border: OutlineInputBorder()), maxLines: 3),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[900], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('LƯU HỒ SƠ PHIẾU PT78BH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
