function findEvents(output_name,output_path)
global frame h_axes_image h_image videoInfo hCursor subCheck_axes check_fig startTrackFrame endTrackFrame noFrames_inspection trackedFrames h_slider h_frameBox auto_events lateral subCheck_data bradyKin_items data subDim manual_events ...
    subCheck_events_manual output_name_title subCheck_events bg_poseVid output_path_global manual_events auto_events
frame = [];

output_path_global = [];
output_path_global = output_path;
output_name_title = [];
output_name_title = output_name;

load(fullfile(output_path,[output_name '_pose.mat']));

startTrackFrame = 1;
endTrackFrame = videoInfo.vid_mediapipe.NumFrames;
trackedFrames = startTrackFrame:endTrackFrame;
noFrames_inspection = length(trackedFrames);

check_fig = figure; set(check_fig,'WindowState','maximized');
[subDim] = [5 9];

frame = bradyKin_segments.fingerTap.right(1);

lateral = {'right','left'};
bradyKin_items = fieldnames(bradyKin_analyze);


plot_bradyKin_timeSeries(bradyKin_items,lateral,subDim,bradyKin_segments,data)

h_axes_image = subplot(subDim(1),subDim(2),[7:9 16:18 25:27 34:36]); hold on

auto_events = findAutoEvents(lateral,bradyKin_items,subCheck_axes,bradyKin_segments,manual_events);

hCursor = datacursormode(check_fig); set(hCursor,'UpdateFcn',@myCursor);
datacursormode on

h_slider = uicontrol(check_fig,'style','slider','Min',startTrackFrame,'Max',endTrackFrame,'SliderStep',[1/noFrames_inspection 10/noFrames_inspection],'Value',frame,...
   'units','normalized','Position',[0.63 0.05 0.29 0.025],'Callback',@currentFrame_slider); % choose frame

h_deleteEvent = uicontrol(check_fig,'style','pushbutton','String','Delete Events',...
   'units','normalized','Position',[.7 .25 0.2 0.05],'Callback',@deleteEvent); % pushbutton to delete events
h_createEvent = uicontrol(check_fig,'style','pushbutton','String','Create Events',...
   'units','normalized','Position',[.7 .20 0.2 0.05],'Callback',@createEvent); % pushbutton to create events
h_summaryEvent = uicontrol(check_fig,'Style','pushbutton','String','Summary Plot',...
    'Units','normalized','Position',[.7 .15 0.2 0.05],'Callback',@summPlot);

uicontrol(check_fig,'style','togglebutton','String','Brush',...
   'units','normalized','Position',[.0 .55 0.05 0.05],'Callback',@tgglBrush); % pushbutton to create to events
uicontrol(check_fig,'style','togglebutton','String','Cursor',...
   'units','normalized','Position',[.0 .5 0.05 0.05],'Callback',@tgglCursor); % pushbutton to create to events
uicontrol(check_fig,'style','togglebutton','String','Zoom',...
   'units','normalized','Position',[.0 .45 0.05 0.05],'Callback',@tgglZoom); % pushbutton to create to events
uicontrol(check_fig,'style','togglebutton','String','Pan',...
   'units','normalized','Position',[.0 .4 0.05 0.05],'Callback',@tgglPan); % pushbutton to create to events

uicontrol(check_fig,'style','togglebutton','String','Brush',...
   'units','normalized','Position',[.645 .55 0.03 0.05],'Callback',@tgglBrush); % pushbutton to create to events
uicontrol(check_fig,'style','togglebutton','String','Cursor',...
   'units','normalized','Position',[.645 .5 0.03 0.05],'Callback',@tgglCursor); % pushbutton to create to events
uicontrol(check_fig,'style','togglebutton','String','Zoom',...
   'units','normalized','Position',[.645 .45 0.03 0.05],'Callback',@tgglZoom); % pushbutton to create to events
uicontrol(check_fig,'style','togglebutton','String','Pan',...
   'units','normalized','Position',[.645 .4 0.03 0.05],'Callback',@tgglPan); % pushbutton to create to events

h_showAutoEvents = uicontrol(check_fig,'style','pushbutton','String','Show Auto Events',...
   'units','normalized','Position',[.1 .0 0.2 0.03],'Callback',@tgglAutoEvents); % pushbutton to delete events

h_save = uicontrol(check_fig,'style','pushbutton','string','Save',...
    'units','normalized','position',[.4 .0 .2 .06],'callback',@saveEvents);


