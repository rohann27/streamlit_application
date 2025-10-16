# -------------------------------
# Stage 1: Builder
# -------------------------------
FROM python:3.10 AS builder

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV VENV_PATH=/venv

# Create virtual environment
RUN python -m venv $VENV_PATH
ENV PATH="$VENV_PATH/bin:$PATH"

# Set working directory
WORKDIR /app

# Copy requirements first (cache optimization)
COPY requirements.txt .

# Upgrade pip and install dependencies
RUN pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# -------------------------------
# Stage 2: Final image
# -------------------------------
FROM python:3.10-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV VENV_PATH=/venv
ENV PATH="$VENV_PATH/bin:$PATH"

# Create virtual environment
RUN python -m venv $VENV_PATH

# Set working directory
WORKDIR /app

# Copy installed packages from builder
COPY --from=builder $VENV_PATH $VENV_PATH

# Copy application code
COPY . .

# Expose port (adjust for your app)
EXPOSE 8501

# Default command (adjust for Streamlit, Flask, etc.)
CMD ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]
