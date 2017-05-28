function res = dynamic_indexing(A,b,c)
% A is input matrix where to get all entries from besides dimension b.
% From dimension b only get element c
% So function performs res = A(:,:,2) for b=3 and c=2.

sz=size(A);

if b == 0  || b > numel(sz)
    res=A;
    return
end

inds=repmat({1},1,ndims(A));
for n=1:numel(sz);inds{n}=1:sz(n);end
inds{b}=c;%
res=A(inds{:});

% END
end