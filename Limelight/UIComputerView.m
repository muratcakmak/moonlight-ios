//
//  UIComputerView.m
//  Moonlight
//
//  Created by Diego Waxemberg on 10/22/14.
//  Copyright (c) 2014 Moonlight Stream. All rights reserved.
//
//  Modified for OpenBench: Clean list-style Mac connection view

#import "UIComputerView.h"

@implementation UIComputerView {
    TemporaryHost* _host;
    UIImageView* _hostIcon;
    UILabel* _hostLabel;
    UILabel* _statusLabel;
    UIView* _statusDot;
    UIImageView* _hostOverlay;
    UIActivityIndicatorView* _hostSpinner;
    id<HostCallback> _callback;
    CGSize _labelSize;
}
static const float REFRESH_CYCLE = 2.0f;

#if TARGET_OS_TV
static const int ITEM_PADDING = 50;
static const int LABEL_DY = 40;
#else
static const int ITEM_PADDING = 0;
static const int LABEL_DY = 20;
#endif

- (id) init {
    self = [super init];

#if TARGET_OS_TV
    self.frame = CGRectMake(0, 0, 400, 400);
#else
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.frame = CGRectMake(0, 0, 280, 70);
    } else {
        self.frame = CGRectMake(0, 0, 200, 60);
    }
#endif

#if !TARGET_OS_TV
    // OpenBench: Modern card style
    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
    self.layer.cornerRadius = 12;
    self.clipsToBounds = YES;

    // Mac icon (SF Symbol)
    _hostIcon = [[UIImageView alloc] init];
    UIImage *macIcon = [UIImage systemImageNamed:@"desktopcomputer"];
    if (macIcon) {
        _hostIcon.image = [macIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _hostIcon.tintColor = [UIColor whiteColor];
    } else {
        [_hostIcon setImage:[UIImage imageNamed:@"Computer"]];
    }
    _hostIcon.contentMode = UIViewContentModeScaleAspectFit;
    _hostIcon.frame = CGRectMake(16, 14, 32, 32);

    // Host name label
    _hostLabel = [[UILabel alloc] init];
    _hostLabel.textColor = [UIColor whiteColor];
    _hostLabel.font = [UIFont boldSystemFontOfSize:16];
    _hostLabel.frame = CGRectMake(60, 12, self.frame.size.width - 80, 22);

    // Status label
    _statusLabel = [[UILabel alloc] init];
    _statusLabel.textColor = [UIColor lightGrayColor];
    _statusLabel.font = [UIFont systemFontOfSize:12];
    _statusLabel.frame = CGRectMake(60, 36, self.frame.size.width - 80, 16);

    // Status dot
    _statusDot = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - 28, 25, 10, 10)];
    _statusDot.layer.cornerRadius = 5;

    // Spinner for unknown state
    _hostSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    _hostSpinner.frame = CGRectMake(self.frame.size.width - 32, 20, 20, 20);
    _hostSpinner.hidesWhenStopped = YES;

    _hostOverlay = [[UIImageView alloc] initWithFrame:CGRectZero]; // unused but kept for compatibility

    [self addSubview:_hostIcon];
    [self addSubview:_hostLabel];
    [self addSubview:_statusLabel];
    [self addSubview:_statusDot];
    [self addSubview:_hostSpinner];
#else
    // tvOS: keep original icon-based layout
    _hostIcon = [[UIImageView alloc] initWithFrame:self.frame];
    [_hostIcon setImage:[UIImage imageNamed:@"Computer"]];

    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOffset = CGSizeMake(5,8);
    self.layer.shadowOpacity = 0.3;

    _hostLabel = [[UILabel alloc] init];
    _hostLabel.textColor = [UIColor whiteColor];

    _hostOverlay = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width / 3, _hostIcon.frame.size.height / 4, _hostIcon.frame.size.width / 3, self.frame.size.height / 3)];
    _hostSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_hostSpinner setFrame:_hostOverlay.frame];
    _hostSpinner.userInteractionEnabled = NO;
    _hostSpinner.hidesWhenStopped = YES;

    [self addSubview:_hostLabel];
    [self addSubview:_hostIcon];

    _hostIcon.clipsToBounds = NO;
    _hostIcon.adjustsImageWhenAncestorFocused = YES;
    _hostIcon.masksFocusEffectToContents = YES;
    self.adjustsImageWhenHighlighted = NO;
    _hostOverlay.masksFocusEffectToContents = YES;
    _hostOverlay.adjustsImageWhenAncestorFocused = NO;
    [_hostIcon.overlayContentView addSubview:_hostOverlay];
    [_hostIcon.overlayContentView addSubview:_hostSpinner];

    _statusLabel = nil;
    _statusDot = nil;
#endif

    [self addTarget:self action:@selector(hostButtonSelected:) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(hostButtonDeselected:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchDragExit];

    return self;
}

- (void) hostButtonSelected:(id)sender {
#if !TARGET_OS_TV
    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
#else
    _hostIcon.layer.opacity = 0.5f;
    _hostSpinner.layer.opacity = 0.5f;
    _hostOverlay.layer.opacity = 0.5f;
#endif
}

- (void) hostButtonDeselected:(id)sender {
#if !TARGET_OS_TV
    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
#else
    _hostIcon.layer.opacity = 1.0f;
    _hostSpinner.layer.opacity = 1.0f;
    _hostOverlay.layer.opacity = 1.0f;
#endif
}

