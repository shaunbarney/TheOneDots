#!/usr/bin/env python3
import json
import os
import sys
import requests

from bs4 import BeautifulSoup

from datetime import datetime, timedelta

# from langchain_community.chat_models import ChatOpenAI  # Update this import

from langchain_openai import ChatOpenAI  # Use the new class from langchain_openai
from langchain.schema import HumanMessage, SystemMessage
from typing import Dict, Any, List, Optional


sys.path.insert(0, os.path.expanduser("~/.config/i3blocks"))
from secret_loader import load_secrets
load_secrets()
CHAT_API_KEY = os.environ["OPENAI_API_KEY"]
chat = ChatOpenAI(openai_api_key=CHAT_API_KEY, model_name="gpt-4-turbo")
SPACEX_URL = "https://spaceflightnow.com/launch-schedule/"

print("Fetching SpaceX launch schedule...")
