# journo-shaker (THIS REPOSITORY IS NOT FOR PRODUCTION USE YET)
Journalist-specific QubesOS task-manager

1. In an AppVM with internet access, download the journo-shaker repository.

```
cd ~
wget https://github.com/kennethrrosen/journo-shaker/archive/refs/heads/main.zip
```

2. Move repository to dom0

```
qvm-run --pass-io journo 'tar -czvf - /home/user/journo-shaker' | tar -C /home/user/ -xzvf -
```

3. In dom0, open a terminal and paste the copied path of the journo-shaker repository into the cd command to change to that directory.

4. Execute the journo-shaker-install.sh script to install the repository and execute the SaltStack formulas.
