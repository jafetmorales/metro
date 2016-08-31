clear all;
close all;
clc;

loadPath='C:\Users\nnf001\Desktop\SSP\FinalProject\yData.mat';
load(loadPath,'y');

% KNOWN PARAMETERS
sig1=30%1;
sig2=30%1;
% PRIOR PARAMETERS
mup1=110%50%80%-2;
mup2=140%130%170%2;
sigp1=20%40%.1;
sigp2=20%40%.1;
lambdap=.10;
% INITIAL VALUES
mu1(1)=40*randn(1,1)+mup1;%20*randn(1,1)+80;%.5*randn(1,1)-2;
mu2(1)=40*randn(1,1)+mup2;%20*randn(1,1)+170;%.5*randn(1,1)+2;
lambda(1)=randn(1,1)+lambdap;
for t=2:100000%WAS 100000
    %JUMPING FUNCTIONS (THESE I OBTAINED FROM PRIOR). I TRIED OTHER FUNCTIONS AND THEY WORKED BUT TOOK LONGER TO CONVERGE.
    mu1_star=sigp1*randn(1,1)+mup1;%20*randn(1,1)+80;%.5*randn(1,1)-2;
    mu2_star=sigp2*randn(1,1)+mup2;%20*randn(1,1)+170;%.5*randn(1,1)+2;
    lambda_star=randn(1,1)+lambdap;
    numerator=mixturePosterior(y,mu1_star,mu2_star,lambda_star,sig1,sig2,mup1,mup2,sigp1,sigp2);
    denominator=mixturePosterior(y,mu1(end),mu2(end),lambda(end),sig1,sig2,mup1,mup2,sigp1,sigp2);
    alpha=numerator/denominator;
    if(alpha>=1)
        mu1(length(mu1)+1)=mu1_star;
        mu2(length(mu2)+1)=mu2_star;
        lambda(length(lambda)+1)=lambda_star;
    else
        u=rand(1,1);
        if(u<alpha)
            mu1(length(mu1)+1)=mu1_star;
            mu2(length(mu2)+1)=mu2_star;
            lambda(length(lambda)+1)=lambda_star;
        end
    end
    t
end

figure(100);stem(mu1);
axis([0 length(mu1) 0 256]);
title('Accepted mu1 samples');
ylabel('level');
xlabel('sample #');

figure(101);stem(mu2);
axis([0 length(mu2) 0 256]);
title('Accepted mu2 samples');
ylabel('level');
xlabel('sample #');

figure(103);stem(lambda);
axis([0 length(lambda) 0 1]);
title('Accepted lambda samples');
ylabel('level');
xlabel('sample #');

noisySignalPath='C:\Users\nnf001\Desktop\SSP\FinalProject\house_noisy.tif';
img=imread(noisySignalPath);
imgRec=medfilt2(img,[3 3]);
thresh=(mu1(end)+mu2(end))/2;
imgRec(imgRec>thresh)=mu2(end);
imgRec(imgRec<=thresh)=mu1(end);
figure(104);imshow(imgRec,[0 255]);

denoisedSignalPath='C:\Users\nnf001\Desktop\SSP\FinalProject\house_denoised_mh.tif';
imwrite(uint8(imgRec),denoisedSignalPath,'tif','Compression','none');



