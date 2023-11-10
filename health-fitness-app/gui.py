import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
import sqlite3
import re

# Function to parse the SQL file and return a mapping of query descriptions to SQL commands
def parse_sql_file(file_path):
    with open(file_path, 'r') as file:
        content = file.read()
    
    pattern = re.compile(r'--\s*(.*?)\s*\n(.*?);', re.DOTALL)
    matches = pattern.findall(content)
    
    query_mapping = {desc.strip(): sql.strip() for desc, sql in matches}
    return query_mapping

# Function to execute the selected query against the SQLite database
def execute_query(sql, parameters=None):
    conn = sqlite3.connect('health_fitness_app.db')
    cursor = conn.cursor()
    if parameters:
        cursor.execute(sql, parameters)
    else:
        cursor.execute(sql)
    results = cursor.fetchall()
    columns = [description[0] for description in cursor.description]
    conn.close()
    return results, columns

# Function to display the results in the Text widget
def display_results(results):
    long_result_text.delete('1.0', tk.END)
    if not results:
        long_result_text.insert(tk.END, "No results found.\n")
    else:
        for result in results:
            result_line = ' | '.join(str(item) if item is not None else 'N/A' for item in result)
            long_result_text.insert(tk.END, result_line + '\n\n')

# Function to run the selected query when the "Run" button is clicked
def run_query():
    selected_description = query_dropdown.get()
    sql = query_mapping.get(selected_description)
    if not sql:
        messagebox.showwarning("Warning", "Please select a valid query")
        return

    expects_user_id = "?" in sql
    try:
        if expects_user_id:
            user_id_input = user_id_entry.get()
            if not user_id_input:
                messagebox.showwarning("Warning", "Please enter a User ID")
                return
            user_id_int = int(user_id_input)
            if sql.count('?') == 2:
                parameters = (user_id_int, user_id_int)
            else:
                parameters = (user_id_int,)
            results, _ = execute_query(sql, parameters)
        else:
            results, _ = execute_query(sql)
        display_results(results)
    except ValueError:
        messagebox.showerror("Error", "User ID should be an integer")
    except sqlite3.Error as e:
        messagebox.showerror("Error", f"Database error: {e}")

# Function to clear the results from the Text widget
def clear_results():
    long_result_text.delete('1.0', tk.END)

# Function to Execute Custom Query
def execute_custom_query():
    sql = custom_query_text.get("1.0", tk.END).strip()
    if not sql:
        messagebox.showwarning("Warning", "Please enter an SQL query")
        return
    try:
        results, columns = execute_query(sql)
        display_results(results)
    except sqlite3.Error as e:
        messagebox.showerror("Error", f"Database error: {e}")

# Initialize the main window
root = tk.Tk()
root.title("Health & Fitness App")

# Parse the SQL file to get the query mapping
query_mapping = parse_sql_file('health_fitness_app_queries.sql')

# Dropdown Menu for Predefined Queries
query_options = list(query_mapping.keys())
query_dropdown = ttk.Combobox(root, values=query_options, width=60)
query_dropdown.grid(row=0, column=1, padx=10, pady=10)

# User ID Entry for Predefined Queries
user_id_label = tk.Label(root, text="User ID:")
user_id_label.grid(row=1, column=0, padx=10, pady=10)
user_id_entry = tk.Entry(root)
user_id_entry.grid(row=1, column=1, padx=10, pady=10)

# Run Button for Predefined Queries
run_button = tk.Button(root, text="Run Query", command=run_query)
run_button.grid(row=2, column=1, padx=10, pady=10, sticky="ew")

# Clear Button
clear_button = tk.Button(root, text="Clear Results", command=clear_results)
clear_button.grid(row=2, column=0, padx=10, pady=10, sticky="ew")

# Results Area - Text Widget
long_result_text = scrolledtext.ScrolledText(root, height=15, wrap=tk.WORD)
long_result_scroll = ttk.Scrollbar(root, command=long_result_text.yview)
long_result_text.configure(yscrollcommand=long_result_scroll.set)
long_result_text.grid(row=3, column=0, columnspan=2, pady=10, sticky='nsew')
long_result_scroll.grid(row=3, column=2, pady=10, sticky='ns')

# Custom Query Section
custom_query_label = tk.Label(root, text="Custom SQL Query:")
custom_query_label.grid(row=4, column=0, padx=10, pady=10, sticky="w")

custom_query_text = scrolledtext.ScrolledText(root, height=5, wrap=tk.WORD)
custom_query_text.grid(row=5, column=0, columnspan=2, padx=10, pady=10, sticky='nsew')

execute_custom_query_button = tk.Button(root, text="Execute Custom Query", command=execute_custom_query)
execute_custom_query_button.grid(row=6, column=1, padx=10, pady=10, sticky="ew")

# Configure the grid layout for resizing
root.grid_columnconfigure(1, weight=1)
root.grid_rowconfigure(3, weight=1)




# Run the application
root.mainloop()
