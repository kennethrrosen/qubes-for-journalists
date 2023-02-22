"""The entry point for the console script."""

from .move_user_js import get_username, move_user_js

def main():
    """Move the user.js and user-overrides.js files to the appropriate location in the .mozilla folder of Firefox."""
    username = get_username()
    user_js_path = 'user.js'
    user_overrides_js_path = 'user-overrides.js'
    move_user_js(username, user_js_path, user_overrides_js_path)

if __name__ == '__main__':
    main()
