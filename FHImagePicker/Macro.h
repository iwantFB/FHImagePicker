//
//  Macro.h
//  FHImagePicker
//
//  Created by 胡斐 on 2019/1/11.
//  Copyright © 2019年 jackson. All rights reserved.
//

#ifndef Macro_h
#define Macro_h

#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height

#define iPHONE_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? ((NSInteger)(([[UIScreen mainScreen] currentMode].size.height/[[UIScreen mainScreen] currentMode].size.width)*100) == 216) : NO)
#define AdjustsScrollViewInsetNever(controller,view) if(@available(iOS 11.0, *)) {view.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;} else if([controller isKindOfClass:[UIViewController class]]) {controller.automaticallyAdjustsScrollViewInsets = false;}
#define  StatusBarHeight            (kIs_iPhoneX ? 44.f : 20.f)
#define  TabbarSafeBottomMargin     (kIs_iPhoneX ? 34.f : 0.f)
#define  TabbarHeight               (kIs_iPhoneX ? (49.f + HT_TabbarSafeBottomMargin ) : 49.f)
#define  NavigationBar_Height       (44.f + HT_StatusBarHeight)

#endif /* Macro_h */
