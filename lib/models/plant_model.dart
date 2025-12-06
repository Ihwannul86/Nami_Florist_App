class PlantApi {
    List<Datum> data;
    int to;
    int perPage;
    int currentPage;
    int from;
    int lastPage;
    int total;

    PlantApi({
        required this.data,
        required this.to,
        required this.perPage,
        required this.currentPage,
        required this.from,
        required this.lastPage,
        required this.total,
    });

}

class Datum {
    int id;
    String commonName;
    List<String> scientificName;
    List<String> otherName;
    Family? family;
    dynamic hybrid;
    dynamic authority;
    dynamic subspecies;
    String? cultivar;
    dynamic variety;
    String speciesEpithet;
    Genus genus;
    DefaultImage? defaultImage;

    Datum({
        required this.id,
        required this.commonName,
        required this.scientificName,
        required this.otherName,
        required this.family,
        required this.hybrid,
        required this.authority,
        required this.subspecies,
        required this.cultivar,
        required this.variety,
        required this.speciesEpithet,
        required this.genus,
        required this.defaultImage,
    });

}

class DefaultImage {
    int license;
    LicenseName licenseName;
    String licenseUrl;
    String originalUrl;
    String regularUrl;
    String mediumUrl;
    String smallUrl;
    String thumbnail;

    DefaultImage({
        required this.license,
        required this.licenseName,
        required this.licenseUrl,
        required this.originalUrl,
        required this.regularUrl,
        required this.mediumUrl,
        required this.smallUrl,
        required this.thumbnail,
    });

}

enum LicenseName {
    ATTRIBUTION_LICENSE,
    ATTRIBUTION_SHARE_ALIKE_30_UNPORTED_CC_BY_SA_30,
    ATTRIBUTION_SHARE_ALIKE_LICENSE,
    CC0_10_UNIVERSAL_CC0_10_PUBLIC_DOMAIN_DEDICATION
}

enum Family {
    PINACEAE,
    SAPINDACEAE
}

enum Genus {
    ABIES,
    ACER
}