- (id) initForAddWithCallback:(id<HostCallback>)callback {
    self = [self init];
    _callback = callback;

    [self addTarget:self action:@selector(addClicked) forControlEvents:UIControlEventPrimaryActionTriggered];

#if !TARGET_OS_TV
    UIImage *plusIcon = [UIImage systemImageNamed:@"plus.circle"];
    if (plusIcon) {
        _hostIcon.image = [plusIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _hostIcon.tintColor = [UIColor systemBlueColor];
    }
    [_hostLabel setText:@"Add Mac Manually"];
    _hostLabel.textColor = [UIColor systemBlueColor];
    [_statusLabel setText:@"Enter IP address"];
    _statusDot.hidden = YES;
    [_hostSpinner stopAnimating];
#else
    [_hostLabel setText:@"Add Host Manually"];
    [_hostLabel sizeToFit];
    [_hostOverlay setImage:[UIImage imageNamed:@"AddOverlayIcon"]];
    [self updateBounds];
#endif

    return self;
}

- (id) initWithComputer:(TemporaryHost*)host andCallback:(id<HostCallback>)callback {
    self = [self init];
    _host = host;
    _callback = callback;

#if !TARGET_OS_TV
    if (@available(iOS 13.0, *)) {
        UIContextMenuInteraction* rightClickInteraction = [[UIContextMenuInteraction alloc] initWithDelegate:self];
        [self addInteraction:rightClickInteraction];
    }
    else
#endif
    {
        UILongPressGestureRecognizer* longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(hostLongClicked:)];
        [self addGestureRecognizer:longPressRecognizer];
    }

    [self addTarget:self action:@selector(hostClicked) forControlEvents:UIControlEventPrimaryActionTriggered];
    [self updateContentsForHost:host];

    return self;
}

- (void)didMoveToSuperview {
    if (self.superview != nil && _host != nil) {
        [self updateLoop];
    }
}

- (void) updateBounds {
#if TARGET_OS_TV
    float x = FLT_MAX;
    float y = FLT_MAX;
    float width = 0;
    float height;

    float iconX = _hostIcon.frame.origin.x + _hostIcon.frame.size.width / 2;
    _hostLabel.center = CGPointMake(iconX, _hostIcon.frame.origin.y + _hostIcon.frame.size.height + LABEL_DY);

    x = MIN(x, _hostIcon.frame.origin.x);
    x = MIN(x, _hostLabel.frame.origin.x);
    y = MIN(y, _hostIcon.frame.origin.y);
    y = MIN(y, _hostLabel.frame.origin.y);
    width = MAX(width, _hostIcon.frame.size.width);
    width = MAX(width, _hostLabel.frame.size.width);
    height = _hostIcon.frame.size.height + _hostLabel.frame.size.height + LABEL_DY / 2;

    self.bounds = CGRectMake(x - ITEM_PADDING, y - ITEM_PADDING, width + 2 * ITEM_PADDING, height + 2 * ITEM_PADDING);
#endif
    // iOS uses fixed frame, no bounds update needed
}

- (void) updateContentsForHost:(TemporaryHost*)host {
    _hostLabel.text = _host.name;

#if !TARGET_OS_TV
    if (host.state == StateOnline) {
        [_hostSpinner stopAnimating];
        _statusDot.hidden = NO;

        if (host.pairState == PairStateUnpaired) {
            _statusDot.backgroundColor = [UIColor systemYellowColor];
            _statusLabel.text = @"Not paired — tap to pair";
        } else {
            _statusDot.backgroundColor = [UIColor systemGreenColor];
            _statusLabel.text = @"Online — tap to connect";
        }
    } else if (host.state == StateOffline) {
        [_hostSpinner stopAnimating];
        _statusDot.hidden = NO;
        _statusDot.backgroundColor = [UIColor systemRedColor];
        _statusLabel.text = @"Offline";
    } else {
        _statusDot.hidden = YES;
        [_hostSpinner startAnimating];
        _statusLabel.text = @"Connecting...";
    }
#else
    [_hostLabel sizeToFit];
    if (host.state == StateOnline) {
        [_hostSpinner stopAnimating];
        if (host.pairState == PairStateUnpaired) {
            [_hostOverlay setImage:[UIImage imageNamed:@"LockedOverlayIcon"]];
        } else {
            [_hostOverlay setImage:nil];
        }
    } else if (host.state == StateOffline) {
        [_hostSpinner stopAnimating];
        [_hostOverlay setImage:[UIImage imageNamed:@"ErrorOverlayIcon"]];
    } else {
        [_hostSpinner startAnimating];
    }
    [self updateBounds];
#endif
}

- (void) updateLoop {
    if (self.superview == nil) {
        return;
    }
    [self updateContentsForHost:_host];
    [self performSelector:@selector(updateLoop) withObject:self afterDelay:REFRESH_CYCLE];
}

- (void) hostLongClicked:(UILongPressGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [_callback hostLongClicked:_host view:self];
    }
}

#if !TARGET_OS_TV
- (UIContextMenuConfiguration *)contextMenuInteraction:(UIContextMenuInteraction *)interaction
                        configurationForMenuAtLocation:(CGPoint)location {
    [self cancelTrackingWithEvent:nil];
    [_callback hostLongClicked:_host view:self];
    return nil;
}
#endif

- (void) hostClicked {
    [_callback hostClicked:_host view:self];
}

- (void) addClicked {
    [_callback addHostClicked];
}

@end