bg_poseVid = uibuttongroup(check_fig,'Position',[.01 .125 .05 .1]);
r_mediapipe = uicontrol(bg_poseVid,'Style','radiobutton','String','MediaPipe','units','normalized','Position',[.01 .6 .9 .1],'fontunits','normalized','fontsize',.7,'callback',@tgglPoseVid);
r_openpose = uicontrol(bg_poseVid,'Style','radiobutton','String','OpenPose','units','normalized','Position',[.01 .1 .9 .1],'fontunits','normalized','fontsize',.7,'callback',@tgglPoseVid);
showImage
uiwait

end
%%
function saveEvents(source,event)
global output_path_global output_name_title check_fig auto_events manual_events
fn_auto = fieldnames(auto_events);
lat_auto = {'left','right'};
for iii = 1:length(fn_auto)
   for iiii = 1:length(lat_auto)
       auto_events.(fn_auto{iii}).(lat_auto{iiii}) = reshape(auto_events.(fn_auto{iii}).(lat_auto{iiii}),[],1);
   end
end
save(fullfile(output_path_global,[output_name_title '_pose.mat']),'auto_events','-append');
close(check_fig)
end
%%
function tgglPoseVid(source,event)
showImage
end
%% 
function tgglAutoEvents(source,event)
global subCheck_events bradyKin_segments lateral bradyKin_items

for i = 1:length(fieldnames(bradyKin_segments))
    for j = 1:length(lateral)
        eval(['switch get(subCheck_events.' bradyKin_items{i} '.' lateral{j} ',''Visible''); case ''on''; set(subCheck_events.' bradyKin_items{i} '.' lateral{j} ',''Visible'',''off''); case ''off''; set(subCheck_events.' bradyKin_items{i} '.' lateral{j} ',''Visible'',''on''); end'])
    end
end

end
%% "Summary plot" pushbutton
function summPlot(source,event)
global subCheck_axes h_frameBox frame subCheck_data bradyKin_items lateral subDim bradyKin_segments data subplot_ind auto_events subDim
plot_bradyKin_coor = {'[5 9]','[5 9]';'[5 9]','[5 9]';'[5]','[5]';'[23]','[20]';'[25]','[22]'};
g = [.5 .5 .5];

summ_subplot_ind = {'[2]', '[1]'; '[4]', '[3]'; '[6]', '[5]'; '[8]', '[7]';'[10]', '[9]'};

summFig = figure;set(summFig,'WindowState','maximized');

