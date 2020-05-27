#!/bin/sh

export SMH_PATH=$(realpath ../../)
luajit run_tests.lua
