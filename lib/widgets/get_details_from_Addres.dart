String getLineAddress({required String address}) {
  if (address.contains('8000')) {
    return '8L';
  }
  if (address.contains('THTOPER')) {
    return 'CF';
  }
  if (address.contains('THT')) {
    return 'THT';
  }
  if (address.contains('RMRC')) return 'RMRC';
  if (address.contains('7SR5')) return '7SR5';
  if (address.contains('Main Line') || address.contains('MainLine')) return 'Main Line';
  if (address.contains('A8000') || address.contains('Automation') || address.contains('A8')) {
    return 'A8000';
  }
  return 'Line Not Entered';
}

String requestTo({required String address}) {
  if (address.contains('THTPROD')) {
    return 'CF';
  } else {
    return 'Warehouse';
  }
}
