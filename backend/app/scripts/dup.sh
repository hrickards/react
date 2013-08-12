#!/bin/bash
mongo parliament scripts/dup.js
ruby run.rb reindex
