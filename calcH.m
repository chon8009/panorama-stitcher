function H = calcH(p1, p2)
% Assume we have two images called '1' and '2' p1 is an n x 2 matrix
% containing n feature points, where each row holds the coordinates of a
% feature point in image '1' p2 is an n x 2 matrix where each row holds the
% coordinates of a corresponding point in image '2' H is the homography
% matrix, such that p1_hom = H * [p2 ones(size(p2, 1), 1)]'
% p1_hom contains the transformed homogeneous coordinates of p2
% from image �2� to image �1�.

n = size(p1, 1);
if n < 4
    error('Not enough points');
end

bestmatchcount = 0;
bestH = zeros(3);
matchset = [];

% calculate and find the best of 100 homography matrices based on 4 random
% feature points
for j = 1:1000
    
    A = zeros(4*3,9);
    b = zeros(4*3,1);
    
    for i = 1:4
        pointindex = randi(n);
        A(3*(i-1)+1,1:3) = [p2(pointindex,:),1];
        A(3*(i-1)+2,4:6) = [p2(pointindex,:),1];
        A(3*(i-1)+3,7:9) = [p2(pointindex,:),1];
        b(3*(i-1)+1:3*(i-1)+3) = [p1(pointindex,:),1];
    end
    x = (A\b)';
    H = [x(1:3); x(4:6); x(7:9)];
    
    p2_hom = [p2 ones(size(p2,1),1)];
    p1_hom = H * p2_hom';
    p1_new = p1_hom(1:2,1:size(p2,1));
    p1_newt = p1_new';
    
    matchcounter = 0;
   
    for i = 1:n
        dist = sqrt(((p1_newt(i,1)-p1(i,1)).^2)+((p1_newt(i,2)-p1(i,2)).^2));
        if dist < 2 % threshold
            matchcounter = matchcounter+1;
        end
    end
    
    if matchcounter > bestmatchcount
        bestmatchcount = matchcounter;
        bestH = H;
    end
end

% recalculate new H with all matching points of bestH
p2_hom = [p2 ones(size(p2,1),1)];
p1_hom = bestH * p2_hom';
p1_new = p1_hom(1:2,1:size(p2,1));
p1_newt = p1_new';

for i = 1:n
    dist = sqrt(((p1_newt(i,1)-p1(i,1)).^2)+((p1_newt(i,2)-p1(i,2)).^2));
    if dist < 3
        matchset = cat(1,matchset,i);
    end
end
len = length(matchset);
A = zeros(len*3,9);
b = zeros(len*3,1);

for i = 1:len
    A(3*(i-1)+1,1:3) = [p2(matchset(i),:),1];
    A(3*(i-1)+2,4:6) = [p2(matchset(i),:),1];
    A(3*(i-1)+3,7:9) = [p2(matchset(i),:),1];
    b(3*(i-1)+1:3*(i-1)+3) = [p1(matchset(i),:),1];
end

x = (A\b)';
H = [x(1:3); x(4:6); x(7:9)];

end
