function [output_name, output_path] = load_pose(bradyKin_analyze)
global bradyKin_analyze bradyKin_segments
%% select files
path_bradykinData = uigetdir(pwd,'Choose Folder Containing Pose and Video Data');
d = dir(path_bradykinData); d(1:2) = [];

[filepath,name,ext] = fileparts(path_bradykinData);

fileInfo = dir(fullfile(path_bradykinData,[name '.*'])); vid_name = fileInfo.name;
vid_path = path_bradykinData;

fileInfo = dir(fullfile(path_bradykinData,[name '_Pose_MediaPipe.*'])); vid_mediapipe_name = fileInfo.name;
vid_mediapipe_path = path_bradykinData;

fileInfo = dir(fullfile(path_bradykinData,[name '_Hand_Outputs.*'])); file_hands_mediapipe = fileInfo.name;
path_hands_mediapipe = path_bradykinData;

fileInfo = dir(fullfile(path_bradykinData,[name '_Body_Outputs.*'])); file_body_mediapipe = fileInfo.name;
path_body_mediapipe = path_bradykinData;

fileInfo = dir(fullfile(path_bradykinData,[name '_Pose_OpenPose.*'])); vid_openpose_name = fileInfo.name;
vid_openpose_path = path_bradykinData;
%% load time-stamped vector
videoInfo.vid = VideoReader(fullfile(vid_path,vid_name));
timeStamp = ((1):videoInfo.vid.NumFrames) / videoInfo.vid.FrameRate;
%% find segments
[filepath,id,ext] = fileparts(vid_name);

segment_bradyKin(path_bradykinData,id,vid_path,vid_name,timeStamp)
%% load json files with OpenPose keypoints (traditional)
% path_openpose = fullfile(path_bradykinData,'JSON_Files');
% file_openpose = dir(path_openpose); file_openpose = file_openpose(3:end); f_openpose = cell(1,length(file_openpose)); for nf = 1:length(file_openpose); f_openpose{nf} = file_openpose(nf).name; end
% videoInfo.vid_openpose = VideoReader(fullfile(vid_openpose_path,vid_openpose_name));
% 
% data_openpose_temp.noFiles = length(f_openpose); % number of files
% 
% frameInfo.openpose.multiplePersonsDetected = false(data_openpose_temp.noFiles,1);
% frameInfo.openpose.numberPersonsDetected = zeros(data_openpose_temp.noFiles,1);
% 
% data_openpose_temp.time = nan(1,data_openpose_temp.noFiles);
% data_openpose_temp.time = 0:1/videoInfo.vid_openpose.FrameRate:(data_openpose_temp.noFiles-1)/videoInfo.vid_openpose.FrameRate; % time vector
% 
% for j = 1:data_openpose_temp.noFiles        
%     val = jsondecode(fileread(fullfile(path_openpose,f_openpose{j})))   ; % load JSON file
%     if length(val.people) > 1; frameInfo.openpose.multiplePersonsDetected(j) = true; end % check if multiple persons are tracked in frame
%     if ~isempty(val.people) % check if any people are detected
%         frameInfo.openpose.numberPersonsDetected(j) = length(val.people);
%         val.people(1).pose_keypoints_2d(val.people(1).pose_keypoints_2d==0) = nan; 
% 
%         data_openpose_temp.pose.data_raw(j,:,1) = val.people(1).pose_keypoints_2d(1:3:end);
%         data_openpose_temp.pose.data_raw(j,:,2) = val.people(1).pose_keypoints_2d(2:3:end);
%         conf.pose(j,:) = val.people(1).pose_keypoints_2d(3:3:end);
% 
%     end   
% end; clearvars j
%% load json files with OpenPose keypoints (csv)
fileInfo = dir(fullfile(path_bradykinData,[name '_OpenPose_Body_Outputs.*'])); file_openpose = fileInfo.name;
path_openpose = fullfile(path_bradykinData);

videoInfo.vid_openpose = VideoReader(fullfile(vid_openpose_path,vid_openpose_name));

openpose_keypoints = readtable(fullfile(path_openpose,file_openpose));

[data_openpose_temp.noFiles y] = size(openpose_keypoints); % number of files

frameInfo.openpose.multiplePersonsDetected = false(data_openpose_temp.noFiles,1);
frameInfo.openpose.numberPersonsDetected = zeros(data_openpose_temp.noFiles,1);

data_openpose_temp.time = nan(1,data_openpose_temp.noFiles);
data_openpose_temp.time = 0:1/videoInfo.vid_openpose.FrameRate:(data_openpose_temp.noFiles-1)/videoInfo.vid_openpose.FrameRate; % time vector

data_openpose_temp.pose.data_raw(:,:,1) = table2array(openpose_keypoints(:,3:3:end));
data_openpose_temp.pose.data_raw(:,:,2) = table2array(openpose_keypoints(:,4:3:end));
%% segment OpenPose data
videoInfo.vid = VideoReader(fullfile(vid_path,vid_name));
openpose_keypoints = {'Nose','Neck','RShoulder','RElbow','RWrist','LShoulder','LElbow','LWrist','MidHip','RHip','RKnee','RAnkle','LHip','LKnee','LAnkle','REye','LEye','REar','LEar','LBigToe','LSmallToe','LHeel','RBigToe','RSmallToe','RHeel'};

if bradyKin_analyze.fingerTap.right
    data.openpose.fingerTap.right.time = timeStamp(bradyKin_segments.fingerTap.right(1):bradyKin_segments.fingerTap.right(2)) - timeStamp(bradyKin_segments.fingerTap.right(1));
    data.openpose.fingerTap.right.pose.body.raw(:,:,1) = data_openpose_temp.pose.data_raw(bradyKin_segments.fingerTap.right(1):bradyKin_segments.fingerTap.right(2),:,1);
    data.openpose.fingerTap.right.pose.body.raw(:,:,2) = data_openpose_temp.pose.data_raw(bradyKin_segments.fingerTap.right(1):bradyKin_segments.fingerTap.right(2),:,2);
    data.openpose.fingerTap.right.pose.body.raw(data.openpose.fingerTap.right.pose.body.raw == 0) = nan;
    data.openpose.fingerTap.right.pose.body.raw(:,:,2) = -data.openpose.fingerTap.right.pose.body.raw(:,:,2) + videoInfo.vid_openpose.Height;
    data.openpose.fingerTap.right.pose.body.keypoint_names = openpose_keypoints;