for i = 1:length(fieldnames(bradyKin_segments))
    for j = 1:length(lateral)
        if strcmp(bradyKin_items{i},'fingerTap') | strcmp(bradyKin_items{i},'handOpenClose')
            eval(['temp_freq = ceil(length(auto_events.' bradyKin_items{i} '.' lateral{j} '(1):auto_events.' bradyKin_items{i} '.' lateral{j} '(end))/(length(auto_events.' bradyKin_items{i} '.' lateral{j} ')-1));'])
            eval(['temp_summ = nan(temp_freq,length(auto_events.' bradyKin_items{i} '.' lateral{j} ')-1);'])
            eval(['for k = 1:length(auto_events.' bradyKin_items{i} '.' lateral{j} ')-1; temp_summ(:,k) = interp1(linspace(0,1,length(auto_events.' bradyKin_items{i} '.' lateral{j} '(k):auto_events.' bradyKin_items{i} '.' lateral{j} '(k+1))),sqrt(sum(diff(data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.' lateral{j} '.filt(auto_events.' bradyKin_items{i} '.' lateral{j} '(k):auto_events.' bradyKin_items{i} '.' lateral{j} '(k+1),[' plot_bradyKin_coor{i,j} '],:),1,2).^2,3)),linspace(0,1,temp_freq),''pchip'');end'])
            eval(['summ_subCheck_axes.' bradyKin_items{i} '.' lateral{j} ' = subplot(5,2,' summ_subplot_ind{i,j} '); hold on'])
            eval(['summ_subCheck_data.' bradyKin_items{i} '.' lateral{j} ' = plot(summ_subCheck_axes.' bradyKin_items{i} '.' lateral{j} ',1:temp_freq,temp_summ,''.-'',''color'',g);'])
        elseif strcmp(bradyKin_items{i},'handProSup') 
            eval(['temp_freq = ceil(length(auto_events.' bradyKin_items{i} '.' lateral{j} '(1):auto_events.' bradyKin_items{i} '.' lateral{j} '(end))/(length(auto_events.' bradyKin_items{i} '.' lateral{j} ')-1));'])
            eval(['temp_summ = nan(temp_freq,length(auto_events.' bradyKin_items{i} '.' lateral{j} ')-1);'])
            eval(['for k = 1:length(auto_events.' bradyKin_items{i} '.' lateral{j} ')-1; temp_summ(:,k) = interp1(linspace(0,1,length(auto_events.' bradyKin_items{i} '.' lateral{j} '(k):auto_events.' bradyKin_items{i} '.' lateral{j} '(k+1))),data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.' lateral{j} '.filt(auto_events.' bradyKin_items{i} '.' lateral{j} '(k):auto_events.' bradyKin_items{i} '.' lateral{j} '(k+1),[' plot_bradyKin_coor{i,j} '],2),linspace(0,1,temp_freq),''pchip'');end'])
            eval(['summ_subCheck_axes.' bradyKin_items{i} '.' lateral{j} ' = subplot(5,2,' summ_subplot_ind{i,j} '); hold on'])
            eval(['summ_subCheck_data.' bradyKin_items{i} '.' lateral{j} ' = plot(summ_subCheck_axes.' bradyKin_items{i} '.' lateral{j} ',1:temp_freq,temp_summ,''.-'',''color'',g);'])
        elseif strcmp(bradyKin_items{i},'toeTap') | strcmp(bradyKin_items{i},'legAgil')
            eval(['temp_freq = ceil(length(auto_events.' bradyKin_items{i} '.' lateral{j} '(1):auto_events.' bradyKin_items{i} '.' lateral{j} '(end))/(length(auto_events.' bradyKin_items{i} '.' lateral{j} ')-1));'])
            eval(['temp_summ = nan(temp_freq,length(auto_events.' bradyKin_items{i} '.' lateral{j} ')-1);'])
            eval(['for k = 1:length(auto_events.' bradyKin_items{i} '.' lateral{j} ')-1; temp_summ(:,k) = interp1(linspace(0,1,length(auto_events.' bradyKin_items{i} '.' lateral{j} '(k):auto_events.' bradyKin_items{i} '.' lateral{j} '(k+1))),data.openpose.' bradyKin_items{i} '.' lateral{j} '.pose.body.filt(auto_events.' bradyKin_items{i} '.' lateral{j} '(k):auto_events.' bradyKin_items{i} '.' lateral{j} '(k+1),[' plot_bradyKin_coor{i,j} '],2),linspace(0,1,temp_freq),''pchip'');end'])
            eval(['summ_subCheck_axes.' bradyKin_items{i} '.' lateral{j} ' = subplot(5,2,' summ_subplot_ind{i,j} '); hold on'])
            eval(['summ_subCheck_data.' bradyKin_items{i} '.' lateral{j} ' = plot(summ_subCheck_axes.' bradyKin_items{i} '.' lateral{j} ',1:temp_freq,temp_summ,''.-'',''color'',g);'])
        end
        if strcmp(lateral{j},'left')
            ylabel({bradyKin_items{i},'Pixel'})
        end
        if i == 1 && strcmp(lateral{j},'left')
           title('Left')
        end
        if i == 1 && strcmp(lateral{j},'right')
           title('Right')
        end  
        if i == 5
           xlabel('Frames') 
        end
        eval(['set(gca,''fontsize'',8,''xlim'',[min(summ_subCheck_axes.' bradyKin_items{i} '.' lateral{j} '.XLim) max(summ_subCheck_axes.' bradyKin_items{i} '.' lateral{j} '.XLim)]);'])
        
    end
end

end
%% "Create" pushbutton
function createEvent(source,event)
global hCursor subCheck_events auto_events subCheck_axes subCheck_data

