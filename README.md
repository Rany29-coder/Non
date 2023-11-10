# Health and Fitness Tracking App

## Overview
The Health and Fitness Tracking App is a sophisticated tool designed for individuals to track and analyze their health metrics. It allows users to monitor workout routines, nutrition intake, sleep patterns, and overall health metrics in a user-friendly interface.

## Features
- **User Profile Management**: Create and manage personal and health information.
- **Workout Tracking**: Log workout details such as type, duration, and calories burned.
- **Nutritional Data Logging**: Record and analyze daily dietary intake.
- **Sleep Pattern Monitoring**: Track and assess sleep quality and duration.
- **Health Metrics Tracking**: Keep track of vital health statistics like weight, blood pressure, and cholesterol.
- **Advanced Data Queries**: Execute custom SQL queries for in-depth data analysis.
- **Graphical User Interface**: An intuitive Tkinter-based GUI for easy navigation and interaction.

## Technical Specifications
- **Programming Language**: Python.
- **Database**: SQLite, for local data storage and management.
- **Frontend**: Tkinter-based graphical user interface.

## Installation and Setup
1. **Clone the Repository**:

git clone [url]
cd health-fitness-app

2. **Install Dependencies**:
pip install -r requirements.txt

3. **Initialize the Database**:
Execute the `fitness.sql` script to set up the database schema.

4. **Populate Sample Data**:
Run the `data_gen.py` script to generate and insert sample data into the database.

## Running the Application
To start the app, run the `gui.py` script:
python gui.py


## File Structure
- `gui.py`: The main application script with the graphical user interface.
- `data_gen.py`: Script for generating sample data.
- `fitness.sql`: SQL script for setting up the database schema.
- `health_fitness_app_queries.sql`: Collection of SQL queries for data analysis.

## Dependencies
- `Faker`: A Python library for generating fake data, utilized in `data_gen.py`.

## Contribution
Contributions to this project are welcome. Please follow the standard fork-and-pull-request workflow.

## License
The project is licensed under the MIT License - see the LICENSE file for details.

## Support and Contact
For support, feedback, or contributions, please email [ranymagdy@uni.minerva.edu](mailto:ranymagdy@uni.minerva.edu).


