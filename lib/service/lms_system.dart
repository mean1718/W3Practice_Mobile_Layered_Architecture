import '../model/student.dart';
import '../model/course.dart';
import '../model/course_result.dart';

// I CHOSE:
// - removeCourse: refused if students are enrolled or results exist
// - discardStudentFromCourse: also removes that student's results in the course
// - addResult: student must be enrolled, score 0..100, one result per student/course
// - removeResult: removes only that result
class LmsSystem {
  final List<Student> students = [];
  final List<Course> courses = [];
  final List<CourseResult> results = [];
  int _nextResultId = 1;

  void addStudent({required String studentId, required String studentName}) {
    // ! Student shall not exist already
    Student? student = _findStudentOrNull(studentId);
    if (student != null) {
      throw Exception('Student $studentId already exists');
    }

    students.add(Student(id: studentId, name: studentName));
  }

  void removeStudent({required String studentId}) {
    Student? student = _findStudentOrNull(studentId);
    if (student == null) {
      throw Exception('Student $studentId not found');
    }
    // 1- Remove student from the students list
    students.removeWhere((student) => student.id == studentId);
    // 2- Remove student from every course
    for (Course c in courses) {
      c.studentIds.remove(studentId);
    }
    // 3- Remove all results of this student
    results.removeWhere((r) => r.studentId == studentId);
  }

  // Task 1
  void addCourse({required String courseId, required String courseName}) {
    if (_findCourseOrNull(courseId) != null) {
      throw Exception('Course $courseId already exists');
    }
    courses.add(Course(id: courseId, name: courseName));
  }

  void removeCourse({required String courseId}) {
    Course? course = _findCourseOrNull(courseId);
    if (course == null) {
      throw Exception('Course $courseId not found');
    }
    if (course.studentIds.isNotEmpty) {
      throw Exception('Course $courseId still has students');
    }
    if (results.any((r) => r.courseId == courseId)) {
      throw Exception('Course $courseId still has results');
    }
    courses.remove(course);
  }

  // Task 2
  void enrollStudent({required String studentId, required String courseId}) {
    if (_findStudentOrNull(studentId) == null) {
      throw Exception('Student $studentId not found');
    }
    Course? course = _findCourseOrNull(courseId);
    if (course == null) {
      throw Exception('Course $courseId not found');
    }
    if (course.studentIds.contains(studentId)) {
      throw Exception('Student $studentId already enrolled');
    }
    course.studentIds.add(studentId);
  }

  // Task 3
  void discardStudentFromCourse(
      {required String studentId, required String courseId}) {
    if (_findStudentOrNull(studentId) == null) {
      throw Exception('Student $studentId not found');
    }
    Course? course = _findCourseOrNull(courseId);
    if (course == null) {
      throw Exception('Course $courseId not found');
    }
    if (!course.studentIds.contains(studentId)) {
      throw Exception('Student $studentId is not enrolled');
    }
    course.studentIds.remove(studentId);
    // results of this student in this course are removed too
    results
        .removeWhere((r) => r.studentId == studentId && r.courseId == courseId);
  }

  // Task 4
  // returns the id of the new result
  String addResult(
      {required String studentId,
      required String courseId,
      required int score}) {
    if (_findStudentOrNull(studentId) == null) {
      throw Exception('Student $studentId not found');
    }
    Course? course = _findCourseOrNull(courseId);
    if (course == null) {
      throw Exception('Course $courseId not found');
    }
    if (!course.studentIds.contains(studentId)) {
      throw Exception('Student $studentId is not enrolled');
    }
    if (score < 0 || score > 100) {
      throw Exception('Score must be between 0 and 100');
    }
    if (results
        .any((r) => r.studentId == studentId && r.courseId == courseId)) {
      throw Exception('Student already has a result for this course');
    }

    String id = 'R${_nextResultId++}';
    results.add(CourseResult(
        id: id, studentId: studentId, courseId: courseId, score: score));
    return id;
  }

  //Task 5
  void removeResult({required String resultId}) {
    int before = results.length;
    results.removeWhere((r) => r.id == resultId);
    if (results.length == before) {
      throw Exception('Result $resultId not found');
    }
  }

  // helpers
  Student? _findStudentOrNull(String studentId) {
    for (Student s in students) {
      if (s.id == studentId) {
        return s;
      }
    }
    return null; // not found
  }

  Course? _findCourseOrNull(String courseId) {
    for (Course c in courses) {
      if (c.id == courseId) {
        return c;
      }
    }
    return null;
  }
}
