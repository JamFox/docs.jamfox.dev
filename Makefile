all: req test

req:
	pip install -r docs/requirements.txt

test: 
	mkdocs serve