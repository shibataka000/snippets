#!/bin/bash
createuser -U postgres testuser
createdb -U postgres -O testuser testdb
