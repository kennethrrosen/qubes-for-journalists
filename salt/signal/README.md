### signal messenger

This will create a Signal qube where you can link your Signal account. It will also create a template (tpl-signal) so that you can use multiple instances (and numbers) of Signal simultaenously.

This application is served over the Tor network.

```
sudo qubesctl --targets=tpl-signal,signal state.apply qujourno.signal.create
```
