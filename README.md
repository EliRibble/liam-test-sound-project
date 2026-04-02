# Liam Test Sound Project

This is just a project to show how to get some Python dependencies installed on NixOS

## Hacking

To use this clone the repository. Then use `nix develop`:

```
$ git clone https://github.com/EliRibble/liam-test-sound-project.git
$ cd liam-test-sound-project
$ nix develop
```

After that you'll have a shell which contains a working copy of `vosk-transcriber` and a Python environment that can import `sounddevice`:

```
$ python src/__init__.py
```
