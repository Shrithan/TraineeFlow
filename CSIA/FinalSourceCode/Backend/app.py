from flask import Flask, request, jsonify
import mysql.connector
from flask_cors import CORS
from collections import Counter
import random
import sqlite3
from datetime import datetime
from datetime import timedelta
import report_generation


initial_questions = [
    {
        "question": "What languages should the trainer be proficient in?",
        "options": ["English", "Hindi"]
    },
    {
        "question": "Do you prefer the training to be onsite, remote, or hybrid?",
        "options": ["Onsite", "Remote", "Hybrid"],
    },
    {
        "question": "What technical skills are you looking for in a trainer? (e.g., Java, Python, Angular)",
        "options": ["Java", "Python", "Angular"],
    },
    {
        "question": "What is your experience level? (in years)",
        "options": "-"
    }
]

final_questions = []

app = Flask(__name__)

CORS(app) 

# db = mysql.connector.connect(
#     host="localhost",
#     user="root",
#     password="Shrithan@2319",
#     database="TrainingManagement"
# )

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    role = data.get('role')

    conn = None
    cursor = None

    try:
        # Get database connection
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # Execute the query
        query = "SELECT Role FROM Users WHERE UserName = %s AND Password = %s AND Role = %s"
        cursor.execute(query, (username, password, role))

        # Ensure all results are fetched to avoid lingering results
        user = cursor.fetchone()
        cursor.fetchall()  # This ensures no unread results remain, even if unnecessary

        # Close cursor explicitly after fetching
        cursor.close()

        if user:
            return jsonify({'Role': user['Role']}), 200
        else:
            return jsonify({'message': 'Invalid credentials'}), 401

    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'message': 'Error connecting to the database'}), 500

    finally:
        # Ensure connection is closed
        if conn and conn.is_connected():
            conn.close()

def get_db_connection():
    connection = mysql.connector.connect(
        host="localhost",
        user="root",
        password="Shrithan@2319",
        database="TrainingManagement"
    )
    return connection

trainers_data = []

final_questions = []