end
if bradyKin_analyze.fingerTap.left
    data.openpose.fingerTap.left.time = timeStamp(bradyKin_segments.fingerTap.left(1):bradyKin_segments.fingerTap.left(2)) - timeStamp(bradyKin_segments.fingerTap.left(1));
    data.openpose.fingerTap.left.pose.body.raw(:,:,1) = data_openpose_temp.pose.data_raw(bradyKin_segments.fingerTap.left(1):bradyKin_segments.fingerTap.left(2),:,1);
    data.openpose.fingerTap.left.pose.body.raw(:,:,2) = data_openpose_temp.pose.data_raw(bradyKin_segments.fingerTap.left(1):bradyKin_segments.fingerTap.left(2),:,2);
    data.openpose.fingerTap.left.pose.body.raw(data.openpose.fingerTap.left.pose.body.raw == 0) = nan;
    data.openpose.fingerTap.left.pose.body.raw(:,:,2) = -data.openpose.fingerTap.left.pose.body.raw(:,:,2) + videoInfo.vid_openpose.Height;
    data.openpose.fingerTap.left.pose.body.keypoint_names = openpose_keypoints;
end

if bradyKin_analyze.handOpenClose.right
    data.openpose.handOpenClose.right.time = timeStamp(bradyKin_segments.handOpenClose.right(1):bradyKin_segments.handOpenClose.right(2)) - timeStamp(bradyKin_segments.handOpenClose.right(1));
    data.openpose.handOpenClose.right.pose.body.raw(:,:,1) = data_openpose_temp.pose.data_raw(bradyKin_segments.handOpenClose.right(1):bradyKin_segments.handOpenClose.right(2),:,1);
    data.openpose.handOpenClose.right.pose.body.raw(:,:,2) = data_openpose_temp.pose.data_raw(bradyKin_segments.handOpenClose.right(1):bradyKin_segments.handOpenClose.right(2),:,2);
    data.openpose.handOpenClose.right.pose.body.raw(data.openpose.handOpenClose.right.pose.body.raw == 0) = nan;
    data.openpose.handOpenClose.right.pose.body.raw(:,:,2) = -data.openpose.handOpenClose.right.pose.body.raw(:,:,2) + videoInfo.vid_openpose.Height;
    data.openpose.handOpenClose.right.pose.body.keypoint_names = openpose_keypoints;
end
if bradyKin_analyze.handOpenClose.left
    data.openpose.handOpenClose.left.time = timeStamp(bradyKin_segments.handOpenClose.left(1):bradyKin_segments.handOpenClose.left(2)) - timeStamp(bradyKin_segments.handOpenClose.left(1));
    data.openpose.handOpenClose.left.pose.body.raw(:,:,1) = data_openpose_temp.pose.data_raw(bradyKin_segments.handOpenClose.left(1):bradyKin_segments.handOpenClose.left(2),:,1);
    data.openpose.handOpenClose.left.pose.body.raw(:,:,2) = data_openpose_temp.pose.data_raw(bradyKin_segments.handOpenClose.left(1):bradyKin_segments.handOpenClose.left(2),:,2);
    data.openpose.handOpenClose.left.pose.body.raw(data.openpose.handOpenClose.left.pose.body.raw == 0) = nan;
    data.openpose.handOpenClose.left.pose.body.raw(:,:,2) = -data.openpose.handOpenClose.left.pose.body.raw(:,:,2) + videoInfo.vid_openpose.Height;
    data.openpose.handOpenClose.left.pose.body.keypoint_names = openpose_keypoints;
end

if bradyKin_analyze.handProSup.right
    data.openpose.handProSup.right.time = timeStamp(bradyKin_segments.handProSup.right(1):bradyKin_segments.handProSup.right(2)) - timeStamp(bradyKin_segments.handProSup.right(1));
    data.openpose.handProSup.right.pose.body.raw(:,:,1) = data_openpose_temp.pose.data_raw(bradyKin_segments.handProSup.right(1):bradyKin_segments.handProSup.right(2),:,1);
    data.openpose.handProSup.right.pose.body.raw(:,:,2) = data_openpose_temp.pose.data_raw(bradyKin_segments.handProSup.right(1):bradyKin_segments.handProSup.right(2),:,2);
    data.openpose.handProSup.right.pose.body.raw(data.openpose.handProSup.right.pose.body.raw == 0) = nan;
    data.openpose.handProSup.right.pose.body.raw(:,:,2) = -data.openpose.handProSup.right.pose.body.raw(:,:,2) + videoInfo.vid_openpose.Height;
    data.openpose.handProSup.right.pose.body.keypoint_names = openpose_keypoints;
end
if bradyKin_analyze.handProSup.left
    data.openpose.handProSup.left.time = timeStamp(bradyKin_segments.handProSup.left(1):bradyKin_segments.handProSup.left(2)) - timeStamp(bradyKin_segments.handProSup.left(1));
    data.openpose.handProSup.left.pose.body.raw(:,:,1) = data_openpose_temp.pose.data_raw(bradyKin_segments.handProSup.left(1):bradyKin_segments.handProSup.left(2),:,1);
    data.openpose.handProSup.left.pose.body.raw(:,:,2) = data_openpose_temp.pose.data_raw(bradyKin_segments.handProSup.left(1):bradyKin_segments.handProSup.left(2),:,2);
    data.openpose.handProSup.left.pose.body.raw(data.openpose.handProSup.left.pose.body.raw == 0) = nan;
    data.openpose.handProSup.left.pose.body.raw(:,:,2) = -data.openpose.handProSup.left.pose.body.raw(:,:,2) + videoInfo.vid_openpose.Height;
    data.openpose.handProSup.left.pose.body.keypoint_names = openpose_keypoints;
end

if bradyKin_analyze.toeTap.right
    data.openpose.toeTap.right.time = timeStamp(bradyKin_segments.toeTap.right(1):bradyKin_segments.toeTap.right(2)) - timeStamp(bradyKin_segments.toeTap.right(1));
    data.openpose.toeTap.right.pose.body.raw(:,:,1) = data_openpose_temp.pose.data_raw(bradyKin_segments.toeTap.right(1):bradyKin_segments.toeTap.right(2),:,1);
    data.openpose.toeTap.right.pose.body.raw(:,:,2) = data_openpose_temp.pose.data_raw(bradyKin_segments.toeTap.right(1):bradyKin_segments.toeTap.right(2),:,2);
    data.openpose.toeTap.right.pose.body.raw(data.openpose.toeTap.right.pose.body.raw == 0) = nan;
    data.openpose.toeTap.right.pose.body.raw(:,:,2) = -data.openpose.toeTap.right.pose.body.raw(:,:,2) + videoInfo.vid_openpose.Height;
    data.openpose.toeTap.right.pose.body.keypoint_names = openpose_keypoints;
