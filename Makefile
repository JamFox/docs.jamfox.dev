all: req serve

req:
	pip install -r docs/requirements.txt

serve: 
	mkdocs serve