if ~isempty(getCursorInfo(hCursor)) % check that user has used data cursor
cursorTarget = getCursorInfo(hCursor).Target;
cursorTarget_axes = cursorTarget.Parent;
if subCheck_events.fingerTap.left.Parent == cursorTarget_axes
variableCreate('fingerTap','left',subCheck_axes,subCheck_data)
elseif subCheck_events.fingerTap.right.Parent == cursorTarget_axes
variableCreate('fingerTap','right',subCheck_axes,subCheck_data)
elseif subCheck_events.handOpenClose.left.Parent == cursorTarget_axes
variableCreate('handOpenClose','left',subCheck_axes,subCheck_data)
elseif subCheck_events.handOpenClose.right.Parent == cursorTarget_axes
variableCreate('handOpenClose','right',subCheck_axes,subCheck_data)
elseif subCheck_events.handProSup.left.Parent == cursorTarget_axes
variableCreate('handProSup','left',subCheck_axes,subCheck_data)
elseif subCheck_events.handProSup.right.Parent == cursorTarget_axes
variableCreate('handProSup','right',subCheck_axes,subCheck_data)
elseif subCheck_events.toeTap.left.Parent == cursorTarget_axes
variableCreate('toeTap','left',subCheck_axes,subCheck_data)
elseif subCheck_events.toeTap.right.Parent == cursorTarget_axes
variableCreate('toeTap','right',subCheck_axes,subCheck_data)
elseif subCheck_events.legAgil.left.Parent == cursorTarget_axes
variableCreate('legAgil','left',subCheck_axes,subCheck_data)
elseif subCheck_events.legAgil.right.Parent == cursorTarget_axes
variableCreate('legAgil','right',subCheck_axes,subCheck_data)
end
end

end
%% "Create sub-function" 
function variableCreate(create_bradyKin,create_lateral,subCheck_axes,subCheck_data)
global hCursor subCheck_events auto_events
eval(['auto_events.' create_bradyKin '.' create_lateral '(end+1) = find(~logical(subCheck_data.' create_bradyKin '.' create_lateral '.XData-getCursorInfo(hCursor).Position(1)));'])
eval(['auto_events.' create_bradyKin '.' create_lateral ' = sort(auto_events.' create_bradyKin '.' create_lateral ');'])
eval(['delete(subCheck_events.' create_bradyKin '.' create_lateral ')'])
eval(['subCheck_events.' create_bradyKin '.' create_lateral ' = plot(subCheck_axes.' create_bradyKin '.' create_lateral ',subCheck_data.' create_bradyKin '.' create_lateral '.XData(auto_events.' create_bradyKin '.' create_lateral '),subCheck_data.' create_bradyKin '.' create_lateral '.YData(auto_events.' create_bradyKin '.' create_lateral '),''o'',''color'',''r'',''markersize'',3);'])
end
%% "Delete" pushbutton
function deleteEvent(source,event)
global subCheck_events auto_events subCheck_axes subCheck_data...
    event_plot events_openpose time l r

if subCheck_events.fingerTap.left.Parent == gca
variableDelete('fingerTap','left',subCheck_axes,subCheck_data)
elseif subCheck_events.fingerTap.right.Parent == gca
variableDelete('fingerTap','right',subCheck_axes,subCheck_data)
elseif subCheck_events.handOpenClose.left.Parent == gca
variableDelete('handOpenClose','left',subCheck_axes,subCheck_data)
elseif subCheck_events.handOpenClose.right.Parent == gca
variableDelete('handOpenClose','right',subCheck_axes,subCheck_data)
elseif subCheck_events.handProSup.left.Parent == gca
variableDelete('handProSup','left',subCheck_axes,subCheck_data)
elseif subCheck_events.handProSup.right.Parent == gca
variableDelete('handProSup','right',subCheck_axes,subCheck_data)
elseif subCheck_events.toeTap.left.Parent == gca
variableDelete('toeTap','left',subCheck_axes,subCheck_data)
elseif subCheck_events.toeTap.right.Parent == gca
variableDelete('toeTap','right',subCheck_axes,subCheck_data)
elseif subCheck_events.legAgil.left.Parent == gca
variableDelete('legAgil','left',subCheck_axes,subCheck_data)
elseif subCheck_events.legAgil.right.Parent == gca
variableDelete('legAgil','right',subCheck_axes,subCheck_data)
end

