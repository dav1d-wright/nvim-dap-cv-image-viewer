import cv2 as cv
import numpy as np

if __name__ == '__main__':
    height, width = (20, 20)
    image = np.zeros((height, width, 3), np.uint8)
    image[:, 0:width // 2] = (255, 0, 0)
    image[:, width // 2:width] = (0, 0, 255)
    print(cv.imencode(".png", image))
