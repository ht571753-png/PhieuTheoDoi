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
    _database = await _initDB('phieu_pt78bh_full.db');
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
        judgment_tha_no TEXT,
        judgment_tha_court TEXT,
        detention_time TEXT,
        crime_during_detention TEXT,
        medical_treatment_time TEXT,
        escape_during_treatment TEXT,
        prior_conviction TEXT,
        prior_offense TEXT,
        drug_history TEXT,
        medical_history TEXT,
        escape_prison TEXT,
        recaptured_info TEXT,
        fine_penalty TEXT,
        fine_status TEXT,
        compensation TEXT,
        compensation_status TEXT,
        return_property TEXT,
        return_property_status TEXT,
        return_other_property TEXT,
        return_other_property_status TEXT,
        court_fee_criminal TEXT,
        court_fee_criminal_status TEXT,
        court_fee_civil TEXT,
        court_fee_civil_status TEXT,
        other_supplementary_penalty TEXT,
        crime_summary TEXT,
        father_info TEXT,
        mother_info TEXT,
        spouse_info TEXT,
        children_info TEXT,
        siblings_info TEXT,
        adoptive_info TEXT,
        social_relations TEXT,
        ratings_summary TEXT,
        reduced_records TEXT,
        temporary_suspension TEXT,
        conditional_release TEXT,
        rewards TEXT,
        disciplines TEXT,
        solitary_confinement TEXT,
        new_crime TEXT,
        probation_classification TEXT,
        extract_records TEXT,
        transfer_records TEXT,
        transfer_evaluation TEXT,
        other_info TEXT,
        officers_in_charge TEXT
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

