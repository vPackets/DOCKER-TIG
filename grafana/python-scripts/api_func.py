import requests
import api_config
import getpass
import sys
import time
import os
#import urllib3

requests.packages.urllib3.disable_warnings()
#urllib3.disable_warning(urllib3.exceptions.InsecureRequestWarning)

def verify_token_authentication():
    cwd = os.getcwd() 
    if os.path.exists(cwd +"/token.txt"):
        with open(cwd + "/token.txt", mode = 'r') as token_txt:
            token = token_txt.read()
            print("'We will use the token within the file " + cwd + "/token.txt': " + token)
            return token
    else:
        print("*" * 69)
        print("There is no token present on the system, we will generate a new token")
        print("*" * 69 + "\n\n")
        token = get_token_authentication()
        return token


def get_token_authentication(url = api_config.URL):
    print("*"*10,"Authentication with the Grafana API Container: ", url, "*"*10)
    username = "root"
    password = "root"
    url = ("http://" + username + ":" + password + "@" + url + "api/auth/keys")
    headers = {
        'Content-Type': "application/json",
    }
    data = '{"name":"apikeycurl", "role": "Admin"}'

    print("\n" + "Processing GET " + url)
    try:
        response = requests.post(url, headers=headers, data = data, verify = False)
        
        if response.status_code != 200:
            print("Something was wrong during the token creation (Credentials, Host down...)")
            print("The status code is: ", response.status_code)
            sys.exit()
        else:    
            print("The status code is: ", response.status_code)
            print("The response from the grafana API is :", response.json())
            print("The Token ID is: ", response.json()["key"], "\n\n") 
            print("*" * 10, "End of Authentication", "*" * 35)
            print("\n")
            token_file = open("token.txt", mode = 'w', encoding = 'utf-8')
            token_file.write(response.json()["key"])
            token_file.close()
            return response.json()["key"]
    except:
        sys.exit()
        





