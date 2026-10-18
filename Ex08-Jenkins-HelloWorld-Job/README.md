# Exercise 8 – Creating a "Hello World" CI/CD Jenkins Job

## Aim
Create a Jenkins Freestyle job that pulls a `hello-world.sh` script from GitHub and executes it.

## Files
| File | Purpose |
|---|---|
| `hello-world.sh` | Prints `Hello, Jenkins!` |

## Steps

### 1. Push the script to GitHub
The script is part of this repository. It was created and pushed with:
```bash
chmod +x hello-world.sh
git add .
git commit -m "Add hello-world.sh"
git push -u origin main
```
GitHub asks for username and a **Personal Access Token** (not the account password) when pushing over HTTPS.

### 2. Create the Jenkins job
1. Jenkins → **New Item** → name `HelloWorld` → **Freestyle project** → OK
2. Description: `Hello World! Jenkins job.`
3. **Source Code Management** → Git → Repository URL: `https://github.com/<your-username>/DevOps-Lab.git` → Branch `*/main`
4. **Build Steps** → Add build step → **Execute shell**:
   ```bash
   sh Ex08-Jenkins-HelloWorld-Job/hello-world.sh
   ```
5. **Save** → **Build Now**
6. Build History → `#1` → **Console Output**

Expected console output:
```
+ sh Ex08-Jenkins-HelloWorld-Job/hello-world.sh
Hello, Jenkins!
Finished: SUCCESS
```

## Output
**Script on GitHub**
![github](screenshots/01-script-on-github.png)

**Job configuration (Git + Execute shell)**
![config](screenshots/02-job-config.png)

**Console output**
![console](screenshots/03-console-output.png)

## Result
A Jenkins Freestyle job fetched the script from GitHub and executed it successfully, printing `Hello, Jenkins!`.