end
if bradyKin_analyze.toeTap.left
    data.openpose.toeTap.left.time = timeStamp(bradyKin_segments.toeTap.left(1):bradyKin_segments.toeTap.left(2)) - timeStamp(bradyKin_segments.toeTap.left(1));
    data.openpose.toeTap.left.pose.body.raw(:,:,1) = data_openpose_temp.pose.data_raw(bradyKin_segments.toeTap.left(1):bradyKin_segments.toeTap.left(2),:,1);
    data.openpose.toeTap.left.pose.body.raw(:,:,2) = data_openpose_temp.pose.data_raw(bradyKin_segments.toeTap.left(1):bradyKin_segments.toeTap.left(2),:,2);
    data.openpose.toeTap.left.pose.body.raw(data.openpose.toeTap.left.pose.body.raw == 0) = nan;
    data.openpose.toeTap.left.pose.body.raw(:,:,2) = -data.openpose.toeTap.left.pose.body.raw(:,:,2) + videoInfo.vid_openpose.Height;
    data.openpose.toeTap.left.pose.body.keypoint_names = openpose_keypoints;
end

if bradyKin_analyze.legAgil.right
    data.openpose.legAgil.right.time = timeStamp(bradyKin_segments.legAgil.right(1):bradyKin_segments.legAgil.right(2)) - timeStamp(bradyKin_segments.legAgil.right(1));
    data.openpose.legAgil.right.pose.body.raw(:,:,1) = data_openpose_temp.pose.data_raw(bradyKin_segments.legAgil.right(1):bradyKin_segments.legAgil.right(2),:,1);
    data.openpose.legAgil.right.pose.body.raw(:,:,2) = data_openpose_temp.pose.data_raw(bradyKin_segments.legAgil.right(1):bradyKin_segments.legAgil.right(2),:,2);
    data.openpose.legAgil.right.pose.body.raw(data.openpose.legAgil.right.pose.body.raw == 0) = nan;
    data.openpose.legAgil.right.pose.body.raw(:,:,2) = -data.openpose.legAgil.right.pose.body.raw(:,:,2) + videoInfo.vid_openpose.Height;
    data.openpose.legAgil.right.pose.body.keypoint_names = openpose_keypoints;
end
if bradyKin_analyze.legAgil.left
    data.openpose.legAgil.left.time = timeStamp(bradyKin_segments.legAgil.left(1):bradyKin_segments.legAgil.left(2)) - timeStamp(bradyKin_segments.legAgil.left(1));
    data.openpose.legAgil.left.pose.body.raw(:,:,1) = data_openpose_temp.pose.data_raw(bradyKin_segments.legAgil.left(1):bradyKin_segments.legAgil.left(2),:,1);
    data.openpose.legAgil.left.pose.body.raw(:,:,2) = data_openpose_temp.pose.data_raw(bradyKin_segments.legAgil.left(1):bradyKin_segments.legAgil.left(2),:,2);
    data.openpose.legAgil.left.pose.body.raw(data.openpose.legAgil.left.pose.body.raw == 0) = nan;
    data.openpose.legAgil.left.pose.body.raw(:,:,2) = -data.openpose.legAgil.left.pose.body.raw(:,:,2) + videoInfo.vid_openpose.Height;
    data.openpose.legAgil.left.pose.body.keypoint_names = openpose_keypoints;
end
%% load .csv files with Google Mediapipe keypoints
videoInfo.vid_mediapipe = VideoReader(fullfile(vid_mediapipe_path,vid_mediapipe_name));

hand_keypoints = readtable(fullfile(path_hands_mediapipe,file_hands_mediapipe));
body_keypoints = readtable(fullfile(path_body_mediapipe,file_body_mediapipe));

if bradyKin_analyze.fingerTap.right
    data.mediapipe.fingerTap.right.time = timeStamp(bradyKin_segments.fingerTap.right(1):bradyKin_segments.fingerTap.right(2)) - timeStamp(bradyKin_segments.fingerTap.right(1));
    
    data.mediapipe.fingerTap.right.pose.body.raw(:,:,1) = table2array(body_keypoints(bradyKin_segments.fingerTap.right(1):bradyKin_segments.fingerTap.right(2),1:2:end));
    data.mediapipe.fingerTap.right.pose.body.raw(:,:,2) = table2array(body_keypoints(bradyKin_segments.fingerTap.right(1):bradyKin_segments.fingerTap.right(2),2:2:end));
    data.mediapipe.fingerTap.right.pose.body.raw(data.mediapipe.fingerTap.right.pose.body.raw(:,:,:) == 0) = nan; %% replace 0-values with NaNs
    data.mediapipe.fingerTap.right.pose.body.raw(:,:,2) = -data.mediapipe.fingerTap.right.pose.body.raw(:,:,2) + videoInfo.vid_mediapipe.Height;
    data.mediapipe.fingerTap.right.pose.body.keypoint_names = body_keypoints.Properties.VariableNames(1:2:end);
    
    data.mediapipe.fingerTap.right.pose.hand.left.raw(:,:,1) = table2array(hand_keypoints(bradyKin_segments.fingerTap.right(1):bradyKin_segments.fingerTap.right(2),1:2:42));
    data.mediapipe.fingerTap.right.pose.hand.left.raw(:,:,2) = table2array(hand_keypoints(bradyKin_segments.fingerTap.right(1):bradyKin_segments.fingerTap.right(2),2:2:42));
    data.mediapipe.fingerTap.right.pose.hand.left.raw(data.mediapipe.fingerTap.right.pose.hand.left.raw(:,:,:) == 0) = nan; %% replace 0-values with NaNs
    data.mediapipe.fingerTap.right.pose.hand.left.raw(:,:,2) = -data.mediapipe.fingerTap.right.pose.hand.left.raw(:,:,2) + videoInfo.vid_mediapipe.Height;
    data.mediapipe.fingerTap.right.pose.hand.left.keypoint_names = hand_keypoints.Properties.VariableNames(1:2:42);
    
    data.mediapipe.fingerTap.right.pose.hand.right.raw(:,:,1) = table2array(hand_keypoints(bradyKin_segments.fingerTap.right(1):bradyKin_segments.fingerTap.right(2),43:2:84));
    data.mediapipe.fingerTap.right.pose.hand.right.raw(:,:,2) = table2array(hand_keypoints(bradyKin_segments.fingerTap.right(1):bradyKin_segments.fingerTap.right(2),44:2:84));
    data.mediapipe.fingerTap.right.pose.hand.right.raw(data.mediapipe.fingerTap.right.pose.hand.right.raw(:,:,:) == 0) = nan; %% replace 0-values with NaNs
    data.mediapipe.fingerTap.right.pose.hand.right.raw(:,:,2) = -data.mediapipe.fingerTap.right.pose.hand.right.raw(:,:,2) + videoInfo.vid_mediapipe.Height;
    data.mediapipe.fingerTap.right.pose.hand.right.keypoint_names = hand_keypoints.Properties.VariableNames(43:2:84);
