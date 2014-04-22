panoramma-stitcher
=====

####take some overlaping pictures and make a panorama!
This script uses a SIFT feature-detector to find feature points and calculate homography matricies to map all the photos onto one reference image. 
Next it uses a RANSAC algorithm to determine a homography matrix (3x3 matrix with 8 deg freedom and a scale factor) based on 4 random feature points.  
It just tests which one is best by using it to warp all the feature points and count matches. It does that 100 times and picks the best one and find the transformed homogenious coordinates from one image to the other. 
It repeats that for all the images and warp them all onto the reference image. 
It then uses bilinear interpolation and inverse warping so we dont get holes. That also vectorizes it so it doesn't take forever.

My main function is main.m
