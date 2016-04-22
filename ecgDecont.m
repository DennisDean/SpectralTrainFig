function cleanSigCell=ecgDecont(sigCell,fs,ecg,fsecg,signalLabels)
rr=PTdetector(ecg,fsecg,0.3);
% now check the quality of the ECG signal
[rr2,perc]=outlier_removal_qual(rr);
if perc<30
    rr=rr2;
    R_t=rr(:,1); %locations of R peaks in seconds
    for jj=1:length(sigCell)
        fprintf('\t\tCleaning: %s\n',signalLabels{jj});
        [clean,nois]=ekgsuppressionMODfilt(sigCell{jj},ecg,fs,fsecg,R_t,0);
        am=rms(sigCell{jj});
        c=1;
        rm=rms(nois)/am;
        while (rm>0.01 && c<10)
            [cclean,nois]=ekgsuppressionMODfilt(sigCell{jj},ecg,fs,fsecg,R_t,0);
            if rms(nois)/am>=rm
                rm=0;
            else
                rm=rms(nois)/am;
                c=c+1;
                clean=cclean;
            end
        end
        cleanSigCell{jj}=clean;
    end
else
    display('ECG too noisy: I will skip decontamination step')
    cleanSigCell=sigCell;
end
end
function varargout = PTdetector(varargin)
% rr=PTdetector(ECG,fs,refrat)
%
% R peak detector via Pan&Tompkins algorithm
% Required Parameters:
% ECG
%       ECG signal (mV or uV), column vector
% fs
%       ECG sampling rate (Hz)
%
% Optional Parameters:
% refrat
%        estimated refractariety time: cannot find beats closer
%        than this interval (default=0.3)
%
% Output:
% rr
%         2 column array: first column contains time instants of R peaks
%         (s), second column contains RR intervals
%
% please report bugs/questions at smariani@partners.com
% endOfHelp

%Set default pararameter values
inputs={'ECG','fs','refrat'};
outputs={'rr'};
Ninputs=length(inputs);
if nargin>Ninputs
    error('Too many input arguments')
end
if nargin<2
    error('Not enough input arguments')
end
refrat=0.3;
for n=1:nargin
    eval([inputs{n} '=varargin{n};'])
end

Noutputs=length(outputs);
if nargout>Noutputs
    error('Too many output arguments')
end

Q = 5;
mov_avg_win = round(0.125*fs);
t=(1:length(ECG))'/fs;
%% - Bandpass
n = 100;
fc = 17;
BW = fc/Q;
band = [(fc-BW/2)*2/fs (fc+BW/2)*2/fs];
b = fir1(n,band);
y = filtfilt(b,1,ECG);

% - Derivative
H = [1/5 1/10 0 -1/10 -1/5];
y = filtfilt(H,1,y);

% - Square
y = y.^2;

% - Moving Average
N = mov_avg_win;
H(1:N) = 1/N;
y = filtfilt(H,1,y);
for h=1:length(y(1,:))
    y(:,h) = y(:,h)./max(y(:,h));
end
thr=median(y);
%% - Detect R peaks
s = zeros(size(ECG,1),1);
s(y > thr) = 1;

dif = s(2:end) - s(1:end-1);
pos1(:,1) = find(dif == 1)+1;
pos2(:,1) = find(dif == -1);

if length(pos1) > length(pos2)
    pos1(end,1) =[];
elseif length(pos1) < length(pos2)
    pos2(1,1) = [];
end

pos = [pos1 pos2];
rr=zeros(length(pos),1);
for j = 1:size(pos,1)
    times = t(pos(j,1):pos(j,2));
    window = abs(ECG(pos(j,1):pos(j,2)));
    [~,n]=max(window);
    rr(j,1)=times(n,1);
end

pos = find(diff(rr(:,1)) < refrat);
rr(pos+1) = [];

rr = repmat(rr,[1 2]);
rr(2:end,2) = diff(rr(:,1));

for n=1:nargout
    eval(['varargout{n}=' outputs{n} ';'])
end
end

function [rr2,perc]=outlier_removal_qual(rr)
%removes outliers in the RR series and corresponding samples in the EDR
%series - employes a sliding window average filter with a length of 41 data
%points. Central points lying outside 20% of the window average are
%rejected

