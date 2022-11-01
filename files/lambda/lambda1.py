import json
import re

# Can be tested at the console using an appropriate object e.g.:
# {"body": "{\"email\": \"test@example.com\"}"}

def validate(event, context):
    event_body = json.loads(event['body'])
    email_regex = re.compile('^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
    matches = email_regex.match(event_body['email']) != None

    response = {
        'statusCode': 200,
        'body': json.dumps({ 'result': matches })
    }

    return response
