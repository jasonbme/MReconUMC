function cost = Objective( data )

tv=abs(squeeze(data));
cost=sum(tv(:));

% END
end