# Copyright (c) 2022 Itz-fork

import os


class Config(object):
    APP_ID = 13239572
    API_HASH = "dd2025a8053604ffa9f7915c1de7e75a" 
    AUTH_USERS = [2126277305]
    BOT_TOKEN = "5003604008:AAG2Srj_mt3VYuYOACiXUi_n42xEggRU1PQ"
    LOGS_CHANNEL = -1001806083045
    IS_PUBLIC_BOT = False
    # DON'T CHANGE THESE 2 VARS
    DOWNLOAD_LOCATION = "./NexaBots"
    TG_MAX_SIZE = 2040108421
    # Mega User Account
    MEGA_EMAIL = os.environ.get("MEGA_EMAIL")
    MEGA_PASSWORD = os.environ.get("MEGA_PASSWORD")
