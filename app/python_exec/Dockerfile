# Use an official Python runtime as a parent image
FROM python:2.7-slim

# Set the working directory to /app
WORKDIR /usr/src/app

# Copy the current directory contents into the container at /app
ADD . /usr/src/app

# Install any needed packages specified in requirements.txt
RUN pip install --trusted-host pypi.python.org -r requirements.txt --proxy http://proxy-chain.intel.com:911


# Run app.py when the container launches
CMD ["python", "app.py"]