end
if bradyKin_analyze.fingerTap.left
    data.mediapipe.fingerTap.left.time = timeStamp(bradyKin_segments.fingerTap.left(1):bradyKin_segments.fingerTap.left(2)) - timeStamp(bradyKin_segments.fingerTap.left(1));

    data.mediapipe.fingerTap.left.pose.body.raw(:,:,1) = table2array(body_keypoints(bradyKin_segments.fingerTap.left(1):bradyKin_segments.fingerTap.left(2),1:2:end));
    data.mediapipe.fingerTap.left.pose.body.raw(:,:,2) = table2array(body_keypoints(bradyKin_segments.fingerTap.left(1):bradyKin_segments.fingerTap.left(2),2:2:end));
    data.mediapipe.fingerTap.left.pose.body.raw(data.mediapipe.fingerTap.left.pose.body.raw(:,:,:) == 0) = nan; %% replace 0-values with NaNs
    data.mediapipe.fingerTap.left.pose.body.raw(:,:,2) = -data.mediapipe.fingerTap.left.pose.body.raw(:,:,2) + videoInfo.vid_mediapipe.Height;
    data.mediapipe.fingerTap.left.pose.body.keypoint_names = body_keypoints.Properties.VariableNames(1:2:end);
    
    data.mediapipe.fingerTap.left.pose.hand.left.raw(:,:,1) = table2array(hand_keypoints(bradyKin_segments.fingerTap.left(1):bradyKin_segments.fingerTap.left(2),1:2:42));
    data.mediapipe.fingerTap.left.pose.hand.left.raw(:,:,2) = table2array(hand_keypoints(bradyKin_segments.fingerTap.left(1):bradyKin_segments.fingerTap.left(2),2:2:42));
    data.mediapipe.fingerTap.left.pose.hand.left.raw(data.mediapipe.fingerTap.left.pose.hand.left.raw(:,:,:) == 0) = nan; %% replace 0-values with NaNs
    data.mediapipe.fingerTap.left.pose.hand.left.raw(:,:,2) = -data.mediapipe.fingerTap.left.pose.hand.left.raw(:,:,2) + videoInfo.vid_mediapipe.Height;
    data.mediapipe.fingerTap.left.pose.hand.left.keypoint_names = hand_keypoints.Properties.VariableNames(1:2:42);
    
    data.mediapipe.fingerTap.left.pose.hand.right.raw(:,:,1) = table2array(hand_keypoints(bradyKin_segments.fingerTap.left(1):bradyKin_segments.fingerTap.left(2),43:2:84));
    data.mediapipe.fingerTap.left.pose.hand.right.raw(:,:,2) = table2array(hand_keypoints(bradyKin_segments.fingerTap.left(1):bradyKin_segments.fingerTap.left(2),44:2:84));
    data.mediapipe.fingerTap.left.pose.hand.right.raw(data.mediapipe.fingerTap.left.pose.hand.right.raw(:,:,:) == 0) = nan; %% replace 0-values with NaNs
    data.mediapipe.fingerTap.left.pose.hand.right.raw(:,:,2) = -data.mediapipe.fingerTap.left.pose.hand.right.raw(:,:,2) + videoInfo.vid_mediapipe.Height;
    data.mediapipe.fingerTap.left.pose.hand.right.keypoint_names = hand_keypoints.Properties.VariableNames(43:2:84);
end

if bradyKin_analyze.handOpenClose.right
    data.mediapipe.handOpenClose.right.time = timeStamp(bradyKin_segments.handOpenClose.right(1):bradyKin_segments.handOpenClose.right(2)) - timeStamp(bradyKin_segments.handOpenClose.right(1));

    data.mediapipe.handOpenClose.right.pose.body.raw(:,:,1) = table2array(body_keypoints(bradyKin_segments.handOpenClose.right(1):bradyKin_segments.handOpenClose.right(2),1:2:end));
    data.mediapipe.handOpenClose.right.pose.body.raw(:,:,2) = table2array(body_keypoints(bradyKin_segments.handOpenClose.right(1):bradyKin_segments.handOpenClose.right(2),2:2:end));
    data.mediapipe.handOpenClose.right.pose.body.raw(data.mediapipe.handOpenClose.right.pose.body.raw(:,:,:) == 0) = nan; %% replace 0-values with NaNs
    data.mediapipe.handOpenClose.right.pose.body.raw(:,:,2) = -data.mediapipe.handOpenClose.right.pose.body.raw(:,:,2) + videoInfo.vid_mediapipe.Height;
    data.mediapipe.handOpenClose.right.pose.body.keypoint_names = body_keypoints.Properties.VariableNames(1:2:end);
    
    data.mediapipe.handOpenClose.right.pose.hand.left.raw(:,:,1) = table2array(hand_keypoints(bradyKin_segments.handOpenClose.right(1):bradyKin_segments.handOpenClose.right(2),1:2:42));
    data.mediapipe.handOpenClose.right.pose.hand.left.raw(:,:,2) = table2array(hand_keypoints(bradyKin_segments.handOpenClose.right(1):bradyKin_segments.handOpenClose.right(2),2:2:42));
    data.mediapipe.handOpenClose.right.pose.hand.left.raw(data.mediapipe.handOpenClose.right.pose.hand.left.raw(:,:,:) == 0) = nan; %% replace 0-values with NaNs
    data.mediapipe.handOpenClose.right.pose.hand.left.raw(:,:,2) = -data.mediapipe.handOpenClose.right.pose.hand.left.raw(:,:,2) + videoInfo.vid_mediapipe.Height;
    data.mediapipe.handOpenClose.right.pose.hand.left.keypoint_names = hand_keypoints.Properties.VariableNames(1:2:42);
    
    data.mediapipe.handOpenClose.right.pose.hand.right.raw(:,:,1) = table2array(hand_keypoints(bradyKin_segments.handOpenClose.right(1):bradyKin_segments.handOpenClose.right(2),43:2:84));
    data.mediapipe.handOpenClose.right.pose.hand.right.raw(:,:,2) = table2array(hand_keypoints(bradyKin_segments.handOpenClose.right(1):bradyKin_segments.handOpenClose.right(2),44:2:84));
    data.mediapipe.handOpenClose.right.pose.hand.right.raw(data.mediapipe.handOpenClose.right.pose.hand.right.raw(:,:,:) == 0) = nan; %% replace 0-values with NaNs
    data.mediapipe.handOpenClose.right.pose.hand.right.raw(:,:,2) = -data.mediapipe.handOpenClose.right.pose.hand.right.raw(:,:,2) + videoInfo.vid_mediapipe.Height;
    data.mediapipe.handOpenClose.right.pose.hand.right.keypoint_names = hand_keypoints.Properties.VariableNames(43:2:84);
