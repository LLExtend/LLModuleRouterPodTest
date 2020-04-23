//
//  LLModuleRouter.h
//  LLModuleRouter
//
//  Created by apple on 2019/12/23.
//  Copyright © 2019 ll. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^HandlerBlock) (id anObject) ;

@interface LLTopViewControllerTool : NSObject

/// 获取顶部控制器
+ (UIViewController *)ll_topViewController;

@end


@interface NSObject (LLCategory)

/// 公共参数 可以用于viewController之间属性传值
@property (nonatomic ,strong) id publicParamer;

/// 回调
@property (nonatomic ,copy) HandlerBlock handlerBlock;

/// 回调
/// @param object 回调参数
/// @param trigger 回调触发者
- (void)routerPassObject:(_Nullable id)object trigger:(_Nullable id)trigger;
@end



@interface LLModuleRouter : NSObject

/// 简化模态
/// @param viewControllerName 控制器类名
/// @param publicParamer 公共参数
/// @param isNeedNavigationController 是否需要导航控制器
/// @param animated 是否需要动画
/// @param handlerBlock 回调
void LLModuleRouterPersent(NSString * _Nullable viewControllerName ,id _Nullable publicParamer ,BOOL isNeedNavigationController ,BOOL animated ,HandlerBlock handlerBlock);

/// 简化dimiss
/// @param viewControllerName 控制器类名
/// @param anObject block回调传输对象
/// @param animated 是否需要动画
void LLModuleRouterDimiss(NSString * _Nullable viewControllerName , id _Nullable anObject ,BOOL animated);

/// 简化push
/// @param viewControllerName 控制器类名
/// @param publicParamer 公共参数
/// @param animated 是否需要动画
/// @param handlerBlock 回调
void LLModuleRouterPush(NSString * _Nullable viewControllerName ,id _Nullable publicParamer ,BOOL animated ,HandlerBlock handlerBlock);

/// 简化pop 默认响应HandlerBlock
/// @param viewControllerName 控制器类名
/// @param anObject block回调传输对象
/// @param animated 是否需要动画
void LLModuleRouterPop(NSString * _Nullable viewControllerName , id _Nullable anObject ,BOOL animated);

/// 根据类名删除指定的viewController（使用场景：A->B->C 在C中返回A跳过B 这时候可以调用此方法删除B 。。 当然也可以使用LLRouterPop跳转到指定的控制器）
/// @param viewControllerName 控制器类名
void dynamicRemoveViewController (NSString *viewControllerName);

@end

NS_ASSUME_NONNULL_END
