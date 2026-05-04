import requests
import json

url = "http://localhost:5000/api/scan"
payload = {
    "lat": 23.2599,
    "lon": 77.4126,
    "sector": "test"
}
headers = {
    "Content-Type": "application/json"
}

response = requests.post(url, data=json.dumps(payload), headers=headers)
print(response.status_code)
print(response.json())