end
if bradyKin_analyze.handOpenClose.left
    data.mediapipe.handOpenClose.left.time = timeStamp(bradyKin_segments.handOpenClose.left(1):bradyKin_segments.handOpenClose.left(2)) - timeStamp(bradyKin_segments.handOpenClose.left(1));
    
    data.mediapipe.handOpenClose.left.pose.body.raw(:,:,1) = table2array(body_keypoints(bradyKin_segments.handOpenClose.left(1):bradyKin_segments.handOpenClose.left(2),1:2:end));
    data.mediapipe.handOpenClose.left.pose.body.raw(:,:,2) = table2array(body_keypoints(bradyKin_segments.handOpenClose.left(1):bradyKin_segments.handOpenClose.left(2),2:2:end));
    data.mediapipe.handOpenClose.left.pose.body.raw(data.mediapipe.handOpenClose.left.pose.body.raw(:,:,:) == 0) = nan; %% replace 0-values with NaNs
    data.mediapipe.handOpenClose.left.pose.body.raw(:,:,2) = -data.mediapipe.handOpenClose.left.pose.body.raw(:,:,2) + videoInfo.vid_mediapipe.Height;
    data.mediapipe.handOpenClose.left.pose.body.keypoint_names = body_keypoints.Properties.VariableNames(1:2:end);
    
    data.mediapipe.handOpenClose.left.pose.hand.left.raw(:,:,1) = table2array(hand_keypoints(bradyKin_segments.handOpenClose.left(1):bradyKin_segments.handOpenClose.left(2),1:2:42));
    data.mediapipe.handOpenClose.left.pose.hand.left.raw(:,:,2) = table2array(hand_keypoints(bradyKin_segments.handOpenClose.left(1):bradyKin_segments.handOpenClose.left(2),2:2:42));
    data.mediapipe.handOpenClose.left.pose.hand.left.raw(data.mediapipe.handOpenClose.left.pose.hand.left.raw(:,:,:) == 0) = nan; %% replace 0-values with NaNs
    data.mediapipe.handOpenClose.left.pose.hand.left.raw(:,:,2) = -data.mediapipe.handOpenClose.left.pose.hand.left.raw(:,:,2) + videoInfo.vid_mediapipe.Height;
    data.mediapipe.handOpenClose.left.pose.hand.left.keypoint_names = hand_keypoints.Properties.VariableNames(1:2:42);
    
    data.mediapipe.handOpenClose.left.pose.hand.right.raw(:,:,1) = table2array(hand_keypoints(bradyKin_segments.handOpenClose.left(1):bradyKin_segments.handOpenClose.left(2),43:2:84));
    data.mediapipe.handOpenClose.left.pose.hand.right.raw(:,:,2) = table2array(hand_keypoints(bradyKin_segments.handOpenClose.left(1):bradyKin_segments.handOpenClose.left(2),44:2:84));
    data.mediapipe.handOpenClose.left.pose.hand.right.raw(data.mediapipe.handOpenClose.left.pose.hand.right.raw(:,:,:) == 0) = nan; %% replace 0-values with NaNs
    data.mediapipe.handOpenClose.left.pose.hand.right.raw(:,:,2) = -data.mediapipe.handOpenClose.left.pose.hand.right.raw(:,:,2) + videoInfo.vid_mediapipe.Height;
    data.mediapipe.handOpenClose.left.pose.hand.right.keypoint_names = hand_keypoints.Properties.VariableNames(43:2:84);
end

if bradyKin_analyze.handProSup.right
    data.mediapipe.handProSup.right.time = timeStamp(bradyKin_segments.handProSup.right(1):bradyKin_segments.handProSup.right(2)) - timeStamp(bradyKin_segments.handProSup.right(1));
    
    data.mediapipe.handProSup.right.pose.body.raw(:,:,1) = table2array(body_keypoints(bradyKin_segments.handProSup.right(1):bradyKin_segments.handProSup.right(2),1:2:end));
    data.mediapipe.handProSup.right.pose.body.raw(:,:,2) = table2array(body_keypoints(bradyKin_segments.handProSup.right(1):bradyKin_segments.handProSup.right(2),2:2:end));
    data.mediapipe.handProSup.right.pose.body.raw(data.mediapipe.handProSup.right.pose.body.raw(:,:,:) == 0) = nan; %% replace 0-values with NaNs
    data.mediapipe.handProSup.right.pose.body.raw(:,:,2) = -data.mediapipe.handProSup.right.pose.body.raw(:,:,2) + videoInfo.vid_mediapipe.Height;
    data.mediapipe.handProSup.right.pose.body.keypoint_names = body_keypoints.Properties.VariableNames(1:2:end);
    
    data.mediapipe.handProSup.right.pose.hand.left.raw(:,:,1) = table2array(hand_keypoints(bradyKin_segments.handProSup.right(1):bradyKin_segments.handProSup.right(2),1:2:42));
    data.mediapipe.handProSup.right.pose.hand.left.raw(:,:,2) = table2array(hand_keypoints(bradyKin_segments.handProSup.right(1):bradyKin_segments.handProSup.right(2),2:2:42));
    data.mediapipe.handProSup.right.pose.hand.left.raw(data.mediapipe.handProSup.right.pose.hand.left.raw(:,:,:) == 0) = nan; %% replace 0-values with NaNs
    data.mediapipe.handProSup.right.pose.hand.left.raw(:,:,2) = -data.mediapipe.handProSup.right.pose.hand.left.raw(:,:,2) + videoInfo.vid_mediapipe.Height;
    data.mediapipe.handProSup.right.pose.hand.left.keypoint_names = hand_keypoints.Properties.VariableNames(1:2:42);
    
    data.mediapipe.handProSup.right.pose.hand.right.raw(:,:,1) = table2array(hand_keypoints(bradyKin_segments.handProSup.right(1):bradyKin_segments.handProSup.right(2),43:2:84));
    data.mediapipe.handProSup.right.pose.hand.right.raw(:,:,2) = table2array(hand_keypoints(bradyKin_segments.handProSup.right(1):bradyKin_segments.handProSup.right(2),44:2:84));
    data.mediapipe.handProSup.right.pose.hand.right.raw(data.mediapipe.handProSup.right.pose.hand.right.raw(:,:,:) == 0) = nan; %% replace 0-values with NaNs
    data.mediapipe.handProSup.right.pose.hand.right.raw(:,:,2) = -data.mediapipe.handProSup.right.pose.hand.right.raw(:,:,2) + videoInfo.vid_mediapipe.Height;
    data.mediapipe.handProSup.right.pose.hand.right.keypoint_names = hand_keypoints.Properties.VariableNames(43:2:84);
