//
//  global.h
//  PhilisenseProject
//
//  Created by weihuachao on 13-1-8.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#ifndef PhilisenseProject_global_h
#define PhilisenseProject_global_h

#define KEY_PROJECT_VERSION (@"project_version")    //版本信息
#define KEY_ZIP_FILENAME (@"zip_fileName")          //资源压缩文件名称

#define KEY_SERVER_IP (@"server_ip")                //服务器IP地址
#define KEY_SERVER_PORT (@"server_port")            //服务器端口号
#define KEY_LOGINSTATUS (@"LOGINSTATUS")            //登录状态
#define KEY_VALIDATESTATUS (@"VALIDATESTATUS")      //注册状态


#define XML_RESOURCE (@"xmlResource")               //xml文件存放文件夹
#define ZIP_RESOURCE (@"zipResource")               //zip文件存放文件夹
#define IMAGE_RESOURCE (@"resource")                //image图片资源存放文件夹

#define XML_SUFFIX (@".xml")                        //xml文件后缀
#define ZIP_SUFFIX (@".zip")                        //zip文件后缀


//消息定义
#define REQEST_NOTIFICATION_TYPE_LOGIN @"login"
#define REQEST_NOTIFICATION_FILE_DOWNLOAD @"filedown"
#define REQEST_NOTIFICATION_DISCONNECT @"disconnect" //网络连接断开

//界面信息
#define XML_HMUIS_ATTR (@"HMUIS")                           //hmuis
#define XML_HMUI_ATTR (@"HMUI")                             //hmui

#define XML_ID_ATTR (@"Id")                                 //Id
#define XML_ACTION_ATTR (@"Action")                         //Action
#define XML_NAME_ATTR (@"Name")                             //name
#define XML_WIDTH_ATTR (@"Width")                           //width
#define XML_HEIGHT_ATTR (@"Height")                         //height
#define XML_STARTPAGE_ATTR (@"StartPage")                   //startpage
#define XML_POPUPPAGE_ATTR (@"PopupPage")                   //popuppage
#define XML_RIGHTPOPUPPAGE_ATTR (@"RightPopupPage")         //RightPopupPage
#define XML_LEFTPOPUPPAGE_ATTR (@"LeftPopupPage")           //LeftPopupPage

#define XML_GEOMETRY_ATTR (@"Geometry")                     //geometry

#define XML_TEXT_ATTR (@"Text")                             //text
#define XML_TEXTALIGN_ATTR (@"TextAlign")
// WarningText
#define XML_WARININGTEXT_ATTR (@"WarningText")
//Warning
#define XML_WARINING_ATTR (@"Warning")
#define XML_FONT_ATTR (@"Font")
#define XML_FONTSIZE_ATTR (@"FontSize")
#define XML_FONT_ATTR (@"Font")
#define XML_FONT_ATTR (@"Font")


#define XML_FOREGROUNDCOLOR_ATTR (@"ForegroundColor")       //foregroundcolor
#define XML_FOREGROUNDCOLOR_PRESSED_ATTR (@"ForegroundColor_pressed")       //foregroundcolor
#define XML_FOREGROUNDCOLOR_FOCUSED_ATTR (@"ForegroundColor_focused")       //foregroundcolor


#define XML_BACKGROUNDCOLOR_ATTR (@"BackgroundColor")                       //backgroundcolor
#define XML_BACKGROUNDCOLOR_PRESSED_ATTR (@"BackgroundColor_pressed")       //backgroundcolor
#define XML_BACKGROUNDCOLOR_FOCUSED_ATTR (@"BackgroundColor_focused")       //backgroundcolor

#define XML_BACKGROUNDIMAGE_ATTR (@"BackgroundImage")                       //backgroundimage
#define XML_BACKGROUNDIMAGE_PRESSED_ATTR (@"BackgroundImage_pressed")       //backgroundimage
#define XML_BACKGROUNDIMAGE_FOCUSED_ATTR (@"BackgroundImage_focused")       //backgroundimage

//Slider
//Slidermarkbackgroundimage
#define XML_SLIDER_MARKBACKGROUNDIMAGE (@"silder_markBackgroundImage")

