# Demoing nix features

This repo aims to demo some features of nix that simplify development workflows
that would be difficult with other package managers. Namely, it shows off a
polyglot build system, a development environment that tracks the build layout
closely, and the ability to track the above all in a single git repo.

The repo is split into 3 steps, each on a separate branch:
- 1-basic: Shows off a basic build with only go and python
- 2-more-packages: Adds ruby and rust to the project
- 3-language-packages: Adds packages to python environment