end
if bradyKin_analyze.handProSup.left
    data.mediapipe.handProSup.left.time = timeStamp(bradyKin_segments.handProSup.left(1):bradyKin_segments.handProSup.left(2)) - timeStamp(bradyKin_segments.handProSup.left(1));
    
    data.mediapipe.handProSup.left.pose.body.raw(:,:,1) = table2array(body_keypoints(bradyKin_segments.handProSup.left(1):bradyKin_segments.handProSup.left(2),1:2:end));
    data.mediapipe.handProSup.left.pose.body.raw(:,:,2) = table2array(body_keypoints(bradyKin_segments.handProSup.left(1):bradyKin_segments.handProSup.left(2),2:2:end));
    data.mediapipe.handProSup.left.pose.body.raw(data.mediapipe.handProSup.left.pose.body.raw(:,:,:) == 0) = nan; %% replace 0-values with NaNs
    data.mediapipe.handProSup.left.pose.body.raw(:,:,2) = -data.mediapipe.handProSup.left.pose.body.raw(:,:,2) + videoInfo.vid_mediapipe.Height;
    data.mediapipe.handProSup.left.pose.body.keypoint_names = body_keypoints.Properties.VariableNames(1:2:end);
    
    data.mediapipe.handProSup.left.pose.hand.left.raw(:,:,1) = table2array(hand_keypoints(bradyKin_segments.handProSup.left(1):bradyKin_segments.handProSup.left(2),1:2:42));
    data.mediapipe.handProSup.left.pose.hand.left.raw(:,:,2) = table2array(hand_keypoints(bradyKin_segments.handProSup.left(1):bradyKin_segments.handProSup.left(2),2:2:42));
    data.mediapipe.handProSup.left.pose.hand.left.raw(data.mediapipe.handProSup.left.pose.hand.left.raw(:,:,:) == 0) = nan; %% replace 0-values with NaNs
    data.mediapipe.handProSup.left.pose.hand.left.raw(:,:,2) = -data.mediapipe.handProSup.left.pose.hand.left.raw(:,:,2) + videoInfo.vid_mediapipe.Height;
    data.mediapipe.handProSup.left.pose.hand.left.keypoint_names = hand_keypoints.Properties.VariableNames(1:2:42);
    
    data.mediapipe.handProSup.left.pose.hand.right.raw(:,:,1) = table2array(hand_keypoints(bradyKin_segments.handProSup.left(1):bradyKin_segments.handProSup.left(2),43:2:84));
    data.mediapipe.handProSup.left.pose.hand.right.raw(:,:,2) = table2array(hand_keypoints(bradyKin_segments.handProSup.left(1):bradyKin_segments.handProSup.left(2),44:2:84));
    data.mediapipe.handProSup.left.pose.hand.right.raw(data.mediapipe.handProSup.left.pose.hand.right.raw(:,:,:) == 0) = nan; %% replace 0-values with NaNs
    data.mediapipe.handProSup.left.pose.hand.right.raw(:,:,2) = -data.mediapipe.handProSup.left.pose.hand.right.raw(:,:,2) + videoInfo.vid_mediapipe.Height;
    data.mediapipe.handProSup.left.pose.hand.right.keypoint_names = hand_keypoints.Properties.VariableNames(43:2:84);
end

if bradyKin_analyze.toeTap.right
    data.mediapipe.toeTap.right.time = timeStamp(bradyKin_segments.toeTap.right(1):bradyKin_segments.toeTap.right(2)) - timeStamp(bradyKin_segments.toeTap.right(1));
    
    data.mediapipe.toeTap.right.pose.body.raw(:,:,1) = table2array(body_keypoints(bradyKin_segments.toeTap.right(1):bradyKin_segments.toeTap.right(2),1:2:end));
    data.mediapipe.toeTap.right.pose.body.raw(:,:,2) = table2array(body_keypoints(bradyKin_segments.toeTap.right(1):bradyKin_segments.toeTap.right(2),2:2:end));
    data.mediapipe.toeTap.right.pose.body.raw(data.mediapipe.toeTap.right.pose.body.raw(:,:,:) == 0) = nan; %% replace 0-values with NaNs
    data.mediapipe.toeTap.right.pose.body.raw(:,:,2) = -data.mediapipe.toeTap.right.pose.body.raw(:,:,2) + videoInfo.vid_mediapipe.Height;
    data.mediapipe.toeTap.right.pose.body.keypoint_names = body_keypoints.Properties.VariableNames(1:2:end);
    
    data.mediapipe.toeTap.right.pose.hand.left.raw(:,:,1) = table2array(hand_keypoints(bradyKin_segments.toeTap.right(1):bradyKin_segments.toeTap.right(2),1:2:42));
    data.mediapipe.toeTap.right.pose.hand.left.raw(:,:,2) = table2array(hand_keypoints(bradyKin_segments.toeTap.right(1):bradyKin_segments.toeTap.right(2),2:2:42));
    data.mediapipe.toeTap.right.pose.hand.left.raw(data.mediapipe.toeTap.right.pose.hand.left.raw(:,:,:) == 0) = nan; %% replace 0-values with NaNs
    data.mediapipe.toeTap.right.pose.hand.left.raw(:,:,2) = -data.mediapipe.toeTap.right.pose.hand.left.raw(:,:,2) + videoInfo.vid_mediapipe.Height;
    data.mediapipe.toeTap.right.pose.hand.left.keypoint_names = hand_keypoints.Properties.VariableNames(1:2:42);
    
    data.mediapipe.toeTap.right.pose.hand.right.raw(:,:,1) = table2array(hand_keypoints(bradyKin_segments.toeTap.right(1):bradyKin_segments.toeTap.right(2),43:2:84));
    data.mediapipe.toeTap.right.pose.hand.right.raw(:,:,2) = table2array(hand_keypoints(bradyKin_segments.toeTap.right(1):bradyKin_segments.toeTap.right(2),44:2:84));
    data.mediapipe.toeTap.right.pose.hand.right.raw(data.mediapipe.toeTap.right.pose.hand.right.raw(:,:,:) == 0) = nan; %% replace 0-values with NaNs
    data.mediapipe.toeTap.right.pose.hand.right.raw(:,:,2) = -data.mediapipe.toeTap.right.pose.hand.right.raw(:,:,2) + videoInfo.vid_mediapipe.Height;
    data.mediapipe.toeTap.right.pose.hand.right.keypoint_names = hand_keypoints.Properties.VariableNames(43:2:84);
