function varargout = pengujian(varargin)
% PENGUJIAN MATLAB code for pengujian.fig
%      PENGUJIAN, by itself, creates a new PENGUJIAN or raises the existing
%      singleton*.
%
%      H = PENGUJIAN returns the handle to a new PENGUJIAN or the handle to
%      the existing singleton*.
%
%      PENGUJIAN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PENGUJIAN.M with the given input arguments.
%
%      PENGUJIAN('Property','Value',...) creates a new PENGUJIAN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pengujian_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pengujian_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pengujian

% Last Modified by GUIDE v2.5 27-Dec-2020 18:34:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pengujian_OpeningFcn, ...
                   'gui_OutputFcn',  @pengujian_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before pengujian is made visible.
function pengujian_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pengujian (see VARARGIN)

% Choose default command line output for pengujian
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
movegui(hObject, 'center');

% UIWAIT makes pengujian wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pengujian_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Menampilkan menu open file
[nama_file, nama_path] = uigetfile('*.jpg');

if ~isequal(nama_file,0)
    
    %membaca file citra
    Img = imread(fullfile(nama_path, nama_file));
    
    %menampilkan citra pada axes 1
    axes(handles.axes1)
    imshow(Img)
    title('Citra Asli');
    
    %menampilkan nama file citra pada edit1
    set(handles.edit1,'String',nama_file)
    
    %menyimpan variabel Img pada lokasi handles
    handles.Img = Img;
    guidata(hObject, handles)
else
    %jika tidak ada file yang dipilih maka akan kembali
    return
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%memanggil variabel Img yang ada dilokasi handles
Img = handles.Img;

%resize citra
Img_resize = imresize(Img,[240 240]);

%hasil Resize
axes(handles.axes2)
imshow(Img_resize)
title('Citra Resize')

%Ambil nilai luas image
rows  = size(Img_resize,1);
cols  = size(Img_resize,2);
Img_size = rows*cols;
    
%konversi citra RGB menjadi greyscale    
Img_grey = rgb2gray(Img_resize);

%hasil Citra Grayscale
axes(handles.axes3)
imshow(Img_grey)
title('Citra Grayscale')

%thresholding
bw = im2bw(Img_grey,graythresh(Img_grey));
bw = bwareaopen(bw,500);
%operasi morfologi
ser = strel('disk',1);
se = strel('disk',2);
bw = imclose(bw,se);
bw = imopen(bw,ser);
bw = imfill(bw,'holes');


%tampilkan hasil thresholding
axes(handles.axes4)
imshow(bw)
title('Citra Biner')

%mask dan tampilkan hasil Segmentasi
maskedRgbImage = bsxfun(@times, Img_resize, cast(bw, 'like', Img_resize));
axes(handles.axes5)
imshow(maskedRgbImage)
title('Hasil Segmentasi')

handles.maskedRgbImage = maskedRgbImage;
handles.bw = bw;
guidata(hObject, handles)

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

maskedRgbImage = handles.maskedRgbImage;
bw = handles.bw;

%ekstraksi ciri warna HSV
HSV = rgb2hsv(maskedRgbImage);
H = HSV(:,:,1);
S = HSV(:,:,2);
V = HSV(:,:,3);
    
H(~bw) = 0;
S(~bw) = 0;
V(~bw) = 0;
    
Hue = sum(sum(H))/sum(sum(bw));
Saturation = sum(sum(S))/sum(sum(bw));
Value = sum(sum(V))/sum(sum(bw));
       
%ekstraksi ciri bentuk
stats = regionprops(bw,'All');
perimeter = stats.Perimeter;
area = stats.Area;
Eccentricity = stats.Eccentricity;
Metric = 4*pi*area/perimeter^2;

ciri_bunga = cell(5,2);
ciri_bunga{1,1} = 'Hue';
ciri_bunga{2,1} = 'Saturation';
ciri_bunga{3,1} = 'Value';
ciri_bunga{4,1} = 'Eccentricity';
ciri_bunga{5,1} = 'Metric';
ciri_bunga{1,2} = Hue;
ciri_bunga{2,2} = Saturation;
ciri_bunga{3,2} = Value;
ciri_bunga{4,2} = Eccentricity;
ciri_bunga{5,2} = Metric;

set(handles.text2,'String','Hasil Ekstraksi Ciri')
set(handles.uitable1,'Data',ciri_bunga,'RowName',1:5)
ciri_uji = [Hue,Saturation,Value,Eccentricity,Metric];

handles.ciri_uji = ciri_uji;
guidata(hObject, handles);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ciri_uji = handles.ciri_uji;

load hasil_pelatihan

hasil_uji = predict(Mdl,ciri_uji);

set(handles.edit2,'String',hasil_uji)


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1)
cla reset
set(gca,'XTick',[])
set(gca,'YTick',[])

axes(handles.axes2)
cla reset
set(gca,'XTick',[])
set(gca,'YTick',[])

axes(handles.axes3)
cla reset
set(gca,'XTick',[])
set(gca,'YTick',[])

axes(handles.axes4)
cla reset
set(gca,'XTick',[])
set(gca,'YTick',[])

axes(handles.axes5)
cla reset
set(gca,'XTick',[])
set(gca,'YTick',[])

set(handles.edit1,'String',[])
set(handles.edit2,'String',[])
set(handles.text2,'String',[])
set(handles.uitable1,'Data',[])



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
