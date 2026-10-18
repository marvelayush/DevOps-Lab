# Exercise 5 – Docker Security with AppArmor and Python

## Aim
Secure a containerised Flask application with an AppArmor profile that blocks access to sensitive files and shell execution, apply it using the Docker CLI and the Docker SDK for Python, and test the restricted actions.

## Files
| File | Purpose |
|---|---|
| `app.py` | Flask app on port 5000 |
| `Dockerfile` | Builds `flask-apparmor` |
| `my-apparmor-profile` | AppArmor profile (denies `/etc/passwd`, shells, `sys_admin`, mount) |
| `apply_apparmor.py` | Builds and runs the container with the profile using the Docker SDK and verifies it |
| `test_restricted_actions.py` | Tries restricted actions inside the confined container |

> **Note:** AppArmor needs a Linux host with AppArmor enabled (e.g. Ubuntu). Check with `sudo aa-status`. Most WSL2 kernels do not have AppArmor enabled; use an Ubuntu VM or lab machine if `aa-status` fails.

## Steps
```bash
sudo apt-get update && sudo apt-get install -y apparmor-utils
sudo aa-status                     # confirm AppArmor is enabled

# Load the profile
sudo cp my-apparmor-profile /etc/apparmor.d/my-apparmor-profile
sudo apparmor_parser -r -W /etc/apparmor.d/my-apparmor-profile
sudo aa-status | grep my-apparmor-profile

# Build and run with the profile (CLI)
docker build -t flask-apparmor .
docker run -d --name secure-flask --security-opt apparmor=my-apparmor-profile -p 5000:5000 flask-apparmor
curl http://localhost:5000
docker inspect secure-flask --format '{{ .AppArmorProfile }}'

# Restricted actions are denied
docker exec secure-flask cat /etc/passwd     # Permission denied
docker exec -it secure-flask /bin/bash       # Permission denied
docker rm -f secure-flask

# Same thing using the Docker SDK for Python
pip install docker
python3 apply_apparmor.py
python3 test_restricted_actions.py
```

## Output
**Profile loaded (`aa-status`)**
![aa-status](screenshots/01-aa-status.png)

**Container running with the profile + app response**
![run](screenshots/02-run-with-profile.png)

**Restricted actions denied**
![denied](screenshots/03-denied-actions.png)

**`apply_apparmor.py` output**
![sdk apply](screenshots/04-apply-apparmor-py.png)

**`test_restricted_actions.py` output**
![sdk test](screenshots/05-test-restricted-py.png)

## Questions
1. **Purpose of AppArmor with Docker?** It enforces mandatory access-control policies that confine what a container can access.
2. **How do profiles secure a container?** They restrict files, binaries, network access and capabilities the process can use.
3. **Why restrict `/etc` and `/var`?** They hold system configuration and user data; blocking them limits damage if the app is compromised.
4. **What else can be restricted?** Network families, port binding, mount, capabilities like `sys_admin`, writes to `/proc` and `/sys`.
5. **How to verify a profile is applied?** `docker inspect <container>` → `AppArmorProfile` / `HostConfig.SecurityOpt`.

## Result
The Flask container ran under a custom AppArmor profile; reading `/etc/passwd` and launching a shell were blocked while the app kept serving requests.
