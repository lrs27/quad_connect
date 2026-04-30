class MatchingService {
  int calculateScore({
    required List<String> userCourses,
    required List<String> otherCourses,
    required List<String> userTags,
    required List<String> otherTags,
  }) {
    int score = 0;

    score += userCourses.where((c) => otherCourses.contains(c)).length * 2;
    score += userTags.where((t) => otherTags.contains(t)).length;

    return score;
  }
}
