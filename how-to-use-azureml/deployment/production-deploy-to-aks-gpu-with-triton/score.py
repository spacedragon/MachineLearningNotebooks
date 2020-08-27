import numpy as np
from PIL import Image
import sys
from functools import partial
import os
import io

import tritonhttpclient
from tritonclientutils import InferenceServerException

from azureml.contrib.services.aml_request import AMLRequest, rawhttp
from azureml.contrib.services.aml_response import AMLResponse

sys.path.append(os.path.join(os.getenv('AZUREML_MODEL_DIR'), 'models'))
from utils import preprocess, postprocess


trition_client = None
_url = "localhost:8000"
_model = "densenet_onnx"
_scaling = "INCEPTION"

def init():
    global triton_client, max_batch_size, input_name, output_name, dtype

    triton_client = tritonhttpclient.InferenceServerClient(_url)

    max_batch_size = 0
    input_name = "data_0"
    output_name = "fc6_1"
    dtype = "FP32"


@rawhttp
def run(request):
    if request.method == 'POST':
        
        reqBody = request.get_data(False)
        img = Image.open(io.BytesIO(reqBody))
        
        image_data = preprocess(img, _scaling, dtype)
        
        input = tritonhttpclient.InferInput(input_name, image_data.shape, dtype)
        input.set_data_from_numpy(image_data, binary_data=True)
        output = tritonhttpclient.InferRequestedOutput(output_name, binary_data=True, class_count=1)
    
        res = triton_client.infer(_model,
                                [input],
                                request_id="0",
                                outputs=[output])

        result = postprocess(res, output_name, 1, max_batch_size > 0)

        return AMLResponse(result, 200)
    else:
        return AMLResponse("bad request", 500)
