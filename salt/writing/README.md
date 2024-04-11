### writing

This salt stack creates two qubes, both standalones: a `writing` qube and a `syncthing` qube. The `writing` qube is entirely offline, inacessible to anyone but you. It connects through an internal QubesOS mechanism called qrexec to `syncthing` through a one-way tunnel that you control. `Syncthing` provides incremental backups of your writing through a one-way tunnel, and makes accessing those files from your phone or other computers easy.

The `writing` qube comes preinstalled with: 
   - libreoffice, a Microsoft Office replacement 
   - Wine (free) and Crossover (paid) for use with Windows software such as Scrivener

```
sudo qubesctl --targets=writing,syncthing state.apply qujourno.writing.create
```

