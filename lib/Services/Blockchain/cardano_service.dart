class CardanoProof {
  final String contributionId;
  final String mockTxHash;
  final String mockDatumHash;

  const CardanoProof({
    required this.contributionId,
    required this.mockTxHash,
    required this.mockDatumHash,
  });
}

class CardanoService {
  Future<CardanoProof> generateMockProof(
      {required String contributionId}) async {
    final txHash =
        'mock_tx_${contributionId.substring(0, contributionId.length > 8 ? 8 : contributionId.length)}';
    final datumHash = 'mock_datum_${DateTime.now().millisecondsSinceEpoch}';

    return CardanoProof(
      contributionId: contributionId,
      mockTxHash: txHash,
      mockDatumHash: datumHash,
    );
  }

  Future<bool> isEnabled() async {
    return false;
  }
}
