function bradykinesiaAnalysis
global bradyKin_analyze 

bradyKin_analyze.fingerTap.right = true; bradyKin_analyze.fingerTap.left = true;
bradyKin_analyze.handOpenClose.right = true; bradyKin_analyze.handOpenClose.left = true;
bradyKin_analyze.handProSup.right = true; bradyKin_analyze.handProSup.left = true;
bradyKin_analyze.toeTap.right = true; bradyKin_analyze.toeTap.left = true;
bradyKin_analyze.legAgil.right = true; bradyKin_analyze.legAgil.left = true;

% bradyKin_fig = figure; set(bradyKin_fig,'windowstyle','docked')
% bradyKin_checkbox.fingerTap.right = uicontrol(bradyKin_fig,'style','checkbox','string','Right Finger Tap','min',0,'max',1,...
%     'value',bradyKin_analyze.fingerTap.right,'units','normalized','position',[0.50 0.75 0.2 0.05],'callback',@bradyKin_include);
% bradyKin_checkbox.fingerTap.left = uicontrol(bradyKin_fig,'style','checkbox','string','Left Finger Tap','min',0,'max',1,...
%     'value',bradyKin_analyze.fingerTap.left,'units','normalized','position',[0.25 0.75 0.2 0.05],'callback',@bradyKin_include);
% 
% bradyKin_checkbox.handOpenClose.right = uicontrol(bradyKin_fig,'style','checkbox','string','Right Hand Open/Close','min',0,'max',1,...
%     'value',bradyKin_analyze.fingerTap.right,'units','normalized','position',[0.50 0.65 0.2 0.05],'callback',@bradyKin_include);
% bradyKin_checkbox.fingerTap.left = uicontrol(bradyKin_fig,'style','checkbox','string','Left Hand Open/Close','min',0,'max',1,...
%     'value',bradyKin_analyze.handOpenClose.left,'units','normalized','position',[0.25 0.65 0.2 0.05],'callback',@bradyKin_include);
% 
% bradyKin_checkbox.handProSup.right = uicontrol(bradyKin_fig,'style','checkbox','string','Right Hand Pro/Sup','min',0,'max',1,...
%     'value',bradyKin_analyze.handProSup.right,'units','normalized','position',[0.50 0.55 0.2 0.05],'callback',@bradyKin_include);
% bradyKin_checkbox.handProSup.left = uicontrol(bradyKin_fig,'style','checkbox','string','Left Hand Pro/Sup','min',0,'max',1,...
%     'value',bradyKin_analyze.handProSup.left,'units','normalized','position',[0.25 0.55 0.2 0.05],'callback',@bradyKin_include);
% 
% bradyKin_checkbox.toeTap.right = uicontrol(bradyKin_fig,'style','checkbox','string','Right Toe Tap','min',0,'max',1,...
%     'value',bradyKin_analyze.toeTap.right,'units','normalized','position',[0.50 0.45 0.2 0.05],'callback',@bradyKin_include);
% bradyKin_checkbox.toeTap.left = uicontrol(bradyKin_fig,'style','checkbox','string','Left Toe Tap','min',0,'max',1,...
%     'value',bradyKin_analyze.toeTap.left,'units','normalized','position',[0.25 0.45 0.2 0.05],'callback',@bradyKin_include);
% 
% bradyKin_checkbox.legAgil.right = uicontrol(bradyKin_fig,'style','checkbox','string','Right Leg Agility','min',0,'max',1,...
%     'value',bradyKin_analyze.legAgil.right,'units','normalized','position',[0.50 0.35 0.2 0.05],'callback',@bradyKin_include);
% bradyKin_checkbox.legAgil.left = uicontrol(bradyKin_fig,'style','checkbox','string','Left Leg Agility','min',0,'max',1,...
%     'value',bradyKin_analyze.legAgil.left,'units','normalized','position',[0.25 0.35 0.2 0.05],'callback',@bradyKin_include);
% uiwait
    
[output_name, output_path] = load_pose(bradyKin_analyze);
gapFill_filter(output_name,output_path)
findEvents(output_name,output_path)
calcMovementParameters(output_name,output_path)
end
%% bradyKin_include
function bradyKin_include(source,event)
global bradyKin_analyze

switch source.String
    case 'Right Finger Tap'
        bradyKin_analyze.fingerTap.right = ~bradyKin_analyze.fingerTap.right;
    case 'Left Finger Tap'
        bradyKin_analyze.fingerTap.left = ~bradyKin_analyze.fingerTap.left;
    case 'Right Hand Open/Close'
        bradyKin_analyze.handOpenClose.right = ~bradyKin_analyze.handOpenClose.right;
    case 'Left Hand Open/Close'
        bradyKin_analyze.handOpenClose.left = ~bradyKin_analyze.handOpenClose.left;
    case 'Right Hand Pro/Sup'
        bradyKin_analyze.handProSup.right = ~bradyKin_analyze.handProSup.right;
    case 'Left Hand Pro/Sup'
        bradyKin_analyze.handProSup.left = ~bradyKin_analyze.handProSup.left;        
    case 'Right Toe Tap'
        bradyKin_analyze.toeTap.right = ~bradyKin_analyze.toeTap.right;
    case 'Left Toe Tap'
        bradyKin_analyze.toeTap.left = ~bradyKin_analyze.toeTap.left;
    case 'Right Leg Agility'
        bradyKin_analyze.legAgil.right = ~bradyKin_analyze.legAgil.right;
    case 'Left Leg Agility'
        bradyKin_analyze.legAgil.left = ~bradyKin_analyze.legAgil.left;
end

end