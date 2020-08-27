import numpy as np
from PIL import Image
import os


def preprocess(img, scaling, dtype):
    """
    Pre-process an image to meet the size, type and format
    requirements specified by the parameters.
    """
    # np.set_printoptions(threshold='nan')
    c = 3
    h = 224
    w = 224
    format = "FORMAT_NCHW"
    
    if c == 1:
        sample_img = img.convert('L')
    else:
        sample_img = img.convert('RGB')

    resized_img = sample_img.resize((w, h), Image.BILINEAR)
    resized = np.array(resized_img)
    if resized.ndim == 2:
        resized = resized[:, :, np.newaxis]

    npdtype = dtype
    typed = resized.astype(npdtype)

    if scaling == 'INCEPTION':
        scaled = (typed / 128) - 1
    elif scaling == 'VGG':
        if c == 1:
            scaled = typed - np.asarray((128,), dtype=npdtype)
        else:
            scaled = typed - np.asarray((123, 117, 104), dtype=npdtype)
    else:
        scaled = typed

    # Swap to CHW if necessary
    if format == "FORMAT_NCHW":
        ordered = np.transpose(scaled, (2, 0, 1))
    else:
        ordered = scaled

    # Channels are in RGB order. Currently model configuration data
    # doesn't provide any information as to other channel orderings
    # (like BGR) so we just assume RGB.
    return ordered

labels_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'densenet_labels.txt')
labels = open(labels_path).read().split('\n')


def postprocess(results):
    """
    Post-process results to show classifications.
    """
    index_max = max(range(len(results)), key=results.__getitem__)
    # res = {'index': index_max, "prediction": labels[index_max]}
    # print(res)

    return labels[index_max]