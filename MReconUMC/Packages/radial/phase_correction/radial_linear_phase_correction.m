function radial_linear_phase_correction( MR,n )
% Recreate reconframes phase correction function 


% Get dimensions for data handling
dims=MR.UMCParameters.AdjointReconstruction.KspaceSize{n};
kpos=MR.Parameter.Gridder.Kpos{n};
data=MR.Data{n};MR.Data{n}=[];

zero2pi=0;
signs=zeros(length(MR.Parameter.Gridder.RadialAngles{n}),1);
radial_angles=mod( MR.Parameter.Gridder.RadialAngles{n},2*pi);
if ~isempty( radial_angles )
    even_profiles=radial_angles > 0 & radial_angles < pi;
    odd_profiles=radial_angles > pi & radial_angles < 2*pi;

    if length( find( even_profiles ) ) ~= length( find( odd_profiles ) ) && mod( length( find( radial_angles == 0 ) ), 2 )
        if length( find( even_profiles ) ) > length( find( odd_profiles ) )
            radial_angles( radial_angles == 0 ) = 2 * pi;
            zero2pi = 1;
        end
    end
    even_profiles = radial_angles >= 0 & radial_angles < pi;
    odd_profiles = radial_angles > pi & radial_angles <= 2 * pi;
end
signs(even_profiles)=1;
signs(odd_profiles)=-1;

radial_angles=mod(radial_angles,pi);
if zero2pi
    radial_angles(radial_angles == 0)=pi;
end

[sorted_angles, ind_sorted]=sort(radial_angles);
signs=signs(ind_sorted);
ind_even=find(signs==1);
ind_odd=find(signs==-1);
l=min([length(ind_even), length(ind_odd)]);
ind_even=ind_even(1:l);
ind_odd=ind_odd(1:l);

data=MRecon.k2i(data, 1, 1 );

linPhase = sum( bsxfun( @times, data( 1:end  - 2, ind_sorted( ind_even ), :, :, : ), conj( data( 2:end  - 1, ind_sorted( ind_even ), :, :, : ) ) ) );
linPhase2 = sum( bsxfun( @times, data( 1:end  - 2, ind_sorted( ind_odd ), :, :, : ), conj( data( 2:end  - 1, ind_sorted( ind_odd ), :, :, : ) ) ) );

linPhase = linPhase ./ abs( linPhase );
linPhase( isnan( linPhase ) ) = 0;
linPhase = angle( linPhase );
linPhase2 = linPhase2 ./ abs( linPhase2 );
linPhase2( isnan( linPhase2 ) ) = 0;
linPhase2 = angle( linPhase2 );
linPhaseavr = ( linPhase + linPhase2 ) / 2;




linPhaseavr = median( linPhaseavr, 2 );

phase_off =  - size( data, 2 ) * linPhaseavr;
data( :, ind_sorted( ind_even ), :, :, : ) = bsxfun( @times, data( :, ind_sorted( ind_even ), :, :, : ), exp( 1i .* bsxfun( @plus, bsxfun( @times, ( 0:( size( data, 1 ) - 1 ) )', linPhaseavr ), phase_off ) ) );
data( :, ind_sorted( ind_odd ), :, :, : ) = bsxfun( @times, data( :, ind_sorted( ind_odd ), :, :, : ), exp( 1i .* bsxfun( @plus, bsxfun( @times, ( 0:( size( data, 1 ) - 1 ) )', linPhaseavr ), phase_off ) ) );


absPhase = sum( data( 1:end  - 1, :, :, :, : ), 1 );



[ ma, ind_max ] = max( reshape( abs( sum( sum( absPhase( :, :, :, :, : ), 2 ), 5 ) ), [  ], 1 ) );
[ sl, co ] = ind2sub( [ size( absPhase, 3 ), size( absPhase, 4 ) ], ind_max );
absPhase = absPhase( :, :, sl, co, : );
absPhase = absPhase ./ abs( absPhase );
absPhase( isnan( absPhase ) ) = 0;

absPhase = angle( absPhase );
absPhasem = sum( sum( absPhase( :, :, :, :, : ), 2 ), 5 );
absPhasem = absPhasem ./ ( 1 * size( absPhase( :, :, :, :, : ), 5 ) );
absPhase = bsxfun( @minus, absPhase, absPhasem );
data( :, :, :, :, : ) = bsxfun( @times, data( :, :, :, :, : ), exp( 1i * ( bsxfun( @plus,  - absPhase, absPhasem ) ) ) );

data = MRecon.i2k( data, 1, 1 );

MR.Data{n}=data;

% END
end
            