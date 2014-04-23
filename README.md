panorama-stitcher
=====

####Take some overlaping pictures and make a panorama!
This script uses a SIFT feature-detector to find feature points and calculate homography matricies to map all the photos onto one reference image. 

![featurepoints](arthuroutfeature1.jpg? =250x raw=true) 

Next it uses a RANSAC algorithm to determine a homography matrix (3x3 matrix with 8 deg freedom and a scale factor) based on 4 random feature points. It just tests which one is best by using it to warp all the feature points and count matches. It does that 100 times and picks the best one and gets the transformed homogenious coordinates from one image to the other. There is definitely a more acurate way to do it, but this way is computationally feasble because matlab is slow.

![matches](arthuroutmatch3.jpg?raw=true =250x)

It repeats that for all the images and warps them all onto the reference image. 
It then uses the matlab bilinear interpolation and inverse warping so we dont get holes. That also vectorizes it so it doesn't take forever.

![output](arthurout1.jpg?raw=true =250x)

This is the output image. It has a pretty gnarly curvature because it's just being projected onto a plane. The cool way to do it is to use a non-planar projective space like a cylinder, but I didn't get that working yet.

My main function is main.m
