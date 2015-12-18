//
//  CXIntercepter.m
//  chaoxi
//
//  Created by fizz on 15/12/11.
//  Copyright © 2015年 chaox. All rights reserved.
//

#import "CXIntercepter.h"
#import "AboutUsViewController.h"
#import "ClearCacheViewController.h"
#import "SaveViewController.h"
#import "NavigationViewController.h"
#import "CXPushTransition.h"
#import "CXPopTransition.h"

#define NeedInterceptArr @[@"ArtViewController",@"FunnyViewController",@"ListenViewController",@"PoeViewController",@"ReadViewController"]
//typedef void (^AspectHandlerBlock)(id<AspectInfo> aspectInfo);

@interface CXIntercepter()

@property (nonatomic, strong) UIViewController *baseViewController;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) SaveViewController *saveVC;
@property (nonatomic, strong) AboutUsViewController *aboutVC;
@property (nonatomic, strong) ClearCacheViewController *clearVC;

@end

@implementation CXIntercepter 

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static CXIntercepter *sharedInstance;
    
    dispatch_once(&onceToken, ^{ sharedInstance = [[CXIntercepter alloc] init];});
    
    return sharedInstance;
}

/**
 *  自动被runtime调用
 */
+ (void)load
{
    [super load];
    [CXIntercepter sharedInstance];
}

- (instancetype)init
{
    if (self = [super init]) {
        
        // 拦截 🤒
        [UIViewController aspect_hookSelector:@selector(loadView)
                                  withOptions:AspectPositionAfter
                                   usingBlock:^(id<AspectInfo>aspectInfo){
                                       
            NSString *className = NSStringFromClass([[aspectInfo instance] class]);
                                       
           if ([NeedInterceptArr containsObject:className]) {
               
               self.baseViewController = [aspectInfo instance];
               [self loadView:[aspectInfo instance]];
            
           }
        } error:NULL];
        
        [UIViewController aspect_hookSelector:@selector(viewWillAppear:)
                                  withOptions:AspectPositionAfter
                                   usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated){
                               
           NSString *className = NSStringFromClass([[aspectInfo instance] class]);
           
           if ([NeedInterceptArr containsObject:className]) {
               
               [self viewWillAppear:animated viewController:[aspectInfo instance]];
           }
        } error:NULL];
    }
    return self;
}

#pragma mark - fake methods
- (void)loadView:(UIViewController *)viewController
{
    NSLog(@"[%@ loadView]", [viewController class]);
    
    viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"潮汐" style:UIBarButtonItemStylePlain target:viewController.navigationController action:@selector(presenting)];
    
    viewController.navigationController.hidesBarsOnSwipe = YES;
    viewController.navigationController.delegate = self;
    viewController.navigationController.navigationBar.tintColor = CXRGBColor(32, 47, 60);
    viewController.navigationController.navigationBar.barTintColor = CXRGBColor(245, 245, 245);
    
//    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    [self addWindow];
}

- (void)viewWillAppear:(BOOL)animated viewController:(UIViewController *)viewController
{
    viewController.navigationController.hidesBarsOnSwipe = YES;

    NSLog(@"[%@ viewWillAppear]", [viewController class]);
}

-(void)addWindow
{
    CXAlterButton *button = [[CXAlterButton alloc]initWithImage:[UIImage imageNamed:@"jian"]];
    
    CXAlterItemButton *item1 = [[CXAlterItemButton alloc]initWithImage:[UIImage imageNamed:@"item1"]];
    
    CXAlterItemButton *item2 = [[CXAlterItemButton alloc]initWithImage:[UIImage imageNamed:@"item2"]];
    
    CXAlterItemButton *item3 = [[CXAlterItemButton alloc]initWithImage:[UIImage imageNamed:@"item3"]];
    
    [button addButtonItems:@[item1, item2, item3]];
    
    button.buttonCenter = CGPointMake(225,8);
    button.buttonSize = CGSizeMake(30, 30);
    
    button.animationDuration = 0.5;
    button.delegate = self;
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 250, 44)];
    view.backgroundColor = [UIColor clearColor];
    
    [view addSubview:button ];
    
    self.baseViewController.navigationItem.rightBarButtonItem =  [[UIBarButtonItem alloc]initWithCustomView:view];
}

- (void)AlterButton:(CXAlterButton *)button clickItemButtonAtIndex:(NSUInteger)index
{
    self.index = index;
    
    switch (index) {
        case 0:
        {
            SaveViewController *saveVC = [[SaveViewController alloc]init];
            [self.baseViewController.navigationController pushViewController:saveVC animated:YES];
            
        }
            break;
        case 1:
        {
            AboutUsViewController *abVC = [[AboutUsViewController alloc]init];
            [self.baseViewController.navigationController pushViewController:abVC animated:YES];
        }
            break;
        case 2:
        {
            ClearCacheViewController *clearVC = [[ClearCacheViewController alloc]init];
            [self.baseViewController.navigationController pushViewController:clearVC animated:YES];
        }
            break;
        default:
            break;
    }
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC{
    if (operation == UINavigationControllerOperationPush) {
        
        CXPushTransition *push = [[CXPushTransition alloc]init];
                
        [RACObserve(self, index) subscribeNext:^(NSNumber *x) {
            
            push.index = [x intValue];
            
            if ([x intValue]== 0) {
                push.popVC = self.saveVC;
            }else if ([x intValue]== 1){
                push.popVC = self.aboutVC;
            }else{
                push.popVC = self.clearVC;
            }
        }];
        return push;
    }
    else if (operation == UINavigationControllerOperationPop){
        
        CXPopTransition *pop  = [[CXPopTransition alloc]init];
        pop.pushVC = self.baseViewController;
        
        [RACObserve(self, index) subscribeNext:^(NSNumber *x) {
            
            pop.index = [x intValue];
            
            if ([x intValue]== 0) {
                pop.popVC = self.saveVC;
            }else if ([x intValue] == 1){
                pop.popVC = self.aboutVC;
            }else{
                pop.popVC = self.clearVC;
            }
        }];
        
        return pop;
    }
    else{
        return nil;
    }
}

@end