end
if bradyKin_analyze.toeTap.left
    data.mediapipe.toeTap.left.time = timeStamp(bradyKin_segments.toeTap.left(1):bradyKin_segments.toeTap.left(2)) - timeStamp(bradyKin_segments.toeTap.left(1));
    
    data.mediapipe.toeTap.left.pose.body.raw(:,:,1) = table2array(body_keypoints(bradyKin_segments.toeTap.left(1):bradyKin_segments.toeTap.left(2),1:2:end));
    data.mediapipe.toeTap.left.pose.body.raw(:,:,2) = table2array(body_keypoints(bradyKin_segments.toeTap.left(1):bradyKin_segments.toeTap.left(2),2:2:end));
    data.mediapipe.toeTap.left.pose.body.raw(data.mediapipe.toeTap.left.pose.body.raw(:,:,:) == 0) = nan; %% replace 0-values with NaNs
    data.mediapipe.toeTap.left.pose.body.raw(:,:,2) = -data.mediapipe.toeTap.left.pose.body.raw(:,:,2) + videoInfo.vid_mediapipe.Height;
    data.mediapipe.toeTap.left.pose.body.keypoint_names = body_keypoints.Properties.VariableNames(1:2:end);
    
    data.mediapipe.toeTap.left.pose.hand.left.raw(:,:,1) = table2array(hand_keypoints(bradyKin_segments.toeTap.left(1):bradyKin_segments.toeTap.left(2),1:2:42));
    data.mediapipe.toeTap.left.pose.hand.left.raw(:,:,2) = table2array(hand_keypoints(bradyKin_segments.toeTap.left(1):bradyKin_segments.toeTap.left(2),2:2:42));
    data.mediapipe.toeTap.left.pose.hand.left.raw(data.mediapipe.toeTap.left.pose.hand.left.raw(:,:,:) == 0) = nan; %% replace 0-values with NaNs
    data.mediapipe.toeTap.left.pose.hand.left.raw(:,:,2) = -data.mediapipe.toeTap.left.pose.hand.left.raw(:,:,2) + videoInfo.vid_mediapipe.Height;
    data.mediapipe.toeTap.left.pose.hand.left.keypoint_names = hand_keypoints.Properties.VariableNames(1:2:42);
    
    data.mediapipe.toeTap.left.pose.hand.right.raw(:,:,1) = table2array(hand_keypoints(bradyKin_segments.toeTap.left(1):bradyKin_segments.toeTap.left(2),43:2:84));
    data.mediapipe.toeTap.left.pose.hand.right.raw(:,:,2) = table2array(hand_keypoints(bradyKin_segments.toeTap.left(1):bradyKin_segments.toeTap.left(2),44:2:84));
    data.mediapipe.toeTap.left.pose.hand.right.raw(data.mediapipe.toeTap.left.pose.hand.right.raw(:,:,:) == 0) = nan; %% replace 0-values with NaNs
    data.mediapipe.toeTap.left.pose.hand.right.raw(:,:,2) = -data.mediapipe.toeTap.left.pose.hand.right.raw(:,:,2) + videoInfo.vid_mediapipe.Height;
    data.mediapipe.toeTap.left.pose.hand.right.keypoint_names = hand_keypoints.Properties.VariableNames(43:2:84);
end

if bradyKin_analyze.legAgil.right
    data.mediapipe.legAgil.right.time = timeStamp(bradyKin_segments.legAgil.right(1):bradyKin_segments.legAgil.right(2)) - timeStamp(bradyKin_segments.legAgil.right(1));
    
    data.mediapipe.legAgil.right.pose.body.raw(:,:,1) = table2array(body_keypoints(bradyKin_segments.legAgil.right(1):bradyKin_segments.legAgil.right(2),1:2:end));
    data.mediapipe.legAgil.right.pose.body.raw(:,:,2) = table2array(body_keypoints(bradyKin_segments.legAgil.right(1):bradyKin_segments.legAgil.right(2),2:2:end));
    data.mediapipe.legAgil.right.pose.body.raw(data.mediapipe.legAgil.right.pose.body.raw(:,:,:) == 0) = nan; %% replace 0-values with NaNs
    data.mediapipe.legAgil.right.pose.body.raw(:,:,2) = -data.mediapipe.legAgil.right.pose.body.raw(:,:,2) + videoInfo.vid_mediapipe.Height;
    data.mediapipe.legAgil.right.pose.body.keypoint_names = body_keypoints.Properties.VariableNames(1:2:end);
    
    data.mediapipe.legAgil.right.pose.hand.left.raw(:,:,1) = table2array(hand_keypoints(bradyKin_segments.legAgil.right(1):bradyKin_segments.legAgil.right(2),1:2:42));
    data.mediapipe.legAgil.right.pose.hand.left.raw(:,:,2) = table2array(hand_keypoints(bradyKin_segments.legAgil.right(1):bradyKin_segments.legAgil.right(2),2:2:42));
    data.mediapipe.legAgil.right.pose.hand.left.raw(data.mediapipe.legAgil.right.pose.hand.left.raw(:,:,:) == 0) = nan; %% replace 0-values with NaNs
    data.mediapipe.legAgil.right.pose.hand.left.raw(:,:,2) = -data.mediapipe.legAgil.right.pose.hand.left.raw(:,:,2) + videoInfo.vid_mediapipe.Height;
    data.mediapipe.legAgil.right.pose.hand.left.keypoint_names = hand_keypoints.Properties.VariableNames(1:2:42);
    
    data.mediapipe.legAgil.right.pose.hand.right.raw(:,:,1) = table2array(hand_keypoints(bradyKin_segments.legAgil.right(1):bradyKin_segments.legAgil.right(2),43:2:84));
    data.mediapipe.legAgil.right.pose.hand.right.raw(:,:,2) = table2array(hand_keypoints(bradyKin_segments.legAgil.right(1):bradyKin_segments.legAgil.right(2),44:2:84));
    data.mediapipe.legAgil.right.pose.hand.right.raw(data.mediapipe.legAgil.right.pose.hand.right.raw(:,:,:) == 0) = nan; %% replace 0-values with NaNs
    data.mediapipe.legAgil.right.pose.hand.right.raw(:,:,2) = -data.mediapipe.legAgil.right.pose.hand.right.raw(:,:,2) + videoInfo.vid_mediapipe.Height;
    data.mediapipe.legAgil.right.pose.hand.right.keypoint_names = hand_keypoints.Properties.VariableNames(43:2:84);
