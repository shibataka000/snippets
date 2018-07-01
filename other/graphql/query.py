import json

import requests


PERSONAL_ACCESS_TOKEN=""
ENDPOINT = "https://api.github.com/graphql"


def query(query_string):
    url = ENDPOINT
    headers = {
        "Authorization": "bearer {}".format(PERSONAL_ACCESS_TOKEN)
    }
    wrapped_query_string = json.dumps({"query": query_string})
    r = requests.post(url, headers=headers, data=wrapped_query_string)
    assert r.status_code == 200
    return r.json()


r = query("query { viewer { login }}")
print(json.dumps(r, indent=4))
