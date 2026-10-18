import docker

PROFILE = "my-apparmor-profile"
IMAGE = "flask-apparmor"

client = docker.from_env()

container = client.containers.run(
    IMAGE,
    ports={"5000/tcp": 5000},
    security_opt=[f"apparmor={PROFILE}"],
    detach=True,
)
print(f"Container started: {container.short_id}")

tests = [
    ("read /etc/passwd", "cat /etc/passwd"),
    ("execute /bin/bash", "/bin/bash -c 'echo shell opened'"),
    ("read app file (allowed)", "cat /app/app.py"),
]

for name, cmd in tests:
    try:
        exit_code, output = container.exec_run(cmd)
        text = output.decode(errors="ignore").strip()
        status = "BLOCKED" if exit_code != 0 else "ALLOWED"
        print(f"Attempt to {name}: Exit Code {exit_code} -> {status}")
        if text:
            print(f"   Output: {text[:120]}")
    except docker.errors.APIError as err:
        print(f"Attempt to {name}: BLOCKED ({err.explanation})")

container.stop()
container.remove()
print("Container stopped")
