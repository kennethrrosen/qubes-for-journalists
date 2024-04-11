## Dangerzone for journalists

This script will create a Dangerzone disposable. Dangerzone enables you to take potentially dangerous PDFs, office documents, or images and convert them to a safe PDF.

```
sudo qubesctl state.apply --targets=tpl-dangerzone qujourno.dangerzone.create
```

An overview of the qubes you'll create:

| qube         |   type   | purpose |
|--------------|----------|---------|
| dz-dvm       | app qube | offline disposable template for performing conversions |


Learn more [here](https://github.com/freedomofpress/dangerzone/blob/main/INSTALL.md)

