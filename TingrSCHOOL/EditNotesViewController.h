//
//  EditNotesViewController.h
//  TingrSCHOOL
//
//  Created by Maisa Pride on 4/13/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "ViewController.h"

@interface EditNotesViewController : ViewController<UITextViewDelegate>

@property (strong, nonatomic) UITextView *textView;
@property (nonatomic, strong) NSString *kid_klid;
@property (nonatomic, strong) NSDictionary *kidDict;
@end
