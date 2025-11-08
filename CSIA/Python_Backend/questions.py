import random
from collections import defaultdict
trainers = [
    {
        "Trainer Experience": 3,
        "Trainer Location": "Onsite",
        "Trainer Technical Skills": ["Java", "SQL"],
        "Project Mapping": "Web Development",
        "Business Domain Expertise": "Finance",
        "Training Styles": "Hands-on",
        "Soft Skills": ["Communication", "Teamwork"],
        "Learning Management Skills": "Moodle",
        "Language Proficiency": ["English"],
        "Availability and Flexibility": ["Morning", "Weekends"]
    },
    {
        "Trainer Experience": 9,
        "Trainer Location": "Remote",
        "Trainer Technical Skills": ["Python", "Cloud (AWS/Azure)"],
        "Project Mapping": "AI/ML",
        "Business Domain Expertise": "Healthcare",
        "Training Styles": "Lecture-based",
        "Soft Skills": ["Leadership"],
        "Learning Management Skills": "Blackboard",
        "Language Proficiency": ["Spanish"],
        "Availability and Flexibility": ["Afternoon"]
    },
    {
        "Trainer Experience": 5,
        "Trainer Location": "Hybrid",
        "Trainer Technical Skills": ["Angular", ".NET"],
        "Project Mapping": "DevOps",
        "Business Domain Expertise": "Retail",
        "Training Styles": "Hybrid",
        "Soft Skills": ["Conflict Resolution", "Communication"],
        "Learning Management Skills": "Custom LMS",
        "Language Proficiency": ["French"],
        "Availability and Flexibility": ["Evening", "Morning"]
    },
    {
        "Trainer Experience": 8,
        "Trainer Location": "Onsite",
        "Trainer Technical Skills": ["React", "Python"],
        "Project Mapping": "Mobile Development",
        "Business Domain Expertise": "Education",
        "Training Styles": "Hands-on",
        "Soft Skills": ["Leadership"],
        "Learning Management Skills": "Moodle",
        "Language Proficiency": ["German", "English"],
        "Availability and Flexibility": ["Morning"]
    },
    {
        "Trainer Experience": 15,
        "Trainer Location": "Remote",
        "Trainer Technical Skills": ["Java", "Cloud (AWS/Azure)"],
        "Project Mapping": "Security",
        "Business Domain Expertise": "Technology",
        "Training Styles": "Lecture-based",
        "Soft Skills": ["Communication"],
        "Learning Management Skills": "Blackboard",
        "Language Proficiency": ["Chinese"],
        "Availability and Flexibility": ["Afternoon", "Weekends"]
    },
    {
        "Trainer Experience": 15,
        "Trainer Location": "Onsite",
        "Trainer Technical Skills": ["Angular", "SQL"],
        "Project Mapping": "Data Analysis",
        "Business Domain Expertise": "Retail",
        "Training Styles": "Hands-on",
        "Soft Skills": ["Teamwork"],
        "Learning Management Skills": "Moodle",
        "Language Proficiency": ["English", "German"],
        "Availability and Flexibility": ["Morning", "Weekends"]
    },
    {
        "Trainer Experience": 15,
        "Trainer Location": "Hybrid",
        "Trainer Technical Skills": ["React", ".NET"],
        "Project Mapping": "Web Development",
        "Business Domain Expertise": "Education",
        "Training Styles": "Hybrid",
        "Soft Skills": ["Communication", "Conflict Resolution"],
        "Learning Management Skills": "Custom LMS",
        "Language Proficiency": ["French"],
        "Availability and Flexibility": ["Evening", "Morning"]
    },
    {
        "Trainer Experience": 15,
        "Trainer Location": "Remote",
        "Trainer Technical Skills": ["Python", "SQL"],
        "Project Mapping": "DevOps",
        "Business Domain Expertise": "Finance",
        "Training Styles": "Lecture-based",
        "Soft Skills": ["Leadership"],
        "Learning Management Skills": "Blackboard",
        "Language Proficiency": ["Spanish"],
        "Availability and Flexibility": ["Afternoon", "Weekends"]
    },
    {
        "Trainer Experience": 15,
        "Trainer Location": "Hybrid",
        "Trainer Technical Skills": ["Java", "Cloud (AWS/Azure)"],
        "Project Mapping": "AI/ML",
        "Business Domain Expertise": "Technology",
        "Training Styles": "Hands-on",
        "Soft Skills": ["Communication"],
        "Learning Management Skills": "Custom LMS",
        "Language Proficiency": ["English"],
        "Availability and Flexibility": ["Morning"]
    },
    {
        "Trainer Experience": 15,
        "Trainer Location": "Onsite",
        "Trainer Technical Skills": ["Angular", "Python"],
        "Project Mapping": "Mobile Development",
        "Business Domain Expertise": "Healthcare",
        "Training Styles": "Hands-on",
        "Soft Skills": ["Teamwork"],
        "Learning Management Skills": "Moodle",
        "Language Proficiency": ["German", "French"],
        "Availability and Flexibility": ["Morning", "Evening"]
    },
    {
        "Trainer Experience": 15,
        "Trainer Location": "Remote",
        "Trainer Technical Skills": ["React", "SQL"],
        "Project Mapping": "Security",
        "Business Domain Expertise": "Finance",
        "Training Styles": "Lecture-based",
        "Soft Skills": ["Leadership"],
        "Learning Management Skills": "Blackboard",
        "Language Proficiency": ["Chinese", "Spanish"],
        "Availability and Flexibility": ["Evening"]
    },
    {
        "Trainer Experience": 15,
        "Trainer Location": "Hybrid",
        "Trainer Technical Skills": ["Java", ".NET"],
        "Project Mapping": "Web Development",
        "Business Domain Expertise": "Retail",
        "Training Styles": "Hybrid",
        "Soft Skills": ["Communication"],
        "Learning Management Skills": "Custom LMS",
        "Language Proficiency": ["English"],
        "Availability and Flexibility": ["Morning", "Afternoon"]
    },
    {
        "Trainer Experience": 15,
        "Trainer Location": "Onsite",
        "Trainer Technical Skills": ["SQL", "Angular"],
        "Project Mapping": "Data Analysis",
        "Business Domain Expertise": "Finance",
        "Training Styles": "Hands-on",
        "Soft Skills": ["Conflict Resolution"],
        "Learning Management Skills": "Moodle",
        "Language Proficiency": ["French", "English"],
        "Availability and Flexibility": ["Morning", "Weekends"]
    }
]
def dynamic_questionnaire_with_weightage(trainers):
    filtered_trainers = trainers.copy()

    # Questions with weightage
    questions = [
        {
            "question": "What languages should the trainer be proficient in?",
            "attribute": "Language Proficiency",
            "type": "categorical_list",
        },
        {
            "question": "How many years of experience do you prefer in a trainer?",
            "attribute": "Trainer Experience",
            "type": "numerical",
        },
        {
            "question": "Do you prefer the training to be onsite, remote, or hybrid?",
            "attribute": "Trainer Location",
            "type": "categorical",
        },
        {
            "question": "What technical skills are you looking for in a trainer? (e.g., Java, Python, Angular)",
            "attribute": "Trainer Technical Skills",
            "type": "categorical_list",
        },
        {
            "question": "Which project domain is most relevant? (e.g., Web Development, Security, AI/ML)",
            "attribute": "Project Mapping",
            "type": "categorical",
        },
        {
            "question": "Which business domain is most relevant? (e.g., Finance, Healthcare, Technology)",
            "attribute": "Business Domain Expertise",
            "type": "categorical",
        },
        {
            "question": "What training style do you prefer? (e.g., Hands-on, Lecture-based, Hybrid)",
            "attribute": "Training Styles",
            "type": "categorical",
        },
        {
            "question": "What soft skills are important to you in a trainer? (e.g., Communication, Leadership)",
            "attribute": "Soft Skills",
            "type": "categorical_list",
        },
        {
            "question": "Do you have a preference for a learning management system (e.g., Moodle, Blackboard)?",
            "attribute": "Learning Management Skills",
            "type": "categorical",
        },
        {
            "question": "When is the training session expected? (e.g., Morning, Afternoon, Weekends)",
            "attribute": "Availability and Flexibility",
            "type": "categorical_list",
        }
    ]
