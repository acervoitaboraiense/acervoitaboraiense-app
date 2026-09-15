class PixPayload {
  static String gerar({
    required String chave,
    required String nome,
    required String cidade,
    String? valor,
    String? txid,
  }) {
    nome = nome.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9 ]'), '').trim();
    if (nome.length > 25) nome = nome.substring(0, 25);
    if (nome.isEmpty) nome = 'RECEBEDOR';

    cidade = cidade.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9 ]'), '').trim();
    if (cidade.length > 15) cidade = cidade.substring(0, 15);
    if (cidade.isEmpty) cidade = 'CIDADE';

    txid = (txid ?? '***').replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    if (txid.length > 25) txid = txid.substring(0, 25);
    if (txid.isEmpty) txid = '***';

    final maInfo = _campo('00', 'br.gov.bcb.pix') + _campo('01', chave);
    final merchantAccount = _campo('26', maInfo);

    final sb = StringBuffer();
    sb.write(_campo('00', '01'));
    sb.write(merchantAccount);
    sb.write(_campo('52', '0000'));
    sb.write(_campo('53', '986'));
    if (valor != null && valor.isNotEmpty) {
      sb.write(_campo('54', valor));
    }
    sb.write(_campo('58', 'BR'));
    sb.write(_campo('59', nome));
    sb.write(_campo('60', cidade));
    sb.write(_campo('62', _campo('05', txid)));

    final payload = sb.toString();
    final crc = _crc16('$payload' '6304');
    return '${payload}6304$crc';
  }

  static String _campo(String id, String valor) {
    final tam = valor.length.toString().padLeft(2, '0');
    return '$id$tam$valor';
  }

  static String _crc16(String dados) {
    int crc = 0xFFFF;
    for (int i = 0; i < dados.length; i++) {
      crc ^= (dados.codeUnitAt(i) << 8);
      for (int j = 0; j < 8; j++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ 0x1021) & 0xFFFF;
        } else {
          crc = (crc << 1) & 0xFFFF;
        }
      }
    }
    return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
  }
}
