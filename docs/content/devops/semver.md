---
title: "Automated releases & commit styles"
date: "2022-03-30"
---

In the ideal environment the developer only needs to commit changes in the correct format and everything else about the release process is done [automatically and programatically](https://semver.org/), [not romantically](http://sentimentalversioning.org/) and [sentimentally](http://sentimentalversioning.org/).

For the [accadmlib](https://gitlab.cern.ch/acc-adm/accadmlib) and [accadmlibclient](https://gitlab.cern.ch/acc-adm/accadmlibclient) projects the [python-semantic-release](https://python-semantic-release.readthedocs.io/en/latest/) tool was implemented to try and unify commit styles as well as make automate the release procedure of Python packages in tandem with the [acc-py devtools templates](https://gitlab.cern.ch/acc-co/devops/python/acc-py-devtools).

Advantages of using **python-semantic-release** is that it can do the following automatically:

* Parse commits and decide which version to bump to
* Parse commits and generate a Changelog
* Change version variables in multiple locations (typically `setup.py` and `docs/conf.py`)
* Create a tag for the release
* Pushe changelog and source to GitLab project Releases (in the future will also be possible to push dist and wheel to the releases if needed)

Advantages of using **acc-py devtools python CI templates** is that it can do the following automatically:

* Run unittests if they exist
* Try to install it in a docker according to ACC-Py Package Index requirements
* Build Sphinx documentation and upload it to `[https://acc-py.web.cern.ch/gitlab/<group>/<project>/docs/master/](https://acc-py.web.cern.ch/gitlab/acc-adm/accadmlib/docs/master/)`
* Upload dist and wheel to ACC-Py Package Index when a tag is pushed to project repository

## Commit style: SciPy

python-semantic-release provides parsers for 3 commit styles (and an option to write a custom parser), of which it was decided to move forward by using the SciPy style.

Commit messages using SciPy tags in the following template:

```
<tag>(<scope>): <subject>
<body>
```

While `<scope>` is supported here it isn’t actually part of the SciPy style. If it is missing, parentheses around it should be too. The commit should then be of the form:

```
<tag>: <subject>
<body>
```

To communicate a breaking change add “BREAKING CHANGE” into the body at the beginning of a paragraph. Fill this paragraph with information how to migrate from the broken behavior to the new behavior. It will be added to the “Breaking” section of the changelog.

The elements `<tag>`, `<scope>` and `<body>` are **optional**.

If no tag is present, the commit will be added to the changelog section “None” and no version increment will be performed.

Supported Tags:

* **API**: an (incompatible) API change
* **BENCH**: changes to the benchmark suite
* **BLD**: change related to building
* **BUG**: bug fix
* **DEP**: deprecate something, or remove a deprecated object
* **DEV**: development tool or utility
* **DOC**: documentation
* **ENH**: enhancement
* **MAINT**: maintenance commit (refactoring, typos, etc.)
* **REV**: revert an earlier commit
* **STY**: style fix (whitespace, PEP8)
* **TST**: addition or modification of tests
* **REL**: related to releasing

Supported Changelog Sections:

breaking, feature, fix, Other, None
