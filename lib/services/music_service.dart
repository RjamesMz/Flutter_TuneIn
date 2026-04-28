import '../models/song.dart';
import '../core/app_strings.dart';

// ─── Music Service ────────────────────────────────────────────────────────────
/// Mock music service with a curated set of songs.
/// In a real app this would call a REST API or Firestore.
class MusicService {
  MusicService._();
  static final MusicService instance = MusicService._();

  /// Returns the full mock catalog after simulating a brief network delay.
  Future<List<Song>> fetchSongs() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockSongs;
  }

  /// Returns songs filtered by [query] (title or artist, case-insensitive).
  Future<List<Song>> search(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (query.trim().isEmpty) return _mockSongs;
    final q = query.toLowerCase();
    return _mockSongs
        .where((s) =>
            s.title.toLowerCase().contains(q) ||
            s.artist.toLowerCase().contains(q) ||
            s.album.toLowerCase().contains(q))
        .toList();
  }

  // ─── Mock Data ────────────────────────────────────────────────────────────
  static final List<Song> _mockSongs = [
    // Trending ────────────────────────────────────────────────────────────────
    Song(
      id: 's001',
      title: 'Velvet Dreams',
      artist: 'Satin Soul Collective',
      album: 'Midnight Velvet',
      category: MusicCategories.trending,
      duration: const Duration(minutes: 3, seconds: 47),
      coverUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuC-qZuxNFaeOssCv6_dYs3pgJ6Zf4sIxX2ED8rzQw-j97tBOb8h655dSYllrnhvG9vo0sn_JBjT2TWCf2bgku5hqTQ73uVsi-I1x5MHfV_yA3ZLkuLmVxnW6ZXUjs-0Trq-UjNU8pMAf6OzutHrYl5YUaUFYE9sCY68FHdG_s5gRgm71qZ5ouF-vbJAuB82fvz2gAPgS3AlUoOC_ai47pD8zk_CEi612HbGK_OM3Vq_tgPvFlEfCyDmdFBkgqhkDB-X28TqbIA0GdWs',
    ),
    Song(
      id: 's002',
      title: 'Neon City Lights',
      artist: 'Aurora Wave',
      album: 'Cyber Garden',
      category: MusicCategories.trending,
      duration: const Duration(minutes: 4, seconds: 12),
      coverUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD8e8gAocDhvBY80l7LBwGBRMp9zHYmBm2VnZSIYbvz3MQhB6oVHKSLXlGeMSnXr24B-43fNnaMqLY3vdlarjbGY4BlcedoXI1ZCsH1Cxn4n_YjP4CFVLB7SDxzqaJYGZW5xn_kk1tk318co3LC5Ndo3fqzpWWQoIcpM0Tn8EAAG7nvWJhrwnWZj-oLZTROqVRQ9lOZCFyTA7TRKHpAltTYYGfNP-Lyi0F4JERLLPjIjiL72B1gdKlbP0oWtxonIj-1BSCw7MO_DBEm',
    ),
    Song(
      id: 's003',
      title: 'Cotton Candy Skies',
      artist: 'Peach Prism',
      album: 'Hyper-pop Energy',
      category: MusicCategories.pop,
      duration: const Duration(minutes: 2, seconds: 58),
      coverUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCFB0hegcx2hUGZyxVQmrUfpznmHZAbS1royMqvhS0lfsOOOGTixx7oYOXFxoR5DU4tSAtHBBqwlB29IVIHCcZiDFuMr65tlxFi_IC07B8LKQ3Vuy_m4Z8jP7Sk4aCYG1N2dm8x5myFbINeWPSW7tkLBJ3phl74DXrbEsDUde2QY8WjeBeE3oJLQMSTlsohyA0ZPAi1dkKEl0TcTrt3g0-8XTyomj5ZooJFxrjYpjL3Z-AxQ9e1r1rcnuIkR_MgHGziPSyLUqGLbCCm',
    ),
    Song(
      id: 's004',
      title: 'Midnight Jazz',
      artist: 'Leo Carver Trio',
      album: 'Mellow Mornings',
      category: MusicCategories.jazz,
      duration: const Duration(minutes: 5, seconds: 33),
      coverUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCo0W25ybod2vfrdU5N5JgEi7LWQZ3o1NStOG6s2o4KEsbAyWqUgVi7TkEuU0jtEAuusYTzhJQ7ZZKHa6fKi4TxXx_RDb_4FkUjfSOnDO0GUEwM1r1fRwPrbHaVcBP25aNCjrEwIjsfk5JpJCF0HtZJPn1Gwfe44zrt0NZG-mHDbH0j5-606Yu7IkTmL9H3f1CcvAm_Kas9fn5YfInypT00ZMwvbA0TSAWgxFWqT6bgXQsAKB4nJsAejoNY-CKaUxGQRg_fVjwO5Sk4',
    ),
    Song(
      id: 's005',
      title: 'Indie Roads',
      artist: 'The Glass Keys',
      album: 'Indie Essentials',
      category: MusicCategories.indie,
      duration: const Duration(minutes: 3, seconds: 21),
      coverUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAP8xLsm5SPVJXUo83qjC3s89o0mrOwRW-BwVOkEn-GbClccrolApb7QqqqmAzKBvp-31yAykhqepYXjI-A1NmFI5qZtcLyzB-XlQdxILWtf85d39sSmrzrINHlgMShFizQIIE5iT_iNicH_emIxLWhhzxFpplMW7MlruKsCdrJcRRm7N2BiD7frBSheqPVziNk4Q3jkJJh_AAyEXqwx0mzbsQ0-q65aXoguMxczuovEjn87Nl5Vnz5Yxhdey8ANhPjfrxzu-mJo3ik',
    ),
    Song(
      id: 's006',
      title: 'Lo-Fi Study Beats Vol. 3',
      artist: 'Cloud Drift',
      album: 'Lo-Fi Study Beats',
      category: MusicCategories.loFi,
      duration: const Duration(minutes: 4, seconds: 05),
      coverUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuClX8soZ7d5K7mIgzjJT216UARHy43IMphni-BPx8O3-LMzQD2nH4phbZkiUR0fm8WPGnktKE-48bV6eBciqoyyzr-ozu3KB6bDu6KqR5fy1l7lCcIcoWP-fkGP1H58yn-xIHj1x0_FPAM5ct3ccnfJhxMEBjeoO5Bp5oBFBBzafcinBuMq80fnsBB7C-4pFIw_8GPlU3EUjepn03AuUKk46oSlRO2LRJteM0qWTBkbUP19e6rhI0SQO40OBlsadH59DLc2X903Nshd',
    ),
    Song(
      id: 's007',
      title: 'Aquarelle',
      artist: 'Émilie Fontaine',
      album: 'Pastel Hours',
      category: MusicCategories.rnb,
      duration: const Duration(minutes: 3, seconds: 52),
      coverUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCFB0hegcx2hUGZyxVQmrUfpznmHZAbS1royMqvhS0lfsOOOGTixx7oYOXFxoR5DU4tSAtHBBqwlB29IVIHCcZiDFuMr65tlxFi_IC07B8LKQ3Vuy_m4Z8jP7Sk4aCYG1N2dm8x5myFbINeWPSW7tkLBJ3phl74DXrbEsDUde2QY8WjeBeE3oJLQMSTlsohyA0ZPAi1dkKEl0TcTrt3g0-8XTyomj5ZooJFxrjYpjL3Z-AxQ9e1r1rcnuIkR_MgHGziPSyLUqGLbCCm',
    ),
    Song(
      id: 's008',
      title: 'Electric Honey',
      artist: 'Satin Soul Collective',
      album: 'Midnight Velvet',
      category: MusicCategories.rnb,
      duration: const Duration(minutes: 4, seconds: 28),
      coverUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD8e8gAocDhvBY80l7LBwGBRMp9zHYmBm2VnZSIYbvz3MQhB6oVHKSLXlGeMSnXr24B-43fNnaMqLY3vdlarjbGY4BlcedoXI1ZCsH1Cxn4n_YjP4CFVLB7SDxzqaJYGZW5xn_kk1tk318co3LC5Ndo3fqzpWWQoIcpM0Tn8EAAG7nvWJhrwnWZj-oLZTROqVRQ9lOZCFyTA7TRKHpAltTYYGfNP-Lyi0F4JERLLPjIjiL72B1gdKlbP0oWtxonIj-1BSCw7MO_DBEm',
    ),
    Song(
      id: 's009',
      title: 'Pine & Dusk',
      artist: 'The Glass Keys',
      album: 'Indie Essentials',
      category: MusicCategories.indie,
      duration: const Duration(minutes: 3, seconds: 10),
      coverUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAP8xLsm5SPVJXUo83qjC3s89o0mrOwRW-BwVOkEn-GbClccrolApb7QqqqmAzKBvp-31yAykhqepYXjI-A1NmFI5qZtcLyzB-XlQdxILWtf85d39sSmrzrINHlgMShFizQIIE5iT_iNicH_emIxLWhhzxFpplMW7MlruKsCdrJcRRm7N2BiD7frBSheqPVziNk4Q3jkJJh_AAyEXqwx0mzbsQ0-q65aXoguMxczuovEjn87Nl5Vnz5Yxhdey8ANhPjfrxzu-mJo3ik',
    ),
    Song(
      id: 's010',
      title: 'Shimmer & Shake',
      artist: 'Peach Prism',
      album: 'Hyper-pop Energy',
      category: MusicCategories.pop,
      duration: const Duration(minutes: 2, seconds: 43),
      coverUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCFB0hegcx2hUGZyxVQmrUfpznmHZAbS1royMqvhS0lfsOOOGTixx7oYOXFxoR5DU4tSAtHBBqwlB29IVIHCcZiDFuMr65tlxFi_IC07B8LKQ3Vuy_m4Z8jP7Sk4aCYG1N2dm8x5myFbINeWPSW7tkLBJ3phl74DXrbEsDUde2QY8WjeBeE3oJLQMSTlsohyA0ZPAi1dkKEl0TcTrt3g0-8XTyomj5ZooJFxrjYpjL3Z-AxQ9e1r1rcnuIkR_MgHGziPSyLUqGLbCCm',
    ),
    Song(
      id: 's011',
      title: 'Rain on Glass',
      artist: 'Cloud Drift',
      album: 'Lo-Fi Study Beats',
      category: MusicCategories.loFi,
      duration: const Duration(minutes: 3, seconds: 59),
      coverUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuClX8soZ7d5K7mIgzjJT216UARHy43IMphni-BPx8O3-LMzQD2nH4phbZkiUR0fm8WPGnktKE-48bV6eBciqoyyzr-ozu3KB6bDu6KqR5fy1l7lCcIcoWP-fkGP1H58yn-xIHj1x0_FPAM5ct3ccnfJhxMEBjeoO5Bp5oBFBBzafcinBuMq80fnsBB7C-4pFIw_8GPlU3EUjepn03AuUKk46oSlRO2LRJteM0qWTBkbUP19e6rhI0SQO40OBlsadH59DLc2X903Nshd',
    ),
    Song(
      id: 's012',
      title: 'Soul Frequency',
      artist: 'Leo Carver Trio',
      album: 'Mellow Mornings',
      category: MusicCategories.jazz,
      duration: const Duration(minutes: 6, seconds: 14),
      coverUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCo0W25ybod2vfrdU5N5JgEi7LWQZ3o1NStOG6s2o4KEsbAyWqUgVi7TkEuU0jtEAuusYTzhJQ7ZZKHa6fKi4TxXx_RDb_4FkUjfSOnDO0GUEwM1r1fRwPrbHaVcBP25aNCjrEwIjsfk5JpJCF0HtZJPn1Gwfe44zrt0NZG-mHDbH0j5-606Yu7IkTmL9H3f1CcvAm_Kas9fn5YfInypT00ZMwvbA0TSAWgxFWqT6bgXQsAKB4nJsAejoNY-CKaUxGQRg_fVjwO5Sk4',
    ),
  ];
}
