//
//  UPArpuInterstitialViewController.m
//  UpArpuSDKDemo
//
//  Created by Martin Lau on 21/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "UPArpuInterstitialViewController.h"
@import UpArpuSDK;
@import UpArpuInterstitial;

NSString *const kMintegralVideoPlacement = @"Mintegral(Video)";
NSString *const kTTVideoPlacement = @"TT(Video)";
#ifdef DEBUG
static NSString *const kGDTPlacementID = @"b5ba34f3beda70";
static NSString *const kTTPlacementID = @"b5ba34fe8c43ec";
static NSString *const kTTVideoPlacementID = @"b5ba3517f34dcd";
static NSString *const kAdmobPlacementID = @"b5ba351e902c08";
static NSString *const kMintegralPlacementID = @"b5ba3523364e4a";
static NSString *const kMintegralVideoPlacementID = @"b5ba3523f21b87";
static NSString *const kApplovinPlacementID = @"b5ba352abe42d0";
static NSString *const kAllPlacementID = @"b5ba34f9cd9da4";
#else
static NSString *const kGDTPlacementID = @"b5bacad8ea3036";
static NSString *const kTTPlacementID = @"b5bacad7373b89";
static NSString *const kTTVideoPlacementID = @"b5bacad80a0fb1";
static NSString *const kAdmobPlacementID = @"b5bacad6860972";
static NSString *const kMintegralPlacementID = @"b5bacad46a8bbb";
static NSString *const kMintegralVideoPlacementID = @"b5bacad5962e84";
static NSString *const kApplovinPlacementID = @"b5bacad34e4294";
static NSString *const kFacebookPlacementID = @"b5baf4bf9829e4";
static NSString *const kAllPlacementID = @"b5bacad26a752a";
#endif

@interface UPArpuInterstitialViewController ()<UPArpuInterstitialDelegate>
@property(nonatomic, readonly) NSString *name;
@property(nonatomic, readonly) NSDictionary<NSString*, NSString*>* placementIDs;
@property(nonatomic, readonly) UIActivityIndicatorView *loadingView;
@property(nonatomic, readonly) UILabel *failureTipsLabel;
@property(nonatomic, readonly) UIButton *reloadADButton;
@property(nonatomic, readonly) UIButton *clearAdButton;
@property(nonatomic, readonly) UIButton *showAdButton;
@property(nonatomic, readonly) UIButton *removeAdButton;
@end

@implementation UPArpuInterstitialViewController
-(instancetype) initWithPlacementName:(NSString *)name {
    if (self = [super init]) {
        _name = name;
        _placementIDs = @{
                          kGDTPlacement:kGDTPlacementID,
                          kTTPlacementName:kTTPlacementID,
                          kTTVideoPlacement:kTTVideoPlacementID,
                          kAdMobPlacement:kAdmobPlacementID,
                          kMintegralPlacement:kMintegralPlacementID,
                          kMintegralVideoPlacement:kMintegralVideoPlacementID,
                          kApplovinPlacement:kApplovinPlacementID,
                          kFacebookPlacement:kFacebookPlacementID,
                          kAllPlacementName:kAllPlacementID
                          };
    }
    return self;
}

