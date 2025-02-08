import Foundation

// MARK: - Data Structures
struct Student {
    let name: String
    var grades: [Double] // Array to store grades for 10 assignments
}

// MARK: - Core Functions

func loadStudents() -> [Student] {
    let filePath = "./students.csv"
    guard FileManager.default.fileExists(atPath: filePath) else {
        print("CSV file not found!")
        return []
    }

    do {
        let csvData = try String(contentsOfFile: filePath, encoding: .utf8)
        var students = [Student]()
        let lines = csvData.components(separatedBy: .newlines)

        for line in lines where !line.isEmpty {
            let components = line.components(separatedBy: ",")
            guard components.count >= 11 else { continue }

            let name = components[0].trimmingCharacters(in: .whitespaces)
            let grades = components[1...10].compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }

            guard grades.count == 10 else { continue }
            students.append(Student(name: name, grades: grades))
        }

        return students
    } catch {
        print("Error reading CSV file: \(error)")
        return []
    }
}

func calculateAverage(grades: [Double]) -> Double {
    guard !grades.isEmpty else { return 0.0 }
    return grades.reduce(0, +) / Double(grades.count)
}

func calculateClassAverage(students: [Student]) -> Double {
    let allGrades = students.flatMap { $0.grades }
    return calculateAverage(grades: allGrades)
}

func calculateAssignmentAverage(students: [Student], assignment: Int) -> Double {
    let assignmentGrades = students.compactMap { $0.grades[safe: assignment - 1] }
    return calculateAverage(grades: assignmentGrades)
}

func findLowestGrade(students: [Student]) -> (String, Double) {
    guard let student = students.min(by: { calculateAverage(grades: $0.grades) < calculateAverage(grades: $1.grades) }) else {
        return ("No students", 0.0)
    }
    return (student.name, calculateAverage(grades: student.grades))
}

func findHighestGrade(students: [Student]) -> (String, Double) {
    guard let student = students.max(by: { calculateAverage(grades: $0.grades) < calculateAverage(grades: $1.grades) }) else {
        return ("No students", 0.0)
    }
    return (student.name, calculateAverage(grades: student.grades))
}

func filterStudentsByGradeRange(students: [Student], minGrade: Double, maxGrade: Double) -> [Student] {
    return students.filter { student in
        let avg = calculateAverage(grades: student.grades)
        return avg >= minGrade && avg <= maxGrade
    }
}

// MARK: - Display Functions

func displayStudentGrade(students: [Student]) {
    let name = getStudentName(students: students)
    if let student = students.first(where: { $0.name.lowercased() == name.lowercased() }) {
        print("\(student.name)'s average grade: \(String(format: "%.2f", calculateAverage(grades: student.grades)))")
    }
}

func displayAllGradesForStudent(students: [Student]) {
    let name = getStudentName(students: students)
    if let student = students.first(where: { $0.name.lowercased() == name.lowercased() }) {
        print("\(student.name)'s grades: \(student.grades.map { String(format: "%.2f", $0) }.joined(separator: ", "))")
    }
}

func displayAllGradesAllStudents(students: [Student]) {
    for student in students {
        print("\(student.name): \(student.grades.map { String(format: "%.2f", $0) }.joined(separator: ", "))")
    }
}

// MARK: - Extra Credit Feature

func changeAssignmentGrade(for students: inout [Student]) {
    let name = getStudentName(students: students)
    guard let index = students.firstIndex(where: { $0.name.lowercased() == name.lowercased() }) else {
        print("Student not found.")
        return
    }

    print("Enter assignment number (1-10):", terminator: " ")
    guard let assignmentInput = readLine(), let assignment = Int(assignmentInput), (1...10).contains(assignment) else {
        print("Invalid assignment number.")
        return
    }

    print("Enter new grade for Assignment \(assignment):", terminator: " ")
    guard let gradeInput = readLine(), let newGrade = Double(gradeInput) else {
        print("Invalid grade input.")
        return
    }

    students[index].grades[assignment - 1] = newGrade
    print("Grade updated successfully for \(students[index].name).")
}

// MARK: - Input Handling

func getMenuChoice() -> Int {
    while true {
        print("\nEnter your choice (1-10):", terminator: " ")
        if let input = readLine(), let choice = Int(input), (1...10).contains(choice) {
            return choice
        }
        print("Invalid option. Please enter a number between 1 and 10.")
    }
}

func getStudentName(students: [Student]) -> String {
    while true {
        print("\nEnter the student's name:", terminator: " ")
        guard let name = readLine()?.trimmingCharacters(in: .whitespaces), !name.isEmpty else {
            print("Please enter a valid name.")
            continue
        }

        if students.contains(where: { $0.name.lowercased() == name.lowercased() }) {
            return name
        }
        print("Student '\(name)' does not exist. Please try again.")
    }
}

// MARK: - Main Program

func main() {
    var students = loadStudents()

    if students.isEmpty {
        print("No students loaded. Exiting program.")
        return
    }

    var shouldQuit = false

    while !shouldQuit {
        print("""
        \nWelcome to the Grade Manager!

        What would you like to do? (Enter the number):
        1. Display grade of a single student
        2. Display all grades for a student
        3. Display all grades of ALL students
        4. Find the average grade of the class
        5. Find the average grade of an assignment
        6. Find the lowest grade in the class
        7. Find the highest grade of the class
        8. Filter students by grade range
        9. Change a specific assignment grade for a student
        10. Quit
        """)

        switch getMenuChoice() {
        case 1: displayStudentGrade(students: students)
        case 2: displayAllGradesForStudent(students: students)
        case 3: displayAllGradesAllStudents(students: students)
        case 4: print("Class average: \(String(format: "%.2f", calculateClassAverage(students: students)))")
        case 5:
            print("Enter assignment number (1-10):", terminator: " ")
            if let input = readLine(), let assignment = Int(input), (1...10).contains(assignment) {
                let avg = calculateAssignmentAverage(students: students, assignment: assignment)
                print("Assignment \(assignment) average: \(String(format: "%.2f", avg))")
            } else {
                print("Invalid assignment number.")
            }
        case 6:
            let (name, avg) = findLowestGrade(students: students)
            print("Lowest grade: \(name) with \(String(format: "%.2f", avg))")
        case 7:
            let (name, avg) = findHighestGrade(students: students)
            print("Highest grade: \(name) with \(String(format: "%.2f", avg))")
        case 8:
            print("Enter minimum grade:", terminator: " ")
            guard let minInput = readLine(), let minGrade = Double(minInput) else {
                print("Invalid input.")
                continue
            }
            print("Enter maximum grade:", terminator: " ")
            guard let maxInput = readLine(), let maxGrade = Double(maxInput) else {
                print("Invalid input.")
                continue
            }
            let filteredStudents = filterStudentsByGradeRange(students: students, minGrade: minGrade, maxGrade: maxGrade)
            if filteredStudents.isEmpty {
                print("No students found in the specified range.")
            } else {
                for student in filteredStudents {
                    print("\(student.name): \(String(format: "%.2f", calculateAverage(grades: student.grades)))")
                }
            }
        case 9:
            changeAssignmentGrade(for: &students)
        case 10:
            print("Goodbye!")
            shouldQuit = true
        default:
            break
        }
    }
}

// MARK: - Helper Extensions

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// Run the program
main()
