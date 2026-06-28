#!/usr/bin/env bash
set -e
iverilog -g2012 -o sim tb/tb_rv_mc.v src/*.v
vvp sim
