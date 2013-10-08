function [ J ] = myhisteq( I )
% Louis Schiff
% CS534 HW 2 P1
% Dyer 10/1/12
% myhisteq.m - performs histogram equalization on an uint8 RGB image
% also prints histograms of the value of the image and the equalized value
% of the image

    % convert to double
    doubleI = im2double(I);
    % convert to hsv
    hsvI = rgb2hsv(doubleI);
    % extract value plane
    valueI = hsvI(:,:,3);
    
    x = 0:1/256:1;
    % compute histogram
    histI = hist(valueI(:),x);
    bar(histI);
    print('-djpeg','P1-histogram.jpg');
    
    % compute cumulative histogram
    chistI = cumsum(histI);
    intvalueI = im2uint8(valueI);
    
    sizeI = size(I);
    eqI = zeros(sizeI(1),sizeI(2),'uint8');
    % find smallest nonzero value
    minchistI = min(chistI(chistI>0));
    
    % compute values for equalised image
    for n = 1:sizeI(1)
        for m = 1:sizeI(2)
            eqI(n,m)= round(255*((chistI(intvalueI(n,m)+1)-minchistI)/((sizeI(1)*sizeI(2))-minchistI)));
        end
    end
    
    eqIdouble = im2double(eqI);
    
    % compute histogram of equalised image
    newhist = hist(eqIdouble(:),x);
    bar(newhist);
    print('-djpeg','P1-eqhistogram.jpg');

    % concatinate new image
    newhsvI = cat(3,hsvI(:,:,1),hsvI(:,:,2),eqIdouble);
    % convert to RGB
    newrgbI = hsv2rgb(newhsvI);
    % convert to int
    J = im2uint8(newrgbI);
    
end