end
%% "Delete sub-function" 
function variableDelete(delete_bradyKin,delete_lateral,subCheck_axes,subCheck_data)
global subCheck_events auto_events
eval(['auto_events.' delete_bradyKin '.' delete_lateral '(logical(subCheck_events.' delete_bradyKin '.' delete_lateral '.BrushData)) = [];'])
eval(['delete(subCheck_events.' delete_bradyKin '.' delete_lateral ')'])
eval(['subCheck_events.' delete_bradyKin '.' delete_lateral ' = plot(subCheck_axes.' delete_bradyKin '.' delete_lateral ',subCheck_data.' delete_bradyKin '.' delete_lateral '.XData(auto_events.' delete_bradyKin '.' delete_lateral '),subCheck_data.' delete_bradyKin '.' delete_lateral '.YData(auto_events.' delete_bradyKin '.' delete_lateral '),''o'',''color'',''r'',''markersize'',3);'])
end
%% "Brush" toggle
function tgglBrush(source,event)
brush on
end
%% "Cursor" toggle
function tgglCursor(source,event)
datacursormode on
end
%% "Zoom" toggle
function tgglZoom(source,event)
zoom on
end
%% "Pan" toggle
function tgglPan(source,event)
pan on
end
%% "findAutoEvents" function
function auto_events = findAutoEvents(lateral,bradyKin_items,subCheck_axes,bradyKin_segments,manual_events)
global subCheck_data subCheck_events subCheck_events_manual

for i = 1:length(fieldnames(bradyKin_segments))
    for j = 1:length(lateral)
        eval(['[pks,auto_events.' bradyKin_items{i} '.' lateral{j} '] = findpeaks(subCheck_data.' bradyKin_items{i} '.' lateral{j} '.YData);'])
        eval(['subCheck_events.' bradyKin_items{i} '.' lateral{j} ' = plot(subCheck_axes.' bradyKin_items{i} '.' lateral{j} ',subCheck_data.' bradyKin_items{i} '.' lateral{j} '.XData(auto_events.' bradyKin_items{i} '.' lateral{j} '),subCheck_data.' bradyKin_items{i} '.' lateral{j} '.YData(auto_events.' bradyKin_items{i} '.' lateral{j} '),''o'',''color'',''r'',''markersize'',3);'])
    end
end

end
%% "Current Frame" slider
function currentFrame_slider(source,event)
global h_slider frame h_image h_frameBox h_axes_timeSeries h_image h_axes_image ...
    frameInfo subCheck_axes 

frame = round(event.Source.Value);
showImage

if ~(gca == h_axes_image)
yLim_temp = get(gca,'YLim');
h_frameBox.Parent = gca;
h_frameBox.Position = [frame-0.5 min(yLim_temp) 1 range(yLim_temp)];
else
h_frameBox.Position = [frame-0.5 h_frameBox.Position(2) 1 h_frameBox.Position(4)];   
end
uistack(h_frameBox,'bottom')
end

%% "My Cursor"
function output_txt = myCursor(obj,event_obj)
global h_axes_timeSeries startTrackFrame endTrackFrame frame hCursor h_image h_frameBox h_image ...
    h_axes_image h_slider h_axes_ankleAngle h_frameBox_ankleAngle frameInfo ...
    subCheck_axes check_fig 



if event_obj.Target.Parent == subCheck_axes.fingerTap.right || event_obj.Target.Parent == subCheck_axes.fingerTap.left || event_obj.Target.Parent == subCheck_axes.handOpenClose.right || event_obj.Target.Parent == subCheck_axes.handOpenClose.left || event_obj.Target.Parent == subCheck_axes.handProSup.right || event_obj.Target.Parent == subCheck_axes.handProSup.left || event_obj.Target.Parent == subCheck_axes.toeTap.right || event_obj.Target.Parent == subCheck_axes.toeTap.left || event_obj.Target.Parent == subCheck_axes.legAgil.right || event_obj.Target.Parent == subCheck_axes.legAgil.left
if event_obj.Position(1) >= startTrackFrame && event_obj.Position(1) <= endTrackFrame
        frame = event_obj.Position(1);    
        output_txt = {};
        
showImage
h_slider.Value = frame;
yLim_temp = get(gca,'YLim');
h_frameBox.Parent = gca;
h_frameBox.Position = [frame-0.5 min(yLim_temp) 1 range(yLim_temp)];
uistack(h_frameBox,'bottom')
end
    
end

