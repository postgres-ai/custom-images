#!/usr/bin/env bash
set -e

/bin/bash -c "trap : TERM INT; sleep infinity & wait"
