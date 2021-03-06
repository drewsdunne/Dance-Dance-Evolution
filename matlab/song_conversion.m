function b = song_conversion(read1)
%read1 = audioread('trimmed.wav');
%read1 = read1(:,1);
%read1 = downsample(read1,2);
%read1 = round(read1*256); %256 bc 8 bit resolution
bdps = 10; %beat detections per second
%segments = bdps*(length(read1)/22000);

beats = zeros(1,9);

[C, L] = wavedec(read1, 11, 'Haar');
[cd1,cd2,cd3,cd4,cd5,cd6,cd7,cd8,cd9,cd10,cd11] = detcoef(C, L,[1, 2, 3, 4,5,6,7,8,9,10,11]);

if (max(abs(cd3)) >= 400)
    beats(1) = 1;
end
if (max(abs(cd4)) >= 600)
    beats(2) = 1;
end
if (max(abs(cd5)) >= 600)
    beats(3) = 1;
end
if (max(abs(cd6)) >= 1000)
    beats(4) = 1;
end
if (max(abs(cd7)) >= 1500)
    beats(5) = 1;
end
if (max(abs(cd8)) >= 1800)
    beats(6) = 1;
end
if (max(abs(cd9)) >= 1800)
    beats(7) = 1;
end
if (max(abs(cd10)) >= 750)
    beats(8) = 1;
end
if (max(abs(cd11)) >= 750)
    beats(9) = 1;
end
%fprintf('at time %5.2f\n', (1/bdps)*i)
disp(beats)
beats = zeros(1,9);

b = beats;
