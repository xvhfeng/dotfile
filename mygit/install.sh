#!/bin/bash

echo "export MYGIT_HOME=$(pwd)" >> ~/.path.bash
echo "export PATH=$(pwd):\$PATH" >> ~/.path.bash
source ~/.profile
