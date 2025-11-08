import threading
from tkinter import Tk, filedialog
import matplotlib
matplotlib.use('Agg')  # Use headless backend
import matplotlib.pyplot as plt
from fpdf import FPDF
import os

class TraineeReport:
    def __init__(self, trainee_name, trainee_id, trainer_name, training_dates, additional_comments, batch_exit_question1, batch_exit_question2, exit_response_1, exit_response_2, data):
        self.trainee_name = trainee_name
        self.trainee_id = trainee_id
        self.trainer_name = trainer_name
        self.training_dates = training_dates
        self.additional_comments = additional_comments
        self.batch_exit_question1 = batch_exit_question1
        self.batch_exit_question2 = batch_exit_question2
        self.exit_response_1 = exit_response_1
        self.exit_response_2 = exit_response_2
        self.data = data
        self.pdf = FPDF()
    
    def create_charts(self):
        charts = []
        try: 
            plt.figure(figsize=(6, 4))
            attendance = [self.data['attendance']['attended'], self.data['attendance']['total']]
            bars = plt.bar(['Sessions Attended', 'Total Sessions'], attendance, color=['skyblue', 'lightgray'])
            plt.bar_label(bars, fmt='%.0f', padding=5)
            plt.title('Attendance Overview', fontsize=14, fontweight='bold')
            plt.grid(axis='y', linestyle='--', alpha=0.7)
            plt.ylabel('Number of Sessions')
            plt.savefig('attendance_chart.png')
            charts.append('attendance_chart.png')
            plt.close()


            plt.figure(figsize=(6, 4))
            plt.plot(['Pre-training', 'Post-training'], 
                    [self.data['skill']['pre'], self.data['skill']['post']], 
                    marker='o', color='green', linewidth=2)
            plt.title('Skill Assessment Progress', fontsize=14, fontweight='bold')
            plt.ylim(0, 100)
            plt.grid(axis='y', linestyle='--', alpha=0.7)
            plt.ylabel('Score')
            plt.savefig('skill_chart.png')
            charts.append('skill_chart.png')
            plt.close()


            plt.figure(figsize=(6, 4))
            labels = ['Engaged', 'Not Engaged']
            sizes = [self.data['engagement']['engaged'], 100 - self.data['engagement']['engaged']]
            explode = (0.1, 0)  
            colors = ['gold', 'lightcoral']
            wedges, texts, autotexts = plt.pie(
                sizes, labels=labels, colors=colors, autopct='%1.1f%%',
                startangle=140, explode=explode, textprops=dict(color="black"))
            plt.title('Engagement Overview', fontsize=14, fontweight='bold')
            plt.savefig('engagement_chart.png')
            charts.append('engagement_chart.png')
            plt.close()

            from math import pi
            attributes = ['Verbal', 'Written', 'Team Contribution', 'Conflict\nManagement', 'Analytical', 'Creativity']
            values = [
                self.data['communication']['verbal'], 
                self.data['communication']['written'],
                self.data['teamwork']['team_contribution'], 
                self.data['teamwork']['conflict_management'],
                self.data['problem_solving']['analytical'], 
                self.data['problem_solving']['creativity']
            ]
            values += values[:1]  
            angles = [n / float(len(attributes)) * 2 * pi for n in range(len(attributes))]
            angles += angles[:1]

            plt.figure(figsize=(6, 6))
            ax = plt.subplot(111, polar=True)
            ax.fill(angles, values, color='skyblue', alpha=0.4)
            ax.plot(angles, values, color='blue', linewidth=2)
            ax.set_xticks(angles[:-1])
            ax.set_xticklabels(attributes)
            ax.set_yticks([2, 4, 6, 8, 10])
            ax.set_title('Skill Attributes Radar', fontsize=14, fontweight='bold', y=1.1)
            plt.savefig('radar_chart.png')
            charts.append('radar_chart.png')
            plt.close()

            return charts
        except Exception as e:
            print(f"Error creating charts: {e}")
            return []
        finally:
            plt.close('all')
    
    def generate_pdf(self, charts):
        print("************** In Generate PDF ************ ")
        try: 
            self.pdf.add_page()
            self.pdf.set_font("Arial", style="B", size=16)
            self.pdf.cell(200, 10, txt="Trainee Performance Report", ln=True, align='C')
            self.pdf.ln(10)

            self.pdf.set_font("Arial", size=12)
            self.pdf.cell(200, 10, txt=f"Trainee Name: {self.trainee_name}", ln=True)
            self.pdf.cell(200, 10, txt=f"Trainee ID: {self.trainee_id}", ln=True)
            self.pdf.cell(200, 10, txt=f"Trainer Name: {self.trainer_name}", ln=True)
            self.pdf.cell(200, 10, txt=f"Training Dates: {self.training_dates}", ln=True)
            self.pdf.ln(10)

            self.pdf.set_font("Arial", style="B", size=14)
            self.pdf.cell(200, 10, txt="Trainer Remarks", ln=True, align='C')
            self.pdf.ln(10)

            self.pdf.set_font("Arial", size=12)
            for key, value in self.data.items():
                if 'remarks' in value:
                    self.pdf.set_font("Arial", style="B", size=12)
                    self.pdf.cell(200, 8, txt=f"{key.capitalize()}:", ln=True)
                    self.pdf.set_font("Arial", size=12)
                    self.pdf.multi_cell(0, 8, txt=value['remarks'])
                    self.pdf.ln(5)

            self.pdf.add_page()
            positions = [(10, 20), (110, 20), (10, 120), (110, 120)]
            count = 0

            for chart in charts:
                x, y = positions[count % 4]
                self.pdf.image(chart, x=x, y=y, w=100)
                count += 1
                if count % 4 == 0 and count < len(charts):
                    self.pdf.add_page()

            self.pdf.add_page()
            self.pdf.set_font("Arial", style="B", size=14)
            self.pdf.cell(200, 10, txt="Exit Questions", ln=True, align='C')
            self.pdf.ln(10)
            self.pdf.set_font("Arial", size=12)
            self.pdf.multi_cell(0, 10, txt=(
            self.batch_exit_question1
            + "\nResponse: " + self.exit_response_1
            + "\n\n\n" + self.batch_exit_question2
            + "\nResponse: " + self.exit_response_2
            ))

            self.pdf.add_page()
            self.pdf.set_font("Arial", style="B", size=14)
            self.pdf.cell(200, 10, txt="Additional Comments", ln=True, align='C')
            self.pdf.ln(10)
            self.pdf.set_font("Arial", size=12)
            self.pdf.multi_cell(0, 10, txt=(
            self.additional_comments
            ))
            # print("************** Before Output file ************ ")
            #print(self.trainee_name)
            output_file = f"{self.trainee_name}_Report.pdf"
            # print("************** After Output file ************ ")
            # print(output_file)
             # Prompt User for Save Location
            # print("Prompting user for file save location...")
            # output_file = None

            # def run_dialog():
            #     nonlocal output_file
            #     output_file = prompt_file_save()

            # dialog_thread = threading.Thread(target=run_dialog)
            # dialog_thread.start()
            # dialog_thread.join()

            # if not output_file:
            #     print("User canceled the save operation.")
            #     return
            
            self.pdf.output(output_file)
            print(f"Report generated: {output_file}")

            for chart in charts:
                os.remove(chart)
                print(f"Removed chart: {chart}")
        except Exception as e:
            print(f"Error generating PDF: {e}")
            raise
        finally:
            self.pdf.output("output.pdf")

def prompt_file_save():
    """Run Tkinter file dialog on the main thread."""
    root = Tk()
    root.withdraw()  # Hide the Tkinter root window
    file_path = filedialog.asksaveasfilename(
        defaultextension=".pdf",
        filetypes=[("PDF Files", "*.pdf")],
        title="Save Report As"
    )
    root.destroy()
    return file_path