rr2=rr;
% limits rejection
p1=numel(find(rr2(:,2)>2 | rr2(:,2)<0.4));
rr2(rr2(:,2)>2 | rr2(:,2)<0.4,:)=[];
% mirror last 40 samples to avoid filter boundary effects
r=[rr2(:,2); rr2(end:-1:end-39,2)];
% averaging filter
w=ones(41,1)./40;
w(21)=0;
avg=filtfilt(w,1,r);
rr2((rr2(:,2)>avg(1:length(rr2))*1.2 | rr2(:,2)<avg(1:length(rr2))*0.8),2)=999;

perc=(numel(find(rr2(:,2)==999))+p1)/length(rr)*100;
%display(['I just removed the ' num2str(perc) '% of outliers from the RR'])
rr2(rr2(:,2)==999,:)=[];
end

function [cleaneeg, nois]=ekgsuppressionMODfilt(eeg,ekg,fseeg,fsekg,R_t,figflag)
% on 2/9/16 I added figflag as an input and nois as an output
% created 2/5/16 to address variable artifact and I added a filter
% detrend EEG
eeg=detrend(eeg);
% resample ekg at same frequency as eeg
time=[1:length(eeg)]/fseeg;
ekgg=interp1([1:length(ekg)]/fsekg,ekg,time);
% figure
% ax(1)=subplot(211); plot(time, eeg);
% ax(2)=subplot(212); plot(time, ekgg);
% linkaxes(ax,'x')
% detect R spikes
R_t=round(R_t*fseeg); %time in samples
rr=diff(R_t);
% select windows on noisy eeg: start 200 ms before trigger
% end 200 ms before the next trigger. The windows will have
% different length, so I add zeros elsewhere
sz=min(max(rr),2*fseeg);
mat=zeros(length(R_t)-1,sz)+NaN;
lim=round(0.2*fseeg); %200 ms in samples
B=fir1(300,[15/fseeg*2 19/fseeg*2]);
e=filtfilt(B,1,eeg);
ampli=abs(e(R_t)); % this is the amplitude of the eeg at each heart beat
ampli=smooth(ampli,5);
ampli=ampli/mean(ampli);
for j=2:length(R_t)-1
    % check if distance is > 2s
    if R_t(j+1)-R_t(j)<(2*fseeg) & R_t(j+1)-R_t(j)>(lim)
        win=eeg(R_t(j)-lim:R_t(j+1)-lim);
    else
        try
            win=eeg(R_t(j)-lim:R_t(j)+lim);
        catch
            win=eeg(R_t(j)-lim:end);
        end
    end
    mat(j,1:length(win))=win;
end
mat(1,:)=[];

% average my windows to produce mean EKG artifact

% for each column, find how many points contributed
n=sum(~isnan(mat));
art=nanmean(mat).*n/length(mat); %Shaun's modification: this way I only weight points that are
%actually there
art=art';
art(isnan(art))=0;
% figure
if figflag
    plot([1:length(art)]/fseeg,art/1000)
    xlim([0 1])
    xlabel('time (s)')
    ylabel('mV')
    set(gca,'Fontsize',18)
end
% concatenate artifact windows to produce artifact signal
nois=zeros(size(eeg));
for j=1:length(R_t)-1
    try
        nois(R_t(j)-lim:R_t(j)-lim+rr(j)-1)=art(1:rr(j))*ampli(j);
    end
end
cleaneeg=eeg-nois;
if figflag
    figure
    ax(1)=subplot(411); plot(time,eeg);
    ylim([-0.1 0.1])
    title('EEG')
    %set(gca,'Fontsize',18)
    ylabel('mV')
    ax(2)=subplot(412); plot(time,ekgg);
    ylim([-1.5 1.5])
    title('ECG')
    %set(gca,'Fontsize',18)
    ylabel('mV')
    ax(3)=subplot(413); plot(time,nois);
    ylim([-0.1 0.1])
    title('artifact on EEG')
    ylabel('mV')
    ax(4)=subplot(414); plot(time,cleaneeg);
    title('denoised EEG')
    ylim([-0.1 0.1])
    %set(gca,'Fontsize',18)
    ylabel('mV')
    xlabel('Time (s)')
    linkaxes(ax,'x')
end
end
