# -*- encoding: utf-8 -*-
# Author: Epix
import numpy as np
import cv2
import sys
from scipy.spatial import Delaunay


# Read points from text file
def readPoints(path):
    # Create an array of points.
    points = []
    # Read points
    with open(path) as file:
        for line in file:
            x, y = line.split()
            points.append((int(x), int(y)))

    return points


# Apply affine transform calculated using srcTri and dstTri to src and
# output an image of size.
def applyAffineTransform(src, srcTri, dstTri, size):
    # Given a pair of triangles, find the affine transform.
    warpMat = cv2.getAffineTransform(np.float32(srcTri), np.float32(dstTri))

    # Apply the Affine Transform just found to the src image
    dst = cv2.warpAffine(src, warpMat, (size[0], size[1]), None, flags=cv2.INTER_LINEAR,
                         borderMode=cv2.BORDER_REFLECT_101)

    return dst


# Warps and alpha blends triangular regions from img1 and img2 to img
def morphTriangle(img1, img2, img, t1, t2, t, alpha):
    # Find bounding rectangle for each triangle
    r1 = cv2.boundingRect(np.float32([t1]))
    r2 = cv2.boundingRect(np.float32([t2]))
    r = cv2.boundingRect(np.float32([t]))

    # Offset points by left top corner of the respective rectangles
    t1Rect = []
    t2Rect = []
    tRect = []

    for i in range(0, 3):
        tRect.append(((t[i][0] - r[0]), (t[i][1] - r[1])))
        t1Rect.append(((t1[i][0] - r1[0]), (t1[i][1] - r1[1])))
        t2Rect.append(((t2[i][0] - r2[0]), (t2[i][1] - r2[1])))

    # Get mask by filling triangle
    mask = np.zeros((r[3], r[2], 3), dtype=np.float32)
    cv2.fillConvexPoly(mask, np.int32(tRect), (1.0, 1.0, 1.0), 16, 0);

    # Apply warpImage to small rectangular patches
    img1Rect = img1[r1[1]:r1[1] + r1[3], r1[0]:r1[0] + r1[2]]
    img2Rect = img2[r2[1]:r2[1] + r2[3], r2[0]:r2[0] + r2[2]]

    size = (r[2], r[3])
    warpImage1 = applyAffineTransform(img1Rect, t1Rect, tRect, size)
    warpImage2 = applyAffineTransform(img2Rect, t2Rect, tRect, size)

    # Alpha blend rectangular patches
    imgRect = (1.0 - alpha) * warpImage1 + alpha * warpImage2

    # Copy triangular region of the rectangular patch to the output image
    img[r[1]:r[1] + r[3], r[0]:r[0] + r[2]] = img[r[1]:r[1] + r[3], r[0]:r[0] + r[2]] * (1 - mask) + imgRect * mask


def makeMorph(p1_filename, p2_filename, output_filename, points1, points2, tri, alpha):
    base_points = [[0, 0], [0, 400], [0, 799], [300, 799], [599, 799], [599, 400], [599, 0], [300, 0]]
    # points1 += base_points
    # points2 += base_points
    img1 = cv2.imread(p1_filename)
    img2 = cv2.imread(p2_filename)
    # alpha = 0.5
    img1 = np.float32(img1)
    img2 = np.float32(img2)
    points = []
    for i in range(0, len(points1)):
        x = (1 - alpha) * points1[i][0] + alpha * points2[i][0]
        y = (1 - alpha) * points1[i][1] + alpha * points2[i][1]
        points.append((x, y))
    imgMorph = np.zeros(img1.shape, dtype=img1.dtype)
    for t_tri in tri:
        x, y, z = t_tri

        x = int(x)
        y = int(y)
        z = int(z)

        t1 = [points1[x], points1[y], points1[z]]
        t2 = [points2[x], points2[y], points2[z]]
        t = [points[x], points[y], points[z]]

        # Morph one triangle at a time.
        morphTriangle(img1, img2, imgMorph, t1, t2, t, alpha)
    cv2.imwrite(output_filename, np.uint8(imgMorph))


def make_morphs(p1_filename, p2_filename, output_filename_prefix, points1, points2):
    r = []
    tri = Delaunay(points1).simplices
    for i in range(11):
        output_file = output_filename_prefix + '_' + str(i) + '.jpg'
        makeMorph(p1_filename, p2_filename, output_file, points1, points2, tri, i / 10)
        r.append(output_file)
    return r


if __name__ == '__main__':
    filename1 = 'a.jpg'
    filename2 = 'b.jpg'
    r_file = 'generated\\r'
    # Read array of corresponding points
    points1 = readPoints('a.txt')
    points2 = readPoints('b.txt')
    rr = make_morphs(filename1, filename2, r_file, points1, points2)
    print(rr)
    # Display Result