end
if bradyKin_analyze.legAgil.left
    data.mediapipe.legAgil.left.time = timeStamp(bradyKin_segments.legAgil.left(1):bradyKin_segments.legAgil.left(2)) - timeStamp(bradyKin_segments.legAgil.left(1));
    
    data.mediapipe.legAgil.left.pose.body.raw(:,:,1) = table2array(body_keypoints(bradyKin_segments.legAgil.left(1):bradyKin_segments.legAgil.left(2),1:2:end));
    data.mediapipe.legAgil.left.pose.body.raw(:,:,2) = table2array(body_keypoints(bradyKin_segments.legAgil.left(1):bradyKin_segments.legAgil.left(2),2:2:end));
    data.mediapipe.legAgil.left.pose.body.raw(data.mediapipe.legAgil.left.pose.body.raw(:,:,:) == 0) = nan; %% replace 0-values with NaNs
    data.mediapipe.legAgil.left.pose.body.raw(:,:,2) = -data.mediapipe.legAgil.left.pose.body.raw(:,:,2) + videoInfo.vid_mediapipe.Height;
    data.mediapipe.legAgil.left.pose.body.keypoint_names = body_keypoints.Properties.VariableNames(1:2:end);
    
    data.mediapipe.legAgil.left.pose.hand.left.raw(:,:,1) = table2array(hand_keypoints(bradyKin_segments.legAgil.left(1):bradyKin_segments.legAgil.left(2),1:2:42));
    data.mediapipe.legAgil.left.pose.hand.left.raw(:,:,2) = table2array(hand_keypoints(bradyKin_segments.legAgil.left(1):bradyKin_segments.legAgil.left(2),2:2:42));
    data.mediapipe.legAgil.left.pose.hand.left.raw(data.mediapipe.legAgil.left.pose.hand.left.raw(:,:,:) == 0) = nan; %% replace 0-values with NaNs
    data.mediapipe.legAgil.left.pose.hand.left.raw(:,:,2) = -data.mediapipe.legAgil.left.pose.hand.left.raw(:,:,2) + videoInfo.vid_mediapipe.Height;
    data.mediapipe.legAgil.left.pose.hand.left.keypoint_names = hand_keypoints.Properties.VariableNames(1:2:42);
    
    data.mediapipe.legAgil.left.pose.hand.right.raw(:,:,1) = table2array(hand_keypoints(bradyKin_segments.legAgil.left(1):bradyKin_segments.legAgil.left(2),43:2:84));
    data.mediapipe.legAgil.left.pose.hand.right.raw(:,:,2) = table2array(hand_keypoints(bradyKin_segments.legAgil.left(1):bradyKin_segments.legAgil.left(2),44:2:84));
    data.mediapipe.legAgil.left.pose.hand.right.raw(data.mediapipe.legAgil.left.pose.hand.right.raw(:,:,:) == 0) = nan; %% replace 0-values with NaNs
    data.mediapipe.legAgil.left.pose.hand.right.raw(:,:,2) = -data.mediapipe.legAgil.left.pose.hand.right.raw(:,:,2) + videoInfo.vid_mediapipe.Height;
    data.mediapipe.legAgil.left.pose.hand.right.keypoint_names = hand_keypoints.Properties.VariableNames(43:2:84);
end
%% save 
output_name = vid_name(1:strfind(vid_name,'.')-1);
output_path = vid_path;
save(fullfile(vid_path,[output_name '_pose.mat']),'data','videoInfo','output_name','bradyKin_segments','bradyKin_analyze','timeStamp');
end
%% segment_bradyKin
function segment_bradyKin(path_bradykinData,id,vid_path,vid_name,timeStamp)
global bradyKin_analyze bradyKin_segments

[excel_data excel_text] = xlsread(fullfile(path_bradykinData,[id '_Segmentation.xlsx']));
v_temp = VideoReader(fullfile(vid_path,vid_name));
approx_time_boris = (excel_data+1)/v_temp.FrameRate;


if bradyKin_analyze.fingerTap.right
    [m,I_startFrame] = min(abs(timeStamp-approx_time_boris(1,1)));
    [m,I_endFrame] = min(abs(timeStamp-approx_time_boris(1,2)));
    bradyKin_segments.fingerTap.right = [I_startFrame I_endFrame];
end
if bradyKin_analyze.fingerTap.left
    [m,I_startFrame] = min(abs(timeStamp-approx_time_boris(2,1)));
    [m,I_endFrame] = min(abs(timeStamp-approx_time_boris(2,2)));
    bradyKin_segments.fingerTap.left = [I_startFrame I_endFrame];
end
if bradyKin_analyze.handOpenClose.right
    [m,I_startFrame] = min(abs(timeStamp-approx_time_boris(3,1)));
    [m,I_endFrame] = min(abs(timeStamp-approx_time_boris(3,2)));
    bradyKin_segments.handOpenClose.right = [I_startFrame I_endFrame];
end
if bradyKin_analyze.handOpenClose.left
    [m,I_startFrame] = min(abs(timeStamp-approx_time_boris(4,1)));
    [m,I_endFrame] = min(abs(timeStamp-approx_time_boris(4,2)));
    bradyKin_segments.handOpenClose.left = [I_startFrame I_endFrame];
end
if bradyKin_analyze.handProSup.right
    [m,I_startFrame] = min(abs(timeStamp-approx_time_boris(5,1)));
    [m,I_endFrame] = min(abs(timeStamp-approx_time_boris(5,2)));
    bradyKin_segments.handProSup.right = [I_startFrame I_endFrame];
end
if bradyKin_analyze.handProSup.left
    [m,I_startFrame] = min(abs(timeStamp-approx_time_boris(6,1)));
    [m,I_endFrame] = min(abs(timeStamp-approx_time_boris(6,2)));
    bradyKin_segments.handProSup.left = [I_startFrame I_endFrame];
end
if bradyKin_analyze.toeTap.right
    [m,I_startFrame] = min(abs(timeStamp-approx_time_boris(7,1)));
    [m,I_endFrame] = min(abs(timeStamp-approx_time_boris(7,2)));
    bradyKin_segments.toeTap.right = [I_startFrame I_endFrame];
end
if bradyKin_analyze.toeTap.left
    [m,I_startFrame] = min(abs(timeStamp-approx_time_boris(8,1)));
    [m,I_endFrame] = min(abs(timeStamp-approx_time_boris(8,2)));
    bradyKin_segments.toeTap.left = [I_startFrame I_endFrame];
end
if bradyKin_analyze.legAgil.right
    [m,I_startFrame] = min(abs(timeStamp-approx_time_boris(9,1)));
    [m,I_endFrame] = min(abs(timeStamp-approx_time_boris(9,2)));
    bradyKin_segments.legAgil.right = [I_startFrame I_endFrame];
end
if bradyKin_analyze.legAgil.left
    [m,I_startFrame] = min(abs(timeStamp-approx_time_boris(10,1)));
    [m,I_endFrame] = min(abs(timeStamp-approx_time_boris(10,2)));
    bradyKin_segments.legAgil.left = [I_startFrame I_endFrame];
end
end