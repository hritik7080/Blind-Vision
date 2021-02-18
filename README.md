# Blind-Vision
Created an application for visually impaired people to recognize the Indian currency with their mobile.

Developed an android application. Created a deep learning YOLOv3 object detection model to detect currency notes and served it with a REST API created with django.

### Demo:
<iframe width="560" height="315" src="https://www.youtube.com/embed/XG8H_vWcp28" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

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
This means your application is hosted on port number **8000**<br>
Leave you terminal open and let's go further
<br><br>
To use this API in you mobile application you have to host it somewhere, so that you can call the API from other devices.<br>
To turn my localhost server to live, I use **<a href="https://ngrok.com/download">ngrok</a>**<br>
Download it from the above link and open. A command prompt/terminal will appear. Now execute the below command there.
<pre>ngrok http 8000</pre>
This will create a link for your live application.<br>
Leave the command prompt/terminal open<br>

### 2. Intall the flutter application
Make you have connected an AVD or you phone usb debugging<br>
Excute the following commmands
<pre>cd customCamera</pre>
<pre>flutter pub get</pre>
Open the file  **customCamera/lib/main.dart**
Copy the **http** link from **ngrok** and paste it in the **main.dart** at line **48**<br>
**Make sure you don't remove the path in the domain**. That is the actual endpoint of the api.<br><br>

***Now make sure you django localhost server and ngrok is running***<br>
After pasting the URL, execute the below command in the cmd/terminal -
<pre>flutter run</pre>
This will install the app on your mobile and you can test it.
