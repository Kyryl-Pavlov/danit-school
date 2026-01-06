import requests
import json

BASE_URL = "http://127.0.0.1:5000/students"
RESULTS_FILE = "results.txt"

def log_result(file, action, response):
    """Helper to print to console and write to results.txt"""
    output = f"--- ACTION: {action} ---\n"
    output += f"Status Code: {response.status_code}\n"
    output += f"Response Body: {json.dumps(response.json(), indent=2)}\n"
    output += "-" * 30 + "\n\n"
    
    print(output)
    file.write(output)

def run_tests():
    with open(RESULTS_FILE, "w", encoding="utf-8") as f:
        # 1. Retrieve all existing students (GET)
        log_result(f, "GET ALL STUDENTS (START)", requests.get(BASE_URL))

        # 2. Create three students (POST)
        students_to_create = [
            {"first_name": "Alice", "last_name": "Smith", "age": 21},
            {"first_name": "Bob", "last_name": "Jones", "age": 22},
            {"first_name": "Charlie", "last_name": "Brown", "age": 23}
        ]
        for student in students_to_create:
            log_result(f, f"CREATE STUDENT: {student['first_name']}", requests.post(BASE_URL, json=student))

        # 3. Retrieve all students (GET)
        log_result(f, "GET ALL STUDENTS (AFTER POST)", requests.get(BASE_URL))

        # 4. Update the age of the second student (PATCH)
        # Assuming ID 2 for the second student
        log_result(f, "PATCH STUDENT 2 AGE", requests.patch(f"{BASE_URL}/2", json={"age": 25}))

        # 5. Retrieve information about the second student (GET)
        log_result(f, "GET STUDENT 2", requests.get(f"{BASE_URL}/2"))

        # 6. Update first name, last name, and age of the third student (PUT)
        # Assuming ID 3 for the third student
        put_data = {"first_name": "Charles", "last_name": "Xavier", "age": 50}
        log_result(f, "PUT STUDENT 3", requests.put(f"{BASE_URL}/3", json=put_data))

        # 7. Retrieve information about the third student (GET)
        log_result(f, "GET STUDENT 3", requests.get(f"{BASE_URL}/3"))

        # 8. Retrieve all existing students (GET)
        log_result(f, "GET ALL STUDENTS (BEFORE DELETE)", requests.get(BASE_URL))

        # 9. Delete the first user (DELETE)
        # Assuming ID 1 for the first student
        log_result(f, "DELETE STUDENT 1", requests.delete(f"{BASE_URL}/1"))

        # 10. Retrieve all existing students (GET)
        log_result(f, "GET ALL STUDENTS (FINAL)", requests.get(BASE_URL))

if __name__ == "__main__":
    try:
        run_tests()
        print(f"Tests completed. Results saved to {RESULTS_FILE}")
    except requests.exceptions.ConnectionError:
        print("Error: Could not connect to the API. Make sure app.py is running on http://127.0.0.1:5000")