def dynamic_questionnaire_with_min_questions(trainers):
    filtered_trainers = trainers.copy()

    # Questions with weightage
    questions = [
        {
            "question": "How many years of experience do you prefer in a trainer?",
            "attribute": "Trainer Experience",
            "type": "numerical",
        },
        {
            "question": "Do you prefer the training to be onsite, remote, or hybrid?",
            "attribute": "Trainer Location",
            "type": "categorical",
        },
        {
            "question": "What technical skills are you looking for in a trainer? (e.g., Java, Python, Angular)",
            "attribute": "Trainer Technical Skills",
            "type": "categorical_list",
        },
        {
            "question": "Which project domain is most relevant? (e.g., Web Development, Security, AI/ML)",
            "attribute": "Project Mapping",
            "type": "categorical",
        },
        {
            "question": "Which business domain is most relevant? (e.g., Finance, Healthcare, Technology)",
            "attribute": "Business Domain Expertise",
            "type": "categorical",
        },
        {
            "question": "What training style do you prefer? (e.g., Hands-on, Lecture-based, Hybrid)",
            "attribute": "Training Styles",
            "type": "categorical",
        },
        {
            "question": "What soft skills are important to you in a trainer? (e.g., Communication, Leadership)",
            "attribute": "Soft Skills",
            "type": "categorical_list",
        },
        {
            "question": "Do you have a preference for a learning management system (e.g., Moodle, Blackboard)?",
            "attribute": "Learning Management Skills",
            "type": "categorical",
        },
        {
            "question": "What languages should the trainer be proficient in?",
            "attribute": "Language Proficiency",
            "type": "categorical_list",
        },
        {
            "question": "When is the training session expected? (e.g., Morning, Afternoon, Weekends)",
            "attribute": "Availability and Flexibility",
            "type": "categorical_list",
        }
    ]

    # Fixed first question: Language Proficiency
    print("What languages should the trainer be proficient in?")
    language_choice = input().strip()

    filtered_trainers = [
        trainer for trainer in filtered_trainers
        if language_choice in trainer["Language Proficiency"]
    ]

    print(f"{len(filtered_trainers)} trainers remain after filtering by language.\n")

    # Remove the Language Proficiency question from the list
    questions = [
        q for q in questions if q["attribute"] != "Language Proficiency"
    ]

    def simulate_question(attribute, attribute_type):
        """Simulate the impact of asking a question."""
        response_counts = defaultdict(int)
        response_trainers = defaultdict(list)

        for trainer in filtered_trainers:
            if attribute_type == "numerical":
                response_counts[trainer[attribute]] += 1
                response_trainers[trainer[attribute]].append(trainer)
            elif attribute_type == "categorical":
                response_counts[trainer[attribute]] += 1
                response_trainers[trainer[attribute]].append(trainer)
            elif attribute_type == "categorical_list":
                for value in trainer[attribute]:
                    response_counts[value] += 1
                    response_trainers[value].append(trainer)

        # Determine the worst-case scenario
        worst_case = max(len(response_trainers[response]) for response in response_counts)
        return worst_case

    questions_asked = 1  # Count of questions asked (starts at 1 for the language question)
    while len(filtered_trainers) > 1 and (questions_asked < 5 and questions):
        # Simulate each question and choose the most impactful one
        question_impacts = []
        for q in questions:
            worst_case = simulate_question(q["attribute"], q["type"])
            question_impacts.append((q, worst_case))

        # Select the question that minimizes the worst-case scenario
        best_question = min(question_impacts, key=lambda x: x[1])[0]
        print(best_question["question"])
        answer = input().strip()

        # Filter trainers based on the answer
        if best_question["type"] == "numerical":
            filtered_trainers = [
                trainer for trainer in filtered_trainers
                if trainer[best_question["attribute"]] == int(answer)
            ]
        elif best_question["type"] == "categorical":
            filtered_trainers = [
                trainer for trainer in filtered_trainers
                if trainer[best_question["attribute"]] == answer
            ]
        elif best_question["type"] == "categorical_list":
            filtered_trainers = [
                trainer for trainer in filtered_trainers
                if answer in trainer[best_question["attribute"]]
            ]

        print(f"{len(filtered_trainers)} trainers remain.\n")
        questions.remove(best_question)
        questions_asked += 1

    if filtered_trainers:
        print("\nSelected Trainer:")
        for key, value in filtered_trainers[0].items():
            print(f"{key}: {value}")
    else:
        print("No suitable trainer found.")

dynamic_questionnaire_with_min_questions(trainers)