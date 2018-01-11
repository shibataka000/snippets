import requests
import datetime

PERSONAL_ACCESS_TOKEN = ""

url = "https://api.github.com/rate_limit"
token = "token {}".format(PERSONAL_ACCESS_TOKEN)
r = requests.get(url, headers={'Authorization': token})
body = r.json()
limit = body["resources"]["core"]["limit"]
remaining = body["resources"]["core"]["remaining"]
reset_unixtime = body["resources"]["core"]["reset"]
reset = datetime.datetime.fromtimestamp(reset_unixtime)

print("{} requests remain until {}".format(remaining, reset))
