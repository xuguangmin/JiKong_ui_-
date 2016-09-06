//
//  PHAlertView.h
//  飞利信集控
//
//  Created by flx on 14-7-31.
//
//

#import <UIKit/UIKit.h>

@interface PHAlertView : UIAlertView <UITableViewDelegate, UITableViewDataSource> {
@private
	UITableView *tableView_;
	UITextField *plainTextField_;
	UITextField *secretTextField_;
}

@property(nonatomic, retain, readonly) UITextField *plainTextField;
@property(nonatomic, retain, readonly) UITextField *secretTextField;

- (id)initWithTitle:(NSString *)title delegate:(id /*<UIAlertViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitles;

@end
