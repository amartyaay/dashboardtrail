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
  return '7SR5';
}

String requestTo({required String address}) {
  if (address.contains('THTPROD')) {
    return 'CF';
  } else {
    return 'Warehouse';
  }
}
