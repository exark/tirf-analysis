function [results] = loadImage

CFPch = 1;
FRETch = 2;
YFPch = 3;
Tagch = 4;

num_channels=4;

[f, p] = uigetfile('*.tif','Select your movie:');

prompt = {'How many slices?'};
defAns = {'1'};

answer = inputdlg(prompt,'Input Params',1,defAns);
num_slices = str2num(answer{1});

header = imfinfo([p f]);

num_frames = size(header,1)/(num_channels*num_slices);

CFP = zeros(512,512,num_frames);
FRET = zeros(512,512,num_frames);
YFP = zeros(512,512,num_frames);
Tag = zeros(512,512,num_frames);

gaussian_filter = fspecial('gaussian',[6 6],2);
% Disable warning from 
warning('off','MATLAB:imagesci:tiffmexutils:libtiffErrorAsWarning')
for i=1:num_frames
    CFP(:,:,i) = imfilter(imadjust(mat2gray(imread([p f],'Index',CFPch+(i-1)*num_channels))),gaussian_filter,'same');
    FRET(:,:,i) = imfilter(imadjust(mat2gray(imread([p f],'Index',FRETch+(i-1)*num_channels))),gaussian_filter,'same');
    YFP(:,:,i) = imfilter(imadjust(mat2gray(imread([p f],'Index',YFPch+(i-1)*num_channels))),gaussian_filter,'same');
    Tag(:,:,i) = imfilter(imadjust(mat2gray(imread([p f],'Index',Tagch+(i-1)*num_channels))),gaussian_filter,'same');
end
warning('on','all')

CFPm = squeeze(mean(CFP,3));

bgMask = roipoly(CFPm);

CFP = CFP-mean(CFP(bgMask));
CFP(CFP<0)=0;
YFP = YFP-mean(YFP(bgMask));
YFP(YFP<0)=0;
FRET = FRET-mean(FRET(bgMask));
FRET(FRET<0)=0;
Tag = Tag-mean(Tag(bgMask));
Tag(Tag<0)=0;


data.cfp = zeros(num_frames,1);
data.yfp = zeros(num_frames,1);
data.fret = zeros(num_frames,1);
data.tag = zeros(num_frames,1);
for i=1:num_frames
	frameCFP = CFP(:,:,i);
	frameYFP = YFP(:,:,i);
	frameFRET = FRET(:,:,i);
	frameTag = Tag(:,:,i);
	
    data.cfp(i) = mean(frameCFP(frameCFP ~= 0));
	data.yfp(i) = mean(frameYFP(frameYFP ~= 0));
	data.fret(i) = mean(frameFRET(frameFRET ~= 0));
	data.tag(i) = mean(frameTag(frameTag ~= 0));
end

data.ratio = data.fret./data.cfp;

figure()
plot(data.ratio)