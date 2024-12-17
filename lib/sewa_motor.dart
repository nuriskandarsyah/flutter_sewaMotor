import 'package:flutter/material.dart';
import 'db/db_helper.dart';

class SewaMotor {
  final int? id;
  final String namaPenyewa;
  final String namaMotor;
  final int durasi;
  final double totalBayar;

  SewaMotor({
    this.id,
    required this.namaPenyewa,
    required this.namaMotor,
    required this.durasi,
    required this.totalBayar,
  });

  factory SewaMotor.fromMap(Map<String, dynamic> map) {
    return SewaMotor(
      id: map['id'],
      namaPenyewa: map['nama_penyewa'],
      namaMotor: map['nama_motor'],
      durasi: map['durasi'],
      totalBayar: map['total_bayar'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_penyewa': namaPenyewa,
      'nama_motor': namaMotor,
      'durasi': durasi,
      'total_bayar': totalBayar,
    };
  }
}

class SewaMotorPage extends StatefulWidget {
  @override
  _SewaMotorPageState createState() => _SewaMotorPageState();
}

class _SewaMotorPageState extends State<SewaMotorPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final TextEditingController namaPenyewaController = TextEditingController();
  final TextEditingController durasiController = TextEditingController();
  final TextEditingController totalBayarController = TextEditingController();

  List<SewaMotor> sewaMotorList = [];
  String? selectedMotor;
  Map<String, double> motorHargaMap = {
    'Honda Beat': 50000.0,
    'Yamaha NMAX': 80000.0,
    'Suzuki GSX': 70000.0,
  };

  @override
  void initState() {
    super.initState();
    _fetchSewaMotor();
  }

  Future<void> _fetchSewaMotor() async {
    final data = await dbHelper.getSewaMotor();
    setState(() {
      sewaMotorList = data.map((e) => SewaMotor.fromMap(e)).toList();
    });
  }

  Future<void> _addSewaMotor() async {
    if (_validateInputs()) {
      try {
        int durasi = int.parse(durasiController.text);
        double hargaPerHari = motorHargaMap[selectedMotor] ?? 0;
        double totalBayar = durasi * hargaPerHari;

        await dbHelper.addSewaMotor(SewaMotor(
          namaPenyewa: namaPenyewaController.text,
          namaMotor: selectedMotor!,
          durasi: durasi,
          totalBayar: totalBayar,
        ));

        _clearFields();
        await _fetchSewaMotor();
      } catch (e) {
        _showSnackbar('Error: Pastikan input valid!');
      }
    }
  }

  Future<void> _updateSewaMotor(SewaMotor sewaMotor) async {
    if (_validateInputs()) {
      try {
        int durasi = int.parse(durasiController.text);
        double hargaPerHari = motorHargaMap[selectedMotor] ?? 0;
        double totalBayar = durasi * hargaPerHari;

        await dbHelper.updateSewaMotor(SewaMotor(
          id: sewaMotor.id,
          namaPenyewa: namaPenyewaController.text,
          namaMotor: selectedMotor!,
          durasi: durasi,
          totalBayar: totalBayar,
        ));

        _clearFields();
        Navigator.pop(context);
        await _fetchSewaMotor();
      } catch (e) {
        _showSnackbar('Error: Pastikan input valid!');
      }
    }
  }

  Future<void> _deleteSewaMotor(int id) async {
    await dbHelper.deleteSewaMotor(id);
    await _fetchSewaMotor();
  }

  bool _validateInputs() {
    if (namaPenyewaController.text.isEmpty ||
        selectedMotor == null ||
        durasiController.text.isEmpty) {
      _showSnackbar('Semua field harus diisi!');
      return false;
    }
    if (int.tryParse(durasiController.text) == null) {
      _showSnackbar('Durasi harus berupa angka!');
      return false;
    }
    return true;
  }

  void _clearFields() {
    namaPenyewaController.clear();
    durasiController.clear();
    selectedMotor = null;
    totalBayarController.clear();
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showEditDialog(SewaMotor sewaMotor) {
    namaPenyewaController.text = sewaMotor.namaPenyewa;
    selectedMotor = sewaMotor.namaMotor;
    durasiController.text = sewaMotor.durasi.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Sewa Motor'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(namaPenyewaController, 'Nama Penyewa'),
                _buildDropdown(),
                _buildTextField(durasiController, 'Durasi (Hari)',
                    isNumber: true),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _updateSewaMotor(sewaMotor),
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedMotor,
      onChanged: (value) {
        setState(() {
          selectedMotor = value;
        });
      },
      items: motorHargaMap.keys.map((motor) {
        return DropdownMenuItem<String>(
          value: motor,
          child: Text(motor),
        );
      }).toList(),
      decoration: InputDecoration(labelText: 'Nama Motor'),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label),
      onChanged: isNumber
          ? (value) {
              if (selectedMotor != null && value.isNotEmpty) {
                final durasi = int.tryParse(value);
                final hargaPerHari = motorHargaMap[selectedMotor] ?? 0;
                if (durasi != null) {
                  totalBayarController.text =
                      (durasi * hargaPerHari).toString();
                }
              }
            }
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Sewa Motor',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(namaPenyewaController, 'Nama Penyewa'),
            _buildDropdown(),
            _buildTextField(durasiController, 'Durasi (Hari)', isNumber: true),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addSewaMotor,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                textStyle: TextStyle(color: Colors.white),
              ),
              child: Text(
                'Simpan',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: sewaMotorList.length,
                itemBuilder: (context, index) {
                  final sewaMotor = sewaMotorList[index];
                  return ListTile(
                    title: Text(sewaMotor.namaMotor),
                    subtitle: Text(
                        '${sewaMotor.namaPenyewa} - ${sewaMotor.durasi} hari - Rp ${sewaMotor.totalBayar}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _showEditDialog(sewaMotor),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteSewaMotor(sewaMotor.id!),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
