import json
from datetime import datetime
import requests
def lambda_handler(event, context):
    # Get current timestamp
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # Create greeting message
    message = f"Hello! שלום Salam Current timestamp is: {current_time}"

    response = requests.get("https://wtfismyip.com/json")
    
    # Return response
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': message + " " + str(response.content)
        })
    }
