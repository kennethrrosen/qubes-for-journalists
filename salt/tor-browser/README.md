### tor-browser

Everyone's heard of the Tor network. It helps maintain a semblence of anonymity at the cost of being rather slow. It is also somewhat amnesiatic. Thanks to this configured browser, though, you can still save bookmarks and logins (to websites like X or Facebook) and still browse elsewhere anonymously.

(Note: A split browser varient is also installed in `writing` so that you may still reference links and source material in a web-connected browser. You may also use `anon-whonix` as an alternative)

```
sudo qubesctl --targets=fedora-39,whonix-workstation-17 state.apply qujourno.tor-browser.create
```

# Keyboard shortcuts

The bold ones override standard browser shortcuts:

Combination      | Function
-----------------|--------------------------------------------------------------
**Alt-b**        | Open bookmarks
**Ctrl-d**       | Bookmark current page
Ctrl-Shift-Enter | Log into current page
Ctrl-Shift-s     | Move downloads to a qube of your choice
**Ctrl-Shift-u** | `New Identity` on steroids: Quit and restart the browser in a new disposable, with fresh Tor circuits.

Credit: [Rustybird](https://github.com/rustybird/qubes-app-split-browser)
