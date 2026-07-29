String normalizeDepartment(String? rawDept) {
  if (rawDept == null) return '';

  final dept = rawDept.toUpperCase().trim();

  if (dept.contains('BALE')) return 'BALE';
  if (dept.contains('BAG')) return 'BAGPRODUCTION';
  if (dept.contains('LAMINATION')) return 'LAMINATION';
  if (dept.contains('CUT')) return 'CUTTING';
  if (dept.contains('LOOM')) return 'LOOM';
  if (dept.contains('RMD')) return 'RMD';
  if (dept.contains('SAMPLE')) return 'SAMPLE';

  return dept;
}
