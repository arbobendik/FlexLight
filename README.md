Screenshots:

![](https://github.com/arbobendik/web-ray-tracer/blob/master/screenshots/screen3.png?raw=true)
example_0 (SCALE = 2 (1080p -> 4k), SAMPLES = 8)

It would be very helpful if you could visit this test page and report any errors here in the "Issues" tab:

example_0 test page: https://arbobendik.github.io/web-ray-tracer/example_0.html

use the raytracer in your project as a javascript library (raytracer.js).
There is no official documentation yet. For code examples look at example_0.

or

Install ray tracer as seperated files as fastapi server (for development purposes)
Install instructions for development server (linux only):

1. cd to project directory.
2. Create a python3 venv in the project directory.
```
python3 -m venv ./venv
```
3. Install all required libraries.
```
./venv/bin/pip3 install -r requirements.txt
```
4. Start fastapi with the in the venv included python version:
```
./venv/bin/python3 ./venv/bin/uvicorn app:app --host 0.0.0.0
```
5. Visit http://localhost:8000 in your browser of choice (Safari & IE unsupported due to a lack of WebGl2 support).

More screenshots (probably from deprecated versions):

![](https://github.com/arbobendik/web-ray-tracer/blob/master/screenshots/screen1.png?raw=true)
![](https://github.com/arbobendik/web-ray-tracer/blob/master/screenshots/screen2.png?raw=true)
