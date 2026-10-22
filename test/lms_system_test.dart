import 'package:test/test.dart';

import 'package:lms_layered_architecture_example/service/lms_system.dart';

void main() {
  late LmsSystem lms;

  // Fresh LMS before every test: 2 students + 1 course
  setUp(() {
    lms = LmsSystem();
    lms.addStudent(studentId: 'S1', studentName: 'ronan');
    lms.addStudent(studentId: 'S2', studentName: 'sophea');
    lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
  });

  group('Task 1 - courses', () {
    test('add and remove a course', () {
      lms.addCourse(courseId: 'C2', courseName: 'Databases');
      expect(lms.courses.length, 2);
      lms.removeCourse(courseId: 'C2');
      expect(lms.courses.length, 1);
    });

    test('reject duplicate course id', () {
      expect(() => lms.addCourse(courseId: 'C1', courseName: 'X'),
          throwsException);
    });

    test('reject removal of nonexistent course', () {
      expect(() => lms.removeCourse(courseId: 'NOPE'), throwsException);
    });

    test('reject removal of course with students', () {
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      expect(() => lms.removeCourse(courseId: 'C1'), throwsException);
    });
  });

  group('Task 2 - enroll', () {
    test('enroll and verify', () {
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      expect(lms.courses.first.studentIds, contains('S1'));
    });

    test('reject unknown student', () {
      expect(() => lms.enrollStudent(studentId: 'X', courseId: 'C1'),
          throwsException);
    });

    test('reject unknown course', () {
      expect(() => lms.enrollStudent(studentId: 'S1', courseId: 'X'),
          throwsException);
    });

    test('reject duplicate enrollment', () {
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      expect(() => lms.enrollStudent(studentId: 'S1', courseId: 'C1'),
          throwsException);
    });
  });

  group('Task 3 - discard student from course', () {
    test('remove enrollment, student and course still exist', () {
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      lms.discardStudentFromCourse(studentId: 'S1', courseId: 'C1');
      expect(lms.courses.first.studentIds, isEmpty);
      expect(lms.students.length, 2);
      expect(lms.courses.length, 1);
    });

    test('reject nonexistent enrollment', () {
      expect(
          () => lms.discardStudentFromCourse(studentId: 'S1', courseId: 'C1'),
          throwsException);
    });

    test('results of that course are removed', () {
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      lms.addResult(studentId: 'S1', courseId: 'C1', score: 80);
      lms.discardStudentFromCourse(studentId: 'S1', courseId: 'C1');
      expect(lms.results, isEmpty);
    });

    test('removeStudent with several courses', () {
      lms.addCourse(courseId: 'C2', courseName: 'Databases');
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      lms.enrollStudent(studentId: 'S1', courseId: 'C2');
      lms.addResult(studentId: 'S1', courseId: 'C1', score: 60);
      lms.addResult(studentId: 'S1', courseId: 'C2', score: 70);
      lms.removeStudent(studentId: 'S1');
      expect(lms.students.length, 1);
      expect(lms.courses[0].studentIds, isEmpty);
      expect(lms.courses[1].studentIds, isEmpty);
      expect(lms.results, isEmpty);
    });
  });

  group('Task 4 - add result', () {
    setUp(() => lms.enrollStudent(studentId: 'S1', courseId: 'C1'));

    test('add a valid result', () {
      lms.addResult(studentId: 'S1', courseId: 'C1', score: 85);
      expect(lms.results.length, 1);
      expect(lms.results.first.score, 85);
    });

    test('reject nonexistent student or course', () {
      expect(() => lms.addResult(studentId: 'X', courseId: 'C1', score: 50),
          throwsException);
      expect(() => lms.addResult(studentId: 'S1', courseId: 'X', score: 50),
          throwsException);
    });

    test('reject student not enrolled', () {
      expect(() => lms.addResult(studentId: 'S2', courseId: 'C1', score: 50),
          throwsException);
    });

    test('reject invalid score', () {
      expect(() => lms.addResult(studentId: 'S1', courseId: 'C1', score: -1),
          throwsException);
      expect(() => lms.addResult(studentId: 'S1', courseId: 'C1', score: 101),
          throwsException);
    });

    test('reject duplicate result', () {
      lms.addResult(studentId: 'S1', courseId: 'C1', score: 50);
      expect(() => lms.addResult(studentId: 'S1', courseId: 'C1', score: 60),
          throwsException);
    });
  });

  group('Task 5 - remove result', () {
    late String r1;
    setUp(() {
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      lms.enrollStudent(studentId: 'S2', courseId: 'C1');
      r1 = lms.addResult(studentId: 'S1', courseId: 'C1', score: 70);
      lms.addResult(studentId: 'S2', courseId: 'C1', score: 80);
    });

    test('remove existing result, everything else unchanged', () {
      lms.removeResult(resultId: r1);
      expect(lms.results.length, 1);
      expect(lms.results.first.studentId, 'S2');
      expect(lms.students.length, 2);
      expect(lms.courses.length, 1);
      expect(lms.courses.first.studentIds.length, 2);
    });

    test('reject nonexistent result', () {
      expect(() => lms.removeResult(resultId: 'NOPE'), throwsException);
    });
  });

  test('scenario: removed student has no trace, other is unchanged', () {
    lms.enrollStudent(studentId: 'S1', courseId: 'C1');
    lms.enrollStudent(studentId: 'S2', courseId: 'C1');
    lms.addResult(studentId: 'S1', courseId: 'C1', score: 60);
    lms.addResult(studentId: 'S2', courseId: 'C1', score: 90);

    lms.removeStudent(studentId: 'S1');

    expect(lms.students.map((s) => s.id), ['S2']);
    expect(lms.courses.first.studentIds, ['S2']);
    expect(lms.results.length, 1);
    expect(lms.results.first.studentId, 'S2');
    expect(lms.results.first.score, 90);
  });
}
