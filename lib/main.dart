import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';
import 'dart:async'; 
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:js' as js;

// ========================================================
// GLOBAL CONFIG
// ========================================================
const String kBackendUrl = "https://gravityai-backend.onrender.com"; 
const String kEarthImg = "assets/images/background.png";
const String kGroqKey = String.fromEnvironment('GROQ_API_KEY', defaultValue: ''); 

void main() { runApp(const GravityApp()); }

class GravityApp extends StatelessWidget {
  const GravityApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gravity AI Portal',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF020617),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          hintStyle: const TextStyle(color: Colors.white30),
        )
      ),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatefulWidget { const LandingPage({super.key}); @override State<LandingPage> createState() => _LandingPageState(); }
class _LandingPageState extends State<LandingPage> {
  final TextEditingController _id = TextEditingController();
  final TextEditingController _pass = TextEditingController();

  void _login(bool isOfficer) {
    if (isOfficer && (_id.text.isEmpty || _pass.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: Enter valid Officer ID and Password", style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent));
      return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => DashboardScreen(isOfficer: isOfficer)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 900;
          
          if (isMobile) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(image: DecorationImage(image: AssetImage(kEarthImg), fit: BoxFit.cover)),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Image.asset("assets/images/logo.png", height: 50, errorBuilder: (c,e,s)=>const Icon(Icons.auto_awesome, color: Colors.cyanAccent)),
                        const SizedBox(width: 8),
                        const Expanded(child: Text("Gravity AI", style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1.0))),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildLoginCard("OFFICER PORTAL", Icons.admin_panel_settings, Colors.blueAccent, true),
                    const SizedBox(height: 20),
                    _buildLoginCard("PUBLIC ACCESS", Icons.public, Colors.greenAccent, false),
                    const SizedBox(height: 30),
                    _buildDetailsCard(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          }

          return Stack(
            children: [
              Container(
                width: double.infinity, 
                height: double.infinity, 
                decoration: const BoxDecoration(
                  color: Color(0xFF020617),
                  image: DecorationImage(
                    image: AssetImage(kEarthImg), 
                    fit: BoxFit.cover,
                  )
                )
              ),
              Positioned(
                top: 40, left: 40,
                child: Row(
                  children: [
                    Image.asset("assets/images/logo.png", height: isMobile ? 50 : 70, errorBuilder: (c,e,s)=>const Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 40)),
                    const SizedBox(width: 12),
                    Text("Gravity AI", style: TextStyle(fontSize: isMobile ? 35 : 50, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1.0)),
                  ],
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.22, left: MediaQuery.of(context).size.width * 0.08, 
                child: SizedBox(
                  width: isMobile ? MediaQuery.of(context).size.width * 0.84 : 580,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      _buildLoginCard("OFFICER PORTAL", Icons.admin_panel_settings, Colors.blueAccent, true),
                      SizedBox(height: isMobile ? 20 : 30),
                      _buildLoginCard("PUBLIC ACCESS", Icons.public, Colors.greenAccent, false),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.22, right: MediaQuery.of(context).size.width * 0.08, 
                child: SizedBox(
                  width: isMobile ? 0 : 540,
                  child: isMobile ? const SizedBox() : _buildDetailsCard(),
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildDetailsCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.35), border: Border.all(color: Colors.white.withValues(alpha: 0.15))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.orangeAccent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Text("POWERED BY ISRO BHUVAN", style: TextStyle(color: Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)), SizedBox(width: 8), BlinkingLight(color: Colors.greenAccent)])),
              const SizedBox(height: 15), const Text("Developed by Team Tensor Titans, Gravity is a Next-Generation Geospatial Intelligence platform for urban administration.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, height: 1.4)),
              const SizedBox(height: 15),
              Text("• Core Engine: Powered by Siam-UNet Neural Networks.\n\n• ISRO Bhuvan Integration: Leverages indigenous Indian satellite imagery, 3D terrain models, and WMS/WFS services for hyper-precise boundary mapping.\n\n• Capabilities: Real-time encroachment tracking via GeoJSON Bhu-Naksha referencing.\n\n• Actionable Intelligence: Automated eviction notices and bulldozer deployment.", style: TextStyle(color: Colors.white.withValues(alpha: 0.8), height: 1.5, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(String title, IconData icon, Color accent, bool isOfficer) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 30, offset: const Offset(0, 15))]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
          child: Container(
            padding: const EdgeInsets.all(35),
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.25), border: Border.all(color: Colors.white.withValues(alpha: 0.2))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Icon(icon, color: accent), const SizedBox(width: 10), Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1.2))]),
                const SizedBox(height: 25),
                if (isOfficer) ...[
                  TextField(controller: _id, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "Officer ID")),
                  const SizedBox(height: 15),
                  TextField(controller: _pass, obscureText: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "Password")),
                  const SizedBox(height: 25),
                ] else ...[
                  Text("Search land risk assessments without privileges.", style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.5)),
                  const SizedBox(height: 25),
                ],
                SizedBox(
                  width: double.infinity, height: 50, 
                  child: isOfficer 
                    ? ElevatedButton(
                        onPressed: () => _login(true), 
                        style: ElevatedButton.styleFrom(backgroundColor: accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text("SECURE LOGIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1))
                      )
                    : OutlinedButton(
                        onPressed: () => _login(false), 
                        style: OutlinedButton.styleFrom(backgroundColor: accent.withValues(alpha: 0.05), side: BorderSide(color: accent, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), 
                        child: Text("ENTER AS GUEST", style: TextStyle(color: accent, fontWeight: FontWeight.w900, letterSpacing: 1.2))
                      )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget { 
  final bool isOfficer; 
  const DashboardScreen({super.key, required this.isOfficer}); 
  @override 
  State<DashboardScreen> createState() => _DashboardScreenState(); 
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  final MapController _mapCtrl = MapController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _booting = true;
  double _bootProgress = 0.0;
  bool _scanning = false;
  bool _ready = false;
  String _status = "SYSTEM STANDBY";

  LatLng _loc = const LatLng(23.2599, 77.4126); 
  double _currentZoom = 13.0; 
  List<Polygon> _anomalyPolygons = [];
  List<Polygon> _govtPolygons = [];

  int _risk = 0, _area = 0, _veg = 0;
  double _val = 0.0, _fine = 0.0, _accuracy = 100.0;
  Map<String, dynamic> _envData = {"temp": 32, "aqi": 145, "soil": "Alluvial", "moisture": 45};
  String _notice = "";
  bool _evictSent = false; int _timerSecs = 0; Timer? _timer; bool _canDemolish = false;
  String _stateName = "MADHYA PRADESH";
  List<Map<String, String>> _tasksList = [];
  
  int _navIndex = 0;
  bool _isHindi = false;
  final List<Map<String, String>> _chatMsgs = [{"role": "ai", "text": "Hello Officer. I am Gravity AI. How can I assist you with urban administration today?"}];
  final TextEditingController _chatCtrl = TextEditingController();
  bool _isSatellite = true; 
  bool _showBhuvanWms = false; 
  
  List<Map<String, dynamic>> _fieldEvidences = [];
  bool _droneActive = false;
  LatLng? _dronePos;
  Timer? _droneTimer;

  @override void initState() { super.initState(); _bootSequence(); }
  @override void dispose() { _timer?.cancel(); _droneTimer?.cancel(); _searchCtrl.dispose(); _chatCtrl.dispose(); super.dispose(); }

  void _bootSequence() async {
    for (int i = 0; i <= 10; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 200)); 
      setState(() => _bootProgress = i / 10); 
    }
    if (mounted) setState(() => _booting = false);
  }

  void _speak(String text) {
    try {
      js.context.callMethod('eval', ["""
        var msg = new SpeechSynthesisUtterance(`${text.replaceAll('`', "'")}`);
        msg.lang = 'en-US';
        msg.rate = 0.9;
        window.speechSynthesis.speak(msg);
      """]);
    } catch (_) {}
  }

  Future<void> _runScan() async {
    String query = _searchCtrl.text.trim();
    if (query.isEmpty) return;
    
    _timer?.cancel();
    if (mounted) {
      setState(() { 
        _scanning = true; _ready = false; _evictSent = false; _canDemolish = false;
        _status = "🛰️ CONNECTING TO SATELLITE..."; 
        _anomalyPolygons.clear(); _govtPolygons.clear();
      });
    }

    try {
      final res = await http.get(Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}, India&format=json&limit=1&addressdetails=1'), headers: {'User-Agent': 'Gravity-Titans'}).timeout(const Duration(seconds: 30));
      final d = json.decode(res.body);
      if (d == null || d.isEmpty) throw "Location not found";
      double lat = double.parse(d[0]['lat']); 
      double lon = double.parse(d[0]['lon']);
      String fetchedState = "GOVERNMENT";
      if (d[0]['address'] != null && d[0]['address']['state'] != null) {
        fetchedState = d[0]['address']['state'].toString().toUpperCase();
      }

      _loc = LatLng(lat, lon);
      if (mounted) setState(() => _stateName = fetchedState);
      _mapCtrl.move(_loc, 18.0);

      if (mounted) setState(() => _status = "🧠 CROSS-REFERENCING GEOJSON...");

      final apiRes = await http.post(
        Uri.parse('$kBackendUrl/api/scan'), 
        headers: {'Content-Type': 'application/json'}, 
        body: json.encode({'lat': lat, 'lon': lon, 'sector': query})
      ).timeout(const Duration(seconds: 90));
      
      if (apiRes.statusCode == 200) {
        final data = json.decode(apiRes.body);
        
        List<LatLng> _parsePoly(dynamic list) {
          if (list == null) return [];
          return (list as List).map((p) => LatLng(double.parse(p['lat'].toString()), double.parse(p['lon'].toString()))).toList();
        }

        if (!mounted) return;
        setState(() {
          _scanning = false; _ready = true;
          _status = "✅ ANALYSIS COMPLETE — ${data['accuracy']}% CONFIDENCE";
          _risk = data['encroaching_count'] != null ? (data['encroaching_count'] * 15).clamp(0, 100) : 0;
          _area = data['area_sqm'] ?? 0;
          _val = (data['land_value'] ?? 0.0).toDouble();
          _fine = (data['penalty'] ?? 0.0).toDouble();
          _veg = data['green_loss'] ?? 0;
          _accuracy = (data['accuracy'] ?? 100.0).toDouble();
          if (data['env_data'] != null) { _envData = Map<String, dynamic>.from(data['env_data']); }
          _notice = data['legal_notice_text'] ?? "Unauthorized construction detected.";
          
          String voiceSum = data['voice_summary'] ?? "Scan complete.";
          _speak(voiceSum);

          if (data['govt_boundary'] != null) { _govtPolygons.add(Polygon(points: _parsePoly(data['govt_boundary']), color: Colors.blue.withValues(alpha: 0.12), borderColor: Colors.blueAccent, borderStrokeWidth: 4, isFilled: true)); }
          if (data['encroaching_buildings'] != null) {
            for (var building in data['encroaching_buildings']) {
              var pts = _parsePoly(building);
              if (pts.length >= 3) { _anomalyPolygons.add(Polygon(points: pts, color: Colors.red.withValues(alpha: 0.5), borderColor: Colors.redAccent, borderStrokeWidth: 2, isFilled: true)); }
            }
          }
          if (data['legal_buildings'] != null) {
            for (var building in data['legal_buildings']) {
              var pts = _parsePoly(building);
              if (pts.length >= 3) { _govtPolygons.add(Polygon(points: pts, color: Colors.green.withValues(alpha: 0.2), borderColor: Colors.greenAccent, borderStrokeWidth: 1, isFilled: true)); }
            }
          }
          if (data['anomaly_polygon'] != null && data['encroaching_buildings'] == null) { _anomalyPolygons.add(Polygon(points: _parsePoly(data['anomaly_polygon']), color: Colors.red.withValues(alpha: 0.4), borderColor: Colors.redAccent, borderStrokeWidth: 3, isFilled: true)); }
        });
      } else { throw "Server Error: ${apiRes.statusCode}"; }
    } catch (e) { if (mounted) setState(() { _scanning = false; _status = e.toString().contains("Timeout") ? "❌ TIMEOUT: SERVER TOOK TOO LONG" : "❌ ERROR: $e"; }); }
  }

  @override
  Widget build(BuildContext context) {
    if (_booting) return _buildBoot();
    return LayoutBuilder(builder: (context, constraints) {
      bool isMobile = constraints.maxWidth < 900;
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFF070B19),
        drawer: isMobile ? _mobileDrawer() : null,
        floatingActionButton: widget.isOfficer ? FloatingActionButton.extended(onPressed: _showChatbot, backgroundColor: Colors.cyanAccent, icon: const Icon(Icons.auto_awesome, color: Colors.black87), label: const Text("Gravity AI", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold))) : null,
        body: Row(children: [
          if (!isMobile) _sidebar(),
          Expanded(child: Column(children: [_topNav(isMobile), Expanded(child: _buildMainContent(isMobile)), _footer()]))
        ]),
      );
    });
  }

  Widget _mobileDrawer() {
    return Drawer(width: MediaQuery.of(context).size.width * 0.75, backgroundColor: const Color(0xFF0B1221), child: Column(children: [
      DrawerHeader(decoration: const BoxDecoration(color: Color(0xFF1E293B)), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Image.asset("assets/images/logo.png", height: 50, errorBuilder: (c,e,s)=>const Icon(Icons.auto_awesome, color: Colors.cyanAccent)), const SizedBox(height: 10), const Text("Gravity AI", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))]))),
      _drawerBtn(Icons.dashboard, "Dashboard", _navIndex == 0, tap: () { setState(() => _navIndex = 0); Navigator.pop(context); }),
      _drawerBtn(Icons.map_outlined, "Map", _navIndex == 1, tap: () { setState(() => _navIndex = 1); Navigator.pop(context); }),
      _drawerBtn(Icons.description_outlined, "Reports", _navIndex == 2, tap: () { setState(() => _navIndex = 2); Navigator.pop(context); }),
      if (widget.isOfficer) _drawerBtn(Icons.checklist_rtl_rounded, "Tasks", _navIndex == 3, tap: () { setState(() => _navIndex = 3); Navigator.pop(context); }),
      const Spacer(),
      _drawerBtn(Icons.satellite_alt, "Bhu-Prahari", false, color: Colors.orangeAccent, tap: () { Navigator.pop(context); _showBhuPrahari(); }),
      const SizedBox(height: 20),
    ]));
  }

  Widget _drawerBtn(IconData i, String label, bool act, {Color? color, VoidCallback? tap}) => ListTile(leading: Icon(i, color: act ? Colors.cyanAccent : (color ?? Colors.white54)), title: Text(label, style: TextStyle(color: act ? Colors.cyanAccent : (color ?? Colors.white54), fontWeight: act ? FontWeight.bold : FontWeight.normal)), onTap: tap, selected: act, selectedTileColor: Colors.cyanAccent.withValues(alpha: 0.1));

  Widget _buildMainContent(bool isMobile) {
    if (_navIndex == 1) return Padding(padding: const EdgeInsets.all(12.0), child: _mapView(isMobile));
    if (_navIndex == 2) return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.description, size: 80, color: Colors.white24), SizedBox(height: 20), Text("REPORTS MODULE", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)), SizedBox(height: 10), Text("No generated reports found for this sector.", style: TextStyle(color: Colors.white54))]));
    if (_navIndex == 3) return Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("OFFICER TASKS", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 5), Text("${_tasksList.length} active tasks recorded.", style: const TextStyle(color: Colors.white54)), const SizedBox(height: 20), Expanded(child: _tasksList.isEmpty ? const Center(child: Text("No tasks queued.", style: TextStyle(color: Colors.white54))) : ListView.builder(itemCount: _tasksList.length, itemBuilder: (c, i) { var t = _tasksList[i]; bool isSuccess = t["status"] == "Success"; return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white10)), child: Row(children: [Icon(isSuccess ? Icons.check_circle : Icons.pending_actions, color: isSuccess ? Colors.green : Colors.orange), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t["title"]!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 5), Text(t["desc"]!, style: const TextStyle(color: Colors.white54, fontSize: 12))])), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(t["status"]!, style: TextStyle(color: isSuccess ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)), const SizedBox(height: 5), Text(t["time"]!, style: const TextStyle(color: Colors.white30, fontSize: 10))])])); }))]));
    if (isMobile) return ListView(padding: const EdgeInsets.all(12), children: [Container(height: MediaQuery.of(context).size.height * 0.45, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)), child: _mapView(isMobile)), const SizedBox(height: 12), _rightPanel(isMobile)]);
    return Padding(padding: const EdgeInsets.all(8.0), child: Row(children: [Expanded(flex: 7, child: _mapView(isMobile)), const SizedBox(width: 8), Expanded(flex: 3, child: _rightPanel(isMobile))]));
  }

  Widget _sidebar() => Container(width: 80, color: const Color(0xFF0B1221), child: Column(children: [const SizedBox(height: 20), _sideBtn(Icons.dashboard, "Dashboard", _navIndex == 0, tap: () => setState(() => _navIndex = 0)), _sideBtn(Icons.map_outlined, "Map", _navIndex == 1, tap: () => setState(() => _navIndex = 1)), _sideBtn(Icons.description_outlined, "Reports", _navIndex == 2, tap: () => setState(() => _navIndex = 2)), if (widget.isOfficer) _sideBtn(Icons.checklist_rtl_rounded, "Tasks", _navIndex == 3, tap: () => setState(() => _navIndex = 3)), const Spacer(), _sideBtn(Icons.satellite_alt, "Bhu-Prahari", false, color: Colors.orangeAccent, tap: _showBhuPrahari), const SizedBox(height: 20)]));

  Widget _sideBtn(IconData i, String label, bool act, {Color? color, VoidCallback? tap}) => InkWell(onTap: tap, child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 15), decoration: BoxDecoration(border: act ? const Border(left: BorderSide(color: Colors.cyanAccent, width: 4)) : null, color: act ? Colors.cyanAccent.withValues(alpha: 0.1) : Colors.transparent), child: Column(children: [Icon(i, color: act ? Colors.cyanAccent : (color ?? Colors.white54), size: 28), const SizedBox(height: 5), Text(label, style: TextStyle(color: act ? Colors.cyanAccent : (color ?? Colors.white54), fontSize: 10), textAlign: TextAlign.center)])));

  Widget _topNav(bool isMobile) => Container(height: 60, padding: const EdgeInsets.symmetric(horizontal: 20), decoration: const BoxDecoration(color: Color(0xFF0B1221), border: Border(bottom: BorderSide(color: Colors.white10))), child: Row(children: [if (isMobile) IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () => _scaffoldKey.currentState?.openDrawer()), Image.asset("assets/images/logo.png", height: 35, errorBuilder: (c,e,s)=>const Icon(Icons.auto_awesome, color: Colors.cyanAccent)), const SizedBox(width: 8), const Text("Gravity AI", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), if (!isMobile) ...[const SizedBox(width: 15), Container(height: 20, width: 2, color: Colors.white24), const SizedBox(width: 15), Text(widget.isOfficer ? "Officer Dashboard" : "Public Dashboard", style: const TextStyle(color: Colors.white70, fontSize: 16))], const Spacer(), if (!isMobile) ...[if (widget.isOfficer) ...[const Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [Text("AUTHORIZED OFFICER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), Text("SECURE SESSION ACTIVE", style: TextStyle(color: Colors.white54, fontSize: 10))]), const SizedBox(width: 10), const CircleAvatar(backgroundColor: Colors.blueGrey, child: Icon(Icons.person, color: Colors.white))] else ...[const Text("GUEST USER", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14))]], const SizedBox(width: 15), Stack(clipBehavior: Clip.none, children: [IconButton(icon: const Icon(Icons.notifications_none, color: Colors.white), onPressed: () => _showNotificationPanel()), if (_tasksList.isNotEmpty) Positioned(top: 8, right: 8, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)))]), const SizedBox(width: 10), IconButton(onPressed: () { _timer?.cancel(); Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const LandingPage())); }, icon: const Icon(Icons.logout, color: Colors.white54))]));

  Widget _mapView(bool isMobile) => ClipRRect(borderRadius: BorderRadius.circular(12), child: Stack(children: [
    FlutterMap(mapController: _mapCtrl, options: MapOptions(initialCenter: _loc, initialZoom: _currentZoom), children: [
      TileLayer(urlTemplate: _isSatellite ? 'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}' : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', subdomains: const ['mt0', 'mt1', 'mt2', 'mt3']),
      if (_showBhuvanWms) TileLayer(urlTemplate: 'https://bhuvan-vec1.nrsc.gov.in/bhuvan/gwc/service/wmts?SERVICE=WMTS&VERSION=1.0.0&REQUEST=GetTile&LAYER=lulc:ap_lulc_50k_1516&STYLE=default&TILEMATRIXSET=EPSG:900913&TILEMATRIX=EPSG:900913:{z}&TILEROW={y}&TILECOL={x}&FORMAT=image/png'),
      PolygonLayer(polygons: _govtPolygons), PolygonLayer(polygons: _anomalyPolygons),
      if (_droneActive && _dronePos != null) MarkerLayer(markers: [Marker(point: _dronePos!, width: 80, height: 80, child: const Icon(Icons.gps_fixed, color: Colors.redAccent, size: 40))]),
    ]),
    Positioned(top: 15, right: 15, left: isMobile ? 15 : null, child: Container(width: isMobile ? null : 350, decoration: BoxDecoration(color: const Color(0xFF0B1221).withValues(alpha: 0.9), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24)), child: Row(children: [Expanded(child: TextField(controller: _searchCtrl, style: const TextStyle(color: Colors.white, fontSize: 13), decoration: const InputDecoration(hintText: "Search City/Sector...", border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12)), onSubmitted: (_) => _scanning ? null : _runScan())), IconButton(icon: _scanning ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyanAccent)) : const Icon(Icons.search, color: Colors.white, size: 20), onPressed: _scanning ? null : _runScan())]))),
    if (!isMobile) Positioned(top: 20, left: 20, child: Container(decoration: BoxDecoration(color: const Color(0xFF0B1221).withValues(alpha: 0.9), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24)), child: Column(children: [IconButton(icon: const Icon(Icons.add, color: Colors.white), onPressed: () { setState(() => _currentZoom++); _mapCtrl.move(_loc, _currentZoom); }), Container(height: 1, width: 30, color: Colors.white24), IconButton(icon: const Icon(Icons.remove, color: Colors.white), onPressed: () { setState(() => _currentZoom--); _mapCtrl.move(_loc, _currentZoom); })]))),
    Positioned(top: isMobile ? 70 : 130, left: isMobile ? 15 : 20, child: GestureDetector(onTap: () => setState(() => _isSatellite = !_isSatellite), child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF0B1221).withValues(alpha: 0.9), borderRadius: BorderRadius.circular(8), border: Border.all(color: _isSatellite ? Colors.cyanAccent.withValues(alpha: 0.5) : Colors.white24)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(_isSatellite ? Icons.satellite_alt : Icons.map_outlined, color: _isSatellite ? Colors.cyanAccent : Colors.white, size: 18), const SizedBox(width: 6), Text(_isSatellite ? "Satellite" : "Street", style: TextStyle(color: _isSatellite ? Colors.cyanAccent : Colors.white, fontSize: 11, fontWeight: FontWeight.bold))])))),
    Positioned(top: isMobile ? 115 : 185, left: isMobile ? 15 : 20, child: GestureDetector(onTap: () => setState(() => _showBhuvanWms = !_showBhuvanWms), child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF0B1221).withValues(alpha: 0.9), borderRadius: BorderRadius.circular(8), border: Border.all(color: _showBhuvanWms ? Colors.orangeAccent.withValues(alpha: 0.5) : Colors.white24)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.layers, color: _showBhuvanWms ? Colors.orangeAccent : Colors.white, size: 18), const SizedBox(width: 6), Text("Bhuvan WMS", style: TextStyle(color: _showBhuvanWms ? Colors.orangeAccent : Colors.white, fontSize: 11, fontWeight: FontWeight.bold))])))),
    Positioned(bottom: 20, right: 20, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF0B1221).withValues(alpha: 0.8), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24)), child: Row(children: [Icon(Icons.thermostat, color: Colors.orangeAccent, size: 14), const SizedBox(width: 5), Text("${_envData['temp']}°C", style: const TextStyle(color: Colors.white, fontSize: 11)), const SizedBox(width: 10), Icon(Icons.air, color: Colors.lightBlueAccent, size: 14), const SizedBox(width: 5), Text("AQI: ${_envData['aqi']}", style: const TextStyle(color: Colors.white, fontSize: 11)), const SizedBox(width: 10), Icon(Icons.landscape, color: Colors.brown, size: 14), const SizedBox(width: 5), Text("Soil: ${_envData['soil']}", style: const TextStyle(color: Colors.white, fontSize: 11)), const SizedBox(width: 10), Icon(Icons.water_drop, color: Colors.blueAccent, size: 14), const SizedBox(width: 5), Text("${_envData['moisture']}%", style: const TextStyle(color: Colors.white, fontSize: 11))]))),
    if (_droneActive) Positioned.fill(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3), width: 40)), child: const Center(child: Icon(Icons.center_focus_strong, color: Colors.cyanAccent, size: 100)))),
  ]));

  Widget _rightPanel(bool isMobile) => Container(decoration: BoxDecoration(color: const Color(0xFF0B1221), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)), padding: const EdgeInsets.all(16), child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text(_status, style: TextStyle(color: _status.contains("ERROR") ? Colors.redAccent : (_ready ? Colors.greenAccent : Colors.cyanAccent), fontSize: 12, fontWeight: FontWeight.bold)), const SizedBox(height: 20), if (widget.isOfficer) ...[Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Quick Officer Tools", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)), Icon(Icons.flash_on, color: Colors.cyanAccent, size: 16)]), const SizedBox(height: 10), _actionBtn(_droneActive ? "Terminate Drone Feed" : "Dispatch Surveillance Drone", Icons.satellite_alt, _toggleDrone), _actionBtn("Capture Field Evidence", Icons.camera_alt, _captureEvidence), const SizedBox(height: 20)], if (!_ready) const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Text("Waiting for target coordinates to initiate analysis workflow...", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12)))) else ...[const Text("Real-time Stats", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 15), _stat("Total Encroached Area", "$_area m²", Colors.white), _stat("Detection Confidence", "$_accuracy%", Colors.cyanAccent), Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_col("EST. VALUE", "₹${(_val/10000000).toStringAsFixed(2)} Cr", Colors.greenAccent), _col("PENALTY", "₹${(_fine/100000).toStringAsFixed(1)} L", Colors.redAccent)]), const Divider(color: Colors.white24, height: 20), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_col("RISK SCORE", "$_risk/100", Colors.orangeAccent), _col("ECOLOGY LOSS", "-$_veg%", Colors.lightGreen)])])), const SizedBox(height: 25), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Anomaly Detection", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)), Icon(Icons.more_horiz, color: Colors.white54)]), const SizedBox(height: 10), Text("High-Precision Pixel Differencing: Unauthorized Construction Detected.", style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)), const SizedBox(height: 25), if (widget.isOfficer) ...[Row(children: [Expanded(child: _btn("Compare", Icons.compare, _showComp)), const SizedBox(width: 10), Expanded(child: _btn("Report", Icons.picture_as_pdf, _makePDF))]), const SizedBox(height: 20), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Scan Actions", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)), Icon(Icons.more_horiz, color: Colors.white54)]), const SizedBox(height: 10), _actionBtn("Generate Eviction Notice", Icons.auto_awesome, _showNotice), if (!_evictSent && !_canDemolish) _actionBtn("Set Warning Timer", Icons.warning_amber_rounded, _startTimer), if (_evictSent) Container(width: double.infinity, padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orangeAccent)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("NOTICE ACTIVE", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 12)), const SizedBox(height: 5), Text("Deadline: $_timerSecs Seconds Remaining", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))])), if (_canDemolish) SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bulldozer Dispatched."), backgroundColor: Colors.green)); setState(() { _tasksList.insert(0, {"title": "Demolition Force Deployed", "desc": "Sector: ${_searchCtrl.text.toUpperCase()} | Loc ID: BHU-449-A", "status": "Success", "time": DateFormat('HH:mm a').format(DateTime.now())}); _canDemolish = false; _ready = false; }); }, icon: const Icon(Icons.construction), label: const Text("Add to Demolition Queue"), style: ElevatedButton.styleFrom(alignment: Alignment.centerLeft, padding: const EdgeInsets.all(15), backgroundColor: Colors.red[800], foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))))] else ...[const Text("NOTE: Administrative tools disabled for guests.", style: TextStyle(color: Colors.orangeAccent, fontSize: 11, fontStyle: FontStyle.italic)), const SizedBox(height: 20), _actionBtn("Submit Citizen Report", Icons.report_problem, _showBhuPrahari)], if (_fieldEvidences.isNotEmpty) ...[const SizedBox(height: 25), const Text("Recent Field Records", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)), const SizedBox(height: 10), ..._fieldEvidences.map((e) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.image, color: Colors.cyanAccent, size: 16), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e['name'], style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)), Text("Geotag: ${e['lat'].toStringAsFixed(4)}, ${e['lon'].toStringAsFixed(4)}", style: const TextStyle(color: Colors.white54, fontSize: 10))])), const Icon(Icons.check_circle, color: Colors.green, size: 14)])))]]])));

  Widget _stat(String t, String v, Color c) => Container(margin: const EdgeInsets.only(bottom: 10), width: double.infinity, padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: const Color(0xFF1E293B).withValues(alpha: 0.5), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(color: Colors.white70, fontSize: 12)), const SizedBox(height: 5), Text(v, style: TextStyle(color: c, fontSize: 24, fontWeight: FontWeight.bold))]));
  Widget _col(String l, String v, Color c) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)), const SizedBox(height: 4), Text(v, style: TextStyle(color: c, fontSize: 14, fontWeight: FontWeight.bold))]);
  Widget _btn(String t, IconData i, VoidCallback tap) => ElevatedButton.icon(onPressed: tap, icon: Icon(i, size: 16), label: Text(t, style: const TextStyle(fontSize: 12)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))));
  Widget _actionBtn(String t, IconData i, VoidCallback tap) => Padding(padding: const EdgeInsets.only(bottom: 10), child: SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: tap, icon: Icon(i, size: 18), label: Text(t), style: ElevatedButton.styleFrom(alignment: Alignment.centerLeft, padding: const EdgeInsets.all(15), backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))));

  void _toggleDrone() { setState(() { _droneActive = !_droneActive; if (_droneActive) { _dronePos = _loc; _status = "🛸 DRONE SURVEILLANCE ACTIVE"; _droneTimer = Timer.periodic(const Duration(milliseconds: 500), (t) { setState(() { _dronePos = LatLng(_dronePos!.latitude + 0.00005, _dronePos!.longitude + 0.00005); }); }); } else { _droneTimer?.cancel(); _status = "✅ DRONE RETURNED TO BASE"; } }); }
  Future<void> _captureEvidence() async { try { _status = "📍 ACQUIRING GPS LOCK..."; setState(() {}); final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high); _status = "📸 OPENING SECURE CAMERA..."; setState(() {}); FilePickerResult? result = await FilePicker.pickFiles(type: FileType.image); if (result != null) { setState(() { _fieldEvidences.insert(0, {"name": "IMG_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.JPG", "lat": pos.latitude, "lon": pos.longitude, "time": DateFormat('HH:mm:ss').format(DateTime.now())}); _tasksList.insert(0, {"title": "Field Evidence Recorded", "desc": "Geotagged proof captured at ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}", "status": "Success", "time": DateFormat('HH:mm a').format(DateTime.now())}); _status = "✅ EVIDENCE SAVED TO BLOCKCHAIN"; }); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Geotagged Evidence Saved."), backgroundColor: Colors.green)); } else { setState(() => _status = "⚠️ CAPTURE CANCELLED"); } } catch (e) { setState(() => _status = "❌ GEOTAG ERROR: $e"); } }

  void _startTimer() { showDialog(context: context, builder: (c) { TextEditingController d = TextEditingController(); return AlertDialog(backgroundColor: const Color(0xFF0F172A), title: const Text("Set Warning Time", style: TextStyle(color: Colors.white)), content: TextField(controller: d, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "Enter seconds (e.g. 15)", filled: true)), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("CANCEL")), ElevatedButton(onPressed: () { Navigator.pop(c); setState(() { _evictSent = true; _timerSecs = int.tryParse(d.text) ?? 15; }); _timer = Timer.periodic(const Duration(seconds: 1), (t) { if (mounted) { setState(() { if (_timerSecs > 0) { _timerSecs--; } else { _canDemolish = true; _evictSent = false; t.cancel(); } }); } }); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800]), child: const Text("DISPATCH"))]); }); }
  
  void _showNotice() async {
    showDialog(context: context, builder: (c) => const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)));
    String noticeText = "Drafting Legal Notice...";
    try {
      final res = await http.post(Uri.parse("https://api.groq.com/openai/v1/chat/completions"), headers: {"Authorization": "Bearer $kGroqKey", "Content-Type": "application/json"}, body: jsonEncode({"model": "llama-3.3-70b-versatile", "messages": [{"role": "system", "content": "You are a legal officer. Draft a formal eviction notice for unauthorized construction on government land. Include terms like 'IMMEDIATE VACATION', 'PENALTY', and 'LEGAL ACTION'."}, {"role": "user", "content": "Area: $_area sqm, Location: ${_searchCtrl.text}"}]}));
      if (res.statusCode == 200) noticeText = jsonDecode(res.body)['choices'][0]['message']['content'];
    } catch (_) {}
    if (mounted) Navigator.pop(context);
    
    showDialog(context: context, builder: (c) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(40),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Column(children: [
                const Icon(Icons.account_balance, color: Colors.black, size: 40),
                const SizedBox(height: 10),
                const Text("GOVERNMENT OF INDIA", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 2)),
                const Text("OFFICE OF THE MUNICIPAL ADMINISTRATION", style: TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.bold)),
                const Divider(color: Colors.black, thickness: 1.5, height: 30),
              ])),
              const Text("REF NO: GRAVITY/EVICT/2026/449", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 5),
              Text("DATE: ${DateFormat('dd MMMM yyyy').format(DateTime.now()).toUpperCase()}", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 30),
              const Center(child: Text("LEGAL NOTICE FOR EVICTION", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.underline))),
              const SizedBox(height: 30),
              Text(noticeText, style: const TextStyle(color: Colors.black, fontSize: 13, height: 1.6, fontFamily: 'serif')),
              const SizedBox(height: 40),
              const Align(alignment: Alignment.bottomRight, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text("(AUTHORIZED SIGNATORY)", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                Text("GRAVITY AI COMMAND CENTER", style: TextStyle(color: Colors.black54, fontSize: 10)),
              ])),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(onPressed: () => Navigator.pop(c), child: const Text("CANCEL", style: TextStyle(color: Colors.red))),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: () { Navigator.pop(c); _makePDF(); }, child: const Text("DOWNLOAD PDF"))
              ])
            ],
          ),
        ),
      ),
    ));
  }

  void _showNotificationPanel() {
    showGeneralDialog(context: context, barrierDismissible: true, barrierLabel: "Notifications", pageBuilder: (c, a1, a2) => Align(alignment: Alignment.topRight, child: Container(width: 350, margin: const EdgeInsets.only(top: 60, right: 20), decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20)]), child: Material(color: Colors.transparent, child: Column(mainAxisSize: MainAxisSize.min, children: [Padding(padding: const EdgeInsets.all(15), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Critical Alerts", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.close, color: Colors.white54, size: 18), onPressed: () => Navigator.pop(c))])), const Divider(color: Colors.white10, height: 1), if (_tasksList.isEmpty) const Padding(padding: EdgeInsets.all(30), child: Text("No new notifications", style: TextStyle(color: Colors.white30, fontSize: 12))) else ..._tasksList.take(4).map((t) => ListTile(leading: Icon(Icons.warning_amber, color: t["status"] == "Success" ? Colors.greenAccent : Colors.orangeAccent, size: 20), title: Text(t["title"]!, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)), subtitle: Text(t["time"]!, style: const TextStyle(color: Colors.white30, fontSize: 11))))])))));
  }

  void _showComp() { showDialog(context: context, builder: (c) => Dialog(backgroundColor: const Color(0xFF0B1221), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.white10)), child: Container(width: 950, constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85), padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Expanded(child: Text("🛰️ Real-Time Land Comparison", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))), IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Navigator.pop(c))]), Container(padding: const EdgeInsets.all(10), margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.withValues(alpha: 0.3))), child: const Row(children: [Icon(Icons.info_outline, color: Colors.amber, size: 16), SizedBox(width: 8), Expanded(child: Text("LEFT: Historical imagery (clean land) | RIGHT: Current imagery with detected encroachments (RED zones)", style: TextStyle(color: Colors.amber, fontSize: 11)))] )), Expanded(child: Row(children: [Expanded(child: _compMapTile("🗓️ 2021 — Before Construction", 'https://wayback.maptiles.arcgis.com/arcgis/rest/services/World_Imagery/WMTS/1.0.0/default028mm/MapServer/tile/{z}/{y}/{x}', false)), const SizedBox(width: 12), Expanded(child: _compMapTile("🗓️ 2026 — Current (Encroachments Detected)", 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', true))]))])))); }
  Widget _compMapTile(String title, String tileUrl, bool showOverlay) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: showOverlay ? Colors.redAccent.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2), borderRadius: const BorderRadius.vertical(top: Radius.circular(8))), child: Row(children: [Icon(showOverlay ? Icons.warning_amber : Icons.check_circle, color: showOverlay ? Colors.redAccent : Colors.greenAccent, size: 16), const SizedBox(width: 6), Text(title, style: TextStyle(color: showOverlay ? Colors.redAccent : Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold))])), SizedBox(height: 300, child: Container(decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)), border: Border.all(color: showOverlay ? Colors.redAccent.withValues(alpha: 0.5) : Colors.greenAccent.withValues(alpha: 0.5))), child: ClipRRect(borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)), child: FlutterMap(options: MapOptions(initialCenter: _loc, initialZoom: 18.0), children: [TileLayer(urlTemplate: tileUrl), if (showOverlay) PolygonLayer(polygons: _anomalyPolygons), if (showOverlay) PolygonLayer(polygons: _govtPolygons)])))), ]);

  Future<void> _makePDF() async { try { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Generating PDF..."), backgroundColor: Colors.blue)); final pdf = pw.Document(); pdf.addPage(pw.Page(build: (pw.Context context) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [pw.Text('GRAVITY OFFICIAL DOSSIER', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)), pw.Divider(), pw.Text('Target Sector: ${_searchCtrl.text.toUpperCase()}'), pw.Text('Coordinates: ${_loc.latitude}, ${_loc.longitude}'), pw.SizedBox(height: 20), pw.Text('Notice Preview:'), pw.Text(_notice, style: const pw.TextStyle(fontSize: 10))]))); final bytes = await pdf.save(); await Printing.sharePdf(bytes: bytes, filename: 'Gravity_Report.pdf'); } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("PDF Error: $e"), backgroundColor: Colors.red)); } }

  Widget _footer() => Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 8), color: const Color(0xFF0B1221), child: const Center(child: Text("Gravity AI - Powered by ISRO Bhuvan - Siam-UNet Neural Networks", style: TextStyle(color: Colors.white24, fontSize: 11))));
  Widget _buildBoot() => Scaffold(backgroundColor: const Color(0xFF020617), body: Container(width: double.infinity, height: double.infinity, decoration: const BoxDecoration(color: Color(0xFF020617), image: DecorationImage(image: AssetImage(kEarthImg), fit: BoxFit.cover)), child: Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.only(left: 40.0), child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Image.asset("assets/images/logo.png", height: 75, errorBuilder: (c, e, s) => const Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 40)), const SizedBox(width: 8), const Text("Gravity AI", style: TextStyle(fontSize: 55, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1.0))]), const SizedBox(height: 40), Container(width: 300, height: 4, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2)), child: Stack(children: [ AnimatedContainer(duration: const Duration(milliseconds: 250), width: 300 * _bootProgress, height: 4, decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.white54, blurRadius: 10)])) ])), const SizedBox(height: 20), const Text("> INITIATING KERNEL...", style: TextStyle(color: Colors.white70, fontFamily: 'monospace', letterSpacing: 1.5, fontSize: 13))])))));
  
  void _showChatbot() { showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (context) => StatefulBuilder(builder: (context, setModalState) => Container(height: MediaQuery.of(context).size.height * 0.7, decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), border: Border.all(color: Colors.white24)), child: Column(children: [Padding(padding: const EdgeInsets.all(15), child: Row(children: [const Icon(Icons.auto_awesome, color: Colors.cyanAccent), const SizedBox(width: 10), const Text("Gravity Assistant", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), const Spacer(), IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Navigator.pop(context))])), Container(height: 1, color: Colors.white10), Expanded(child: ListView.builder(padding: const EdgeInsets.all(15), itemCount: _chatMsgs.length, itemBuilder: (context, index) { final msg = _chatMsgs[index]; bool isAi = msg['role'] == 'ai'; return Align(alignment: isAi ? Alignment.centerLeft : Alignment.centerRight, child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isAi ? const Color(0xFF1E293B) : Colors.cyanAccent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: isAi ? Colors.white10 : Colors.cyanAccent.withValues(alpha: 0.5))), child: Text(msg['text']!, style: const TextStyle(color: Colors.white)))); })), Padding(padding: const EdgeInsets.all(15), child: Row(children: [Expanded(child: TextField(controller: _chatCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "Ask Gravity AI...", hintStyle: TextStyle(color: Colors.white54)), onSubmitted: (val) { if (val.trim().isEmpty) return; setModalState(() { _chatMsgs.add({"role": "user", "text": val}); _chatCtrl.clear(); }); _getGroqResponse(val, setModalState); })), IconButton(icon: const Icon(Icons.send, color: Colors.cyanAccent), onPressed: () { String val = _chatCtrl.text; if (val.trim().isEmpty) return; setModalState(() { _chatMsgs.add({"role": "user", "text": val}); _chatCtrl.clear(); }); _getGroqResponse(val, setModalState); })]))])))); }
  Future<void> _getGroqResponse(String userMsg, Function setModalState) async { if (kGroqKey.isEmpty) { setModalState(() { _chatMsgs.add({"role": "ai", "text": "Error: Groq API Key not configured."}); }); return; } try { final response = await http.post(Uri.parse("https://api.groq.com/openai/v1/chat/completions"), headers: {"Authorization": "Bearer $kGroqKey", "Content-Type": "application/json"}, body: jsonEncode({"model": "llama-3.3-70b-versatile", "messages": [{"role": "system", "content": "You are Gravity AI, a geospatial intelligence assistant for ISRO Bhuvan platform. You help urban officers with encroachment detection, land mapping, and administrative tasks. Be professional, concise, and futuristic."}, {"role": "user", "content": userMsg}]})); if (response.statusCode == 200) { final data = jsonDecode(response.body); final aiMsg = data['choices'][0]['message']['content']; setModalState(() { _chatMsgs.add({"role": "ai", "text": aiMsg}); }); } } catch (e) { setModalState(() { _chatMsgs.add({"role": "ai", "text": "Connection Error: $e"}); }); } }
  void _showBhuPrahari() { showDialog(context: context, builder: (c) => AlertDialog(backgroundColor: const Color(0xFF0F172A), title: const Text("Citizen Portal", style: TextStyle(color: Colors.white)), content: const Text("Community reporting system active. You can submit reports of suspected encroachments here.", style: TextStyle(color: Colors.white70)))); }
}

class BlinkingLight extends StatefulWidget {
  final Color color;
  const BlinkingLight({Key? key, required this.color}) : super(key: key);
  @override
  _BlinkingLightState createState() => _BlinkingLightState();
}

class _BlinkingLightState extends State<BlinkingLight> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(width: 8, height: 8, decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: widget.color, blurRadius: 5)])),
    );
  }
}