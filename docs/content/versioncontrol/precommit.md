---
title: "Pre-commit"
date: "2022-03-30"
---

Git hook scripts are useful for identifying simple issues before submission to code review. By pointing these issues out before code review, this allows a code reviewer to focus on the architecture of a change while not wasting time with trivial style nitpicks because the style is unified before submission.

## Installation

Before you can run hooks, you need to have the pre-commit package manager installed:

Install pre-commit to your environment:

```bash
pip install pre-commit
```

**In a python project, add the following to your requirements.txt (or requirements-dev.txt):**

```bash
pre-commit
```

**To set up the git hook scripts in your project:**

```bash
pre-commit install
```

*(optional)* **Run against all the files**

It's usually a good idea to run the hooks against all of the files when adding new hooks so you can see what will change, what the hooks will do etc:

```bash
pre-commit run --all-files
```

## Configuration

- create a file named `.pre-commit-config.yaml`
- you can generate a very basic configuration using the command `pre-commit sample-config`

For accadmlib we used a very basic config that just formats the code using black: 

```yml
repos:
- repo: local 
  hooks:
  - id: black
    name: black
    entry: black --verbose 
    language: system
    types: [python] 
```

But notice how we didn't use a repository for the black hook, instead we used a local entrypoint that uses the black cli command.