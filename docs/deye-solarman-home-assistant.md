# Deye Solarman + Home Assistant Integration

This document explains how this homelab integrates a Deye inverter with Home Assistant.

## Overview

- Data collection is done with the `ha-solarman` integration: https://github.com/davidrapan/ha-solarman
- The inverter/logger is reachable at `192.168.40.45`.
- The `deye-dummycloud` service is used only to keep the logger connected and stable on Wi-Fi (to avoid periodic disconnect/reconnect behavior).
- MQTT data path from `deye-dummycloud` is not used in this setup.

## Data Flow Used in This Homelab

1. Home Assistant polls inverter data directly from `192.168.40.45` using `ha-solarman`.
2. `deye-dummycloud` runs at `192.168.50.100:10000` only as a local cloud endpoint for the logger.
3. The inverter is pointed to that local endpoint so it stops trying to use the external Solarman cloud.

## Configure The Inverter Hidden Page

The Deye logger has a hidden page used to configure cloud endpoints.

1. Open `http://192.168.40.45/config_hide.html` in a browser.
2. Set `Server A Setting` to `192.168.50.100:10000`.
3. Set `Optional Server Setting` to `192.168.50.100:10000`.
4. Save/apply the changes in the inverter UI.

These values are based on the dummycloud setup documented here:
https://github.com/Hypfer/deye-microinverter-cloud-free/tree/master/dummycloud

## Verification Checklist

- Home Assistant entities from `ha-solarman` continue updating.
- Inverter remains connected on Wi-Fi without hourly disconnect behavior.
- `deye-dummycloud` container stays running on the Debian VM.
