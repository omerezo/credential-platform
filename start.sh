#!/bin/sh
export ROCKET_PORT="${PORT:-80}"
export ROCKET_ADDRESS="0.0.0.0"
exec /vaultwarden
