#!/usr/bin/env python3

import json
import sys
import requests

# Default Coordinates (Rajshahi)
LATITUDE = 24.3745
LONGITUDE = 88.6042
DEFAULT_LOCATION = "Rajshahi"

# ============================================================
# WIND DIRECTIONS & ARROWS
# ============================================================
# Arrows point in the direction the wind is blowing.
# E.g., North wind blows South (⬇), East wind blows West (⬅).
WIND_ARROWS = {
    "N": "⬇", "NNE": "↙", "NE": "↙", "ENE": "⬅", "E": "⬅", "ESE": "↖",
    "SE": "↖", "SSE": "⬆", "S": "⬆", "SSW": "↗", "SW": "↗", "WSW": "→",
    "W": "→", "WNW": "↘", "NW": "↘", "NNW": "⬇"
}

def get_wind_direction(degree):
    """Convert wind direction in degrees to a 16-point compass direction"""
    compass_sectors = [
        "N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
        "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"
    ]
    idx = int((degree / 22.5) + 0.5) % 16
    return compass_sectors[idx]

def get_uv_risk(uv_val):
    """Map UV index to risk level and icon"""
    if uv_val < 3: return "Low", "🟢"
    if uv_val < 6: return "Moderate", "🟡"
    if uv_val < 8: return "High", "🟠"
    if uv_val < 11: return "Very High", "🔴"
    return "Extreme", "🟣"

# ============================================================
# WMO WEATHER CODES & ICONS
# ============================================================
WMO_CODES = {
    0:  {"desc": "Clear sky", "icon_day": "󰖙", "icon_night": "󰖔"},
    1:  {"desc": "Mainly clear", "icon_day": "󰂕", "icon_night": "󰼱"},
    2:  {"desc": "Partly cloudy", "icon_day": "󰖐", "icon_night": "󰼱"},
    3:  {"desc": "Overcast", "icon_day": "󰖐", "icon_night": "󰖐"},
    45: {"desc": "Fog", "icon_day": "󰖑", "icon_night": "󰖑"},
    48: {"desc": "Freezing fog", "icon_day": "󰖑", "icon_night": "󰖑"},
    51: {"desc": "Light drizzle", "icon_day": "󰖕", "icon_night": "󰼳"},
    53: {"desc": "Moderate drizzle", "icon_day": "󰖕", "icon_night": "󰼳"},
    55: {"desc": "Dense drizzle", "icon_day": "󰖖", "icon_night": "󰼳"},
    56: {"desc": "Light freezing drizzle", "icon_day": "󰖖", "icon_night": "󰼳"},
    57: {"desc": "Dense freezing drizzle", "icon_day": "󰖖", "icon_night": "󰼳"},
    61: {"desc": "Slight rain", "icon_day": "󰖕", "icon_night": "󰼳"},
    63: {"desc": "Moderate rain", "icon_day": "󰖖", "icon_night": "󰼳"},
    65: {"desc": "Heavy rain", "icon_day": "󰖖", "icon_night": "󰼳"},
    66: {"desc": "Light freezing rain", "icon_day": "󰖖", "icon_night": "󰼳"},
    67: {"desc": "Heavy freezing rain", "icon_day": "󰖖", "icon_night": "󰼳"},
    71: {"desc": "Slight snow", "icon_day": "󰼶", "icon_night": "󰼶"},
    73: {"desc": "Moderate snow", "icon_day": "󰼶", "icon_night": "󰼶"},
    75: {"desc": "Heavy snow", "icon_day": "󰼶", "icon_night": "󰼶"},
    77: {"desc": "Snow grains", "icon_day": "󰼶", "icon_night": "󰼶"},
    80: {"desc": "Slight rain showers", "icon_day": "󰖕", "icon_night": "󰼳"},
    81: {"desc": "Moderate rain showers", "icon_day": "󰖖", "icon_night": "󰼳"},
    82: {"desc": "Violent rain showers", "icon_day": "󰖖", "icon_night": "󰼳"},
    85: {"desc": "Slight snow showers", "icon_day": "󰼶", "icon_night": "󰼶"},
    86: {"desc": "Heavy snow showers", "icon_day": "󰼶", "icon_night": "󰼶"},
    95: {"desc": "Thunderstorm", "icon_day": "󰙾", "icon_night": "󰙾"},
    96: {"desc": "Thunderstorm, slight hail", "icon_day": "󰙾", "icon_night": "󰙾"},
    99: {"desc": "Thunderstorm, heavy hail", "icon_day": "󰙾", "icon_night": "󰙾"},
}

