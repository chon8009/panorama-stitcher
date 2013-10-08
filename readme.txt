panorama - Louis Schiff
- get pictures in order from side to side. turn in into a flat panorama
use Sift corner detector to find feature points and calculate homography matricies to map all the photos onto one reference image. 
- use ransack algorithm to determine homography matrix. 1000 homography matrices (3x3 matrix with 8 deg freedom and a scale factor) based on 4 random feature points.  Tests which homography matrix does the best by using it to warp all the feature points. We then see how many matches there are. We do it 100 times and pick the best one and find the transformed homogenious coordinates from one image to the other. We do that for all the images and warp them all onto the reference image. We do bilinear interpolation and inverse warping so we dont get holes. That also vectorizes it so it doesn't take forever.
My main function is main.m
