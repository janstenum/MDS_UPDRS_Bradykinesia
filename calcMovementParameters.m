function calcMovementParameters(output_name,output_path)

load(fullfile(output_path,[output_name '_pose.mat']),'auto_events','timeStamp','bradyKin_segments','data')

fn_auto = fieldnames(auto_events);
fn_lat = fieldnames(auto_events.(fn_auto{1}));
for iii = 1:length(fn_auto)
    for iiii = 1:length(fn_lat)
        temporalParameters.(fn_auto{iii}).(fn_lat{iiii}).movementTimes = diff( timeStamp( ( bradyKin_segments.(fn_auto{iii}).(fn_lat{iiii})(1) - 1 ) + auto_events.(fn_auto{iii}).(fn_lat{iiii}) ) ,1,2);
        temporalParameters.(fn_auto{iii}).(fn_lat{iiii}).meanMovementTimes = nanmean(temporalParameters.(fn_auto{iii}).(fn_lat{iiii}).movementTimes);
        temporalParameters.(fn_auto{iii}).(fn_lat{iiii}).sdMovementTimes = nanstd(temporalParameters.(fn_auto{iii}).(fn_lat{iiii}).movementTimes);
        temporalParameters.(fn_auto{iii}).(fn_lat{iiii}).frequency = 1/temporalParameters.(fn_auto{iii}).(fn_lat{iiii}).meanMovementTimes;
    end
end


for kkk = 1 % finger tapping
    for kkkk = 1:length(fn_lat)
        amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).cycleAmplitudes = ...
            eval(['sqrt(sum(diff(data.mediapipe.' fn_auto{kkk} '.' fn_lat{kkkk} '.pose.hand.' fn_lat{kkkk} '.filt(auto_events.' fn_auto{kkk} '.' fn_lat{kkkk} ',[5 9],:),1,2).^2,3)) ./ sqrt(sum(diff(data.openpose.' fn_auto{kkk} '.' fn_lat{kkkk} '.pose.body.filt(auto_events.' fn_auto{kkk} '.' fn_lat{kkkk} ',[2 9],:),1,2).^2,3));']);
        
        amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).meanCycleAmplitudes = nanmean(amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).cycleAmplitudes);
        amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).sdCycleAmplitudes = nanstd(amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).cycleAmplitudes);
        
        mdl_temp = fitlm(1:length(amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).cycleAmplitudes),amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).cycleAmplitudes);
        amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).slopeCycleAmplitudes = table2array(mdl_temp.Coefficients(2,1));
    end
end

for kkk = 2 % hand open/close
    for kkkk = 1:length(fn_lat)
        amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).cycleAmplitudes = ...
            eval(['nanmean([sqrt(sum(diff(data.mediapipe.' fn_auto{kkk} '.' fn_lat{kkkk} '.pose.hand.' fn_lat{kkkk} '.filt(auto_events.' fn_auto{kkk} '.' fn_lat{kkkk} ',[5 9],:),1,2).^2,3)) sqrt(sum(diff(data.mediapipe.' fn_auto{kkk} '.' fn_lat{kkkk} '.pose.hand.' fn_lat{kkkk} '.filt(auto_events.' fn_auto{kkk} '.' fn_lat{kkkk} ',[5 13],:),1,2).^2,3)) sqrt(sum(diff(data.mediapipe.' fn_auto{kkk} '.' fn_lat{kkkk} '.pose.hand.' fn_lat{kkkk} '.filt(auto_events.' fn_auto{kkk} '.' fn_lat{kkkk} ',[5 17],:),1,2).^2,3)) sqrt(sum(diff(data.mediapipe.' fn_auto{kkk} '.' fn_lat{kkkk} '.pose.hand.' fn_lat{kkkk} '.filt(auto_events.' fn_auto{kkk} '.' fn_lat{kkkk} ',[5 21],:),1,2).^2,3))],2) ./ sqrt(sum(diff(data.openpose.' fn_auto{kkk} '.' fn_lat{kkkk} '.pose.body.filt(auto_events.' fn_auto{kkk} '.' fn_lat{kkkk} ',[2 9],:),1,2).^2,3));']);
        
        amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).meanCycleAmplitudes = nanmean(amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).cycleAmplitudes);
        amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).sdCycleAmplitudes = nanstd(amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).cycleAmplitudes);
        
        mdl_temp = fitlm(1:length(amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).cycleAmplitudes),amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).cycleAmplitudes);
        amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).slopeCycleAmplitudes = table2array(mdl_temp.Coefficients(2,1));
    end
end

plot_bradyKin_coor = {'[5 9]','[5 9]';'[5 9]','[5 9]';'[5]','[5]';'[23 20]','[20 23]';'[25 22]','[22 25]'};
for kkk = 4 % toe tapping
    for kkkk = 1:length(fn_lat)
        amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).cycleAmplitudes = ...
            eval(['diff(data.openpose.' fn_auto{kkk} '.' fn_lat{kkkk} '.pose.body.filt(auto_events.' fn_auto{kkk} '.' fn_lat{kkkk} ',[' plot_bradyKin_coor{kkk,kkkk} '],2),1,2) ./ diff(data.openpose.' fn_auto{kkk} '.' fn_lat{kkkk} '.pose.body.filt(auto_events.' fn_auto{kkk} '.' fn_lat{kkkk} ',[2 9],2),1,2);']);
        
        amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).meanCycleAmplitudes = nanmean(amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).cycleAmplitudes);
        amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).sdCycleAmplitudes = nanstd(amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).cycleAmplitudes);
        
        mdl_temp = fitlm(1:length(amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).cycleAmplitudes),amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).cycleAmplitudes);
        amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).slopeCycleAmplitudes = table2array(mdl_temp.Coefficients(2,1));
    end
end

for kkk = 5 % leg agility
    for kkkk = 1:length(fn_lat)
        amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).cycleAmplitudes = ...
            eval(['diff(data.openpose.' fn_auto{kkk} '.' fn_lat{kkkk} '.pose.body.filt(auto_events.' fn_auto{kkk} '.' fn_lat{kkkk} ',[' plot_bradyKin_coor{kkk,kkkk} '],2),1,2) ./ diff(data.openpose.' fn_auto{kkk} '.' fn_lat{kkkk} '.pose.body.filt(auto_events.' fn_auto{kkk} '.' fn_lat{kkkk} ',[2 9],2),1,2);']);
        
        amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).meanCycleAmplitudes = nanmean(amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).cycleAmplitudes);
        amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).sdCycleAmplitudes = nanstd(amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).cycleAmplitudes);
        
        mdl_temp = fitlm(1:length(amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).cycleAmplitudes),amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).cycleAmplitudes);
        amplitudeParameters.(fn_auto{kkk}).(fn_lat{kkkk}).slopeCycleAmplitudes = table2array(mdl_temp.Coefficients(2,1));
    end
end

save(fullfile(output_path,[output_name '_pose.mat']),'temporalParameters','amplitudeParameters','-append')
end