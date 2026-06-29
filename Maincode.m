
clc
clear all
close all
Adj=1;
global test_image
%------------ Image Reading ------------------------------------------
[FILENAME PATHNAME]=uigetfile('*.tiff;*.bmp','Select the Image');
FilePath=strcat(PATHNAME,FILENAME);
disp('The Image File Location is');
disp(FilePath);
[DataArray,map]=imresize(imread(FilePath),[256,256]);
figure,imshow(DataArray,map);
title('Original  image');
[rows,columns,c]=size(DataArray);
sum=0;
if(c==3)
DataArray=rgb2gray(DataArray);
end
DataImg=DataArray;
% Key Generation
d_key  = input('Enter key between 0.2 and 0.9\n');
key = keyGen(size(DataArray,1)*size(DataArray,2),d_key);
% disp('Generated Key');
% disp(key);
encrypted_Image = Encrypt(DataArray,key);
figure,imshow(encrypted_Image)
title('Encrypted Image')
test_image=DataImg;
im=double(test_image);

[heigth,width]=size(im);
%--
T=80;
k=0;map=zeros(heigth,width/2);C=[];
Csign=zeros(heigth,width/2);   
for i=1:heigth
    for j=1:2:width
        l=floor((im(i,j)+im(i,j+1))/2);
        h=im(i,j)-im(i,j+1);
        if abs(2*h+1)<=min(2*(255-l),2*l+1) &&abs(2*h)<=min(2*(255-l),2*l+1)  
            if h==0||h==-1   
                map(i,(j+1)/2)=1;
            else           
                if h<=T   
                     map(i,(j+1)/2)=1;
                else     
                     map(i,(j+1)/2)=0;   
                     k=k+1;
                     C(k)=mod(h,2); 
                     Csign(i,(j+1)/2)=1;
                end
            end           
        else   
            if abs(2*floor(h/2)+1)<=min(2*(255-l),2*l+1)&& abs(2*floor(h/2))<=min(2*(255-l),2*l+1)   
                map(i,(j+1)/2)=0;
                k=k+1;
                C(k)=mod(h,2);
                Csign(i,(j+1)/2)=1;
            else   
                map(i,(j+1)/2)=0;
            end  
        end
        im(i,j)=l;
        im(i,j+1)=h;
    end
end
im1=im;
cimdata2=bitxor(uint8(im),reshape(key,size(DataImg,1),size(DataImg,2)));
cim1=imresize(cimdata2,0.5);
figure,imshow(uint8(cim1));
title('Mapping Image')

block_width = 4;
block_height = 4;
[width,height] = size(uint8(im));
grid_width = width / block_width;
grid_height = height / block_height;
seg_Data= segment(uint8(im),grid_width,grid_height,block_width,block_height);
[hcode8] = huffmanencoding(seg_Data);
CODE1=num2str(hcode8);
Hashvalue=strrep(CODE1,' ','');
disp('--Stage1-Message---');
disp(Hashvalue); 
B=hcode8;
Slength=length(B);
k=length(B);
for i=1:heigth
    for j=1:2:width
        if k<Slength;
            if map(i,(j+1)/2)==1
                k=k+1;
                im(i,j+1)=im(i,j+1)*2+B(k);
            elseif  map(i,(j+1)/2)==0 &&  Csign(i,(j+1)/2)==1
                k=k+1;
                im(i,j+1)=floor(im(i,j+1)/2)*2+B(k);
            end
        end
        x=im(i,j)+floor((im(i,j+1)+1)/2);   
        y=im(i,j)-floor(im(i,j+1)/2); 
        im(i,j)=x;im(i,j+1)=y;
    end
end

cim2=imresize(bitxor(uint8(im),reshape(key,size(DataImg,1),size(DataImg,2))),0.5);
figure,imshow(uint8(cim2));
title('Stage1 Data Embedding Image');
% Stage 2 Ordered Embedding
mapping=reshape(map,1,[]);
[val,len]=rle(mapping);
L=val;
lengthL=size(val,2);
lengthC=size(C,2);
% Data Encryption
Msg=input('Enter the string or word or character to be embedded in single qoutes........           ','s');
% Msg=strcat(Msg,'_',num2str(Pk),'_',num2str(d));
disp('Message');
disp(Msg);
MsgLength=length(Msg);
disp('Message Length');
disp(MsgLength);
Msg=uint8(Msg);
Key12=input('Enter Key to Encrypt data');
EncMsg=bitxor(Msg,Key12);
disp('--Stage2-Message---');
disp(char(EncMsg));
TotalBitstobeEmbed=MsgLength*8;
MsgBitStream=zeros(1,TotalBitstobeEmbed);
for i=0:MsgLength-1
    for j=0:8-1
        BitData=bitand(EncMsg(1,i+Adj),2^(7-j));
        if(BitData>0)
            MsgBitStream(1,i*8+j+Adj)=1;
        else
            MsgBitStream(1,i*8+j+Adj)=0;
        end
    end
end
E= MsgBitStream;
P=reshape(E,1,[]);
lengthP=size(P,2);
Slength=lengthL+lengthC+lengthP;
B=[L,C,P];
k=0;
im=im1;
for i=1:heigth
    for j=1:2:width
        if k<Slength;
            if map(i,(j+1)/2)==1
                k=k+1;
                im(i,j+1)=im(i,j+1)*2+B(k);
            elseif  map(i,(j+1)/2)==0 &&  Csign(i,(j+1)/2)==1
                k=k+1;
                im(i,j+1)=floor(im(i,j+1)/2)*2+B(k);
            end
        end
        x=im(i,j)+floor((im(i,j+1)+1)/2);   
        y=im(i,j)-floor(im(i,j+1)/2); 
        im(i,j)=x;im(i,j+1)=y;
    end
end
cim3=bitxor(uint8(im),reshape(key,size(DataImg,1),size(DataImg,2)));
cim1=imresize(cim3,0.5);
figure,imshow(uint8(cim1));
title('Stage2 Data Embedding Image');
imwrite(cim3,'Embedded.bmp');
save data.mat len Slength lengthC cim3 cimdata2

Slength=lengthL+lengthC+lengthP;
decrypted_Image = Decrypt(im,key);
im=bitxor(uint8(cim3),reshape(key,size(DataImg,1),size(DataImg,2)));
figure,imshow(uint8(im));
title('Directly Decrypted Image');

orignal=DataImg;

ImH=heigth;
ImW=width;
m=0;
%% Compute Total Payload & PSNR
MSE=0.0; 
for i=1:ImH
     for j=1:ImW
         MSE=MSE+abs(double(DataImg(i,j))-double(im(i,j)))^2;
     end
 end
 MSE=MSE/((double(ImH))*(double(ImW)));
 PSNR=10.0*log10((255.0*255.0)/MSE);
disp('----------------------------------------------------------------');
str = sprintf('Payload(bpp) = %f ----- Total bits = %d',Slength/(size(im,1)*size(im,2)),Slength);
disp(str);
disp('----------------------------------------------------------------');
disp('The Mean Square Error is')
disp(MSE);
disp('The PSNR is')
disp(PSNR);
 %---------------Retrieval---------------
 Start=input('Enter Any Key...........');
 disp('Process start....');
 extraction