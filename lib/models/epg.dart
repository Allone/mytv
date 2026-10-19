class EpgProgramme {
  final int startAt;
  final int endAt;
  final String title;
  const EpgProgramme({required this.startAt, required this.endAt, required this.title});
}

class EpgProgrammeList {
  final List<EpgProgramme> programmes;
  const EpgProgrammeList({this.programmes = const []});
}

class Epg {
  final String channelName;
  final EpgProgrammeList programmes;
  const Epg({required this.channelName, required this.programmes});
}

class EpgList {
  final List<Epg> epgs;
  const EpgList({this.epgs = const []});
}