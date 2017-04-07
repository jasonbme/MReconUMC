function output = mtimes(cc,data) 

% Deal with multiple temporal frames.
cc.S=double(cc.S);
num_data=numel(data);

for n=1:num_data
    Id=cc.Idim{n};
    if cc.adjoint==1 % S
        for avg=1:Id(12)
        for ex2=1:Id(11)
        for ex1=1:Id(10)
        for mix=1:Id(9)
        for loc=1:Id(8)
        for ech=1:Id(7)
        for ph=1:Id(6)
        for dyn=1:Id(5)
            output{n}(:,:,:,:,dyn,ph,ech,loc,mix,ex1,ex2,avg)=sum(data{n}(:,:,:,:,dyn,ph,ech,loc,mix,ex1,ex2,avg).*conj(cc.S),4);
        end
        end
        end
        end
        end
        end
        end
        end
    else % S^-1
        for avg=1:Id(12)
        for ex2=1:Id(11)
        for ex1=1:Id(10)
        for mix=1:Id(9)
        for loc=1:Id(8)
        for ech=1:Id(7)
        for ph=1:Id(6)
        for dyn=1:Id(5)
            output{n}(:,:,:,:,dyn,ph,ech,loc,mix,ex1,ex2,avg)=repmat(data{n}(:,:,:,1,dyn,ph,ech,loc,mix,ex1,ex2,avg),[1 1 1 Id(4) 1 1 1 1 1 1 1 1]).*cc.S;
        end
        end
        end
        end
        end
        end
        end
        end
        
    end
end

% END
end  
