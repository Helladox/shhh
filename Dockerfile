# Use a lightweight Python base image
FROM python:3.10.8-slim-buster

# Update and install required dependencies
RUN apt-get update -y && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends gcc libffi-dev musl-dev ffmpeg aria2 python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set up the working directory and copy the app files
WORKDIR /app
COPY . /app/

# Install Python dependencies
RUN pip3 install --no-cache-dir --upgrade --requirement requirements.txt
RUN pip install pytube

# Create a non-root user with a UID between 10000-20000 (as required by Choreo)
RUN useradd -m -u 10001 myuser

# Give the non-root user ownership of the app directory to avoid permission issues
RUN chown -R 10001:10001 /app

# Switch to the non-root user
USER 10001

# Set environment variables
ENV COOKIES_FILE_PATH="youtube_cookies.txt"

# Start the application
CMD gunicorn app:app & python3 main.py
