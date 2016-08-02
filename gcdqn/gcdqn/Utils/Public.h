//
//  Public.h
//  gcdqn
//
//  Created by admin on 16/7/19.
//  Copyright © 2016年 hardtosaygoodbye. All rights reserved.
//

#ifndef Public_h
#define Public_h

//系统的版本号
#define SystemVersion ([[[UIDevice currentDevice]systemVersion]floatValue])

//获取设备的物理高度
#define ScreenHeight ([UIScreen mainScreen].bounds.size.height)

//获取设备的物理宽度
#define ScreenWidth ([UIScreen mainScreen].bounds.size.width)

//快捷rgb颜色
#define RGBColor(r,g,b,a) ([UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a])

//李旭调试代码
#define LX_DEBUG 1

#endif /* Public_h */
