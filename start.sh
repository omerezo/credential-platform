#!/bin/bash

export ROCKET_PORT="${PORT:-80}"
export ROCKET_ADDRESS="0.0.0.0"
export DATA_FOLDER="${DATA_FOLDER:-/data}"

exec /vaultwarden
