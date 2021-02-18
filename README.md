# Blind-Vision
Created an application for visually impaired people to recognize the Indian currency with their mobile.

Developed an android application. Created a deep learning YOLOv3 object detection model to detect currency notes and served it with a REST API created with django.

### REQUIREMENTS:
<pre>
django==3.1.4<br>
opencv-contrib-python==4.4.0.46<br>
numpy==1.18.5<br>
django-rest-framework<br>
</pre>

also given in the **requirements.txt** file.

### 1. Intall the python libraries and start the django server
<pre>pip install -r requirements.txt</pre>

<pre>cd currency</pre>
<pre>python manage.py runserver</pre>
This command will run your localhost server will give you a link as -
<pre>http://127.0.0.1:8000</pre>
This means your application is hosted on port number **8000**
<br><br>
To use this API in you mobile application you have to host it somewhere, so that you can call the API from other devices.<br>
To turn my localhost server to live, I cuse **<a href="https://ngrok.com/download">ngrok</a>**