#define XML_SLIDER_MARKBACKGROUNDCOLOR (@"silder_markbackgroundColor")

//Slidermainbackgroundimage
#define XML_SLIDER_MAINBACKGROUNDIMAGE (@"silder_mainBackgroundImage")

#define XML_SLIDER_MAINBACKGROUNDCOLOR (@"silder_mainBackgroundColor")

//属性
#define XML_VISIBLE_ATTR (@"Visible")
#define XML_ENABLE_ATTR (@"Enable")
#define XML_VALUE_ATTR (@"Value")
#define XML_CHOOSE_ATTR (@"Choose")
#define XML_Z_INDEX_ATTR (@"Z-Index")
#define XML_ORIENTATION_ATTR (@"Orientation")


#define XML_SLIDER_MAINHEIGHT (@"silder_mainHeight")
#define XML_SLIDER_MAINWIDTH (@"silder_mainWidth")

#define XML_SLIDER_MARKHEIGHT (@"silder_markHeight")
#define XML_SLIDER_MARKWIDTH (@"silder_markWidth")

//事件
#define XML_EVENT_ATTR (@"Event")
#define XML_CLICK_ATTR (@"Click")
#define XML_PRESSED_ATTR (@"Pressed")
#define XML_RELEASED_ATTR (@"Released")
#define XML_METHOD_ATTR (@"Method")
#define XML_OBJECT_ATTR (@"Object")
#define XML_PARAMETER_ATTR (@"Parameter")

//方法
#define METHOD_SHOW (@"显示")
#define METHOD_HIDE (@"隐藏")
#define METHOD_ENABLE (@"可用")
#define METHOD_UNABLE (@"禁用")


//各类控件
#define CONTROL_TYPE_BUTTON (@"ButtonControl")       //buttoncontrol
#define CONTROL_TYPE_IMAGE (@"ImageControl")         //imagecontrol
#define CONTROL_TYPE_SLIDER (@"SliderControl")       //slidercontrol
#define CONTROL_TYPE_LABEL (@"LabelControl")         //labelcontrol
#define CONTROL_TYPE_CheckBox (@"CheckBoxControl")   //checkboxcontrol
#define CONTROL_TYPE_RadioBox (@"RadioBoxControl")   //radioboxcontrol

#define CONTROL_TYPE_Progress (@"ProcessBarControl") //ProcessBarControl

#define CONTROL_TYPE_VIDEO (@"Videocontrol")    //Videocontrol

//默认值设置
#define DEFAULT_BACKGROUND_COLOR (@"#ffffff")           //默认背景色
#define DEFAULT_BACKGROUND_PRESSED_COLOR (@"#ffffff")

#define DEFAULT_FOREGROUND_COLOR (@"#000000")           //默认前景色
#define DEFAULT_FOREGROUND_PRESSED_COLOR (@"#ffffff")

#define DEFAULT_MARKBACKGROUND_COLOR (@"#00ff00")  //绿色      //Mark默认颜色

#define DEFAULT_MAINBACKGROUND_COLOR (@"#ffffff")        //Main默认颜色

//字符串分割符
#define SEPARATOR_SEMICOLONT (@";")
#define SEPARATOR_UNDERLINE (@"_")
#define SEPARATOR_COMMA (@",")


#define trangle(x) (3.1415926*x/180)


#define EVENT_BUTTON_CLICK 0x1010
#define EVENT_BUTTON_PRESSED 0x1011
#define EVENT_BUTTON_RELEASED 0x1012


#define EVENT_IMAGE_CLICK 0x1020
#define EVENT_IMAGE_PRESSED 0x1021
#define EVENT_IMAGE_RELEASED 0x1022

#define EVENT_SLIDER_VALUE_CHANGED 0x1080

#define EVENT_PROCESSBAR_VALUE_CHANGED 0x10a0

//定义文本的对齐方式

#define TEXTALIGNMENTLEFT 129
#define TEXTALIGNMENTRIGHT 130
#define TEXTALIGNMENTMIDDLE 132

#endif