// ==================== 2. MÀN HÌNH DANH SÁCH HỒ SƠ ====================
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    title: 'Phiếu Theo Dõi PT78BH - C10',
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
      MaterialPageRoute(builder: (context) => FullProfileEditScreen(profile: item)),
    );
    if (res == true) _loadData();
  }

  Future<void> _exportHtmlPrint(Map<String, dynamic> item) async {
    final name = (item['full_name'] ?? '').toString().toUpperCase();
    final shspn = item['shspn'] ?? '';

    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>PHIẾU THEO DÕI QUÁ TRÌNH CHẤP HÀNH ÁN PHẠT TÙ CỦA PHẠM NHÂN</title>
<style>
  @page { size: portrait; margin: 12mm; }
  body { font-family: "Times New Roman", Times, serif; font-size: 13px; line-height: 1.5; color: #000; }
  .center { text-align: center; }
  .bold { font-weight: bold; }
  .header-tbl { width: 100%; border-collapse: collapse; margin-bottom: 12px; }
  .header-tbl td { border: none; padding: 2px; }
  .title { font-size: 15px; font-weight: bold; text-align: center; margin: 15px 0 5px 0; }
  .section { font-weight: bold; margin-top: 14px; text-transform: uppercase; font-size: 13.5px; border-bottom: 1px solid #000; padding-bottom: 2px; }
  .item { margin-top: 4px; }
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
  <div class="center" style="margin-bottom: 15px;">SHSPN: <b>$shspn</b></div>

  <div class="section">I. SƠ LƯỢC LÝ LỊCH</div>
  <div class="item">- Họ và tên: <b>$name</b>; Tên gọi khác: ${item['alias_name'] ?? ''}</div>
  <div class="item">- Ngày sinh: ${item['dob'] ?? ''}; Quê quán: ${item['hometown'] ?? ''}</div>
  <div class="item">- Nơi thường trú: ${item['residence'] ?? ''}</div>
  <div class="item">- Số CCCD/Hộ chiếu: ${item['cccd'] ?? ''}; Ngày cấp: ${item['cccd_date'] ?? ''}; Nơi cấp: ${item['cccd_place'] ?? ''}</div>
  <div class="item">- Dân tộc: ${item['ethnicity'] ?? ''}; Quốc tịch: ${item['nationality'] ?? 'Việt Nam'}; Tôn giáo: ${item['religion'] ?? 'Không'}; Trình độ: ${item['education'] ?? ''}</div>
  <div class="item">- Tội danh: <b>${item['crime'] ?? ''}</b></div>
  <div class="item">- Ngày bắt: ${item['arrest_date'] ?? ''}; Án phạt: <b>${item['sentence'] ?? ''}</b>; Ngày đến trại: ${item['arrival_date'] ?? ''}</div>
  <div class="item">- Bản án số: ${item['judgment_no'] ?? ''} của TAND ${item['judgment_court'] ?? ''}</div>
  <div class="item">- Quyết định THA số: ${item['judgment_tha_no'] ?? ''} của TAND ${item['judgment_tha_court'] ?? ''}</div>
  <div class="item">- Thời gian tạm giữ, tạm giam: ${item['detention_time'] ?? ''}</div>
  <div class="item">- Vi phạm trong thời gian tạm giữ, tạm giam: ${item['crime_during_detention'] ?? 'Không'}</div>
  <div class="item">- Bắt buộc chữa bệnh: ${item['medical_treatment_time'] ?? 'Không'}; Vi phạm khi chữa bệnh: ${item['escape_during_treatment'] ?? 'Không'}</div>
  <div class="item">- Tiền án: ${item['prior_conviction'] ?? 'Không'}</div>
  <div class="item">- Tiền sự: ${item['prior_offense'] ?? 'Không'}</div>
  <div class="item">- Tiền sử ma túy: ${item['drug_history'] ?? 'Không'}; Tiền sử bệnh tật: ${item['medical_history'] ?? 'Bình thường'}</div>
  <div class="item">- Trốn trại: ${item['escape_prison'] ?? 'Không'}; Bắt lại (đầu thú): ${item['recaptured_info'] ?? 'Không'}</div>
  
  <div class="item" style="font-weight:bold; margin-top:6px;">* Hình phạt bổ sung & nghĩa vụ dân sự:</div>
  <div>+ Phạt tiền: ${item['fine_penalty'] ?? ''} (Đã: ${item['fine_status'] ?? ''})</div>
  <div>+ Bồi thường thiệt hại: ${item['compensation'] ?? ''} (Đã: ${item['compensation_status'] ?? ''})</div>
  <div>+ Nghĩa vụ trả lại tài sản: ${item['return_property'] ?? ''} (Đã: ${item['return_property_status'] ?? ''})</div>
  <div>+ Án phí HS: ${item['court_fee_criminal'] ?? ''} (Đã: ${item['court_fee_criminal_status'] ?? ''}); Án phí DS: ${item['court_fee_civil'] ?? ''} (Đã: ${item['court_fee_civil_status'] ?? ''})</div>

  <div class="section">II. TÓM TẮT HÀNH VI PHẠM TỘI</div>
  <div class="item" style="text-align: justify;">${item['crime_summary'] ?? 'Đang cập nhật...'}</div>

  <div class="section">III. QUAN HỆ GIA ĐÌNH</div>
  <div class="item">1. Bố: ${item['father_info'] ?? ''}</div>
  <div class="item">2. Mẹ: ${item['mother_info'] ?? ''}</div>
  <div class="item">3. Vợ / Chồng: ${item['spouse_info'] ?? ''}</div>
  <div class="item">4. Các con: ${item['children_info'] ?? ''}</div>
  <div class="item">5. Anh, chị em ruột: ${item['siblings_info'] ?? ''}</div>
  <div class="item">6. Con nuôi, bố mẹ nuôi: ${item['adoptive_info'] ?? 'Không có'}</div>

  <div class="section">IV. QUAN HỆ XÃ HỘI</div>
  <div class="item" style="text-align: justify;">${item['social_relations'] ?? 'Chưa phát hiện quan hệ phức tạp ngoài xã hội.'}</div>

  <div class="section">V. QUÁ TRÌNH CHẤP HÀNH ÁN PHẠT TÙ</div>
  <div class="item">- <b>1. Xếp loại chấp hành án:</b><br>${item['ratings_summary'] ?? ''}</div>
  <div class="item">- <b>2. Giảm thời hạn tù:</b><br>${item['reduced_records'] ?? 'Chưa'}</div>
  <div class="item">- <b>3. Tạm đình chỉ:</b> ${item['temporary_suspension'] ?? 'Không'}</div>
  <div class="item">- <b>4. Tha tù trước thời hạn có ĐK:</b> ${item['conditional_release'] ?? 'Không'}</div>
  <div class="item">- <b>5. Khen thưởng:</b> ${item['rewards'] ?? 'Chưa'}</div>
  <div class="item">- <b>6. Kỷ luật:</b> ${item['disciplines'] ?? 'Không'}</div>
  <div class="item">- <b>7. Giam riêng:</b> ${item['solitary_confinement'] ?? 'Không'}</div>
  <div class="item">- <b>8. Phạm tội mới trong trại:</b> ${item['new_crime'] ?? 'Không'}</div>
  <div class="item">- <b>9. Phân loại quản chế:</b> ${item['probation_classification'] ?? ''}</div>
  <div class="item">- <b>10. Trích xuất:</b> ${item['extract_records'] ?? 'Không'}</div>
  <div class="item">- <b>11. Chuyển đội/phân trại:</b> ${item['transfer_records'] ?? ''}</div>
  <div class="item">- <b>12. Nhận xét trước khi chuyển giao:</b> ${item['transfer_evaluation'] ?? ''}</div>
  <div class="item">- <b>13. Thông tin khác:</b> ${item['other_info'] ?? ''}</div>

  <div class="section">VI. CÁN BỘ QUẢN GIÁO PHỤ TRÁCH TỔ, ĐỘI</div>
  <div class="item">${item['officers_in_charge'] ?? ''}</div>
</body>
</html>
''';

    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/Phieu_PT78BH_${shspn.isNotEmpty ? shspn : item['id']}.html');
      await file.writeAsString(htmlContent);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/html')],
        text: 'Phiếu theo dõi phạm nhân $name (Mở bằng Chrome để In hoặc Lưu PDF)',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi xuất bản in: $e')));
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
                hintText: 'Tìm theo Tên, SHSPN, CCCD, Can tội...',
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
                                child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                              ),
                              title: Text((item['full_name'] ?? '').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                              subtitle: Text(
                                'SHSPN: ${item['shspn'] ?? '-'} | Ngày sinh: ${item['dob'] ?? '-'}\nCan tội: ${item['crime'] ?? '-'}\nÁn phạt: ${item['sentence'] ?? '-'}',
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

// ==================== 3. BIỂU MẪU ĐẦY ĐỦ 5 MỤC LỚN & CÁC MỤC NHỎ ====================
class FullProfileEditScreen extends StatefulWidget {
  final Map<String, dynamic>? profile;
  const FullProfileEditScreen({Key? key, this.profile}) : super(key: key);

  @override
  State<FullProfileEditScreen> createState() => _FullProfileEditScreenState();
}

class _FullProfileEditScreenState extends State<FullProfileEditScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // I. Sơ lược lý lịch
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
  final _judgmentThaNoCtl = TextEditingController();
  final _judgmentThaCourtCtl = TextEditingController();
  final _detentionTimeCtl = TextEditingController();
  final _crimeDuringDetentionCtl = TextEditingController();
  final _medicalTreatmentTimeCtl = TextEditingController();
  final _escapeDuringTreatmentCtl = TextEditingController();
  final _priorConvictionCtl = TextEditingController();
  final _priorOffenseCtl = TextEditingController();
  final _drugHistoryCtl = TextEditingController();
  final _medicalHistoryCtl = TextEditingController();
  final _escapePrisonCtl = TextEditingController();
  final _recapturedInfoCtl = TextEditingController();

  // Nghĩa vụ dân sự & hình phạt bổ sung
  final _finePenaltyCtl = TextEditingController();
  final _fineStatusCtl = TextEditingController();
  final _compensationCtl = TextEditingController();
  final _compensationStatusCtl = TextEditingController();
  final _returnPropertyCtl = TextEditingController();
  final _returnPropertyStatusCtl = TextEditingController();
  final _returnOtherPropertyCtl = TextEditingController();
  final _returnOtherPropertyStatusCtl = TextEditingController();
  final _courtFeeCriminalCtl = TextEditingController();
  final _courtFeeCriminalStatusCtl = TextEditingController();
  final _courtFeeCivilCtl = TextEditingController();
  final _courtFeeCivilStatusCtl = TextEditingController();
  final _otherSupplementaryPenaltyCtl = TextEditingController();

  // II. Hành vi phạm tội
  final _crimeSummaryCtl = TextEditingController();

  // III. Quan hệ gia đình
  final _fatherCtl = TextEditingController();
  final _motherCtl = TextEditingController();
  final _spouseCtl = TextEditingController();
  final _childrenCtl = TextEditingController();
  final _siblingsCtl = TextEditingController();
  final _adoptiveCtl = TextEditingController();

  // IV. Quan hệ xã hội
  final _socialRelationsCtl = TextEditingController();

  // V. Quá trình chấp hành án phạt tù (13 mục nhỏ)
  final _ratingsSummaryCtl = TextEditingController();
  final _reducedRecordsCtl = TextEditingController();
  final _temporarySuspensionCtl = TextEditingController();
  final _conditionalReleaseCtl = TextEditingController();
  final _rewardsCtl = TextEditingController();
  final _disciplinesCtl = TextEditingController();
  final _solitaryConfinementCtl = TextEditingController();
  final _newCrimeCtl = TextEditingController();
  final _probationClassificationCtl = TextEditingController();
  final _extractRecordsCtl = TextEditingController();
  final _transferRecordsCtl = TextEditingController();
  final _transferEvaluationCtl = TextEditingController();
  final _otherInfoCtl = TextEditingController();

  // VI. Cán bộ quản giáo phụ trách
  final _officersInChargeCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
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
      _judgmentThaNoCtl.text = p['judgment_tha_no'] ?? '';
      _judgmentThaCourtCtl.text = p['judgment_tha_court'] ?? '';
      _detentionTimeCtl.text = p['detention_time'] ?? '';
      _crimeDuringDetentionCtl.text = p['crime_during_detention'] ?? '';
      _medicalTreatmentTimeCtl.text = p['medical_treatment_time'] ?? '';
      _escapeDuringTreatmentCtl.text = p['escape_during_treatment'] ?? '';
      _priorConvictionCtl.text = p['prior_conviction'] ?? '';
      _priorOffenseCtl.text = p['prior_offense'] ?? '';
      _drugHistoryCtl.text = p['drug_history'] ?? '';
      _medicalHistoryCtl.text = p['medical_history'] ?? '';
      _escapePrisonCtl.text = p['escape_prison'] ?? '';
      _recapturedInfoCtl.text = p['recaptured_info'] ?? '';

      _finePenaltyCtl.text = p['fine_penalty'] ?? '';
      _fineStatusCtl.text = p['fine_status'] ?? '';
      _compensationCtl.text = p['compensation'] ?? '';
      _compensationStatusCtl.text = p['compensation_status'] ?? '';
      _returnPropertyCtl.text = p['return_property'] ?? '';
      _returnPropertyStatusCtl.text = p['return_property_status'] ?? '';
      _returnOtherPropertyCtl.text = p['return_other_property'] ?? '';
      _returnOtherPropertyStatusCtl.text = p['return_other_property_status'] ?? '';
      _courtFeeCriminalCtl.text = p['court_fee_criminal'] ?? '';
      _courtFeeCriminalStatusCtl.text = p['court_fee_criminal_status'] ?? '';
      _courtFeeCivilCtl.text = p['court_fee_civil'] ?? '';
      _courtFeeCivilStatusCtl.text = p['court_fee_civil_status'] ?? '';
      _otherSupplementaryPenaltyCtl.text = p['other_supplementary_penalty'] ?? '';

      _crimeSummaryCtl.text = p['crime_summary'] ?? '';
      _fatherCtl.text = p['father_info'] ?? '';
      _motherCtl.text = p['mother_info'] ?? '';
      _spouseCtl.text = p['spouse_info'] ?? '';
      _childrenCtl.text = p['children_info'] ?? '';
      _siblingsCtl.text = p['siblings_info'] ?? '';
      _adoptiveCtl.text = p['adoptive_info'] ?? '';
      _socialRelationsCtl.text = p['social_relations'] ?? '';

      _ratingsSummaryCtl.text = p['ratings_summary'] ?? '';
      _reducedRecordsCtl.text = p['reduced_records'] ?? '';
      _temporarySuspensionCtl.text = p['temporary_suspension'] ?? '';
      _conditionalReleaseCtl.text = p['conditional_release'] ?? '';
      _rewardsCtl.text = p['rewards'] ?? '';
      _disciplinesCtl.text = p['disciplines'] ?? '';
      _solitaryConfinementCtl.text = p['solitary_confinement'] ?? '';
      _newCrimeCtl.text = p['new_crime'] ?? '';
      _probationClassificationCtl.text = p['probation_classification'] ?? '';
      _extractRecordsCtl.text = p['extract_records'] ?? '';
      _transferRecordsCtl.text = p['transfer_records'] ?? '';
      _transferEvaluationCtl.text = p['transfer_evaluation'] ?? '';
      _otherInfoCtl.text = p['other_info'] ?? '';
      _officersInChargeCtl.text = p['officers_in_charge'] ?? '';
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
        'judgment_tha_no': _judgmentThaNoCtl.text.trim(),
        'judgment_tha_court': _judgmentThaCourtCtl.text.trim(),
        'detention_time': _detentionTimeCtl.text.trim(),
        'crime_during_detention': _crimeDuringDetentionCtl.text.trim(),
        'medical_treatment_time': _medicalTreatmentTimeCtl.text.trim(),
        'escape_during_treatment': _escapeDuringTreatmentCtl.text.trim(),
        'prior_conviction': _priorConvictionCtl.text.trim(),
        'prior_offense': _priorOffenseCtl.text.trim(),
        'drug_history': _drugHistoryCtl.text.trim(),
        'medical_history': _medicalHistoryCtl.text.trim(),
        'escape_prison': _escapePrisonCtl.text.trim(),
        'recaptured_info': _recapturedInfoCtl.text.trim(),

        'fine_penalty': _finePenaltyCtl.text.trim(),
        'fine_status': _fineStatusCtl.text.trim(),
        'compensation': _compensationCtl.text.trim(),
        'compensation_status': _compensationStatusCtl.text.trim(),
        'return_property': _returnPropertyCtl.text.trim(),
        'return_property_status': _returnPropertyStatusCtl.text.trim(),
        'return_other_property': _returnOtherPropertyCtl.text.trim(),
        'return_other_property_status': _returnOtherPropertyStatusCtl.text.trim(),
        'court_fee_criminal': _courtFeeCriminalCtl.text.trim(),
        'court_fee_criminal_status': _courtFeeCriminalStatusCtl.text.trim(),
        'court_fee_civil': _courtFeeCivilCtl.text.trim(),
        'court_fee_civil_status': _courtFeeCivilStatusCtl.text.trim(),
        'other_supplementary_penalty': _otherSupplementaryPenaltyCtl.text.trim(),

        'crime_summary': _crimeSummaryCtl.text.trim(),
        'father_info': _fatherCtl.text.trim(),
        'mother_info': _motherCtl.text.trim(),
        'spouse_info': _spouseCtl.text.trim(),
        'children_info': _childrenCtl.text.trim(),
        'siblings_info': _siblingsCtl.text.trim(),
        'adoptive_info': _adoptiveCtl.text.trim(),
        'social_relations': _socialRelationsCtl.text.trim(),

        'ratings_summary': _ratingsSummaryCtl.text.trim(),
        'reduced_records': _reducedRecordsCtl.text.trim(),
        'temporary_suspension': _temporarySuspensionCtl.text.trim(),
        'conditional_release': _conditionalReleaseCtl.text.trim(),
        'rewards': _rewardsCtl.text.trim(),
        'disciplines': _disciplinesCtl.text.trim(),
        'solitary_confinement': _solitaryConfinementCtl.text.trim(),
        'new_crime': _newCrimeCtl.text.trim(),
        'probation_classification': _probationClassificationCtl.text.trim(),
        'extract_records': _extractRecordsCtl.text.trim(),
        'transfer_records': _transferRecordsCtl.text.trim(),
        'transfer_evaluation': _transferEvaluationCtl.text.trim(),
        'other_info': _otherInfoCtl.text.trim(),
        'officers_in_charge': _officersInChargeCtl.text.trim(),
      };

      if (widget.profile == null) {
        await DatabaseHelper.instance.insertProfile(row);
      } else {
        await DatabaseHelper.instance.updateProfile(widget.profile!['id'], row);
      }

      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.profile == null ? 'Lập Phiếu PT78BH Mới' : 'Cập Nhật Hồ Sơ PT78BH'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.amber,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'I. Lý Lịch & Căn Cước'),
            Tab(text: 'II. Hành Vi'),
            Tab(text: 'III. Gia Đình'),
            Tab(text: 'IV. Xã Hội'),
            Tab(text: 'V. Quá Trình Thi Hành Án (1-13)'),
            Tab(text: 'VI. Cán Bộ'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            // TAB 1: I. Sơ lược lý lịch
            ListView(
              padding: const EdgeInsets.all(14),
              children: [
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _shspnCtl, decoration: const InputDecoration(labelText: 'SHSPN *', border: OutlineInputBorder()))),
                    const SizedBox(width: 8),
                    Expanded(child: TextFormField(controller: _dobCtl, decoration: const InputDecoration(labelText: 'Ngày sinh (dd/MM/yyyy)', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(controller: _nameCtl, decoration: const InputDecoration(labelText: 'Họ và tên phạm nhân *', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Bắt buộc' : null),
                const SizedBox(height: 8),
                TextFormField(controller: _aliasCtl, decoration: const InputDecoration(labelText: 'Tên gọi khác', border: OutlineInputBorder())),
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
                    Expanded(child: TextFormField(controller: _judgmentNoCtl, decoration: const InputDecoration(labelText: 'Bản án số/ngày', border: OutlineInputBorder()))),
                    const SizedBox(width: 6),
                    Expanded(child: TextFormField(controller: _judgmentCourtCtl, decoration: const InputDecoration(labelText: 'TAND ra bản án', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _judgmentThaNoCtl, decoration: const InputDecoration(labelText: 'QĐ THA số/ngày', border: OutlineInputBorder()))),
                    const SizedBox(width: 6),
                    Expanded(child: TextFormField(controller: _judgmentThaCourtCtl, decoration: const InputDecoration(labelText: 'TAND ra QĐ THA', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(controller: _detentionTimeCtl, decoration: const InputDecoration(labelText: 'Thời gian tạm giữ, tạm giam', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextFormField(controller: _crimeDuringDetentionCtl, decoration: const InputDecoration(labelText: 'Hành vi vi phạm trong thời gian tạm giữ, tạm giam', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextFormField(controller: _medicalTreatmentTimeCtl, decoration: const InputDecoration(labelText: 'Thời gian bắt buộc chữa bệnh', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextFormField(controller: _escapeDuringTreatmentCtl, decoration: const InputDecoration(labelText: 'Bỏ trốn / vi phạm khi chữa bệnh', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextFormField(controller: _priorConvictionCtl, decoration: const InputDecoration(labelText: 'Tiền án (ghi rõ từng lần, tội danh, trại giam)', border: OutlineInputBorder()), maxLines: 2),
                const SizedBox(height: 8),
                TextFormField(controller: _priorOffenseCtl, decoration: const InputDecoration(labelText: 'Tiền sự (bao nhiêu lần, hành vi)', border: OutlineInputBorder()), maxLines: 2),
                const SizedBox(height: 8),
                TextFormField(controller: _drugHistoryCtl, decoration: const InputDecoration(labelText: 'Tiền sử sử dụng ma túy', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextFormField(controller: _medicalHistoryCtl, decoration: const InputDecoration(labelText: 'Tiền sử bệnh tật', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextFormField(controller: _escapePrisonCtl, decoration: const InputDecoration(labelText: 'Trốn trại giam, trại tạm giam', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextFormField(controller: _recapturedInfoCtl, decoration: const InputDecoration(labelText: 'Bắt lại (đầu thú)', border: OutlineInputBorder())),

                const Divider(height: 24),
                const Text('HÌNH PHẠT BỔ SUNG & BỒI THƯỜNG DÂN SỰ:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _finePenaltyCtl, decoration: const InputDecoration(labelText: 'Phạt tiền', border: OutlineInputBorder()))),
                    const SizedBox(width: 6),
                    Expanded(child: TextFormField(controller: _fineStatusCtl, decoration: const InputDecoration(labelText: 'Đã / Chưa thực hiện', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _compensationCtl, decoration: const InputDecoration(labelText: 'Bồi thường thiệt hại', border: OutlineInputBorder()))),
                    const SizedBox(width: 6),
                    Expanded(child: TextFormField(controller: _compensationStatusCtl, decoration: const InputDecoration(labelText: 'Đã / Chưa thực hiện', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _returnPropertyCtl, decoration: const InputDecoration(labelText: 'Nghĩa vụ trả lại tài sản', border: OutlineInputBorder()))),
                    const SizedBox(width: 6),
                    Expanded(child: TextFormField(controller: _returnPropertyStatusCtl, decoration: const InputDecoration(labelText: 'Đã / Chưa thực hiện', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _courtFeeCriminalCtl, decoration: const InputDecoration(labelText: 'Án phí hình sự', border: OutlineInputBorder()))),
                    const SizedBox(width: 6),
                    Expanded(child: TextFormField(controller: _courtFeeCriminalStatusCtl, decoration: const InputDecoration(labelText: 'Đã / Chưa thực hiện', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _courtFeeCivilCtl, decoration: const InputDecoration(labelText: 'Án phí dân sự', border: OutlineInputBorder()))),
                    const SizedBox(width: 6),
                    Expanded(child: TextFormField(controller: _courtFeeCivilStatusCtl, decoration: const InputDecoration(labelText: 'Đã / Chưa thực hiện', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(controller: _otherSupplementaryPenaltyCtl, decoration: const InputDecoration(labelText: 'Hình phạt bổ sung khác (nếu có)', border: OutlineInputBorder())),
              ],
            ),

            // TAB 2: II. Tóm tắt hành vi phạm tội
            ListView(
              padding: const EdgeInsets.all(14),
              children: [
                const Text('TÓM TẮT HÀNH VI PHẠM TỘI (Ghi rõ diễn biến hành vi phạm tội theo bản án):', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _crimeSummaryCtl,
                  maxLines: 15,
                  decoration: const InputDecoration(
                    hintText: 'Nhập nội dung tóm tắt hành vi phạm tội...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),

            // TAB 3: III. Quan hệ gia đình
            ListView(
              padding: const EdgeInsets.all(14),
              children: [
                const Text('THÔNG TIN GIA ĐÌNH:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(controller: _fatherCtl, maxLines: 2, decoration: const InputDecoration(labelText: '1. Họ tên Bố (Năm sinh, quê quán, nơi ĐKTT, chỗ ở, nghề nghiệp)', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextFormField(controller: _motherCtl, maxLines: 2, decoration: const InputDecoration(labelText: '2. Họ tên Mẹ (Năm sinh, quê quán, nơi ĐKTT, chỗ ở, nghề nghiệp)', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextFormField(controller: _spouseCtl, maxLines: 2, decoration: const InputDecoration(labelText: '3. Họ tên Vợ / Chồng (Năm sinh, nơi ĐKTT, chỗ ở, nghề nghiệp)', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextFormField(controller: _childrenCtl, maxLines: 3, decoration: const InputDecoration(labelText: '4. Các con (Ghi rõ họ tên, năm sinh, địa chỉ, nghề nghiệp từng con)', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextFormField(controller: _siblingsCtl, maxLines: 3, decoration: const InputDecoration(labelText: '5. Anh, chị em ruột (Họ tên, năm sinh, nơi cư trú, nghề nghiệp)', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextFormField(controller: _adoptiveCtl, maxLines: 2, decoration: const InputDecoration(labelText: '6. Bố nuôi, mẹ nuôi, con nuôi hợp pháp (nếu có)', border: OutlineInputBorder())),
              ],
            ),

            // TAB 4: IV. Quan hệ xã hội
            ListView(
              padding: const EdgeInsets.all(14),
              children: [
                const Text('QUAN HỆ XÃ HỘI (Ghi rõ họ tên, năm sinh, quê quán, nơi ở hiện tại, nghề nghiệp các đối tượng có quan hệ):', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _socialRelationsCtl,
                  maxLines: 12,
                  decoration: const InputDecoration(
                    hintText: 'Nhập thông tin các mối quan hệ xã hội phức tạp, bạn bè liên quan...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),

            // TAB 5: V. Quá trình chấp hành án (Đầy đủ 13 mục nhỏ)
            ListView(
              padding: const EdgeInsets.all(14),
              children: [
                const Text('QUÁ TRÌNH CHẤP HÀNH ÁN PHẠT TÙ (13 TIỂU MỤC):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _ratingsSummaryCtl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: '1. Xếp loại chấp hành án phạt tù (Tháng 12 đến 11, các Quý I, II, III, IV)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _reducedRecordsCtl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: '2. Giảm thời hạn tù (Năm, mức giảm, số QĐ, Tòa án, ghi chú)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _temporarySuspensionCtl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: '3. Tạm đình chỉ chấp hành án (Thời gian, vi phạm nếu có)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _conditionalReleaseCtl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: '4. Tha tù trước thời hạn có điều kiện (Thời gian, vi phạm nếu có)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _rewardsCtl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: '5. Khen thưởng (Số QĐ/ngày, nội dung, hình thức)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _disciplinesCtl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: '6. Kỷ luật (Số QĐ/ngày, hành vi vi phạm, hình thức, QĐ tiến bộ)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _solitaryConfinementCtl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: '7. Giam riêng (Số QĐ/ngày, lý do, thời gian, QĐ tiến bộ)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _newCrimeCtl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: '8. Phạm tội mới trong thời gian chấp hành án (Tội danh, mức án)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _probationClassificationCtl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: '9. Phân loại quản chế (Ngày tháng phân loại, nâng/hạ loại)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _extractRecordsCtl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: '10. Trích xuất (Ngày trích xuất, trả trích xuất, lý do, cơ quan)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _transferRecordsCtl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: '11. Chuyển đội, Phân trại hoặc trại khác (Ngày, nơi chuyển, lý do)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _transferEvaluationCtl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: '12. Nhận xét đánh giá của CB quản giáo trước khi chuyển giao',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _otherInfoCtl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: '13. Thông tin khác',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),

            // TAB 6: VI. Cán bộ quản giáo phụ trách
            ListView(
              padding: const EdgeInsets.all(14),
              children: [
                const Text('VI. CÁN BỘ QUẢN GIÁO PHỤ TRÁCH TỔ, ĐỘI:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text('Ghi rõ: Cán bộ quản giáo phụ trách (Từ ngày... đến ngày..., Cấp bậc, Họ và tên):', style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _officersInChargeCtl,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText: 'Ví dụ:\nThiếu tá: Trần Anh Hà (Từ ngày 01/01/2024 đến nay)\nĐại úy: Nguyễn Văn B (Từ 01/06/2022 đến 31/12/2023)...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: Colors.white,
        child: ElevatedButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save),
          label: const Text('LƯU TOÀN BỘ PHIẾU THEO DÕI (PT78BH)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey[900],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}
