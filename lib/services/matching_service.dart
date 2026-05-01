class MatchingService {
  int calculateScore({
    required List<String> userCourses,
    required List<String> otherCourses,
    required List<String> userTags,
    required List<String> otherTags,
  }) {
    // Weights
    const int courseWeight = 20;
    const int tagWeight = 10;

    // Shared items
    final sharedCourses = userCourses
        .where((c) => otherCourses.contains(c))
        .length;

    final sharedTags = userTags.where((t) => otherTags.contains(t)).length;

    // Raw score
    final rawScore = (sharedCourses * courseWeight) + (sharedTags * tagWeight);

    // Maximum possible score
    final maxScore =
        (userCourses.length * courseWeight) + (userTags.length * tagWeight);

    if (maxScore == 0) return 0;

    // Convert to percentage
    final percent = ((rawScore / maxScore) * 100).round();

    return percent.clamp(0, 100);
  }
}
