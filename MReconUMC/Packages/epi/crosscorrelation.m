function res = crosscorrelation(calib_data)
% Calculate the cross correlation per channel for all the pairs

% Dimensionality
Id=size(calib_data);

% Preallocate shift
shift=zeros([2,Id(4)]);

% Loop over all pairs and do cross correlation
for p=1:Id(2)
    for c=1:Id(4)
        
        % Select pair
        pair=calib_data(:,[1+2*(p-1) 1+2*(p-1)+1],1,c);
        
        % Multiply with complex conjugate
        g=pair(:,1).*conj(pair(:,2));
    end
end
res=[]
% END
end