# ============================================================
# FETCH WEATHER FROM OPEN-METEO
# ============================================================
def fetch_weather(location=DEFAULT_LOCATION):
    try:
        url = (
            f"https://api.open-meteo.com/v1/forecast?"
            f"latitude={LATITUDE}&longitude={LONGITUDE}"
            f"&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,"
            f"wind_speed_10m,wind_direction_10m,wind_gusts_10m,cloud_cover,surface_pressure,precipitation,rain,showers,visibility"
            f"&hourly=uv_index"
            f"&daily=temperature_2m_max,temperature_2m_min,uv_index_max,uv_index_clear_sky_max,"
            f"precipitation_sum,precipitation_probability_max,sunrise,sunset"
            f"&timezone=auto"
        )

        response = requests.get(url, timeout=5)
        response.raise_for_status()
        data = response.json()

        current = data.get("current", {})
        daily = data.get("daily", {})
        hourly = data.get("hourly", {})

        # --- Parse Weather Code & Day/Night ---
        code = current.get("weather_code", 0)
        is_day = current.get("is_day", 1) == 1
        weather_info = WMO_CODES.get(code, {"desc": "Unknown", "icon_day": "󰖙", "icon_night": "󰖔"})
        
        desc = weather_info["desc"]
        icon = weather_info["icon_day"] if is_day else weather_info["icon_night"]

        # --- Parse Wind ---
        wind_deg = current.get("wind_direction_10m", 0)
        wind_dir = get_wind_direction(wind_deg)
        wind_arrow = WIND_ARROWS.get(wind_dir, "󰈐")
        wind_gusts = current.get("wind_gusts_10m", 0)

        # --- Parse UV (Match Current Hour to Hourly Array) ---
        current_time = current.get("time", "")
        hourly_times = hourly.get("time", [])
        hourly_uv_array = hourly.get("uv_index", [])
        
        current_uv = 0.0
        if current_time in hourly_times:
            current_uv = hourly_uv_array[hourly_times.index(current_time)]
            
        uv_risk, uv_icon = get_uv_risk(current_uv)

        # --- Parse Sunrise/Sunset ---
        sunrise_raw = daily.get("sunrise", [""])[0]
        sunset_raw = daily.get("sunset", [""])[0]
        sunrise = sunrise_raw.split("T")[-1] if "T" in sunrise_raw else "--:--"
        sunset = sunset_raw.split("T")[-1] if "T" in sunset_raw else "--:--"

        # --- Visibility ---
        visibility_km = round(current.get("visibility", 0) / 1000, 1)

        return {
            # Existing Keys Preserved
            "location": location,
            "temp": f"{round(current.get('temperature_2m', 0))}°C",
            "feels": f"{round(current.get('apparent_temperature', 0))}°C",
            "temp_min_max": f"{round(daily.get('temperature_2m_min', [0])[0])}°C / {round(daily.get('temperature_2m_max', [0])[0])}°C",
            "desc": desc,
            "humidity": f"{current.get('relative_humidity_2m', 0)}%",
            "wind": f"{round(current.get('wind_speed_10m', 0))} km/h",
            "wind_dir": wind_dir,
            "wind_arrow": wind_arrow,
            "uv_index": str(round(daily.get("uv_index_max", [0])[0])),
            "icon": icon,

            # New UV Specifics
            "uv_current": str(current_uv),
            "uv_risk": uv_risk,
            "uv_icon": uv_icon,
            "uv_max": str(round(daily.get("uv_index_max", [0])[0], 1)),
            "uv_clear_sky_max": str(round(daily.get("uv_index_clear_sky_max", [0])[0], 1)),

            # New Precipitation & Clouds
            "precip_prob": f"{daily.get('precipitation_probability_max', [0])[0]}%",
            "precip_daily": f"{daily.get('precipitation_sum', [0])[0]} mm",
            "current_rain": f"{current.get('precipitation', 0)} mm",
            "cloud_cover": f"{current.get('cloud_cover', 0)}%",

            # New Wind Details
            "wind_gusts": f"{round(wind_gusts)} km/h",
            "wind_dir_deg": f"{wind_deg}°",

            # New Environment/Atmosphere
            "pressure": f"{round(current.get('surface_pressure', 0))} hPa",
            "visibility": f"{visibility_km} km",
            
            # Sun Cycle
            "sunrise": sunrise,
            "sunset": sunset,
        }

    except Exception:
        # Ultimate fail-safe so your widget renders cleanly even on network drop
        return {
            "location": location,
            "temp": "--°C", "feels": "--°C", "temp_min_max": "--°C / --°C",
            "desc": "Offline", "humidity": "--%", "wind": "-- km/h",
            "wind_dir": "--", "wind_arrow": "󰈐", "uv_index": "0", "icon": "󰖑",
            
            "uv_current": "--", "uv_risk": "Unknown", "uv_icon": "⚪",
            "uv_max": "--", "uv_clear_sky_max": "--",
            "precip_prob": "--%", "precip_daily": "-- mm", "current_rain": "-- mm",
            "cloud_cover": "--%", "wind_gusts": "-- km/h", "wind_dir_deg": "--°",
            "pressure": "-- hPa", "visibility": "-- km",
            "sunrise": "--:--", "sunset": "--:--"
        }

# ============================================================
# MAIN
# ============================================================
if __name__ == "__main__":
    loc = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_LOCATION
    result = fetch_weather(loc)
    print(json.dumps(result, ensure_ascii=False))