end
%% "Show Image" function
function showImage(source,event)
global frame videoInfo h_image h_axes_image output_name_title bg_poseVid
delete(h_image)
if strcmp(get(bg_poseVid.SelectedObject,'String'),'MediaPipe')
h_image = imshow(read(videoInfo.vid_mediapipe,frame),'InitialMagnification','fit','Parent',h_axes_image);
elseif strcmp(get(bg_poseVid.SelectedObject,'String'),'OpenPose')
h_image = imshow(read(videoInfo.vid_openpose,frame),'InitialMagnification','fit','Parent',h_axes_image);
end
title(h_axes_image,[output_name_title '; Frame ' num2str(frame)],'FontSize',8,'interpreter','none')
end
%%
function plot_bradyKin_timeSeries(bradyKin_items,lateral,subDim,bradyKin_segments,data,subplot_ind)
global subCheck_axes h_frameBox frame subCheck_data
plot_bradyKin_coor = {'[5 9]','[5 9]';'[5 9]','[5 9]';'[5]','[5]';'[23]','[20]';'[25]','[22]'};
g = [.5 .5 .5];

subplot_ind = {'[4 5 6]', '[1 2 3]'; '[13 14 15]', '[10 11 12]'; '[22 23 24]', '[19 20 21]'; '[31 32 33]', '[28 29 30]';'[40 41 42]', '[37 38 39]'};

for i = 1:length(fieldnames(bradyKin_segments))
    for j = 1:length(lateral)
        if strcmp(bradyKin_items{i},'fingerTap') | strcmp(bradyKin_items{i},'handOpenClose')
            eval(['subCheck_axes.' bradyKin_items{i} '.' lateral{j} ' = subplot(subDim(1),subDim(2),' subplot_ind{i,j} '); hold on'])
            eval(['subCheck_data.' bradyKin_items{i} '.' lateral{j} ' = plot(subCheck_axes.' bradyKin_items{i} '.' lateral{j} ',bradyKin_segments.' bradyKin_items{i} '.' lateral{j} '(1):bradyKin_segments.' bradyKin_items{i} '.' lateral{j} '(2),sqrt(sum(diff(data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.' lateral{j} '.filt(:,[' plot_bradyKin_coor{i,j} '],:),1,2).^2,3)),''.-'',''color'',g);'])
        elseif strcmp(bradyKin_items{i},'handProSup') 
            eval(['subCheck_axes.' bradyKin_items{i} '.' lateral{j} ' = subplot(subDim(1),subDim(2),' subplot_ind{i,j} '); hold on'])
            eval(['subCheck_data.' bradyKin_items{i} '.' lateral{j} ' = plot(subCheck_axes.' bradyKin_items{i} '.' lateral{j} ',bradyKin_segments.' bradyKin_items{i} '.' lateral{j} '(1):bradyKin_segments.' bradyKin_items{i} '.' lateral{j} '(2),data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.' lateral{j} '.filt(:,[' plot_bradyKin_coor{i,j} '],2),''.-'',''color'',g);'])
        elseif strcmp(bradyKin_items{i},'toeTap') | strcmp(bradyKin_items{i},'legAgil')
            eval(['subCheck_axes.' bradyKin_items{i} '.' lateral{j} ' = subplot(subDim(1),subDim(2),' subplot_ind{i,j} '); hold on'])
            eval(['subCheck_data.' bradyKin_items{i} '.' lateral{j} ' = plot(subCheck_axes.' bradyKin_items{i} '.' lateral{j} ',bradyKin_segments.' bradyKin_items{i} '.' lateral{j} '(1):bradyKin_segments.' bradyKin_items{i} '.' lateral{j} '(2),nanmean(data.openpose.' bradyKin_items{i} '.' lateral{j} '.pose.body.raw(:,[' plot_bradyKin_coor{i,j} '],2),2),''.-'',''color'',g);'])
        end
        if strcmp(lateral{j},'left')
            ylabel({bradyKin_items{i},'Pixel'})
        end
        if i == 1 && strcmp(lateral{j},'left')
           title('Left')
        end
        if i == 1 && strcmp(lateral{j},'right')
           title('Right')
        end  
        if i == 5
           xlabel('Frames') 
        end
        set(gca,'fontsize',8,'xlim',[min(get(get(gca,'children'),'XData')) max(get(get(gca,'children'),'XData'))])
        
    end
end


h_frameBox = rectangle(subCheck_axes.fingerTap.right,'Position',[frame-0.5 min(subCheck_axes.fingerTap.right.YLim) 1 range(subCheck_axes.fingerTap.right.YLim)],'edgecolor',[.7 .7 .7],'facecolor',[.7 .7 .7],'linewidth',.2);
uistack(h_frameBox,'bottom')

end