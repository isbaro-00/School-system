import 'package:supabase_flutter/supabase_flutter.dart';

class FeeService {
  final SupabaseClient client;

  FeeService({SupabaseClient? client})
      : client = client ?? Supabase.instance.client;

  Future<List<Map<String, dynamic>>> listFeeTypes({
    required String schoolId,
  }) async {
    final data = await client
        .from('fee_types')
        .select('id, name, description, amount, frequency, status')
        .eq('school_id', schoolId)
        .order('name');

    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> createFeeType({
    required String schoolId,
    required String name,
    required num amount,
    String? description,
    String? frequency,
  }) async {
    final data = await client
        .from('fee_types')
        .insert({
          'school_id': schoolId,
          'name': name.trim(),
          'amount': amount,
          if (description != null && description.trim().isNotEmpty)
            'description': description.trim(),
          if (frequency != null && frequency.trim().isNotEmpty)
            'frequency': frequency.trim(),
        })
        .select()
        .single();

    return Map<String, dynamic>.from(data);
  }

  Future<List<Map<String, dynamic>>> listStudentFees({
    required String schoolId,
    String? studentId,
  }) async {
    var query = client
        .from('student_fees')
        .select(
          'id, student_id, fee_type_id, amount_due, amount_paid, due_date, status, fee_types(name)',
        )
        .eq('school_id', schoolId);

    if (studentId != null) {
      query = query.eq('student_id', studentId);
    }

    final data = await query.order('due_date', ascending: true);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> createStudentFee({
    required String schoolId,
    required String studentId,
    required String feeTypeId,
    required num amountDue,
    DateTime? dueDate,
  }) async {
    final data = await client
        .from('student_fees')
        .insert({
          'school_id': schoolId,
          'student_id': studentId,
          'fee_type_id': feeTypeId,
          'amount_due': amountDue,
          if (dueDate != null) 'due_date': _dateOnly(dueDate),
        })
        .select()
        .single();

    return Map<String, dynamic>.from(data);
  }

  Future<List<Map<String, dynamic>>> listPayments({
    required String schoolId,
    String? studentId,
  }) async {
    var query = client
        .from('payments')
        .select(
          'id, payment_id, student_id, student_fee_id, amount, payment_method, payment_date, reference, status',
        )
        .eq('school_id', schoolId);

    if (studentId != null) {
      query = query.eq('student_id', studentId);
    }

    final data = await query.order('payment_date', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> recordPayment({
    required String schoolId,
    required String studentId,
    required String studentFeeId,
    required num amount,
    required String paymentMethod,
    String? reference,
    DateTime? paymentDate,
  }) async {
    final data = await client
        .from('payments')
        .insert({
          'school_id': schoolId,
          'student_id': studentId,
          'student_fee_id': studentFeeId,
          'amount': amount,
          'payment_method': paymentMethod,
          if (reference != null && reference.trim().isNotEmpty)
            'reference': reference.trim(),
          if (paymentDate != null) 'payment_date': _dateOnly(paymentDate),
        })
        .select()
        .single();

    return Map<String, dynamic>.from(data);
  }

  String _dateOnly(DateTime date) {
    final d = date.toLocal();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
