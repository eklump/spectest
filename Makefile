# SHELL:=/bin/bash
PROJECT=spectest
PYTHON_VERSION=3.8.2
VENV=${PROJECT}-${PYTHON_VERSION}
VENV_DIR=$(shell pyenv root)/versions/${VENV}
PYTHON=${VENV_DIR}/bin/python
JUPYTER_ENV_NAME=${VENV}
MELTANO_TEST_DIR=meltano-test

.PHONY: run clean build venv ipykernel update jupyter clean-build clean-venv

# Colors for echos 
ccend=$(shell tput sgr0)
ccbold=$(shell tput bold)
ccgreen=$(shell tput setaf 2)
ccso=$(shell tput smso)

clean-venv:
	@echo "$(ccso)--> Removing virtual environment $(ccend)"
	-pyenv virtualenv-delete --force ${VENV}
	-rm .python-version
	-unset PYENV_VERSION
	-unset "PYENV_VERSION"


clean-build:
	@echo "$(ccso)--> Removing project test directories $(ccend)"
	-rm -rf ${MELTANO_TEST_DIR}
	-rm -rf postgres-data

clean:
	$(MAKE) clean-build
	$(MAKE) clean-venv


build-venv: ##@main >> build the virtual environment with an ipykernel for jupy${ter and install requirements
	@echo ""
	@echo "$(ccso)--> Build $(ccend)"
	$(MAKE) install
	$(MAKE) ipykernel

venv: $(VENV_DIR) ## >> setup the virtual environment

$(VENV_DIR):
	@echo "$(ccso)--> Install and setup pyenv and virtualenv $(ccend)"
	python3 -m pip install --upgrade pip
	pyenv virtualenv ${PYTHON_VERSION} ${VENV}
	echo ${VENV} > .python-version

install-jupyter: venv requirements.txt ##@main >> update requirements.txt inside the virtual environment
	@echo "$(ccso)--> Updating packages $(ccend)"
	$(PYTHON) -m pip install -r requirements-dev.txt

ipykernel: install-jupyter ##@main >> install a Jupyter iPython kernel using our virtual environment
	@echo ""
	@echo "$(ccso)--> Install ipykernel to be used by jupyter notebooks $(ccend)"
	$(PYTHON) -m pip install ipykernel jupyter jupyter_contrib_nbextensions
	$(PYTHON) -m ipykernel install \
					--user \
					--name=$(VENV) \
					--display-name=$(JUPYTER_ENV_NAME)
	$(PYTHON) -m jupyter nbextension enable --py widgetsnbextension --sys-prefix

