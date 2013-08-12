#!/bin/bash
# Shell script that removes duplicate bills
mongo parliament scripts/dup.js
# If we don't reindex, mongo will give errors
ruby run.rb reindex
