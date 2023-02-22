#Make sure to replace the directories as needed if downloaded elsewhere on desktop
#Run the script through terminal with `python install_journoSEC_config.py'

import os
import shutil
import getpass

def get_username():
    """Return the current user's username."""
    return getpass.getuser()

def get_firefox_profile_path(username):
    """Return the path to the Firefox profile folder for the given username."""
    return f"/home/{username}/.mozilla/firefox/*.default"

def move_user_js(username, user_js_path, user_overrides_js_path):
    """Move the user.js and user-overrides.js files to the appropriate location in the .mozilla folder of Firefox."""
    firefox_profile_path = get_firefox_profile_path(username)
    firefox_profile_path = firefox_profile_path.replace("*", "")
    
    # Copy the user.js file to the Firefox profile folder
    if os.path.exists(user_js_path):
        shutil.copy(user_js_path, os.path.join(firefox_profile_path, "user.js"))

    # Copy the user-overrides.js file to the Firefox profile folder
    if os.path.exists(user_overrides_js_path):
        shutil.copy(user_overrides_js_path, os.path.join(firefox_profile_path, "user-overrides.js"))

username = get_username()

# Replace the values below with the appropriate paths for your system
user_js_path = f"/home/{username}/Downloads/user.js"
user_overrides_js_path = f"/home/{username}/Downloads/user-overrides.js"
move_user_js(username, user_js_path, user_overrides_js_path)