@app.route('/initialize', methods=['POST'])
def initialize_all_arrays():
    global trainers_data
    global final_questions
    data = request.get_json() 
    print(data)
    try: 
        if data['initialize_yes_or_no'] == 'yes':
            
            connection = get_db_connection()
            cursor = connection.cursor()

            cursor.execute('''SELECT *
                        FROM Trainers
                        WHERE current_assigned_trainers < Max_Trainees;''')

            rows = cursor.fetchall()

            column_names = [description[0] for description in cursor.description]

            trainers_data = []
            for row in rows:
                trainer_dict = {column_names[i]: row[i] for i in range(len(column_names))}
                trainers_data.append(trainer_dict)

            print("++++++++++++++++++++Trainer  Data++++++++++++++++++++")
            print(trainers_data)

            #cursor = connection.cursor()

            cursor.execute("SELECT * FROM PromptQuestions")

            rows = cursor.fetchall()

            column_names = [description[0] for description in cursor.description]


            for row in rows:
                final_questions_dict = {column_names[i]: row[i] for i in range(len(column_names))}
                final_questions.append(final_questions_dict)

            print(final_questions)

        return jsonify({'message': 'Initialization successfull'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        if (connection.is_connected()):
            cursor.close()
            connection.close()

@app.route('/add_user', methods=['POST'])
def add_user():
    data = request.get_json()
    username = data.get('UserName')
    password = data.get('Password')
    role = data.get('Role')

    if not username or not password or not role:
        return jsonify({'error': 'Missing required fields'}), 400

    connection = get_db_connection()
    cursor = connection.cursor()

    try:
        query = "INSERT INTO Users (UserName, Password, Role) VALUES (%s, %s, %s)"
        cursor.execute(query, (username, password, role))
        connection.commit()
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        connection.close()

    return jsonify({'message': 'User added successfully'}), 201

@app.route('/send_initial_questions', methods=['GET'])
def send_initial_questions():
    return jsonify(initial_questions)

@app.route('/send_next_best_question', methods=['GET'])
def send_next_best_question():
    top_five_trainers = find_top_five(trainers_data)
    next_question = get_best_question(final_questions, top_five_trainers)

    split_strings = next_question['options'].split(", ")
    next_best_question = {
            'question': next_question["question_text"],
            'options': split_strings
        }
    return jsonify(next_best_question)

@app.route('/get_answer', methods=['POST'])
def get_answer():
    data = request.get_json() 
    question = data.get('question')  
    answer = data.get('answer') 
    top_five_trainers = find_top_five(trainers_data)
    for ques in final_questions:
        if ques["question_text"] == question:
            attribute = ques["attribute"]
    score_calculator(top_five_trainers, answer, attribute)

    return jsonify({'message': 'User added successfully'}), 200

answers_array = []

x=0

@app.route('/submit_answer', methods=['POST'])
def submit_answer():
    global x
    x = x +1
    data = request.get_json()
    print(f"Received data: {data}")  # Debugging line

    question = data.get('question')
    answer = data.get('answer')

    if not question or not answer:
        return jsonify({'error': 'Missing question or answer'}), 400

    answers_array.append({
        'question': question,
        'answer': answer
    })

    print(f"Updated answers array: {answers_array}")  # Debugging line
    
    if x == 3:
        get_initial_score()

    return jsonify({'message': 'Answer received successfully'}), 200

@app.route('/submit_experience_answer', methods=['POST'])
def submit_experience_answer():
    data = request.get_json()
    print(f"Received data: {data}")  # Debugging line

    question = data.get('question')
    answer = data.get('answer')

    if not question or not answer:
        return jsonify({'error': 'Missing question or answer'}), 400

    answers_array.append({
        'question': question,
        'answer': answer
    })

    print("Updated answers array: {answers_array}")  # Debugging line

    top_five = find_experience_match_score(trainers_data)

    return jsonify({'message': 'Answer received successfully'}), 200

def transform_string(input_string):
    return input_string.replace(" ", "_").lower()

final_scores = []

def has_only_one_max(a_list):
    sorted_list = sorted(a_list, reverse=True)
    if sorted_list[0] == sorted_list[1]:
        return False
    else:
        return True

def find_top_five(trainers, top_n=5):
    sorted_trainers = sorted(trainers, key=lambda x: x['match_score'], reverse=True)

    if len(sorted_trainers) < top_n:
        top_n_score = sorted_trainers[-1]["match_score"]
    else:
        top_n_score = sorted_trainers[top_n - 1]["match_score"]

    top_trainers = [trainer for trainer in sorted_trainers if trainer["match_score"] >= top_n_score]
    
    return top_trainers

def get_initial_score():
    for answer in answers_array:
        if answer['question'] == "What languages should the trainer be proficient in?":
            language_choice = answer["answer"]
        elif answer['question'] == "Do you prefer the training to be onsite, remote, or hybrid?":
            location_choice = answer["answer"]
        elif answer['question'] == "What technical skills are you looking for in a trainer? (e.g., Java, Python, Angular)":
            programming_language_choice = answer["answer"]

    for trainer in trainers_data:
        score = 0
        trainer_language_proficiency = trainer["language_proficiency"]
        trainer_technical_skills = trainer["trainer_technical_skills"]
        trainer_location = trainer["trainer_location"]
        if language_choice in trainer_language_proficiency:
            score = score + 100
        if programming_language_choice in trainer_technical_skills:
            score = score + 100
        if location_choice in trainer_location:
            score = score + 100
        trainer["match_score"] = score
        final_scores.append(score)
    
def find_experience_match_score(trainer_list, answers_array=answers_array):
    trainer_experience = int(answers_array[3]["answer"])
    for trainer in trainer_list:
        current_trainer_experience = trainer["trainer_experience"]
        if current_trainer_experience > trainer_experience:
            continue
        elif current_trainer_experience == trainer_experience:
            trainer["match_score"] += 100
        else:
            trainer["match_score"] += (100 - (trainer_experience - current_trainer_experience) / 15 * 100)

    top_five = find_top_five(trainer_list)
    return top_five

def find_common_attributes(trainers, attribute):
    attribute_counts = Counter()
    for trainer in trainers:
        if isinstance(trainer[attribute], list):
            attribute_counts.update(trainer[attribute])
        else:
            attribute_counts[trainer[attribute]] += 1
    

    max_count = max(attribute_counts.values())
    min_count = min(attribute_counts.values())
    

    max_attributes = [key for key, count in attribute_counts.items() if count == max_count]
    min_attributes = [key for key, count in attribute_counts.items() if count == min_count]
    
    return {
        "max_count": max_count,
        "max_attributes": max_attributes,
        "min_count": min_count,
        "min_attributes": min_attributes
    }

def get_best_question(final_questions, top_five_trainers):
    attribute = "project_mapping"  
    PM_result = find_common_attributes(top_five_trainers, attribute)
    attribute = "business_domain_expertise" 
    BDE_result = find_common_attributes(top_five_trainers, attribute)
    attribute = "training_styles"
    TS_result = find_common_attributes(top_five_trainers, attribute)
    attribute = "soft_skills"
    SS_result = find_common_attributes(top_five_trainers, attribute)
    attribute = "learning_management_skills"
    LMS_result = find_common_attributes(top_five_trainers, attribute)
    attribute = "availability_and_flexibility"
    AF_result = find_common_attributes(top_five_trainers, attribute)
    attribute = "training_goals"
    TG_result = find_common_attributes(top_five_trainers, attribute)
    attribute = "training_duration"
    TD_result = find_common_attributes(top_five_trainers, attribute)
    attribute = "target_audience"
    TA_result = find_common_attributes(top_five_trainers, attribute)

    min_attributes = [PM_result["min_attributes"], BDE_result["min_attributes"], TS_result["min_attributes"], SS_result["min_attributes"], LMS_result["min_attributes"], AF_result["min_attributes"], TG_result["min_attributes"], TD_result["min_attributes"], TA_result["min_attributes"]]
    attributes = ["project_mapping", "business_domain_expertise", "training_styles", "soft_skills", "learning_management_skills", "availability_and_flexibility", "training_goals", "training_duration", "target_audience"]
    attribute_min_lengths = [len(min_attr) for min_attr in min_attributes]
    max_min_common_index = attribute_min_lengths.index(max(attribute_min_lengths))
    next_attribute_to_ask = attributes[max_min_common_index]
    already_asked_question = []

    for i in range(len(final_questions)):
        if final_questions[i]["already_asked"]:
            already_asked_question.append(i)
    if final_questions[max_min_common_index]["already_asked"]:
        valid_indices = [i for i in range(len(final_questions)) if i not in already_asked_question]
        if valid_indices:
            random_index = random.choice(valid_indices)
            final_questions[random_index]["already_asked"] = True
            return(final_questions[random_index])
        else:
            return("Completed All questions")
    
    elif final_questions[max_min_common_index]["already_asked"] == False:
        final_questions[max_min_common_index]["already_asked"] = True
        return(final_questions[max_min_common_index])
        
def score_calculator(top_trainers, answer, next_attribute_to_ask):
    next_attribute_to_ask = transform_string(next_attribute_to_ask)
    for trainer in top_trainers:  
        trainer_attribute_value = trainer[next_attribute_to_ask]
        if answer in trainer_attribute_value:
            trainer["match_score"] += 100




@app.route('/get_best_trainer', methods=['GET'])
def get_best_trainer():
    fin_top_five_trainers = find_top_five(trainers_data)
    return jsonify(fin_top_five_trainers)

final_trainer_choice = ""

final_trainer = {}

@app.route('/get_assigned_trainer', methods=['POST'])
def get_assigned_trainer():
    global final_trainer 
    global trainers_data

    try:
        connection = get_db_connection()
        cursor = connection.cursor()

        cursor.execute("SELECT * FROM Trainers")
        rows = cursor.fetchall()
        column_names = [description[0] for description in cursor.description]

        for row in rows:
            trainer_dict = {column_names[i]: row[i] for i in range(len(column_names))}
            trainers_data.append(trainer_dict)
        #print(trainers_data)
    
        data = request.get_json()
        trainee_name = data.get('TraineeName')
        #print(trainee_name)

        traineeIDQuery = "SELECT UserID FROM Users WHERE UserName = %s"
        cursor.execute(traineeIDQuery, (trainee_name, ))
        res1=cursor.fetchone()
        traineeID = res1[0]
        #print(traineeID)   

        traineeQuery = "SELECT BatchID FROM Trainee_Batches WHERE TraineeID = %s"
        cursor.execute(traineeQuery, (traineeID, ))
        res=cursor.fetchone()   
        batch_id = res[0]
        #print(batch_id)   

        finalQuery = "SELECT TrainerID FROM Batches WHERE BatchID = %s"
        cursor.execute(finalQuery, (batch_id, ))
        res2=cursor.fetchone()   
        trainerID = res2[0]

        #print(trainers_data)
        for trainer in trainers_data:
            if trainer["TrainerID"] == trainerID:
                print(trainer)
                final_trainer = trainer
                break

        return jsonify({'message': 'Trainer choice received successfully'}), 200
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': str(e)}), 500
    finally:
        if(connection.is_connected):
            cursor.close()
            connection.close()
        

alltrainees = []

@app.route('/get_assigned_trainees', methods=['POST'])
def get_assigned_trainees():
    print("I came to get Assigned Trainees 2")
    global alltrainees
    try:
        connection = get_db_connection()   
        cursor = connection.cursor()

        data = request.get_json()
        trainer_name = data.get('TrainerID')

        # SQL query to get trainee names
        getAllTrainees = '''
            SELECT B.UserName FROM Batches A, Users B, Trainee_Batches C, Users D 
            WHERE A.BatchID = C.BatchID AND B.UserID = C.TraineeID AND A.TrainerID = D.UserID AND D.UserName = %s'''
        cursor.execute(getAllTrainees, (trainer_name,))
        allTrainees = cursor.fetchall()

        # Extract trainee names from list of tuples
        trainee_names = [trainee[0] for trainee in allTrainees]  # Flattening the list of tuples
        #print("Trainee Names:", trainee_names)
        alltrainees = trainee_names

        #print("ALL Trainee Names:", alltrainees)

        # Return properly formatted JSON response
        return jsonify({'trainee_names': alltrainees, 'message': 'Trainer choice received successfully'}), 200

    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': str(e)}), 500

    finally:
        if(connection.is_connected):
            cursor.close()
            connection.close()
        

        
@app.route('/send_all_trainees', methods=['GET'])
def send_assigned_trainees():
    global alltrainees
    return jsonify(alltrainees)

trainer_batch_id = 0


@app.route('/get_batch_progress', methods=['POST'])
def get_batch_progress():
    try:
        connection = get_db_connection()
        cursor = connection.cursor()
                
        # SQL query to get batch progress
        getBatches = '''SELECT 
                            CONCAT(A.BatchName, ' - ', B.UserName) AS Batch_Trainer,
                            LEAST(GREATEST((DATEDIFF(SYSDATE(), A.StartDate) / NULLIF(DATEDIFF(A.EndDate, A.StartDate), 0)), 0), 100) AS Progress
                        FROM 
                            Batches A, Users B 
                        WHERE 
                            A.TrainerID = B.UserID;'''
    
        cursor.execute(getBatches)
        batch_progress = cursor.fetchall()

        print("ALL Batchs:", batch_progress)

        # Return properly formatted JSON response
        return jsonify({'batch_progress': batch_progress}), 200

    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': str(e)}), 500

    finally:
        if (connection.is_connected):
            cursor.close()
            connection.close()


@app.route('/get_trainers_information', methods=['POST'])
def get_trainers_information():
    try:
        
        connection = get_db_connection()
        cursor = connection.cursor()

        # SQL query to get trainers information
        getTrainersInfo = '''SELECT TrainerID, trainer_name, training_goals, target_audience FROM Trainers;'''
    
        cursor.execute(getTrainersInfo)
        trainerInformation = cursor.fetchall()

        print("Trainers Information :", trainerInformation)
        
        # Always close the cursor after executing a query
        cursor.close()

        # Return properly formatted JSON response
        return jsonify({'trainers_information': trainerInformation}), 200

    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': str(e)}), 500

    finally:
        # Close the connection in case of success or failure
        if (connection.is_connected):
            connection.close()

@app.route('/add_task', methods=['POST'])
def get_batch_id():
    global trainer_batch_id

    try:
        connection = get_db_connection()
        cursor = connection.cursor()
    
        data = request.get_json()
        trainer_name = data.get('TrainerName')
        task_name = data.get('TaskName')
        task_description = data.get('TaskDescription')
        task_deadline = data.get('TaskDeadline')

        #print(trainee_name)

        traineeIDQuery = "SELECT TrainerID FROM Trainers WHERE trainer_name = %s"
        cursor.execute(traineeIDQuery, (trainer_name, ))
        res1=cursor.fetchone()
        trainerID = res1[0]
        #print(traineeID)   

        traineeQuery = "SELECT BatchID FROM Batches WHERE TrainerID = %s"
        cursor.execute(traineeQuery, (trainerID, ))
        res=cursor.fetchone()   
        batch_id = res[0]
        trainer_batch_id = batch_id

        insertQuery = '''INSERT INTO Tasks
                        (
                        TaskName,
                        BatchID,
                        TaskDescription,
                        AssignedDate,
                        DueDate)
                        VALUES(%s, %s, %s, %s, %s);'''

        cursor.execute(insertQuery, (task_name, batch_id, task_description, datetime.now(), task_deadline))
        connection.commit()
        return jsonify({'message': 'Task Added Successfully'}), 200
    
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': str(e)}), 500
    finally:
        if(connection.is_connected):
            cursor.close()
            connection.close()

@app.route('/send_trainer_choice', methods=['POST'])
def get_trainer_choice():
    
    global final_trainer_choice
    global final_trainer

    try : 
        data = request.get_json()
        print(data)
        trainer_choice = data.get('TrainerID')
        trainee_name = data.get('TraineeName')

        print(trainer_choice)

        conn = get_db_connection()
        cursor = conn.cursor()

        traineeQuery = "SELECT UserID FROM Users WHERE UserName = %s"
        cursor.execute(traineeQuery, (trainee_name, ))
        res=cursor.fetchone()   
        traineeId = res[0]

        query="SELECT BatchID FROM Batches WHERE TrainerID = %s"    
        cursor.execute(query, (trainer_choice,))
        res = cursor.fetchone()
        batch_id = res[0]

        insert_query = '''INSERT INTO Trainee_Batches
                        (TraineeID, 
                        BatchID,
                        RegistrationDate)
                        VALUES (%s, %s, %s)'''

        print("Hellor(**************************************)")
        print(traineeId)
        update_trainers_query = '''UPDATE Trainers
            SET current_assigned_trainers = current_assigned_trainers + 1
            WHERE TrainerID = %s'''
        
        cursor.execute(insert_query, (traineeId, batch_id, datetime.now()))
        
        cursor.execute(update_trainers_query, (trainer_choice, ))

        conn.commit()
        
        final_trainer_choice = trainer_choice
        for trainer in trainers_data:
            if trainer["TrainerID"] == final_trainer_choice:
                final_trainer = trainer
                break
        
        return jsonify({'message': 'Trainer choice received successfully'}), 200

    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': str(e)}), 500
    finally:
        if(conn.is_connected):
            cursor.close() 
            conn.close() 

@app.route('/get_final_trainer', methods=['GET'])
def send_final_trainer():
    return jsonify(final_trainer)

@app.route('/api/update_trainer_info', methods=['POST'])
def update_trainer_info():
    try:
        data = request.get_json()
        trainee_name = data.get('traineeName')
        trainer_name = data.get('trainerName')
        attendance_feedback = data.get('attendance_feedback')
        skill_feedback = data.get('skill_feedback')
        engagement_feedback = data.get('engagement_feedback')
        assignment_feedback = data.get('assignement_feedback')
        communication_feedback = data.get('communication_feedback')
        teamwork_feedback = data.get('teamwork_feedback')
        problemsolving_feedback = data.get('problemsolving_feedback')
        adaptability_feedback = data.get('adaptability_feedback')
        additional_feedback = data.get('additional_feedback')

        days_attended = int(data.get('days_attended', ))
        total_days = int(data.get('total_days', ))
        pre_skill = int(data.get('pre_skill', ))
        post_skill = int(data.get('post_skill', ))
        engagement_amount = int(data.get('engagement_amount', ))
        completed_assignments = int(data.get('completed_assignments', ))
        total_assignments = int(data.get('total_assignments', ))
        verbal_communication = int(data.get('verbal_communication', ))
        written_communication = int(data.get('written_communication', ))
        team_contribution = int(data.get('team_contribution', ))
        conflict_management = int(data.get('conflict_management', ))
        analytical_skills = int(data.get('analytical_skills', ))
        creativity = int(data.get('creativity', ))
        learning_curve = int(data.get('learning_curve', ))
        overall_score = int(data.get('overall_score', ))

        # Additional responses
        exit_response_1 = data.get('exit_response_1')
        exit_response_2 = data.get('exit_response_2')
        print(trainer_name)
        print(trainee_name)
        print(attendance_feedback)

        conn = get_db_connection()
        cursor = conn.cursor()

        traineeID_query = "SELECT UserID FROM Users WHERE UserName = %s"
        cursor.execute(traineeID_query, (trainee_name, ))
        traineeID = cursor.fetchone()[0]

        trainerID_query = "SELECT UserID FROM Users WHERE UserName = %s"
        cursor.execute(trainerID_query, (trainer_name, ))
        trainerID = cursor.fetchone()[0]

        query = '''
                INSERT INTO TraineeFeedback
                (
                    TraineeID,
                    TrainerID,
                    AttendanceFeedback,
                    SkillFeedback,
                    EngagementFeedback,
                    AssignmentFeedback,
                    CommunicationFeedback,
                    TeamworkFeedback,
                    ProblemSolvingFeedback,
                    AdaptabilityFeedback,
                    AdditionalFeedback,
                    DaysAttended,
                    TotalDays,
                    PreSkill,
                    PostSkill,
                    EngagedAmount,
                    CompletedAssignments,
                    TotalAssignments,
                    VerbalCommunication,
                    WrittenCommunication,
                    TeamContribution,
                    ConflictManagement,
                    AnalyticalSkills,
                    Creativity,
                    LearningCurve,
                    OverallScore,
                    ExitResponse1,
                    ExitResponse2
                )
                VALUES
                (
                    %s, %s, %s, %s, %s, 
                    %s, %s, %s, %s, %s, 
                    %s, %s, %s, %s, %s, 
                    %s, %s, %s, %s, %s, 
                    %s, %s, %s, %s, %s, 
                    %s, %s, %s
                );
                '''
        values = (
                    traineeID, trainerID, attendance_feedback, skill_feedback, engagement_feedback, 
                    assignment_feedback, communication_feedback, teamwork_feedback, 
                    problemsolving_feedback, adaptability_feedback, additional_feedback, 
                    days_attended, total_days, pre_skill, post_skill, 
                    engagement_amount, completed_assignments, total_assignments, 
                    verbal_communication, written_communication, team_contribution, 
                    conflict_management, analytical_skills, creativity, learning_curve, 
                    overall_score, exit_response_1, exit_response_2
                )
        print("************** Values ************ ")
        print(values)


        cursor.execute(query, (
            traineeID, trainerID, attendance_feedback, skill_feedback, engagement_feedback, 
            assignment_feedback, communication_feedback, teamwork_feedback, 
            problemsolving_feedback, adaptability_feedback, additional_feedback, 
            days_attended, total_days, pre_skill, post_skill, 
            engagement_amount, completed_assignments, total_assignments, 
            verbal_communication, written_communication, team_contribution, 
            conflict_management, analytical_skills, creativity, learning_curve, 
            overall_score, exit_response_1, exit_response_2
        ))

        conn.commit()
        return jsonify({"message": "Trainer information updated successfully"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()


@app.route('/api/check_allocation', methods=['POST'])
def check_allocation():
    data = request.json
    trainee_name = data.get('trainee_name')
    print("************** Trainee Name ************ ")
    print(trainee_name)

    if not trainee_name:
        return jsonify({'error': 'Trainee name is required'}), 400

    try:
        connection = get_db_connection()
        cursor = connection.cursor()

        traineeQuery = "SELECT UserID FROM Users WHERE UserName = %s"
        cursor.execute(traineeQuery, (trainee_name, ))
        res=cursor.fetchone()   
        if len(res) == 0:
            return jsonify({'allocated': False, 'message': 'Trainee not found'}), 404
        
        traineeId = res[0]

        query = "SELECT BatchID FROM Trainee_Batches WHERE TraineeID = %s"
        cursor.execute(query, (traineeId,))
        result = cursor.fetchone()
        
        if len(result) == 0:
            is_allocated = False
            return jsonify({'allocated': is_allocated})
        else:
            is_allocated = True
            return jsonify({'allocated': is_allocated})
    
        #is_allocated = result[0] == 1  # Check if is_allocated is 1
        print(f"Trainee {trainee_name} is allocated: {is_allocated}")
    except Exception as e:
        print(f"Database error: {e}")
        return jsonify({'error': 'Internal server error'}), 500
    # Ensure the database connection is closed
    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()


@app.route('/tasks', methods=['GET'])
def get_tasks():
   
    date = request.args.get('date')  # Format: 'YYYY-MM-DD'
    trainee_name = request.args.get('trainee_name')  # Trainee name to filter tasks
    
    # Check if both parameters are provided
    if not date or not trainee_name:
        return jsonify({"error": "Both date and trainee_name are required"}), 400
    
    try:
        # Establish database connection
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        # Query to filter tasks by both date and trainee_name
        query = '''
            SELECT A.* FROM TrainingManagement.Tasks A, Trainee_Batches B, Users C
            WHERE A.BatchID = B.BatchID 
            AND B.TraineeID = C.UserID
            AND C.UserName = %s
            AND DATE(A.DueDate) = %s;
        '''   
        cursor.execute(query, (trainee_name, date))
        
        # Fetch the results
        tasks = cursor.fetchall()

        # If no tasks are found, return a 404 response
        if not tasks:
            return jsonify({"message": "No tasks found for the specified date and trainee."}), 404
        
        # Return the tasks as a JSON response
        return jsonify(tasks)
    except Exception as e:
        # Handle any exceptions that occur during the database operation
        return jsonify({"error": str(e)}), 500
    # Ensure the database connection is closed
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()

def get_total_count(table_name):

    try:
        connection = get_db_connection()
        cursor = connection.cursor()
        
        # Query to get the total count of rows in the table
        query = f"SELECT COUNT(*) FROM {table_name}"
        cursor.execute(query)
        
        # Fetch the result and get the count
        count = cursor.fetchone()[0]
        
        return count
    except mysql.connector.Error as err:
        return str(err)
    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()

@app.route('/get_row_count/<table_name>', methods=['GET'])
def get_row_count(table_name):
    # Get the total row count for the specified table
    count = get_total_count(table_name)
    
    if isinstance(count, int):
        return jsonify({'table': table_name, 'row_count': count})
    else:
        return jsonify({'error': count}), 500


@app.route('/generate-pdf', methods=['POST'])
def generate_pdf():
    trainee_name = request.json.get('trainee_name')
    print("************** Trainee Name ************ ")
    print(trainee_name)
    
    if not trainee_name:
        return jsonify({"error": "Trainee name is required"}), 400

    try:
        connection = get_db_connection()
        cursor = connection.cursor()

        # SQL query to get data related to pdf generation
        reportDetailsQuery = '''SELECT A.* , C.BatchExitQuestion1, C.BatchExitQuestion2
                                FROM TraineeFeedback A, Users B, Batches C
                                WHERE A.TraineeID = B.UserID and C.TrainerID = A.TrainerID and B.UserName = %s;'''

        cursor.execute(reportDetailsQuery, (trainee_name,))
        print("Shilpa - Query executed successfully.")
        report_details = cursor.fetchall()

        print("All Report Details: 1", report_details[0][28])
        print("All Report Details: 2", report_details[0][29])
        print("All Report Details: 3", report_details[0][30])
        print("All Report Details: 4", report_details[0][31])
        # Run your Python PDF generation script

        TraineeFeedbackID =  report_details[0][0]
        TraineeID =  report_details[0][1]
        TrainerID =  report_details[0][2]
        AttendanceFeedback =  report_details[0][3]
        SkillFeedback =  report_details[0][4]
        EngagementFeedback =  report_details[0][5]
        AssignmentFeedback =  report_details[0][6]
        CommunicationFeedback =  report_details[0][7]
        TeamworkFeedback =  report_details[0][8]
        ProblemSolvingFeedback =  report_details[0][9]
        AdaptabilityFeedback =  report_details[0][10]
        AdditionalFeedback =  report_details[0][11]
        FeedbackDate =  report_details[0][12]
        DaysAttended =  report_details[0][13]
        TotalDays =  report_details[0][14]
        PreSkill =  report_details[0][15]
        PostSkill =  report_details[0][16]
        EngagedAmount =  report_details[0][17]
        CompletedAssignments =  report_details[0][18]
        TotalAssignments =  report_details[0][19]
        VerbalCommunication =  report_details[0][20]
        WrittenCommunication =  report_details[0][21]
        TeamContribution =  report_details[0][22]
        ConflictManagement =  report_details[0][23]
        AnalyticalSkills =  report_details[0][24]
        Creativity =  report_details[0][25]
        LearningCurve =  report_details[0][26]
        OverallScore =  report_details[0][27]
        ExitResponse1 = report_details[0][28]
        ExitResponse2 = report_details[0][29]
        BatchExitQuestion1 =  report_details[0][30]
        BatchExitQuestion2 = report_details[0][31]

        data = {
            'attendance': {'attended':DaysAttended, 'total': TotalDays, 'remarks': AttendanceFeedback},
            'skill': {'pre': PreSkill, 'post': PostSkill, 'remarks': SkillFeedback},
            'engagement': {'engaged': EngagedAmount, 'remarks': EngagementFeedback},
            'assignments': {'completed': CompletedAssignments, 'total': TotalAssignments, 'remarks': AssignmentFeedback},
            'communication': {'verbal': VerbalCommunication, 'written': WrittenCommunication, 'remarks': CommunicationFeedback},
            'teamwork': {'team_contribution': TeamContribution, 'conflict_management': ConflictManagement, 'remarks': TeamworkFeedback},
            'problem_solving': {'analytical': AnalyticalSkills, 'creativity': Creativity, 'remarks': ProblemSolvingFeedback},
            'adaptability': {'learning_curve': LearningCurve, 'remarks': AdaptabilityFeedback},
            'final_evaluation': {'overall_score': OverallScore, 'certification_ready': 'Yes'}
        }
        print("************** Data ************ ")

        report = report_generation.TraineeReport(
            trainee_name=trainee_name,
            trainee_id=TraineeID,
            trainer_name=TrainerID,
            training_dates=FeedbackDate,
            additional_comments=AdditionalFeedback,
            batch_exit_question1=BatchExitQuestion1,
            batch_exit_question2=BatchExitQuestion2,
            exit_response_1=ExitResponse1,
            exit_response_2=ExitResponse2,
            data=data
        )
        print("************** Report ************ ")

        charts = report.create_charts()
        print("************** Charts ************ ")
        report.generate_pdf(charts)


        #subprocess.run(['python', 'generate_pdf.py', trainee_name], check=True)

        # Assuming the script generates 'output.pdf' as the file
        #return send_file('output.pdf', as_attachment=True)
        return jsonify({"message": "PDF generated successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if(connection.is_connected()):
            cursor.close()
            connection.close()

@app.route('/add_trainee_feedback', methods=['POST'])
def add_trainee_feedback():
    
    data = request.get_json() 
    print(data)
    Feedback = data.get('Feedback')
    TraineeName = data.get('TraineeName')
    print(Feedback)
    print(TraineeName)
    
    try: 
        conn = get_db_connection()
        cursor = conn.cursor()

        selectQuery = '''SELECT UserID, C.TrainerID FROM Users A, Trainee_Batches B, Batches C 
                        WHERE UserName = %s and A.UserID = B.TraineeID and B.BatchID = C.BatchID'''

        insertQuery = '''INSERT INTO TrainerFeedback (
                        TraineeID,
                        TrainerID,
                        FeedbackContent,
                        FeedbackDate)
                        VALUES
                        (%s, %s, %s, %s);
                        '''
        cursor.execute(selectQuery, (TraineeName, ))
        result = cursor.fetchall()

        cursor.execute(insertQuery, (result[0][0], result[0][1], Feedback, datetime.now()))
        conn.commit()
    

        return jsonify({"message": "Trainer information updated successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if(conn.is_connected()):
            cursor.close()
            conn.close()


@app.route('/get_trainees_status_info', methods=['POST'])
def get_trainees_status_info():
    
    data = request.get_json()
    trainer_id = data.get('trainer_id')
    
    try:
        print("Trainer ID :", trainer_id)
        connection = get_db_connection()
        cursor = connection.cursor()

        # SQL query to get trainees and status information
        getTraineesAndStatusInfo = '''
                SELECT 
                    D.UserName,
                    CASE
                        WHEN A.TraineeID IS NOT NULL THEN 'Completed'
                        ELSE 'Incomplete'
                    END AS Status
                FROM 
                    Trainee_Batches B
                JOIN 
                    Batches C ON B.BatchID = C.BatchID
                JOIN
                    Users D ON D.UserID = B.TraineeID
                LEFT JOIN 
                    TraineeFeedback A ON A.TraineeID = B.TraineeID AND A.TrainerID = C.TrainerID
                WHERE 
                    C.TrainerID = %s;'''
    
        cursor.execute(getTraineesAndStatusInfo,(trainer_id,))
        traineesAndStatusInfo = cursor.fetchall()

        print("Trainees and Status Information :", traineesAndStatusInfo)
        
        # Return properly formatted JSON response
        return jsonify({'trainees_and_status_info': traineesAndStatusInfo}), 200

    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': str(e)}), 500

    finally:
        # Close the connection in case of success or failure
        if (connection.is_connected):
            cursor.close
            connection.close()

if __name__ == '__main__':
    app.run(debug=True, port=5000)