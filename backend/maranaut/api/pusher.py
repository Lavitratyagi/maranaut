from pymongo import MongoClient
import json

# Connect to MongoDB
# Update with your MongoDB URI if needed
client = MongoClient(
    "mongodb+srv://test:test@cluster0.yvlq9mj.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0")
db = client["maranaut"]  # Database name
collection = db["ports"]  # Collection name

# Load JSON data
with open("ports.json") as file:
    data = json.load(file)

# Insert data into MongoDB
collection.insert_many(data)

print("Data inserted successfully!")
