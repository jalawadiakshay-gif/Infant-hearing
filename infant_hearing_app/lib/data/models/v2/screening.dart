import 'package:cloud_firestore/cloud_firestore.dart';

/// Embedded trial data within a BOA screening.
class BoaTrialData {
  final int dbLevel; // 45, 70, 90
  final int freqHz;
  final String response; // 'y', 'n', 'u'
  final bool isCatch;
  final double aiConf;
  final String aiType; // 'head', 'eye', 'moro', 'freeze', 'body', 'none'
  final int latencyMs;

  const BoaTrialData({
    required this.dbLevel,
    required this.freqHz,
    required this.response,
    required this.isCatch,
    required this.aiConf,
    required this.aiType,
    required this.latencyMs,
  });

  factory BoaTrialData.fromMap(Map<String, dynamic> data) {
    return BoaTrialData(
      dbLevel: data['db'] ?? 0,
      freqHz: data['hz'] ?? 0,
      response: data['r'] ?? 'u',
      isCatch: data['c'] ?? false,
      aiConf: (data['ai'] as num?)?.toDouble() ?? 0.0,
      aiType: data['det'] ?? 'none',
      latencyMs: data['ms'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'db': dbLevel,
      'hz': freqHz,
      'r': response,
      'c': isCatch,
      'ai': aiConf,
      'det': aiType,
      'ms': latencyMs,
    };
  }
}

/// Unified model for a screening session (Questionnaire or BOA).
class Screening {
  final String screeningId;
  final String childId;
  final String conductedBy;
  final String type; // 'q', 'boa'
  final String result; // 'pass', 'refer', 'monitor', 'incomplete'
  final DateTime date;
  final bool isOffline;
  final String? clipPath; // Local or Firebase Storage path for review clip
  final String? videoUrl; // Firebase Storage URL for the recorded screening video
  final String? pdfUrl;   // Firebase Storage URL for the generated PDF report
  final DateTime? createdAt;

  // Questionnaire specific
  final Map<String, String>? qAnswers;
  final int? qScore;
  final double? qRiskPct;
  final int? qAgeMonths;

  // BOA specific
  final String? boaOutcome;
  final double? boaNoiseDb;
  final List<BoaTrialData>? boaTrials;

  const Screening({
    required this.screeningId,
    required this.childId,
    required this.conductedBy,
    required this.type,
    required this.result,
    required this.date,
    this.isOffline = false,
    this.clipPath,
    this.videoUrl,
    this.pdfUrl,
    this.createdAt,
    this.qAnswers,
    this.qScore,
    this.qRiskPct,
    this.qAgeMonths,
    this.boaOutcome,
    this.boaNoiseDb,
    this.boaTrials,
  });

  factory Screening.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse questionnaire map
    final qMap = data['q'] as Map<String, dynamic>?;
    
    // Parse BOA map
    final bMap = data['b'] as Map<String, dynamic>?;
    final trialsData = bMap?['trials'] as List<dynamic>?;
    final List<BoaTrialData>? parsedTrials = trialsData
        ?.map((t) => BoaTrialData.fromMap(t as Map<String, dynamic>))
        .toList();

    return Screening(
      screeningId: doc.id,
      childId: data['childId'] ?? '',
      conductedBy: data['conductedBy'] ?? '',
      type: data['type'] ?? '',
      result: data['result'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      isOffline: data['offline'] ?? false,
      clipPath: data['clipPath'],
      videoUrl: data['videoUrl'],
      pdfUrl: data['pdfUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      
      qAnswers: qMap != null 
          ? Map<String, String>.from(qMap['answers'] as Map) 
          : null,
      qScore: qMap?['score'],
      qRiskPct: (qMap?['pct'] as num?)?.toDouble(),
      qAgeMonths: qMap?['age'],
      
      boaOutcome: bMap?['outcome'],
      boaNoiseDb: (bMap?['noise'] as num?)?.toDouble(),
      boaTrials: parsedTrials,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'childId': childId,
      'conductedBy': conductedBy,
      'type': type,
      'result': result,
      'date': Timestamp.fromDate(date),
      'offline': isOffline,
      if (clipPath != null) 'clipPath': clipPath,
      if (videoUrl != null) 'videoUrl': videoUrl,
      if (pdfUrl != null) 'pdfUrl': pdfUrl,
      if (type == 'q') 'q': {
        if (qAnswers != null) 'answers': qAnswers,
        if (qScore != null) 'score': qScore,
        if (qRiskPct != null) 'pct': qRiskPct,
        if (qAgeMonths != null) 'age': qAgeMonths,
      },
      if (type == 'boa') 'b': {
        if (boaOutcome != null) 'outcome': boaOutcome,
        if (boaNoiseDb != null) 'noise': boaNoiseDb,
        if (boaTrials != null) 'trials': boaTrials!.map((t) => t.toMap()).toList(),
      },
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  bool get isBoa => type == 'boa';
  bool get isQuestionnaire => type == 'q';

  @override
  String toString() => 'Screening(id: $screeningId, type: $type, result: $result)';
}
