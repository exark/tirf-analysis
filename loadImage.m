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
% Disable warning from 
warning('off','MATLAB:imagesci:tiffmexutils:libtiffErrorAsWarning')
for i=1:num_frames
    CFP(:,:,i) = imread([p f],'Index',CFPch+(i-1)*num_channels);
    FRET(:,:,i) = imread([p f],'Index',FRETch+(i-1)*num_channels);
    YFP(:,:,i) = imread([p f],'Index',YFPch+(i-1)*num_channels);
    Tag(:,:,i) = imread([p f],'Index',Tagch+(i-1)*num_channels);
end
warning('on','all')

CFPm = squeeze(mean(CFP,3));
CFPm = (CFPm-min(CFPm(:)))/(max(CFPm(:))-min(CFPm(:)));

bgMask = roipoly(CFPm);
fgMask = roipoly(CFPm);

data.cfp = zeros(num_frames,1);
data.yfp = zeros(num_frames,1);
data.fret = zeros(num_frames,1);
data.tag = zeros(num_frames,1);
for i=1:num_frames
	frameCFP = CFP(:,:,i);
	frameYFP = YFP(:,:,i);
	frameFRET = FRET(:,:,i);
	frameTag = Tag(:,:,i);
	
    data.cfp(i) = mean(frameCFP(fgMask))-mean(frameCFP(bgMask));
	data.yfp(i) = mean(frameYFP(fgMask))-mean(frameYFP(bgMask));
	data.fret(i) = mean(frameFRET(fgMask))-mean(frameFRET(bgMask));
	data.tag(i) = mean(frameTag(fgMask))-mean(frameTag(bgMask));
end

data.ratio = data.fret./data.cfp
