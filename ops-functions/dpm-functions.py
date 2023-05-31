import json
import shutil
import datetime

def add_agent(username, newhost, pw):
    ts = datetime.datetime.now().strftime("%m%d%Y%H%M")
    shutil.copyfile("./vc-agent-007.conf", f"./vc-agent-007.conf-{ts}")
    with open("./vc-agent-007.conf", "r") as file:
        content = json.load(file)

    agentcount = len(content["drv-manual-host-uri"])
    creds = f"{username}@{pw}"
    pg = f"{newhost}:{creds}:5432/postgres?sslenabled=true&sslmode=require"

    if agentcount == 1:
        content["drv-manual-query-capture"] = "poll"
        content["drv-manual-host-uri"].append(pg)
    elif agentcount >= 2:
        content["drv-manual-host-uri"].append(pg)

    with open("./vc-agent-007.conf", "w") as file:
        json.dump(content, file, indent=4)

def remove_agent(hostname):
    with open("./vc-agent-007.conf", "r") as file:
        content = json.load(file)

    uri = content["drv-manual-host-uri"]
    remove = [u for u in uri if not u.startswith(hostname)]

    content["drv-manual-host-uri"] = remove

    with open("./vc-agent-007.conf", "w") as file:
        json.dump(content, file, indent=4)

def get_agent():
    with open("./vc-agent-007.conf", "r") as file:
        content = json.load(file)

    uri = content["drv-manual-host-uri"]
    count = len(uri)

    if count == 1:
        print("1 configuration in this file")
        print(uri[0])
    elif count > 1:
        print(f"There are {count} configurations in this file")
        for u in uri:
            print(u)

# Example usage:
# add_agent("username", "newhost", "password")
# remove_agent("hostname")
get_agent()
