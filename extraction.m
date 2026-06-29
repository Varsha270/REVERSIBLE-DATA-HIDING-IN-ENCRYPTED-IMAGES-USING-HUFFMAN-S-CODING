%%%%%%%%=%%%%%%%%%%%%Extraction===============
% close all;
% clear all;
% clc;
global test_image
%Intialization========
Adj=1;
load data.mat
im = imread('Embedded.bmp');
im1=im;
d_key  = input('Enter key between 0.2 and 0.9\n');
key = keyGen(256*256,d_key);
im=bitxor(uint8(cim3),reshape(key,256,256));
im=double(im);
Llen=len;
[heigth,width]=size(im);
[ImH,ImW]=size(im);
embeddata=[];k=0;
mapdata=zeros(ImH,ImW/2);
for i=1:heigth
    for j=1:2:width
        l=floor((im(i,j)+im(i,j+1))/2);
        h=im(i,j)-im(i,j+1);
        if k<Slength
            %         sign1=(abs(h)<=min(2*(255-l),2*l+1)); 
            sign2=(abs(2*floor(h/2)+1)<=min(2*(255-l),2*l+1) && abs(2*floor(h/2))<=min(2*(255-l),2*l+1));  
            if sign2==1
                mapdata(i,(j+1)/2)=1;
                k=k+1;
                embeddata(k)=mod(h,2); 
            end
        end
        im(i,j)=l;
        im(i,j+1)=h;
    end
end
lengthL=size(Llen,2);     
if length(embeddata) < lengthL
    error('Insufficient embedded data for extraction. Ensure the embedding process completed successfully.');
end
L = embeddata(1:lengthL);
mapping=rld(L,Llen);  
Map=reshape(mapping,ImH,ImW/2);
C=embeddata(lengthL+1 : lengthL+lengthC); 
P=embeddata(1+lengthL+lengthC :end); 
L=length(P);
TotalBitstobeEmbed=L;
ByteStream=zeros(1,TotalBitstobeEmbed/8);
for k=0:8:TotalBitstobeEmbed-1
    SumValue=0;
    for l=0:8-1
        SumValue=SumValue+P(1,k+l+Adj)*(2^(7-l));
    end
    ByteStream(1,fix(k/8)+Adj)=SumValue;
end
DecMsg=ByteStream;
Key12=input('Enter Key to Decrypt data');
DecMsg=bitxor(DecMsg,Key12);
DecMsg=char(DecMsg);
expression = '_';
splitStr = regexp(DecMsg,expression,'split');
disp('Decrypted Secret Message');
disp(char(splitStr(1)));

disp('---------Decryption and Reversible Transformation');
% decrypted_Image = Decrypt(im,key);
im=bitxor(cimdata2,reshape(key,size(DataImg,1),size(DataImg,2)));

% Reversible Transformation
m=0;
 for i=1:ImH
     for j=1:2:ImW
         if mapdata(i,(j+1)/2)==1
%              k=k+1;
             if Map(i,(j+1)/2)==1
                im(i,j+1)=floor(im(i,j+1)/2);
             else
                 if m<lengthC
                     m=m+1;
                     im(i,j+1)=2*floor(im(i,j+1)/2)+C(m);
                 end
             end
         end
        x=im(i,j)+floor((im(i,j+1)+1)/2);  
        y=im(i,j)-floor(im(i,j+1)/2); 
        im(i,j)=x;im(i,j+1)=y;
     end
 end
 figure,imshow(uint8(im));title('Retrival Image');  
orignal = imread(FilePath);
  MSE=0.0;
 for i=1:ImH
     for j=1:ImW
         MSE=MSE+abs(double(test_image(i,j))-double(im(i,j)))^2;
     end
 end
 MSE=MSE/((double(ImH))*(double(ImW)));
 PSNR=10.0*log10((255.0*255.0)/MSE);
 if(PSNR>=30)
     MSE=0;
     PSNR='Inf';
 else
     
 end
 disp('The Mean Square Error is')
 disp(MSE);
 disp('The PSNR is')
 disp(PSNR);