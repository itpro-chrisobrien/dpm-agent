import json
import os
import glob


def add_agent(dbalias, pghost, pgpw, pgip):
    incre = len(glob.glob("vc-agent-007-backup*"))
    incre += 1
    shutil.copyfile("./vc-agent-007.conf", f"./vc-agent-007-backup-{incre}.conf")

    with open("./vc-agent-007.conf", "r") as file:
        c = json.load(file)

    agentcount = len(c["drv-manual-host-uri"])

    pg = f"{dbalias}=postgres://vividcortex%40{pghost}:{pgpw}@{pgip}:5432/postgres?sslenabled=true&sslmode=require"

    if agentcount == 0:
        outconfig = {
            "drv-manual-query-capture": "poll",
            "drv-manual-host-uri": pg
        }
        with open("./vc-agent-007.conf", "w") as file:
            json.dump(outconfig, file, indent=4)
    elif agentcount >= 1:
        c["drv-manual-host-uri"].append(pg)
        outconfig = {
            "drv-manual-query-capture": "poll",
            "drv-manual-host-uri": c["drv-manual-host-uri"]
        }
        with open("./vc-agent-007.conf", "w") as file:
            json.dump(outconfig, file, indent=4)


def remove_agent(hostname):
    with open("./vc-agent-007.conf", "r") as file:
        c = json.load(file)

    uri = c["drv-manual-host-uri"]
    remove = [u for u in uri if not u.startswith(hostname)]
    c["drv-manual-host-uri"] = remove

    outconfig = {
        "drv-manual-query-capture": "poll",
        "drv-manual-host-uri": c["drv-manual-host-uri"]
    }

    with open("./vc-agent-007.conf", "w") as file:
        json.dump(outconfig, file, indent=4)


def get_agent():
    with open("./vc-agent-007.conf", "r") as file:
        c = json.load(file)

    uri = c["drv-manual-host-uri"]
    count = len(uri)

    if count == 1:
        print(f"{count} configuration in this file")
    elif count > 1:
        print(f"There are {count} configurations in this file")
    elif count == 0:
        print("This host is not yet configured")

    for u in uri:
        print(u)


def restore_agent(old):
    os.remove("./vc-agent-007.conf")
    items = sorted(glob.glob("vc-agent-007-backup*"), key=os.path.getctime, reverse=True)
    print(items)
    old = input("Choose the backup number 1, 2, 3, etc: ")
    os.rename(f"vc-agent-007-backup-{old}.conf", "vc-agent-007.conf")


# Usage examples
add_agent("dbalias", "pghost", "pgpw", "pgip")
remove_agent("hostname")
get_agent()
restore_agent("old")