-(void) viewDidLoad {
    [super viewDidLoad];
    self.title = _name;
    self.view.backgroundColor = [UIColor whiteColor];
    
    _reloadADButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_reloadADButton addTarget:self action:@selector(reloadADButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [_reloadADButton setTitleColor:_reloadADButton.tintColor forState:UIControlStateNormal];
    [_reloadADButton setTitle:@"Reload AD" forState:UIControlStateNormal];
    _reloadADButton.frame = CGRectMake(.0f, CGRectGetMaxY(self.view.bounds) - 100.0f, (CGRectGetWidth(self.view.bounds) - 40) / 2.0f, 60.0f);
    [self.view addSubview:_reloadADButton];
    
    _showAdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_showAdButton addTarget:self action:@selector(showAD) forControlEvents:UIControlEventTouchUpInside];
    [_showAdButton setTitleColor:_showAdButton.tintColor forState:UIControlStateNormal];
    [_showAdButton setTitle:@"Show AD" forState:UIControlStateNormal];
    _showAdButton.frame = CGRectMake(CGRectGetMaxX(_reloadADButton.frame) + 40.0f, CGRectGetMinY(_reloadADButton.frame), (CGRectGetWidth(self.view.bounds) - 40) / 2.0f, 60.0f);
    [self.view addSubview:_showAdButton];
    
    _clearAdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_clearAdButton addTarget:self action:@selector(clearAdButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [_clearAdButton setTitleColor:_clearAdButton.tintColor forState:UIControlStateNormal];
    [_clearAdButton setTitle:@"clear cache" forState:UIControlStateNormal];
    _clearAdButton.frame = CGRectMake(.0f, CGRectGetMinY(_reloadADButton.frame) - 20.0f - 60.0f, (CGRectGetWidth(self.view.bounds) - 40) / 2.0f, 60.0f);
    [self.view addSubview:_clearAdButton];
    
    _removeAdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_removeAdButton addTarget:self action:@selector(removeAdButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [_removeAdButton setTitleColor:_removeAdButton.tintColor forState:UIControlStateNormal];
    [_removeAdButton setTitle:@"Ad Ready?" forState:UIControlStateNormal];
    _removeAdButton.frame = CGRectMake(CGRectGetMaxX(_clearAdButton.frame) + 40.0f, CGRectGetMinY(_clearAdButton.frame), (CGRectGetWidth(self.view.bounds) - 40) / 2.0f, 60.0f);
    [self.view addSubview:_removeAdButton];
    
    _failureTipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(.0f, 64.0f, CGRectGetWidth(self.view.bounds), 400.0f)];
    _failureTipsLabel.text = @"Failed to load ad";
    _failureTipsLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_failureTipsLabel];
    _failureTipsLabel.hidden = YES;
}


//Ad ready?
-(void) removeAdButtonTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[[UPArpuAdManager sharedManager] interstitialReadyForPlacementID:_placementIDs[_name]] ? @"Ready!" : @"Not Yet!" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) clearAdButtonTapped {
    [[UPArpuAdManager sharedManager] clearCache];
}

-(void) dealloc {
    NSLog(@"dealloc");
}

-(void) reloadADButtonTapped {
    NSLog(@"Begin loading interstitial ad");
    _failureTipsLabel.hidden = YES;
    [self.view addSubview:_loadingView];
    [[UPArpuAdManager sharedManager] loadADWithPlacementID:_placementIDs[_name] extra:nil customData:nil delegate:self];
}

-(void) showAD {
    //Remove previously shown ad first.
    [[UPArpuAdManager sharedManager] showInterstitialWithPlacementID:_placementIDs[_name] inViewController:self delegate:self];
}

#pragma mark - delegate method(s)
-(void) didFinishLoadingADWithPlacementID:(NSString *)placementID {
    NSLog(@"UPArpuInterstitialViewController::didFinishLoadingADWithPlacementID:%@", placementID);
    _showAdButton.enabled = YES;
}

-(void) didFailToLoadADWithPlacementID:(NSString*)placementID error:(NSError*)error {
    NSLog(@"UPArpuInterstitialViewController::didFailToLoadADWithPlacementID:%@ error:%@", placementID, error);
}

-(void) interstitialDidShowForPlacementID:(NSString *)placementID {
    NSLog(@"UPArpuInterstitialViewController::interstitialDidShowForPlacementID:%@", placementID);
}

-(void) interstitialFailedToShowForPlacementID:(NSString*)placementID error:(NSError*)error {
    NSLog(@"UPArpuInterstitialViewController::interstitialFailedToShowForPlacementID:%@ error:%@", placementID, error);
}

-(void) interstitialDidStartPlayingVideoForPlacementID:(NSString*)placementID {
    NSLog(@"UPArpuInterstitialViewController::interstitialDidStartPlayingVideoForPlacementID:%@", placementID);
}

-(void) interstitialDidEndPlayingVideoForPlacementID:(NSString*)placementID {
    NSLog(@"UPArpuInterstitialViewController::interstitialDidEndPlayingVideoForPlacementID:%@", placementID);
}

-(void) interstitialDidFailToPlayForPlacementID:(NSString*)placementID error:(NSError*)error {
    NSLog(@"UPArpuInterstitialViewController::interstitialDidFailToPlayForPlacementID:%@", placementID);
}

-(void) interstitialDidCloseForPlacementID:(NSString*)placementID {
    NSLog(@"UPArpuInterstitialViewController::interstitialDidCloseForPlacementID:%@", placementID);
}

-(void) interstitialDidClickForPlacementID:(NSString*)placementID {
    NSLog(@"UPArpuInterstitialViewController::interstitialDidClickForPlacementID:%@", placementID);
}
@end