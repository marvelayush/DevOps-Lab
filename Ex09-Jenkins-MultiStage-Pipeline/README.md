# Exercise 9 – Jenkins Multi-Stage Pipeline for a Python Application

## Aim
Create a Jenkins Pipeline that builds, tests, deploys, runs and re-tests a Python Flask application from GitHub using a `Jenkinsfile`.

## Files
| File | Purpose |
|---|---|
| `app.py` | Flask app returning `Hello, Jenkins Multi-Stage Pipeline!` |
| `requirements.txt` | Dependencies |
| `test_app.py` | Unit test for the `/` route |
| `Jenkinsfile` | Stages: Build → Test → Deploy → Run Application → Test Application |

## Pipeline stages
| Stage | What it does |
|---|---|
| Build | Creates a virtualenv and installs `requirements.txt` |
| Test | Runs `unittest` |
| Deploy | Copies the app to `python-app-deploy/` |
| Run Application | Starts the app in the background, saves its PID |
| Test Application | Runs the test from the deploy directory |

## Steps
1. Make sure Python is available inside Jenkins (one time):
   ```bash
   docker exec -u root jenkins bash -c "apt-get update && apt-get install -y python3 python3-venv python3-pip"
   ```
2. Push this folder to GitHub (already part of this repo).
3. Jenkins → **New Item** → `Python-MultiStage-Pipeline` → **Pipeline** → OK
4. **Pipeline** section → Definition: *Pipeline script from SCM* → SCM: Git
   - Repository URL: `https://github.com/<your-username>/DevOps-Lab.git`
   - Branch: `*/main`
   - Script Path: `Ex09-Jenkins-MultiStage-Pipeline/Jenkinsfile`
5. **Save** → **Build Now** → open the build → **Console Output** / **Stage View**

Run locally (optional):
```bash
pip install -r requirements.txt
python3 -m unittest discover -s . -v
```

## Output
**Pipeline configuration (SCM + Script Path)**
![config](screenshots/01-pipeline-config.png)

**Stage View – all stages green**
![stages](screenshots/02-stage-view.png)

**Console output – tests passed, Finished: SUCCESS**
![console](screenshots/03-console-output.png)

## Result
The multi-stage Jenkins pipeline pulled the code from GitHub, installed dependencies, passed the unit tests, deployed and ran the application, and finished with `SUCCESS`.
