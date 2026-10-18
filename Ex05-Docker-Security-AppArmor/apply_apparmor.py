import docker

PROFILE = "my-apparmor-profile"
IMAGE = "flask-apparmor"

client = docker.from_env()

print("Building image from Dockerfile...")
client.images.build(path=".", tag=IMAGE)

print("Running container with AppArmor profile...")
container = client.containers.run(
    IMAGE,
    ports={"5000/tcp": 5000},
    security_opt=[f"apparmor={PROFILE}"],
    detach=True,
)
print(f"Container started: {container.short_id}")

print("Inspecting container to verify AppArmor profile...")
info = client.api.inspect_container(container.id)
print(f"SecurityOpt: {info['HostConfig']['SecurityOpt']}")
print(f"AppArmorProfile: {info.get('AppArmorProfile')}")

print("Stopping the container...")
container.stop()
container.remove()
print("Container stopped and removed")
