This project will be converted into a javascript library later for the moment it runs on a small FastAPI backend 

Install instructions:

1. cd to project directory.
2. Set database password of your choice:
```
export DB_PASS=<<your_db_password>>
```

3. Start fastapi with the in the venv included python version:

```/venv/bin/python3 ./venv/bin/uvicorn app:app --host 0.0.0.0```

4. Visit http://localhost:8000 in your browser of choice (Safari & IE unsupported due to a lack of WebGl2).
