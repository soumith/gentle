#!/bin/bash

set -e

git submodule init
git submodule update

./install_deps.sh
./install_kaldi.sh
./install_models.sh
cd ext && make
