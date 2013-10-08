function output = panorama(imagepath)
% Generates panorama image from a set of images in imagepath directory
% Assumes images are in order and are the only files in this directory

files = dir(imagepath);
% Eliminate . and .. and assume everything else in directory is an input
% image Also assume that all images are color
imagelist = files(3:end);
%imagelist(1).name

for i = 1:length(imagelist)-1
    
    image1 = strcat(imagepath,imagelist(i).name);
    image2 = strcat(imagepath,imagelist(i+1).name);
    I = imread(image1);
    % Find matching feature points between current two images using SIFT
    [~, matchIndex, loc1, loc2] = match(image1, image2);
    showkeys(I,loc1);
    im1_ftr_pts = loc1(find(matchIndex>0), 1:2);
    im2_ftr_pts = loc2(matchIndex(find(matchIndex>0)), 1:2);
    
    %showkeys(imread(image1),loc1)
    
    % Calculate 3x3 homography matrix, H, mapping coordinates in image2
    % into coordinates in image1
    H = calcH(im1_ftr_pts, im2_ftr_pts);
    
    H_list(i) = {H};
    
end

% Select one input image as the reference image

% Generate new homographies that map every other image directly to the
% reference image by composing H matrices in H_list
H_map = H_list;
for i = 1:length(imagelist)
    
    Hcomp = eye(3);
    for j = i-1:-1:1
        Hcomp = H_list{j} * Hcomp;
    end
    H_map{i} = Hcomp;
end

% Compute size of output panorama image
min_row = 1;
min_col = 1;
max_row = 0;
max_col = 0;

% for each input image
for i = 1:length(H_map)
    cur_image = imread(strcat(imagepath,imagelist(i).name));
    

    
    [rows,cols,~] = size(cur_image);
    
    % create a matrix with the coordinates of the four corners of the
    % current image
    pt_matrix = cat(3, [1,1,1]', [1,cols,1]', [rows, 1,1]', [rows,cols,1]');
    
    % Map each of the 4 corner's coordinates into the coordinate system of
    % the reference image
    for j = 1:4
        result = H_map{i}*pt_matrix(:,:,j);
        
        min_row = floor(min(min_row, result(1)));
        min_col = floor(min(min_col, result(2)));
        max_row = ceil(max(max_row, result(1)));
        max_col = ceil(max(max_col, result(2)));
    end
    
end

% Calculate output image size
im_rows = max_row - min_row + 1;
im_cols = max_col - min_col + 1;

% Calculate offset of the upper-left corner of the reference image relative
% to the upper-left corner of the output image
row_offset = 1 - min_row;
col_offset = 1 - min_col;

% Initialize output image to black (0)
pan_image = zeros(im_rows, im_cols, 3);

% weight vector
weight_pan = 1 : -1/(im_cols-1) : 0
% weight matrix: repeat of weight vector
weight_matrix = repmat(weight_pan, im_rows, 1);
%im_cols, 
% weight vector
weight_pan2 = 1 - weight_pan;
% weight matrix: repeat of weight vector
weight_matrix2 = repmat(weight_pan2, im_rows, 1);

ref_img = imread(strcat(imagepath,imagelist(1).name));

% Perform inverse mapping for each input image
for i = 1:length(H_map)
    imloop = i
    %cur_image = imhistmatch(im2double(imread(strcat(imagepath,imagelist(i).name))),ref_img,65535);
    cur_image = im2double(imread(strcat(imagepath,imagelist(i).name)));
    %ref_img = cur_image;
    % Create a list of all pixels' coordinates in output image
    [x,y] = meshgrid(1:im_cols, 1:im_rows);
    % Create list of all row coordinates and column coordinates in separate
    % vectors, x and y, including offset
    x = reshape(x,1,[]) - col_offset;
    
    y = reshape(y,1,[]) - row_offset;
    
    % Create homogeneous coordinates for each pixel in output image
    pan_pts(1,:) = y;
    pan_pts(2,:) = x;
    pan_pts(3,:) = ones(1,size(pan_pts,2));
    
    % Perform inverse warp to compute coordinates in current input image
    
    image_coords = H_map{i}\pan_pts;
    
    row_coords = reshape(image_coords(1,:),im_rows, im_cols);
    col_coords = reshape(image_coords(2,:),im_rows, im_cols);
    % Note:  Some values will return as NaN because they
    % map to points outside the domain of the input image
    
    % Bilinear interpolate color values
    %imshow(cur_image(:,:,1));
    pixel_color_r = interp2(cur_image(:,:,1), col_coords, row_coords, 'linear', 0);
    pixel_color_g = interp2(cur_image(:,:,2), col_coords, row_coords, 'linear', 0);
    pixel_color_b = interp2(cur_image(:,:,3), col_coords, row_coords, 'linear', 0);
        
    for j = 1:im_rows
        for k = 1:im_cols
            if (pixel_color_r(j,k) > 0)
                if (pan_image(j,k,1) > 0)
                    pan_image(j,k,1) = pixel_color_r(j,k) .* weight_matrix(j,k) + pan_image(j,k,1) .* weight_matrix2(j,k);
                    pan_image(j,k,2) = pixel_color_g(j,k) .* weight_matrix(j,k) + pan_image(j,k,2) .* weight_matrix2(j,k);
                    pan_image(j,k,3) = pixel_color_b(j,k) .* weight_matrix(j,k) + pan_image(j,k,3) .* weight_matrix2(j,k);
                else
                    pan_image(j,k,1) = pixel_color_r(j,k);
                    pan_image(j,k,2) = pixel_color_g(j,k);
                    pan_image(j,k,3) = pixel_color_b(j,k);
                end
            end
        end
    end
    
end

output = pan_image;
imshow(output);
%imwrite(output,'output.jpg','JPG');
end

