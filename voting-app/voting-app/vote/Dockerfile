FROM python:3.11-alpine

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

EXPOSE 80

CMD ["gunicorn", "--bind", "0.0.0.0:80", "--workers", "4", "app:app"]
