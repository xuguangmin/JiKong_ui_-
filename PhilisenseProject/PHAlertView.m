//
//  PHAlertView.m
//  飞利信集控
//
//  Created by flx on 14-7-31.
//
//

#import "PHAlertView.h"


@interface PHAlertView ()

@property(nonatomic, retain) UITableView *tableView;
@property(nonatomic, retain) UITextField *plainTextField;
@property(nonatomic, retain) UITextField *secretTextField;
- (void)orientationDidChange:(NSNotification *)notification;
@end

@implementation PHAlertView

@synthesize tableView = tableView_;
@synthesize plainTextField = plainTextField_;
@synthesize secretTextField = secretTextField_;


- (id)initWithTitle:(NSString *)title delegate:(id /*<UIAlertViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitles {
    
	if ((self = [super initWithTitle:title message:@"\n\n\n" delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil])) {
		// FIXME: This is a workaround. By uncomment below, UITextFields in tableview will show characters when typing (possible keyboard reponder issue).
		[self addSubview:self.plainTextField];
        
		tableView_ = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
		tableView_.delegate = self;
		tableView_.dataSource = self;
		tableView_.scrollEnabled = NO;
		tableView_.opaque = NO;
		tableView_.layer.cornerRadius = 3.0f;
		tableView_.editing = YES;
		tableView_.rowHeight = 35.0f;
		[self addSubview:tableView_];
        
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	
	[tableView_ setDataSource:nil];
	[tableView_ setDelegate:nil];
	[tableView_ release];
    [super dealloc];
}

#pragma mark layout

- (void)layoutSubviews {
	// We assume keyboard is on.
	if ([[UIDevice currentDevice] isGeneratingDeviceOrientationNotifications]) {
		if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
			self.center = CGPointMake(500.0f,300.0f);
			self.tableView.frame = CGRectMake(12.0f,61.0f, 260.0f, 70.0f);
		} else {
			self.center = CGPointMake(500.0f, 300.0f);
			self.tableView.frame = CGRectMake(12.0f, 45.0f, 260.0f, 70.0f);
		}
	}
}

- (void)orientationDidChange:(NSNotification *)notification {
    
	[self setNeedsLayout];
}

#pragma mark Accessors

- (UITextField *)plainTextField {
    
	if (!plainTextField_) {
		plainTextField_ = [[UITextField alloc] initWithFrame:CGRectMake(5.0f, 0.0f, 255.0f, 28.0f)];
		plainTextField_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		plainTextField_.clearButtonMode = UITextFieldViewModeWhileEditing;
		plainTextField_.placeholder = @"请输入IP地址";
        
	}
	return plainTextField_;
}

- (UITextField *)secretTextField {
	
	if (!secretTextField_) {
		secretTextField_ = [[UITextField alloc] initWithFrame:CGRectMake(5.0f, 0.0f, 255.0f, 28.0f)];
		secretTextField_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        //		secretTextField_.secureTextEntry = YES;
		secretTextField_.clearButtonMode = UITextFieldViewModeWhileEditing;
		secretTextField_.placeholder = @"请输入端口号";
	}
	return secretTextField_;
}

#pragma mark UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *AlertPromptCellIdentifier = @"PHAlertCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:AlertPromptCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:AlertPromptCellIdentifier] autorelease];
    }
	
	if (![cell.contentView.subviews count]) {
		if (indexPath.row) {
			[cell.contentView addSubview:self.secretTextField];
		} else {
			[cell.contentView addSubview:self.plainTextField];
		}
	}
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}


@end
