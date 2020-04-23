//
//  LLModuleRouter.m
//  LLModuleRouter
//
//  Created by apple on 2019/12/23.
//  Copyright © 2019 ll. All rights reserved.
//

#import "LLModuleRouter.h"
#import <objc/runtime.h>

@implementation LLTopViewControllerTool

+ (UIViewController *)ll_topViewController {
    UIViewController *resultViewController = nil;
    resultViewController = [LLTopViewControllerTool _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultViewController.presentedViewController) {
        resultViewController = [LLTopViewControllerTool _topViewController:resultViewController.presentedViewController];
    }
    return resultViewController;
}

+ (UIViewController *)_topViewController:(UIViewController *)viweController {
    if ([viweController isKindOfClass:[UINavigationController class]]) {
        return [LLTopViewControllerTool _topViewController:[(UINavigationController *)viweController topViewController]];
    }
        
    if ([viweController isKindOfClass:[UITabBarController class]]) {
        return [LLTopViewControllerTool _topViewController:[(UITabBarController *)viweController selectedViewController]];
    }
        
    return viweController;
}

@end

static char LL_PublicParamerKey;
static char LL_HandlerBlockKey;

@implementation NSObject (FJPublicPush)

- (id)publicParamer {
    return objc_getAssociatedObject(self, &LL_PublicParamerKey);
}

- (void)setPublicParamer:(id)publicParamer {
    objc_setAssociatedObject(self,
                             &LL_PublicParamerKey,
                             publicParamer,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (HandlerBlock)handlerBlock {
    return objc_getAssociatedObject(self, &LL_HandlerBlockKey);
}

- (void)setHandlerBlock:(HandlerBlock)handlerBlock {
    objc_setAssociatedObject(self, &LL_HandlerBlockKey, handlerBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)routerPassObject:(id)object trigger:(id)trigger {
    NSLog(@"routerPassObject:trigger: -- %@ %@",object,trigger);
}

@end


@implementation LLModuleRouter

void LLModuleRouterPersent(NSString * _Nullable viewControllerName ,id _Nullable publicParamer ,BOOL isNeedNavigationController ,BOOL animated ,HandlerBlock handlerBlock) {
    BOOL isExistViewController = dynamicCheckIsExistViewController(viewControllerName);
    if (isExistViewController) {
    
        Class newClass = NSClassFromString(viewControllerName);
        // 动态生成对象
        UIViewController *viewController = [[newClass alloc] init];
        // 动态传递数据
        dynamicDeliverParamerForViewController(viewController, publicParamer);
        
        if (handlerBlock) {
            viewController.handlerBlock = [handlerBlock copy];
        }
        
        UIViewController *presentViewController = viewController;
        if (isNeedNavigationController) {
            UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:viewController];
            presentViewController = navigation;
        }
        
        // 调用presentViewController
        presentViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        
        [LLTopViewControllerTool.ll_topViewController presentViewController:presentViewController animated:YES completion:nil];
    }
}

void LLModuleRouterDimiss(NSString * _Nullable viewControllerName , id _Nullable anObject ,BOOL animated) {
    if (LLTopViewControllerTool.ll_topViewController.handlerBlock) {
        LLTopViewControllerTool.ll_topViewController.handlerBlock(anObject);
    }
    
    if (viewControllerName.length == 0) {
        [getCurrentNavigationController() dismissViewControllerAnimated:YES completion:nil];
    } else {
        UIViewController *appointViewController = isContainsViewController(viewControllerName);

        if ([appointViewController respondsToSelector:@selector(routerPassObject:trigger:)]) {
            [appointViewController routerPassObject:anObject trigger:LLTopViewControllerTool.ll_topViewController];
        }
        
        [getCurrentNavigationController() dismissViewControllerAnimated:YES completion:nil];
    }
}

void LLModuleRouterPush(NSString * _Nullable viewControllerName ,id _Nullable publicParamer ,BOOL animated ,HandlerBlock handlerBlock) {
    BOOL isExistViewController = dynamicCheckIsExistViewController(viewControllerName);
       
    if (isExistViewController) {
        Class newClass = NSClassFromString(viewControllerName);
        // 动态生成对象
        UIViewController *viewController = [[newClass alloc] init];
        // 动态传递数据
        dynamicDeliverParamerForViewController(viewController, publicParamer);
       
        if (handlerBlock) {
            viewController.handlerBlock = [handlerBlock copy];
        }
        // 调用push
        [getCurrentNavigationController() pushViewController:viewController animated:animated];
   }
}

void LLModuleRouterPop(NSString * _Nullable viewControllerName , id _Nullable anObject ,BOOL animated) {
    if (LLTopViewControllerTool.ll_topViewController.handlerBlock) {
        LLTopViewControllerTool.ll_topViewController.handlerBlock(anObject);
    }
    
    if (viewControllerName.length == 0) {
        [getCurrentNavigationController() popViewControllerAnimated:animated];
    } else {
        UIViewController *appointViewController = isContainsViewController(viewControllerName);

        if ([appointViewController respondsToSelector:@selector(routerPassObject:trigger:)]) {
            [appointViewController routerPassObject:anObject trigger:LLTopViewControllerTool.ll_topViewController];
        }
        
        if (appointViewController) {
            [getCurrentNavigationController() popToViewController:appointViewController animated:animated];
        } else {
            [getCurrentNavigationController() popViewControllerAnimated:animated];
        }
    }
}

UINavigationController * getCurrentNavigationController (void) {
    return LLTopViewControllerTool.ll_topViewController.navigationController;
}

UIViewController * isContainsViewController (NSString *viewControllerName) {
    if (viewControllerName.length == 0) return nil;
    Class class = NSClassFromString(viewControllerName);
    NSArray *viewControllers = getCurrentNavigationController().viewControllers;
    UIViewController *appointViewController = nil;
    for (UIViewController *viewController in viewControllers) {
        if ([viewController isKindOfClass:class]) {
            appointViewController = viewController;
            break;
        }
    }
    return appointViewController;
}

void dynamicRemoveViewController (NSString *viewControllerName) {
    UIViewController *viewController = isContainsViewController(viewControllerName);
    if (!viewController) return;
    NSMutableArray<__kindof UIViewController *> *controllers = [viewController.navigationController.viewControllers mutableCopy];
    __block UIViewController *controllerToRemove = nil;
    [controllers enumerateObjectsUsingBlock:^(__kindof UIViewController * obj, NSUInteger idx, BOOL * stop) {
        if (obj == viewController) {
            controllerToRemove = obj;
            *stop = YES;
        }
    }];
    
    if (controllerToRemove) {
        [controllers removeObject:controllerToRemove];
        [viewController.navigationController setViewControllers:[NSArray arrayWithArray:controllers] animated:NO];
    }
}

BOOL dynamicCheckIsExistViewController (NSString *viewControllerName) {
    if (viewControllerName.length == 0) return NO;
    
    const char *className = [viewControllerName cStringUsingEncoding:NSASCIIStringEncoding];
    Class newClass = objc_getClass(className);
    if (!newClass) {
        Class superClass = [NSObject class];
        newClass = objc_allocateClassPair(superClass, className, 0);
        objc_registerClassPair(newClass);
        NSLog(@"项目中 没有 %@ 类", viewControllerName);
        return NO;
    }
    return YES;
}

void dynamicDeliverParamerForViewController (UIViewController *viewController , id publicParamer) {
    if (publicParamer) {
        viewController.publicParamer = publicParamer;
        NSLog(@"publicParamer - %@\n类名%@",publicParamer,viewController.class);
    }
}

@end
