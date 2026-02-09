---
name: commands
description: How to run commands in python directory in vscode terminal
---
The best way to run python commands in the vscode terminal is to use the command `docker exec -it <container-name> <cmd> <filename>.ext` where `<filename>` is the name of your file. You can also use `python -m <module>` to run a module. If you have multiple versions of python installed, you can specify the version by using `python3` or `python2` instead of just `python`.
