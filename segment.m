function Farr= segment(Img,grid_width,grid_height,block_width,block_height)
fd=1;
for gx = 1:grid_width
    for gy = 1:grid_height
        cx = (gx-1) * block_width + 1; cy = (gy-1) * block_width + 1;
        posx = cx:cx+block_width-1; posy = cy:cy+block_height-1;
        block = Img(posx, posy);
        if nnz(block) == 0
        else
            CF(:,:,fd)=block(:,:);
            fd=fd+1;
        end
       
    end
end
Farr=zeros(1,size(CF,3));
for id=1:size(CF,3)
Adata=reshape(CF(:,:,id),1,4*4);
Adata(Adata>0)=1;
A=bin2dec(num2str(Adata));
Farr(1,id)=A;
end