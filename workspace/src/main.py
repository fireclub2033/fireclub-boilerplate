import os
from dotenv import load_dotenv

load_dotenv()

def show_config():
    print("👋 Hello, World!")
    print("🔧 Loaded config:")
    for key in ["DB_HOST", "DB_PORT", "DB_NAME", "DB_USER"]:
        print(f"  {key} = {os.getenv(key)}")

if __name__ == "__main__":
    show_config()
