%This script encodes the events
%By Qiangsen He 
% this function is used to encoding a sequence of events into a numeric
% vector, the key in this function is to encode the transition from H0 to
% Hi(i>0 and i<=9), the output vector recodes Hi events from onset of H0 to >H0,
% for the preceding 3 events (-1, -2, -3) and following 3 events (1, 2, 3). 
% Need to account for various scenarios in the data and overlap between close 
%stage transitions.

function [numericVector2,numericVector] = encodingEvents(FFT)

if ~isempty({FFT.event.type})
    eventSequence = string({FFT.event.type});
else
    error('Current FFT has no events inside...');
end

numericVector = zeros(1,length(eventSequence))';
numericVector2 = numericVector;
for i=1:length(eventSequence)-1
    if eventSequence(i)=="H0" && eventSequence(i+1)~="H0"
           numericVector(i) = 1;
    end
end

indices = find(numericVector==1);

%% code the onset of H0 to Hi(i>0) events
for i = 1:length(indices)
    if(i==1)
        last = 1;
        next = indices(i+1);
    elseif(i==length(indices))
        last = indices(i-1);
        next = length(numericVector)+1;
    elseif(1<i && i<length(indices))
        last = indices(i-1);
        next = indices(i+1);
    end
    
    
    left = min(indices(i)-last+1,6);
    right =min(next -indices(i),6);

    left = floor(left/2);
    right = ceil(right/2);

    m=1;
    n=1;
    % iterate to left
    while(left>0)
        if(numericVector2(indices(i)-m+1)~=0)
            break;
        else
            numericVector2(indices(i)-m+1) = -1*m;
            left = left-1;
            m = m+1;
        end
    end
    % iterate to right
    while (right>0)
        if(numericVector2(indices(i)+n)~=0)
            break;
        else
            numericVector2(indices(i)+n) = n;
            right = right-1;
            n = n + 1;
        end
    end
end

end

