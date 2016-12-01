function [avgval,stddev] = avgval(map,ntimes)
% Simple function to get the mean/std out of a ROI in a plot.
for l=1:ntimes
    imagesc(map);colormap('hot')
    BW=roipoly(); % Create a mask to do calculations with
    dim=size(BW);
    n_pixels=sum(sum(BW));    % Number of pixel in the ROI
    sum_pixels=0;
    for j=1:dim(1)
        for k=1:dim(2)
            if BW(j,k)==1
                sum_pixels=sum_pixels+map(j,k);
            end
        end
    end
    
    avgval(l)=sum_pixels/n_pixels;
    
    % Calculate standard deviation.
    dev=0; % Deviation
    for j=1:dim(1)
        for k=1:dim(2)
            if BW(j,k)==1
                dev=dev+abs(map(j,k)-avgval(l));
            end
        end
    end
    
    stddev(l)=dev/n_pixels;
    
end

% END
end