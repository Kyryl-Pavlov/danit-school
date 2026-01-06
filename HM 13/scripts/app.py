import csv
import os
from flask import Flask, request, jsonify

app = Flask(__name__)
CSV_FILE = 'students.csv'
HEADERS = ['id', 'first_name', 'last_name', 'age']

# Ensure CSV exists and has headers
if not os.path.exists(CSV_FILE):
    with open(CSV_FILE, mode='w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=HEADERS)
        writer.writeheader()

def read_students():
    with open(CSV_FILE, mode='r') as f:
        return list(csv.DictReader(f))

def write_students(students):
    with open(CSV_FILE, mode='w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=HEADERS)
        writer.writeheader()
        writer.writerows(students)

# --- ROUTES ---

@app.route('/students', methods=['GET'])
def get_students():
    # Check for last_name query parameter
    last_name = request.args.get('last_name')
    students = read_students()
    
    if last_name:
        filtered = [s for s in students if s['last_name'].lower() == last_name.lower()]
        if not filtered:
            return jsonify({"error": f"No students found with last name '{last_name}'"}), 404
        return jsonify(filtered)
    
    return jsonify(students)

@app.route('/students/<int:student_id>', methods=['GET'])
def get_student_by_id(student_id):
    students = read_students()
    student = next((s for s in students if int(s['id']) == student_id), None)
    if not student:
        return jsonify({"error": "Student ID not found"}), 404
    return jsonify(student)

@app.route('/students', methods=['POST'])
def create_student():
    data = request.get_json() or {}
    students = read_students()

    # Validation: No fields or extra fields
    required = {'first_name', 'last_name', 'age'}
    if not data:
        return jsonify({"error": "No data provided"}), 400
    if not required.issubset(data.keys()) or not set(data.keys()).issubset(required):
        return jsonify({"error": "Invalid or missing fields. Required: first_name, last_name, age"}), 400

    # Auto-increment ID
    new_id = 1 if not students else max(int(s['id']) for s in students) + 1
    
    new_student = {
        'id': str(new_id),
        'first_name': data['first_name'],
        'last_name': data['last_name'],
        'age': str(data['age'])
    }
    
    students.append(new_student)
    write_students(students)
    return jsonify(new_student), 201

@app.route('/students/<int:student_id>', methods=['PUT'])
def update_student(student_id):
    data = request.get_json() or {}
    students = read_students()
    student = next((s for s in students if int(s['id']) == student_id), None)

    if not student:
        return jsonify({"error": "Student ID not found"}), 404

    required = {'first_name', 'last_name', 'age'}
    if not data or not required.issubset(data.keys()) or not set(data.keys()).issubset(required):
        return jsonify({"error": "Invalid or missing fields for PUT"}), 400

    student.update({
        'first_name': data['first_name'],
        'last_name': data['last_name'],
        'age': str(data['age'])
    })
    
    write_students(students)
    return jsonify(student)

@app.route('/students/<int:student_id>', methods=['PATCH'])
def patch_student_age(student_id):
    data = request.get_json() or {}
    students = read_students()
    student = next((s for s in students if int(s['id']) == student_id), None)

    if not student:
        return jsonify({"error": "Student ID not found"}), 404

    # Validation: Only age is allowed, and must be present
    if not data or 'age' not in data or len(data) > 1:
        return jsonify({"error": "Only the 'age' field is allowed and required"}), 400

    student['age'] = str(data['age'])
    write_students(students)
    return jsonify(student)

@app.route('/students/<int:student_id>', methods=['DELETE'])
def delete_student(student_id):
    students = read_students()
    # Check if student exists
    if not any(int(s['id']) == student_id for s in students):
        return jsonify({"error": "Student ID not found"}), 404

    new_list = [s for s in students if int(s['id']) != student_id]
    write_students(new_list)
    return jsonify({"message": f"Student {student_id} successfully deleted"}), 200

if __name__ == '__main__':
    app.run(debug=True)