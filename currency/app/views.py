from django.shortcuts import render

# Create your views here.
from django.shortcuts import render

# Create your views here.
from rest_framework.views import APIView
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.response import Response
from rest_framework import status
from .serializers import FileSerializer

from .models import File
import numpy as np
import os
import cv2
import numpy as np

net = cv2.dnn.readNet('./yolov3_training_last(1).weights',
                      './yolov3_training.cfg')
classes = []
with open("./classes.txt", "r") as f:
    classes = f.read().splitlines()

# cap = cv2.VideoCapture('note2.mp4')
font = cv2.FONT_HERSHEY_PLAIN
colors = np.random.uniform(0, 255, size=(100, 3))


def predict_note(image_path):
    if True:
        img = cv2.imread(f'.{image_path}')
        #720, 1280
        # print(img.shape)
        # img = cv2.resize(img, (1280, 720), fx=0,fy=0, interpolation=cv2.INTER_CUBIC)
        height, width, _ = img.shape

        blob = cv2.dnn.blobFromImage(
            img, 1/255, (416, 416), (0, 0, 0), swapRB=True, crop=False)
        net.setInput(blob)
        output_layers_names = net.getUnconnectedOutLayersNames()
        layerOutputs = net.forward(output_layers_names)

        boxes = []
        confidences = []
        class_ids = []

        for output in layerOutputs:
            for detection in output:
                scores = detection[5:]
                class_id = np.argmax(scores)
                confidence = scores[class_id]
                if confidence > 0.1:
                    center_x = int(detection[0]*width)
                    center_y = int(detection[1]*height)
                    w = int(detection[2]*width)
                    h = int(detection[3]*height)

                    x = int(center_x - w/2)
                    y = int(center_y - h/2)

                    boxes.append([x, y, w, h])
                    confidences.append((float(confidence)))
                    class_ids.append(class_id)

        indexes = cv2.dnn.NMSBoxes(boxes, confidences, 0.2, 0.4)

        if len(indexes) > 0:
            for i in indexes.flatten():
                x, y, w, h = boxes[i]
                label = str(classes[class_ids[i]])
                confidence = str(round(confidences[i], 2))
                color = colors[i]
                # if label=='mask':
                cv2.rectangle(img, (x, y), (x+w, y+h), (65, 105, 225), 2)
                cv2.putText(img, str(label), (x, y+20),
                            font, 2, (255, 255, 255), 2)
                print(str(label))
            if str(label).find('_') != -1:
                return [str(label)[:-2]]
            return [str(label)]
    return ['Nothing Captured']


class FileView(APIView):
    parser_classes = (MultiPartParser, FormParser)

    def post(self, request, *args, **kwargs):
        # try:
        file_serializer = FileSerializer(data=request.data)
        if file_serializer.is_valid():
            file_serializer.save()
            # dict(file_serializer.data)['file']
            output = predict_note(dict(file_serializer.data)['file'])
            objs = File.objects.all()
            objs = [i for i in objs]
            objs[-1].delete()
            print(dict(file_serializer.data)['file'])
            os.remove(f".{dict(file_serializer.data)['file']}")
            return Response({"result": output[0], "success": True},
                            status=status.HTTP_201_CREATED)
        else:
            return Response(file_serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        # except:
        #     objs = File.objects.all()
        #     objs = [i for i in objs]
        #     objs[-1].delete()
        #     os.remove(f".{dict(file_serializer.data)['file']}")
        #     return Response({"error": "an error occurred"}, status=status.HTTP_400_BAD_REQUEST)
