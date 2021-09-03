This project will be converted into a javascript library later. For the moment it runs on a small FastAPI backend for testing and development purposes.

Screenshots:

![](https://github.com/arbobendik/web-ray-tracer/blob/master/screenshots/screen0.png?raw=true)
![](https://github.com/arbobendik/web-ray-tracer/blob/master/screenshots/screen1.png?raw=true)

Install instructions:

1. cd to project directory.
2. Set database password of your choice:
```
export DB_PASS=<<your_db_password>>
```
3. Create a python3 venv in the project directory.
```
python3 -m venv ./venv
```
4. Install all required libraries.
```
./venv/bin/pip3 install -r requirements.txt
```
5. Start fastapi with the in the venv included python version:
```
./venv/bin/python3 ./venv/bin/uvicorn app:app --host 0.0.0.0
```
6. Visit http://localhost:8000 in your browser of choice (Safari & IE unsupported due to a lack of WebGl2 support).
