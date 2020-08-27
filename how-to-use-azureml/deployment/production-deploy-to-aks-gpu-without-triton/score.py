import numpy as np
from PIL import Image
import sys
from functools import partial
import os
import io
import onnxruntime

from azureml.contrib.services.aml_request import AMLRequest, rawhttp
from azureml.contrib.services.aml_response import AMLResponse

sys.path.append(os.path.join(os.getenv('AZUREML_MODEL_DIR'), 'models'))
# sys.path.append('models')
from utils import preprocess, postprocess

_scaling = "INCEPTION"
dtype = np.float32
max_batch_size = 0

def init():
    global session, input_name, output_name, input_shape

    # AZUREML_MODEL_DIR is an environment variable created during deployment.
    # It is the path to the model folder (./azureml-models/$MODEL_NAME/$VERSION)
    # For multiple models, it points to the folder containing all deployed models (./azureml-models)
    model = os.path.join(os.getenv('AZUREML_MODEL_DIR'), 'models', 'model.onnx')
    #model = os.path.join('models', 'model.onnx')
    session = onnxruntime.InferenceSession(model, None)
    input_name = session.get_inputs()[0].name
    input_shape = session.get_inputs()[0].shape
    output_name = session.get_outputs()[0].name
    print("input: ", input_name, ", output: ", output_name, ", input_shape: ", input_shape)


@rawhttp
def run(request):
    if request.method == 'POST':
        
        reqBody = request.get_data(False)
        img = Image.open(io.BytesIO(reqBody))
        
        result = score(img)

        return AMLResponse(result, 200)
    else:
        return AMLResponse("bad request", 500)

def score(data):
    image_data = preprocess(data, _scaling, dtype)
    print(image_data.shape)
    input = np.reshape(image_data, input_shape)
    r = session.run([output_name], {input_name: input})[0]
    print(r.shape)
    res = r.flatten()
    print(len(res))
    result = postprocess(res)
    return result

if __name__ == "__main__":
    init()
    content = Image.open("car.jpg")
    print(score(content))

