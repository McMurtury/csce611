#!/bin/sh

cd "$(dirname "$0")"

./csce611.sh clean_sim
vsim -do sim.do
