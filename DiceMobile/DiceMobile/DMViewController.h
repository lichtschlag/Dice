//
//  DMViewController.h
//  DiceMobile
//
//  Created by Leonhard Lichtschlag on 01/May/13.
//  Copyright (c) 2012 Leonhard Lichtschlag. All rights reserved.
//

#import <GLKit/GLKit.h>

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


// ===============================================================================================================
@interface DMViewController : GLKViewController <GLKViewDelegate, MFMailComposeViewControllerDelegate>
// ===============================================================================================================

@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;

- (IBAction) userDidTap:(UIGestureRecognizer *)sender;
- (IBAction) userDidSwipeRight:(UIGestureRecognizer *)sender;
- (IBAction) userDidSwipeLeft:(UIGestureRecognizer *)sender;
- (IBAction) userDidSwipeUp:(UIGestureRecognizer *)sender;
- (IBAction) userDidSwipeDown:(UIGestureRecognizer *)sender;

- (IBAction) userDidTapShareButton:(id)sender;
- (IBAction) userDidTapInfoButton:(id)sender;


@end

