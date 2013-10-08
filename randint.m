function [rn] = randint(i1,i2)
% VERSION 2.0
%  i1 -- integer towards minus infinity
%  i2 -- integer towards plus infinity
if isinteger(int8([i1 i2]))==1
    if (i1<0 && i2<0)||(i1>0 && i2>0)
        N = abs(i1)+abs(i2)-1;
    elseif (i1*i2<=0)
        N = abs(i1)+abs(i2)+1;
    end
    rn = min(i1,i2) + floor(N*rand(N,1));
    %     RN = min(i1,i2) + floor(numel(i1:i2)*rand(numel(i1:i2),1)); - VERSION 1.0    
else
    disp('Please enter valid input arguments..')
end
end
% by sunil anandatheertha, Feb 06, 2012